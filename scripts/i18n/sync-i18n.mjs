import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import ts from "../../professional_portal/node_modules/typescript/lib/typescript.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const repoRoot = path.resolve(__dirname, "../..");

const sharedI18nDir = path.join(repoRoot, "shared", "i18n");
const localesDir = path.join(sharedI18nDir, "locales");
const supportedLocalesPath = path.join(sharedI18nDir, "supported-locales.json");
const flutterMetaPath = path.join(sharedI18nDir, "flutter-meta.json");

const flutterEnArbPath = path.join(repoRoot, "lib", "l10n", "intl_en.arb");
const flutterEsArbPath = path.join(repoRoot, "lib", "l10n", "intl_es.arb");
const supabaseCopyPath = path.join(repoRoot, "supabase", "functions", "_shared", "copy.ts");
const mealInterpretationPath = path.join(
  repoRoot,
  "supabase",
  "functions",
  "_shared",
  "meal_interpretation.ts",
);
const portalSrcDir = path.join(repoRoot, "professional_portal", "src");

const portalGeneratedPath = path.join(
  repoRoot,
  "professional_portal",
  "src",
  "lib",
  "generated",
  "i18n.ts",
);
const supabaseGeneratedPath = path.join(
  repoRoot,
  "supabase",
  "functions",
  "_shared",
  "generated_i18n.ts",
);
const flutterLocaleRegistryPath = path.join(
  repoRoot,
  "lib",
  "core",
  "i18n",
  "generated_supported_locales.dart",
);

const defaultSupportedLocales = {
  defaultLocale: "en",
  locales: [
    {
      code: "en",
      nativeName: "English",
      languageCode: "en",
      countryCode: null,
    },
    {
      code: "en-GB",
      nativeName: "English (United Kingdom)",
      languageCode: "en",
      countryCode: "GB",
    },
    {
      code: "es",
      nativeName: "Español",
      languageCode: "es",
      countryCode: null,
    },
  ],
};

function ensureDir(dirPath) {
  fs.mkdirSync(dirPath, { recursive: true });
}

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function writeFileIfChanged(filePath, content) {
  const next = content.replace(/\r?\n/g, "\n");
  const current = fs.existsSync(filePath)
    ? fs.readFileSync(filePath, "utf8").replace(/\r?\n/g, "\n")
    : null;
  if (current === next) return false;
  ensureDir(path.dirname(filePath));
  fs.writeFileSync(filePath, next, "utf8");
  return true;
}

function writeJson(filePath, value) {
  return writeFileIfChanged(filePath, `${JSON.stringify(value, null, 2)}\n`);
}

function slugify(value) {
  return value
    .normalize("NFKD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/[^a-zA-Z0-9]+/g, "_")
    .replace(/^_+|_+$/g, "")
    .replace(/_+/g, "_")
    .toLowerCase();
}

function toParamName(expressionText, fallbackIndex) {
  const identifierLike = expressionText
    .replace(/\?.*$/g, "")
    .split(/[^\w]+/)
    .filter(Boolean)
    .slice(-2)
    .join("_");
  const base = slugify(identifierLike) || `value_${fallbackIndex + 1}`;
  return /^\d/.test(base) ? `value_${base}` : base;
}

function extractPlaceholders(template) {
  const matches = template.match(/\{([a-zA-Z0-9_]+)\}/g) ?? [];
  return matches.map((entry) => entry.slice(1, -1));
}

function createNestedMap(flatMap) {
  const nested = {};
  for (const [flatKey, value] of Object.entries(flatMap)) {
    const segments = flatKey.split(".");
    let cursor = nested;
    for (let index = 0; index < segments.length - 1; index += 1) {
      const segment = segments[index];
      cursor[segment] ??= {};
      cursor = cursor[segment];
    }
    cursor[segments.at(-1)] = value;
  }
  return nested;
}

function flattenNestedMap(value, prefix = "", output = {}) {
  for (const [key, child] of Object.entries(value)) {
    const nextKey = prefix ? `${prefix}.${key}` : key;
    if (
      child &&
      typeof child === "object" &&
      !Array.isArray(child)
    ) {
      flattenNestedMap(child, nextKey, output);
    } else {
      output[nextKey] = child;
    }
  }
  return output;
}

function readSupportedLocales() {
  if (!fs.existsSync(supportedLocalesPath)) {
    writeJson(supportedLocalesPath, defaultSupportedLocales);
  }
  return readJson(supportedLocalesPath);
}

function localeFilePath(localeCode) {
  return path.join(localesDir, `${localeCode}.json`);
}

function readLocaleMaps() {
  const { locales } = readSupportedLocales();
  const maps = {};
  for (const locale of locales) {
    const filePath = localeFilePath(locale.code);
    if (!fs.existsSync(filePath)) {
      throw new Error(`Missing locale file: ${path.relative(repoRoot, filePath)}`);
    }
    maps[locale.code] = flattenNestedMap(readJson(filePath));
  }
  return maps;
}

function splitFlutterArb(arb) {
  const values = {};
  const meta = {};
  for (const [key, value] of Object.entries(arb)) {
    if (key.startsWith("@")) {
      meta[key.slice(1)] = value;
    } else {
      values[key] = value;
    }
  }
  return { values, meta };
}

function parseExportedObject(filePath, exportName) {
  const source = fs.readFileSync(filePath, "utf8");
  const match = source.match(
    new RegExp(`export const ${exportName} = ([\\s\\S]*?) as const;`),
  );
  if (!match) {
    throw new Error(`Unable to parse ${exportName} from ${path.relative(repoRoot, filePath)}`);
  }
  return Function(`return (${match[1]});`)();
}

function parseLocalObject(filePath, constName) {
  const source = fs.readFileSync(filePath, "utf8");
  const match = source.match(
    new RegExp(`const ${constName}: [\\s\\S]*?= ([\\s\\S]*?);\\n\\nexport`),
  );
  if (!match) {
    throw new Error(`Unable to parse ${constName} from ${path.relative(repoRoot, filePath)}`);
  }
  return Function(`return (${match[1]});`)();
}

function collectCopyEntries(prefix, value, enMap, esMap) {
  for (const [key, child] of Object.entries(value)) {
    const nextKey = prefix ? `${prefix}.${key}` : key;
    if (
      child &&
      typeof child === "object" &&
      "en" in child &&
      "es" in child &&
      typeof child.en === "string" &&
      typeof child.es === "string"
    ) {
      enMap[nextKey] = child.en;
      esMap[nextKey] = child.es;
      continue;
    }
    collectCopyEntries(nextKey, child, enMap, esMap);
  }
}

function walkFiles(dirPath, predicate, collected = []) {
  for (const entry of fs.readdirSync(dirPath, { withFileTypes: true })) {
    const fullPath = path.join(dirPath, entry.name);
    if (entry.isDirectory()) {
      walkFiles(fullPath, predicate, collected);
    } else if (predicate(fullPath)) {
      collected.push(fullPath);
    }
  }
  return collected;
}

function toRelativePortalNamespace(filePath) {
  const relativePath = path.relative(portalSrcDir, filePath).replace(/\\/g, "/");
  const withoutExtension = relativePath.replace(/\.[^.]+$/, "");
  return withoutExtension
    .split("/")
    .map((segment) => slugify(segment))
    .filter(Boolean)
    .join(".");
}

function buildPortalKey(filePath, englishText, usedKeys, usedPairs) {
  const namespace = toRelativePortalNamespace(filePath);
  const baseText = englishText.replace(/\{[a-zA-Z0-9_]+\}/g, " ").trim();
  const slugBase = slugify(baseText).slice(0, 72) || "copy";
  const baseKey = `portal.${namespace}.${slugBase}`;

  if (usedPairs.has(baseKey) && usedPairs.get(baseKey) === englishText) {
    return baseKey;
  }

  let candidate = baseKey;
  let counter = 2;
  while (usedKeys.has(candidate) && usedPairs.get(candidate) !== englishText) {
    candidate = `${baseKey}_${counter}`;
    counter += 1;
  }
  usedKeys.add(candidate);
  usedPairs.set(candidate, englishText);
  return candidate;
}

function parseLocalizedArgument(node, sourceFile, forcedParamNames = null) {
  if (ts.isStringLiteral(node) || ts.isNoSubstitutionTemplateLiteral(node)) {
    if (forcedParamNames && forcedParamNames.length > 0) {
      throw new Error(`Expected template literal near ${sourceFile.fileName}:${sourceFile.getLineAndCharacterOfPosition(node.pos).line + 1}`);
    }
    return { text: node.text, params: [] };
  }

  if (!ts.isTemplateExpression(node)) {
    throw new Error(`Unsupported translation argument in ${sourceFile.fileName}: ${node.getText(sourceFile)}`);
  }

  const params = [];
  let text = node.head.text;
  node.templateSpans.forEach((span, index) => {
    const expressionText = span.expression.getText(sourceFile);
    const paramName = forcedParamNames?.[index] ?? toParamName(expressionText, index);
    if (params.some((entry) => entry.name === paramName)) {
      throw new Error(`Duplicate placeholder name "${paramName}" in ${sourceFile.fileName}`);
    }
    params.push({ name: paramName, expressionText });
    text += `{${paramName}}${span.literal.text}`;
  });
  return { text, params };
}

function migratePortalTrCalls(enMap, esMap) {
  const portalFiles = walkFiles(
    portalSrcDir,
    (filePath) =>
      /\.(ts|tsx)$/.test(filePath) &&
      !filePath.includes(`${path.sep}generated${path.sep}`),
  );
  const usedKeys = new Set(Object.keys(enMap));
  const usedPairs = new Map(Object.entries(enMap).map(([key, value]) => [key, value]));

  for (const filePath of portalFiles) {
    const sourceText = fs.readFileSync(filePath, "utf8");
    if (!sourceText.includes("tr(") && !sourceText.includes("{ tr")) {
      continue;
    }

    const sourceFile = ts.createSourceFile(
      filePath,
      sourceText,
      ts.ScriptTarget.Latest,
      true,
      filePath.endsWith(".tsx") ? ts.ScriptKind.TSX : ts.ScriptKind.TS,
    );

    const edits = [];

    function visit(node) {
      if (
        ts.isVariableDeclaration(node) &&
        ts.isObjectBindingPattern(node.name) &&
        node.initializer &&
        ts.isCallExpression(node.initializer) &&
        ts.isIdentifier(node.initializer.expression) &&
        node.initializer.expression.text === "usePortalI18n"
      ) {
        for (const element of node.name.elements) {
          if (
            !element.propertyName &&
            ts.isIdentifier(element.name) &&
            element.name.text === "tr"
          ) {
            edits.push({
              start: element.getStart(sourceFile),
              end: element.getEnd(),
              text: "t",
            });
          }
        }
      }

      if (
        ts.isCallExpression(node) &&
        ((ts.isIdentifier(node.expression) && node.expression.text === "tr") ||
          (ts.isPropertyAccessExpression(node.expression) &&
            node.expression.name.text === "tr")) &&
        node.arguments.length === 2
      ) {
        const esArg = parseLocalizedArgument(node.arguments[0], sourceFile);
        const enArg = parseLocalizedArgument(
          node.arguments[1],
          sourceFile,
          esArg.params.map((param) => param.name),
        );

        if (esArg.params.length !== enArg.params.length) {
          throw new Error(`Placeholder count mismatch in ${filePath}`);
        }

        const key = buildPortalKey(filePath, enArg.text, usedKeys, usedPairs);
        enMap[key] = enArg.text;
        esMap[key] = esArg.text;

        const params = enArg.params.map((param) => `${param.name}: ${param.expressionText}`);
        const runtimeKey = key.replace(/^portal\./, "");
        const replacement = params.length === 0
          ? `t('${runtimeKey}')`
          : `t('${runtimeKey}', { ${params.join(", ")} })`;

        edits.push({
          start: node.getStart(sourceFile),
          end: node.getEnd(),
          text: replacement,
        });
      }

      ts.forEachChild(node, visit);
    }

    visit(sourceFile);

    if (edits.length === 0) {
      continue;
    }

    edits.sort((left, right) => right.start - left.start);
    let nextText = sourceText;
    for (const edit of edits) {
      nextText = `${nextText.slice(0, edit.start)}${edit.text}${nextText.slice(edit.end)}`;
    }
    writeFileIfChanged(filePath, nextText);
  }
}

function bootstrap() {
  ensureDir(localesDir);

  if (!fs.existsSync(supportedLocalesPath)) {
    writeJson(supportedLocalesPath, defaultSupportedLocales);
  }

  const enArb = splitFlutterArb(readJson(flutterEnArbPath));
  const esArb = splitFlutterArb(readJson(flutterEsArbPath));

  const enMap = {};
  const esMap = {};

  for (const [key, value] of Object.entries(enArb.values)) {
    enMap[`flutter.${key}`] = value;
  }
  for (const [key, value] of Object.entries(esArb.values)) {
    esMap[`flutter.${key}`] = value;
  }

  writeJson(flutterMetaPath, enArb.meta);

  if (fs.existsSync(supabaseCopyPath)) {
    const edgeCopy = parseExportedObject(supabaseCopyPath, "edgeCopy");
    collectCopyEntries("functions", edgeCopy, enMap, esMap);
  }

  const mealCopy = parseLocalObject(mealInterpretationPath, "MEAL_INTERPRETATION_COPY");
  for (const [locale, copy] of Object.entries(mealCopy)) {
    const target = locale === "es" ? esMap : enMap;
    for (const [key, value] of Object.entries(copy)) {
      target[`functions.mealInterpretation.${key}`] = value;
    }
  }

  migratePortalTrCalls(enMap, esMap);

  const enGbMap = Object.fromEntries(
    Object.entries(enMap).map(([key, value]) => [key, value]),
  );

  writeJson(localeFilePath("en"), createNestedMap(enMap));
  writeJson(localeFilePath("es"), createNestedMap(esMap));
  writeJson(localeFilePath("en-GB"), createNestedMap(enGbMap));
}

function validateLocaleMaps(localeMaps, defaultLocale) {
  const locales = Object.keys(localeMaps);
  const canonicalKeys = Object.keys(localeMaps[defaultLocale] ?? {}).sort();
  if (canonicalKeys.length === 0) {
    throw new Error(`Default locale "${defaultLocale}" is empty.`);
  }

  for (const locale of locales) {
    const keys = Object.keys(localeMaps[locale]).sort();
    const missing = canonicalKeys.filter((key) => !(key in localeMaps[locale]));
    const extra = keys.filter((key) => !(key in localeMaps[defaultLocale]));
    if (missing.length > 0 || extra.length > 0) {
      throw new Error(
        `Locale ${locale} is out of parity. Missing: ${missing.slice(0, 10).join(", ")} Extra: ${extra.slice(0, 10).join(", ")}`,
      );
    }

    for (const key of canonicalKeys) {
      const expected = extractPlaceholders(String(localeMaps[defaultLocale][key]));
      const actual = extractPlaceholders(String(localeMaps[locale][key]));
      if (expected.join("|") !== actual.join("|")) {
        throw new Error(
          `Placeholder mismatch for ${key} in locale ${locale}. Expected [${expected.join(", ")}] but found [${actual.join(", ")}]`,
        );
      }
    }
  }
}

function makeArbFileName(code) {
  return `intl_${code.replace(/-/g, "_")}.arb`;
}

function generateFlutterArbs(localeMaps) {
  const flutterMeta = readJson(flutterMetaPath);
  for (const [locale, flatMap] of Object.entries(localeMaps)) {
    const arb = {
      "@@locale": locale.replace(/-/g, "_"),
    };
    const flutterKeys = Object.keys(flatMap)
      .filter((key) => key.startsWith("flutter."))
      .sort();
    for (const key of flutterKeys) {
      const arbKey = key.replace(/^flutter\./, "");
      arb[arbKey] = flatMap[key];
      if (flutterMeta[arbKey]) {
        arb[`@${arbKey}`] = flutterMeta[arbKey];
      }
    }
    writeJson(path.join(repoRoot, "lib", "l10n", makeArbFileName(locale)), arb);
  }
}

function generatePortalModule(localeMaps, supportedLocales, defaultLocale) {
  const portalKeys = Object.keys(localeMaps[defaultLocale])
    .filter((key) => key.startsWith("portal."))
    .map((key) => key.replace(/^portal\./, ""))
    .sort();

  const translations = {};
  for (const locale of supportedLocales.locales) {
    translations[locale.code] = {};
    for (const key of portalKeys) {
      translations[locale.code][key] = localeMaps[locale.code][`portal.${key}`];
    }
  }

  const content = `export const defaultPortalLocale = '${defaultLocale}' as const;

export const portalLocaleMetadata = ${JSON.stringify(supportedLocales.locales, null, 2)} as const;

export const portalI18nData = ${JSON.stringify(translations, null, 2)} as const;

export type PortalLocale = keyof typeof portalI18nData;
export type PortalLocaleCode = PortalLocale;
export type PortalTranslationKey = keyof typeof portalI18nData[typeof defaultPortalLocale];
`;

  writeFileIfChanged(portalGeneratedPath, content);
}

function generateSupabaseModule(localeMaps, supportedLocales, defaultLocale) {
  const functionKeys = Object.keys(localeMaps[defaultLocale])
    .filter((key) => key.startsWith("functions."))
    .map((key) => key.replace(/^functions\./, ""))
    .sort();

  const translations = {};
  for (const locale of supportedLocales.locales) {
    translations[locale.code] = {};
    for (const key of functionKeys) {
      translations[locale.code][key] = localeMaps[locale.code][`functions.${key}`];
    }
  }

  const content = `export const defaultRequestLocale = '${defaultLocale}' as const;

export const requestLocaleMetadata = ${JSON.stringify(supportedLocales.locales, null, 2)} as const;

export const requestI18nData = ${JSON.stringify(translations, null, 2)} as const;

export type RequestLocale = keyof typeof requestI18nData;
export type RequestTranslationKey = keyof typeof requestI18nData[typeof defaultRequestLocale];
`;

  writeFileIfChanged(supabaseGeneratedPath, content);
}

function generateFlutterLocaleRegistry(supportedLocales, defaultLocale) {
  const entries = supportedLocales.locales
    .map((locale) => {
      const countryCode = locale.countryCode ? `'${locale.countryCode}'` : "null";
      return `  AppSupportedLocale(
    code: '${locale.code}',
    nativeName: '${locale.nativeName.replace(/'/g, "\\'")}',
    languageCode: '${locale.languageCode}',
    countryCode: ${countryCode},
  ),`;
    })
    .join("\n");

  const content = `import 'package:flutter/material.dart';

class AppSupportedLocale {
  final String code;
  final String nativeName;
  final String languageCode;
  final String? countryCode;

  const AppSupportedLocale({
    required this.code,
    required this.nativeName,
    required this.languageCode,
    required this.countryCode,
  });

  Locale get locale => Locale.fromSubtags(
        languageCode: languageCode,
        countryCode: countryCode,
      );
}

const appDefaultLocaleCode = '${defaultLocale}';

const appSupportedLocales = <AppSupportedLocale>[
${entries}
];

AppSupportedLocale? findSupportedLocaleByCode(String code) {
  final normalized = code.replaceAll('_', '-').toLowerCase();
  for (final locale in appSupportedLocales) {
    if (locale.code.toLowerCase() == normalized) {
      return locale;
    }
  }

  final baseLanguage = normalized.split('-').first;
  for (final locale in appSupportedLocales) {
    if (locale.languageCode.toLowerCase() == baseLanguage) {
      return locale;
    }
  }

  for (final locale in appSupportedLocales) {
    if (locale.code == appDefaultLocaleCode) {
      return locale;
    }
  }
  return null;
}

Locale? buildSupportedLocale(String? code) {
  if (code == null || code.isEmpty) {
    return null;
  }
  return findSupportedLocaleByCode(code)?.locale;
}

List<AppSupportedLocale> getSupportedLocalesMetadata() => List.unmodifiable(appSupportedLocales);
`;

  writeFileIfChanged(flutterLocaleRegistryPath, content);
}

function build() {
  const supportedLocales = readSupportedLocales();
  const localeMaps = readLocaleMaps();
  validateLocaleMaps(localeMaps, supportedLocales.defaultLocale);
  generateFlutterArbs(localeMaps);
  generatePortalModule(localeMaps, supportedLocales, supportedLocales.defaultLocale);
  generateSupabaseModule(localeMaps, supportedLocales, supportedLocales.defaultLocale);
  generateFlutterLocaleRegistry(supportedLocales, supportedLocales.defaultLocale);
}

function main() {
  const command = process.argv[2] ?? "build";
  if (command === "bootstrap") {
    bootstrap();
    build();
    return;
  }
  if (command === "build") {
    build();
    return;
  }
  if (command === "validate") {
    const supportedLocales = readSupportedLocales();
    validateLocaleMaps(readLocaleMaps(), supportedLocales.defaultLocale);
    return;
  }
  throw new Error(`Unknown command: ${command}`);
}

main();
