// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a es locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'es';

  static String m0(count) => "${count} activos";

  static String m1(mealType) =>
      "Importa una imagen de comida, revisa el borrador editable y guárdalo en ${mealType}.";

  static String m2(item) => "Editar ${item}";

  static String m3(count) => "${count} ingredientes";

  static String m4(unit) => "Cantidad (${unit})";

  static String m5(source) =>
      "Sustituido por ${source} para mejorar la precisión.";

  static String m6(count) => "${count} raciones listas para guardar";

  static String m7(title) => "Sugerencia aplicada: ${title}";

  static String m8(label) => "Usar habitual: ${label}";

  static String m9(versionNumber) => "Versión ${versionNumber}";

  static String m10(pctCarbs, pctFats, pctProteins) =>
      "${pctCarbs}% carbos, ${pctFats}% grasas, ${pctProteins}% proteínas";

  static String m11(count) => "${count} actividades";

  static String m12(percent) => "${percent}% adherencia";

  static String m13(count) => "${count}/7 días";

  static String m14(count) => "${count} elementos";

  static String m15(amount) => "${amount} g restantes";

  static String m16(amount) => "+${amount} kcal";

  static String m17(amount) => "${amount} kcal restantes";

  static String m18(carbsTracked, carbsGoal, fatTracked, fatGoal,
          proteinTracked, proteinGoal) =>
      "Carbohidratos ${carbsTracked}/${carbsGoal} g, grasas ${fatTracked}/${fatGoal} g, proteína ${proteinTracked}/${proteinGoal} g";

  static String m19(count) => "${count} comidas";

  static String m20(amount) => "${amount}g proteína media";

  static String m21(recipe, slot) => "${recipe} añadida a ${slot}";

  static String m22(count) => "${count} porciones";

  static String m23(riskValue) => "Riesgo de comorbilidades: ${riskValue}";

  static String m24(phase) => "Fase actual: ${phase}";

  static String m25(name) => "${name} añadida";

  static String m26(count) => "${count} ingredientes";

  static String m27(count) => "${count} raciones";

  static String m28(count) => "Llamadas foto: ${count}";

  static String m29(count) => "Llamadas texto: ${count}";

  static String m30(count) => "Llamadas totales: ${count}";

  static String m31(cost) => "Este mes: ${cost}";

  static String m32(cost) => "Hoy: ${cost}";

  static String m33(cost) => "Total estimado: ${cost}";

  static String m34(kcal) => "Ajuste diario actualizado a ${kcal} kcal.";

  static String m35(delta) => "Aplicar ${delta} kcal/día";

  static String m36(percent) => "${percent}% de días registrados";

  static String m37(count) => "${count} días registrados esta semana";

  static String m38(delta) => "Tendencia de peso: ${delta} kg/semana";

  static String m39(age) => "${age} años";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "activityExample": MessageLookupByLibrary.simpleMessage(
            "ej. correr, ciclismo, yoga..."),
        "activityLabel": MessageLookupByLibrary.simpleMessage("Actividad"),
        "addItemLabel":
            MessageLookupByLibrary.simpleMessage("Añadir nuevo elemento:"),
        "addLabel": MessageLookupByLibrary.simpleMessage("Añadir"),
        "addMealBarcode": MessageLookupByLibrary.simpleMessage("Barras"),
        "addMealPhoto": MessageLookupByLibrary.simpleMessage("Foto"),
        "addMealSaved": MessageLookupByLibrary.simpleMessage("Guardadas"),
        "addMealText": MessageLookupByLibrary.simpleMessage("Texto"),
        "additionalInfoLabelCompendium2011": MessageLookupByLibrary.simpleMessage(
            "Información proporcionada\npor el\n\'Compendio 2011\nde actividades físicas\'"),
        "additionalInfoLabelCustom":
            MessageLookupByLibrary.simpleMessage("Elemento personalizado"),
        "additionalInfoLabelFDC": MessageLookupByLibrary.simpleMessage(
            "Más información en\nFoodData Central"),
        "additionalInfoLabelOFF": MessageLookupByLibrary.simpleMessage(
            "Más información en\nOpenFoodFacts"),
        "additionalInfoLabelUnknown":
            MessageLookupByLibrary.simpleMessage("Elemento desconocido"),
        "ageLabel": MessageLookupByLibrary.simpleMessage("Edad"),
        "aiActiveItemsCount": m0,
        "aiAddIngredient":
            MessageLookupByLibrary.simpleMessage("Añadir ingrediente"),
        "aiAmountLabel": MessageLookupByLibrary.simpleMessage("Cantidad"),
        "aiButtonCapture":
            MessageLookupByLibrary.simpleMessage("Hacer foto y revisar"),
        "aiButtonPickGallery":
            MessageLookupByLibrary.simpleMessage("Elegir de galería"),
        "aiButtonUse": MessageLookupByLibrary.simpleMessage("Usar"),
        "aiButtonUseText": MessageLookupByLibrary.simpleMessage("Usar texto"),
        "aiCaptureByPhotoSubtitle": m1,
        "aiCaptureByPhotoTitle":
            MessageLookupByLibrary.simpleMessage("Registro por foto"),
        "aiConfidenceHigh":
            MessageLookupByLibrary.simpleMessage("Confianza alta"),
        "aiConfidenceLow":
            MessageLookupByLibrary.simpleMessage("Confianza baja"),
        "aiConfidenceLowGenericHint": MessageLookupByLibrary.simpleMessage(
            "Este ingrediente tiene poca certeza. Revisa cantidad o sustitúyelo por un alimento más preciso."),
        "aiConfidenceLowHint": MessageLookupByLibrary.simpleMessage(
            "Este ingrediente tiene poca certeza. Tu corrección habitual suele ser la opción más rápida."),
        "aiConfidenceMedium":
            MessageLookupByLibrary.simpleMessage("Confianza media"),
        "aiConfidenceMediumHint": MessageLookupByLibrary.simpleMessage(
            "La cantidad puede variar. Revisa la ración si ves que no encaja con la foto."),
        "aiCropLabel": MessageLookupByLibrary.simpleMessage("Recorte"),
        "aiCustomServingsHelper": MessageLookupByLibrary.simpleMessage(
            "Ajusta la ración final antes de guardar."),
        "aiCustomServingsLabel":
            MessageLookupByLibrary.simpleMessage("Raciones personalizadas"),
        "aiDetectedIngredients":
            MessageLookupByLibrary.simpleMessage("Ingredientes detectados"),
        "aiDraftNotFound": MessageLookupByLibrary.simpleMessage(
            "Borrador no encontrado o caducado."),
        "aiEditAmountTitle": m2,
        "aiEditableLabel": MessageLookupByLibrary.simpleMessage("Editable"),
        "aiErrorGeneric": MessageLookupByLibrary.simpleMessage(
            "Falló la interpretación remota de imagen. Se creó un borrador local con apoyo de memoria."),
        "aiErrorMissingKey": MessageLookupByLibrary.simpleMessage(
            "La IA remota no está configurada en el backend. Se creó un borrador local."),
        "aiErrorPayloadTooLarge": MessageLookupByLibrary.simpleMessage(
            "La imagen es demasiado grande para IA remota. Se creó borrador local."),
        "aiErrorQuotaExceeded": MessageLookupByLibrary.simpleMessage(
            "Se alcanzó el límite de cuota/rate de IA remota. Se creó un borrador local."),
        "aiErrorUnsupportedFormat": MessageLookupByLibrary.simpleMessage(
            "Formato de imagen no soportado por IA remota. Prueba JPG/PNG. Se creó un borrador local."),
        "aiExcludeFromMeal": MessageLookupByLibrary.simpleMessage(
            "Excluido de la comida final."),
        "aiFavoriteQuickAccess":
            MessageLookupByLibrary.simpleMessage("Favorita para acceso rápido"),
        "aiFitLabel": MessageLookupByLibrary.simpleMessage("Ajuste"),
        "aiGymLabelBalanced":
            MessageLookupByLibrary.simpleMessage("Balanceada"),
        "aiGymLabelHighProtein":
            MessageLookupByLibrary.simpleMessage("Alta en proteína"),
        "aiGymLabelLeanDefinition":
            MessageLookupByLibrary.simpleMessage("Ligera para definición"),
        "aiGymLabelPostWorkout":
            MessageLookupByLibrary.simpleMessage("Post entreno"),
        "aiGymLabelPreWorkout":
            MessageLookupByLibrary.simpleMessage("Pre entreno"),
        "aiHintCheckSaucesSubtitle": MessageLookupByLibrary.simpleMessage(
            "El borrador es solo el primer paso. Corrige calorías ocultas."),
        "aiHintCheckSaucesTitle":
            MessageLookupByLibrary.simpleMessage("Revisa salsas y aceites"),
        "aiHintGymMealsSubtitle": MessageLookupByLibrary.simpleMessage(
            "Útil para bowls, batidos, post entreno y comidas repetidas."),
        "aiHintGymMealsTitle": MessageLookupByLibrary.simpleMessage(
            "Pensado para comidas de gimnasio"),
        "aiHintRecommendations":
            MessageLookupByLibrary.simpleMessage("Recomendaciones"),
        "aiHintShowFullPlateSubtitle": MessageLookupByLibrary.simpleMessage(
            "Mejor encuadre, mejor detección de ingredientes."),
        "aiHintShowFullPlateTitle":
            MessageLookupByLibrary.simpleMessage("Muestra el plato completo"),
        "aiIngredientsCount": m3,
        "aiMatchGood":
            MessageLookupByLibrary.simpleMessage("Coincidencia buena"),
        "aiMatchHigh":
            MessageLookupByLibrary.simpleMessage("Coincidencia alta"),
        "aiMatchPossible":
            MessageLookupByLibrary.simpleMessage("Coincidencia posible"),
        "aiMatchesHint": MessageLookupByLibrary.simpleMessage(
            "Usa una comida frecuente, receta o corrección previa si se parece más a lo que has comido."),
        "aiMealPhotoTitle":
            MessageLookupByLibrary.simpleMessage("Comida por foto IA"),
        "aiMealSaveError": MessageLookupByLibrary.simpleMessage(
            "No se pudo guardar esta comida"),
        "aiMealSavedSuccess":
            MessageLookupByLibrary.simpleMessage("Comida guardada"),
        "aiPhotoCaptured":
            MessageLookupByLibrary.simpleMessage("Foto capturada"),
        "aiPhotoCapturedHint": MessageLookupByLibrary.simpleMessage(
            "Toca para ampliar. Alterna recorte/ajuste para inspección rápida."),
        "aiPhotoPreviewError": MessageLookupByLibrary.simpleMessage(
            "No se pudo cargar la vista previa"),
        "aiPhotoZoomTitle":
            MessageLookupByLibrary.simpleMessage("Zoom de la foto"),
        "aiQuantityUnitLabel": m4,
        "aiQuickAdjustment":
            MessageLookupByLibrary.simpleMessage("Ajuste rápido"),
        "aiRecipeNameHelper": MessageLookupByLibrary.simpleMessage(
            "Usa nombres como avena pre, pollo arroz post o batido."),
        "aiRecipeNameLabel":
            MessageLookupByLibrary.simpleMessage("Nombre de la receta"),
        "aiRemoveLabel": MessageLookupByLibrary.simpleMessage("Quitar"),
        "aiReplaceEmpty": MessageLookupByLibrary.simpleMessage(
            "Busca un alimento para reemplazar este ingrediente."),
        "aiReplaceError": MessageLookupByLibrary.simpleMessage(
            "No se pueden buscar alimentos ahora mismo."),
        "aiReplaceHint":
            MessageLookupByLibrary.simpleMessage("Buscar alimentos"),
        "aiReplaceMinLength": MessageLookupByLibrary.simpleMessage(
            "Escribe al menos 2 caracteres."),
        "aiReplaceNoResults": MessageLookupByLibrary.simpleMessage(
            "No se encontraron resultados."),
        "aiReplaceTitle":
            MessageLookupByLibrary.simpleMessage("Reemplazar ingrediente"),
        "aiReplacedBySummary": m5,
        "aiRestoreLabel": MessageLookupByLibrary.simpleMessage("Restaurar"),
        "aiRetry": MessageLookupByLibrary.simpleMessage("Reintentar"),
        "aiReviewDraftTitle":
            MessageLookupByLibrary.simpleMessage("Revisar borrador IA"),
        "aiSaveAsRecipe":
            MessageLookupByLibrary.simpleMessage("Guardar como receta"),
        "aiSaveDraftChangesError": MessageLookupByLibrary.simpleMessage(
            "No se pudieron guardar los cambios del borrador"),
        "aiSaveMeal": MessageLookupByLibrary.simpleMessage("Guardar comida"),
        "aiSavingMeal":
            MessageLookupByLibrary.simpleMessage("Guardando comida..."),
        "aiServingsReady": m6,
        "aiServingsToSave":
            MessageLookupByLibrary.simpleMessage("Raciones a guardar"),
        "aiSourcePhoto": MessageLookupByLibrary.simpleMessage("Foto IA"),
        "aiSourceText": MessageLookupByLibrary.simpleMessage("Texto IA"),
        "aiStatusConsulting":
            MessageLookupByLibrary.simpleMessage("Consultando IA..."),
        "aiStatusPersonalizing":
            MessageLookupByLibrary.simpleMessage("Personalizando..."),
        "aiStatusPreparing":
            MessageLookupByLibrary.simpleMessage("Preparando imagen..."),
        "aiStepPickImage":
            MessageLookupByLibrary.simpleMessage("Elegir imagen"),
        "aiStepReviewItems":
            MessageLookupByLibrary.simpleMessage("Revisar ítems"),
        "aiStepSaveMeal":
            MessageLookupByLibrary.simpleMessage("Guardar comida"),
        "aiSubstituteLabel": MessageLookupByLibrary.simpleMessage("Sustituir"),
        "aiSuggestionApplied": m7,
        "aiTextCaptureButton":
            MessageLookupByLibrary.simpleMessage("Interpretar comida"),
        "aiTextCaptureDescription": MessageLookupByLibrary.simpleMessage(
            "Describe la comida de forma natural. El texto puede procesarse de forma remota para estimar ingredientes y macros, y siempre revisarás el borrador antes de guardarlo."),
        "aiTextCaptureError": MessageLookupByLibrary.simpleMessage(
            "Interpretación remota no disponible. Se creó un borrador local con apoyo de memoria."),
        "aiTextCaptureHint": MessageLookupByLibrary.simpleMessage(
            "Ejemplo: 2 huevos, tostadas con mantequilla y café con leche"),
        "aiTextCaptureLoading":
            MessageLookupByLibrary.simpleMessage("Interpretando..."),
        "aiTextCaptureTitle":
            MessageLookupByLibrary.simpleMessage("Comida por texto"),
        "aiUseHabitual": m8,
        "aiYourMatches":
            MessageLookupByLibrary.simpleMessage("Coincidencias tuyas"),
        "allItemsLabel": MessageLookupByLibrary.simpleMessage("Todo"),
        "alphaVersionName": MessageLookupByLibrary.simpleMessage("[Alpha]"),
        "appDescription": MessageLookupByLibrary.simpleMessage(
            "MacroTracker es un rastreador de calorías y nutrientes gratuito y de código abierto que respeta tu privacidad."),
        "appLicenseLabel":
            MessageLookupByLibrary.simpleMessage("Licencia GPL-3.0"),
        "appTitle": MessageLookupByLibrary.simpleMessage("MacroTracker"),
        "appVersionName": m9,
        "baseQuantityLabel":
            MessageLookupByLibrary.simpleMessage("Cantidad base (g/ml)"),
        "betaVersionName": MessageLookupByLibrary.simpleMessage("[Beta]"),
        "bmiInfo": MessageLookupByLibrary.simpleMessage(
            "El Índice de Masa Corporal (IMC) es un índice para clasificar el sobrepeso y la obesidad en adultos. Se define como el peso en kilogramos dividido por el cuadrado de la altura en metros (kg/m²).\n\nEl IMC no diferencia entre masa grasa y muscular y puede ser engañoso para algunas personas."),
        "bmiLabel": MessageLookupByLibrary.simpleMessage("IMC"),
        "breakfastExample": MessageLookupByLibrary.simpleMessage(
            "ej. cereales, leche, café..."),
        "breakfastLabel": MessageLookupByLibrary.simpleMessage("Desayuno"),
        "burnedLabel": MessageLookupByLibrary.simpleMessage("quemado"),
        "buttonNextLabel": MessageLookupByLibrary.simpleMessage("SIGUIENTE"),
        "buttonResetLabel": MessageLookupByLibrary.simpleMessage("Reiniciar"),
        "buttonSaveLabel": MessageLookupByLibrary.simpleMessage("Guardar"),
        "buttonStartLabel": MessageLookupByLibrary.simpleMessage("EMPEZAR"),
        "buttonYesLabel": MessageLookupByLibrary.simpleMessage("SÍ"),
        "calculationsMacronutrientsDistributionLabel":
            MessageLookupByLibrary.simpleMessage("Distribución de macros"),
        "calculationsMacrosDistribution": m10,
        "calculationsRecommendedLabel":
            MessageLookupByLibrary.simpleMessage("(recomendado)"),
        "calculationsTDEEIOM2006Label": MessageLookupByLibrary.simpleMessage(
            "Ecuación del Instituto de Medicina"),
        "calculationsTDEELabel":
            MessageLookupByLibrary.simpleMessage("Ecuación TDEE"),
        "carbohydrateLabel":
            MessageLookupByLibrary.simpleMessage("carbohidratos"),
        "carbsLabel": MessageLookupByLibrary.simpleMessage("carbos"),
        "chooseWeightGoalLabel":
            MessageLookupByLibrary.simpleMessage("Elige el objetivo de peso"),
        "cmLabel": MessageLookupByLibrary.simpleMessage("cm"),
        "copyDialogTitle": MessageLookupByLibrary.simpleMessage(
            "¿A qué tipo de comida quieres copiar?"),
        "copyOrDeleteTimeDialogContent": MessageLookupByLibrary.simpleMessage(
            "Con \"Copiar a hoy\" puedes copiar la comida a hoy. Con \"Eliminar\" puedes borrar la comida."),
        "copyOrDeleteTimeDialogTitle":
            MessageLookupByLibrary.simpleMessage("¿Qué quieres hacer?"),
        "createCustomDialogContent": MessageLookupByLibrary.simpleMessage(
            "¿Quieres crear un plato personalizado?"),
        "createCustomDialogTitle":
            MessageLookupByLibrary.simpleMessage("¿Crear plato personalizado?"),
        "dailyKcalAdjustmentLabel":
            MessageLookupByLibrary.simpleMessage("Ajuste diario de Kcal:"),
        "dataCollectionLabel": MessageLookupByLibrary.simpleMessage(
            "Apoya el desarrollo proporcionando datos de uso anónimos"),
        "dayLabel": MessageLookupByLibrary.simpleMessage("día"),
        "deleteAllLabel": MessageLookupByLibrary.simpleMessage("Eliminar todo"),
        "deleteTimeDialogContent": MessageLookupByLibrary.simpleMessage(
            "¿Quieres eliminar el elemento seleccionado?"),
        "deleteTimeDialogPluralContent": MessageLookupByLibrary.simpleMessage(
            "¿Quieres eliminar todos los elementos de esta comida?"),
        "deleteTimeDialogPluralTitle":
            MessageLookupByLibrary.simpleMessage("¿Eliminar elementos?"),
        "deleteTimeDialogTitle":
            MessageLookupByLibrary.simpleMessage("¿Eliminar elemento?"),
        "dialogCancelLabel": MessageLookupByLibrary.simpleMessage("CANCELAR"),
        "dialogCopyLabel": MessageLookupByLibrary.simpleMessage("Copiar a hoy"),
        "dialogDeleteLabel": MessageLookupByLibrary.simpleMessage("ELIMINAR"),
        "dialogOKLabel": MessageLookupByLibrary.simpleMessage("OK"),
        "diaryActivitiesPill": m11,
        "diaryAdherencePill": m12,
        "diaryCopyDayToToday":
            MessageLookupByLibrary.simpleMessage("Copiar día a hoy"),
        "diaryCurrentWeek":
            MessageLookupByLibrary.simpleMessage("Semana en curso"),
        "diaryDayCopied":
            MessageLookupByLibrary.simpleMessage("Día copiado a hoy"),
        "diaryDaysPill": m13,
        "diaryElementsSection": m14,
        "diaryEmptySection": MessageLookupByLibrary.simpleMessage("Vacío"),
        "diaryGoalReached":
            MessageLookupByLibrary.simpleMessage("Objetivo cumplido"),
        "diaryGramsRemaining": m15,
        "diaryInGoal": MessageLookupByLibrary.simpleMessage("En objetivo"),
        "diaryKcalOver": m16,
        "diaryKcalRemaining": m17,
        "diaryLabel": MessageLookupByLibrary.simpleMessage("Diario"),
        "diaryMacrosSummary": m18,
        "diaryMealsPill": m19,
        "diaryNextDayTooltip":
            MessageLookupByLibrary.simpleMessage("Día siguiente"),
        "diaryPreviousDayTooltip":
            MessageLookupByLibrary.simpleMessage("Día anterior"),
        "diaryProteinPill": m20,
        "diarySelectedDayLabel":
            MessageLookupByLibrary.simpleMessage("Día seleccionado"),
        "diaryStatusAbove": MessageLookupByLibrary.simpleMessage("Por encima"),
        "diaryStatusBelow": MessageLookupByLibrary.simpleMessage("Por debajo"),
        "diaryStatusInRange": MessageLookupByLibrary.simpleMessage("En rango"),
        "diarySummaryTitle":
            MessageLookupByLibrary.simpleMessage("Resumen del día"),
        "dinnerExample":
            MessageLookupByLibrary.simpleMessage("ej. sopa, pollo, vino..."),
        "dinnerLabel": MessageLookupByLibrary.simpleMessage("Cena"),
        "disclaimerText": MessageLookupByLibrary.simpleMessage(
            "MacroTracker no es una aplicación médica. Todos los datos proporcionados no están validados y deben usarse con precaución. Por favor, mantén un estilo de vida saludable y consulta a un profesional si tienes algún problema. No se recomienda su uso durante enfermedades, embarazo o lactancia."),
        "editItemDialogTitle":
            MessageLookupByLibrary.simpleMessage("Editar elemento"),
        "editMealLabel": MessageLookupByLibrary.simpleMessage("Editar plato"),
        "energyLabel": MessageLookupByLibrary.simpleMessage("energía"),
        "errorFetchingProductData": MessageLookupByLibrary.simpleMessage(
            "Error al obtener datos del producto"),
        "errorLoadingActivities": MessageLookupByLibrary.simpleMessage(
            "Error al cargar las actividades"),
        "errorMealSave": MessageLookupByLibrary.simpleMessage(
            "Error al guardar el plato. ¿Has introducido la información correcta?"),
        "errorOpeningBrowser":
            MessageLookupByLibrary.simpleMessage("Error al abrir el navegador"),
        "errorOpeningEmail": MessageLookupByLibrary.simpleMessage(
            "Error al abrir la aplicación de correo"),
        "errorProductNotFound":
            MessageLookupByLibrary.simpleMessage("Producto no encontrado"),
        "exportAction": MessageLookupByLibrary.simpleMessage("Exportar"),
        "exportImportDescription": MessageLookupByLibrary.simpleMessage(
            "Puedes exportar los datos de la aplicación a un archivo zip e importarlos más tarde. Esto es útil si quieres hacer una copia de seguridad de tus datos o transferirlos a otro dispositivo.\n\nLa aplicación no utiliza ningún servicio en la nube para almacenar tus datos."),
        "exportImportErrorLabel": MessageLookupByLibrary.simpleMessage(
            "Error en la exportación / importación"),
        "exportImportLabel":
            MessageLookupByLibrary.simpleMessage("Exportar / Importar datos"),
        "exportImportSuccessLabel": MessageLookupByLibrary.simpleMessage(
            "Exportación / Importación exitosa"),
        "fatLabel": MessageLookupByLibrary.simpleMessage("grasas"),
        "fiberLabel": MessageLookupByLibrary.simpleMessage("fibra"),
        "flOzUnit": MessageLookupByLibrary.simpleMessage("fl.oz"),
        "ftLabel": MessageLookupByLibrary.simpleMessage("ft"),
        "genderFemaleLabel": MessageLookupByLibrary.simpleMessage("♀ mujer"),
        "genderLabel": MessageLookupByLibrary.simpleMessage("Género"),
        "genderMaleLabel": MessageLookupByLibrary.simpleMessage("♂ hombre"),
        "goalGainWeight": MessageLookupByLibrary.simpleMessage("Ganar peso"),
        "goalLabel": MessageLookupByLibrary.simpleMessage("Objetivo"),
        "goalLoseWeight": MessageLookupByLibrary.simpleMessage("Perder peso"),
        "goalMaintainWeight":
            MessageLookupByLibrary.simpleMessage("Mantener peso"),
        "gramMilliliterUnit": MessageLookupByLibrary.simpleMessage("g/ml"),
        "gramUnit": MessageLookupByLibrary.simpleMessage("g"),
        "heightLabel": MessageLookupByLibrary.simpleMessage("Altura"),
        "homeLabel": MessageLookupByLibrary.simpleMessage("Inicio"),
        "homeWeeklyInsightsSubtitle": MessageLookupByLibrary.simpleMessage(
            "Revisa promedios, adherencia, proteína y comidas top"),
        "hydrationAddWater":
            MessageLookupByLibrary.simpleMessage("Añadir agua"),
        "hydrationGoalReached":
            MessageLookupByLibrary.simpleMessage("¡Objetivo alcanzado!"),
        "hydrationRemoveWater":
            MessageLookupByLibrary.simpleMessage("Reducir agua"),
        "hydrationTitle": MessageLookupByLibrary.simpleMessage("Hidratación"),
        "importAction": MessageLookupByLibrary.simpleMessage("Importar"),
        "infoAddedActivityLabel":
            MessageLookupByLibrary.simpleMessage("Nueva actividad añadida"),
        "infoAddedIntakeLabel":
            MessageLookupByLibrary.simpleMessage("Nuevo registro añadido"),
        "itemDeletedSnackbar":
            MessageLookupByLibrary.simpleMessage("Elemento eliminado"),
        "itemUpdatedSnackbar":
            MessageLookupByLibrary.simpleMessage("Elemento actualizado"),
        "kcalLabel": MessageLookupByLibrary.simpleMessage("kcal"),
        "kcalLeftLabel": MessageLookupByLibrary.simpleMessage("kcal restantes"),
        "kgLabel": MessageLookupByLibrary.simpleMessage("kg"),
        "lbsLabel": MessageLookupByLibrary.simpleMessage("lbs"),
        "lunchExample": MessageLookupByLibrary.simpleMessage(
            "ej. pizza, ensalada, arroz..."),
        "lunchLabel": MessageLookupByLibrary.simpleMessage("Comida"),
        "macroDistributionLabel": MessageLookupByLibrary.simpleMessage(
            "Distribución de macronutrientes:"),
        "macroSuggestionsAddedTo": m21,
        "macroSuggestionsEmpty": MessageLookupByLibrary.simpleMessage(
            "Guarda algunas recetas y esta sección empezará a sugerirte según tu día de entrenamiento."),
        "macroSuggestionsServingsPortions": m22,
        "macroSuggestionsSubtitleDefault": MessageLookupByLibrary.simpleMessage(
            "Comidas guardadas según lo que aún te falta hoy."),
        "macroSuggestionsSubtitleGym": MessageLookupByLibrary.simpleMessage(
            "Comidas recomendadas para rendir y recuperar mejor."),
        "macroSuggestionsSubtitleLoseWeight":
            MessageLookupByLibrary.simpleMessage(
                "Opciones altas en proteína con calorías controladas."),
        "macroSuggestionsSubtitleRest": MessageLookupByLibrary.simpleMessage(
            "Cierres limpios con proteína alta y sin exceso calórico."),
        "macroSuggestionsTitleCardio":
            MessageLookupByLibrary.simpleMessage("Opciones para cardio"),
        "macroSuggestionsTitleDef":
            MessageLookupByLibrary.simpleMessage("Opciones para definición"),
        "macroSuggestionsTitleLeg":
            MessageLookupByLibrary.simpleMessage("Opciones para pierna"),
        "macroSuggestionsTitleRest":
            MessageLookupByLibrary.simpleMessage("Opciones para descanso"),
        "macroSuggestionsTitleTorso":
            MessageLookupByLibrary.simpleMessage("Opciones para torso"),
        "mealBrandsLabel": MessageLookupByLibrary.simpleMessage("Marcas"),
        "mealCarbsLabel": MessageLookupByLibrary.simpleMessage("carbos por"),
        "mealFatLabel": MessageLookupByLibrary.simpleMessage("grasas por"),
        "mealKcalLabel": MessageLookupByLibrary.simpleMessage("kcal por"),
        "mealNameLabel":
            MessageLookupByLibrary.simpleMessage("Nombre del plato"),
        "mealProteinLabel":
            MessageLookupByLibrary.simpleMessage("proteínas por 100 g/ml"),
        "mealSizeLabel": MessageLookupByLibrary.simpleMessage("Tamaño (g/ml)"),
        "mealSizeLabelImperial":
            MessageLookupByLibrary.simpleMessage("Tamaño (oz/fl oz)"),
        "mealUnitLabel": MessageLookupByLibrary.simpleMessage("Unidad"),
        "milliliterUnit": MessageLookupByLibrary.simpleMessage("ml"),
        "missingProductInfo": MessageLookupByLibrary.simpleMessage(
            "Falta información de kcal o macronutrientes requerida en el producto"),
        "noActivityRecentlyAddedLabel": MessageLookupByLibrary.simpleMessage(
            "No hay actividades añadidas recientemente"),
        "noMealsRecentlyAddedLabel": MessageLookupByLibrary.simpleMessage(
            "No hay comidas añadidas recientemente"),
        "noResultsFound": MessageLookupByLibrary.simpleMessage(
            "No se encontraron resultados"),
        "notAvailableLabel": MessageLookupByLibrary.simpleMessage("N/D"),
        "nothingAddedLabel":
            MessageLookupByLibrary.simpleMessage("Nada añadido"),
        "nutritionInfoLabel":
            MessageLookupByLibrary.simpleMessage("Información nutricional"),
        "nutritionalStatusNormalWeight":
            MessageLookupByLibrary.simpleMessage("Peso normal"),
        "nutritionalStatusObeseClassI":
            MessageLookupByLibrary.simpleMessage("Obesidad Clase I"),
        "nutritionalStatusObeseClassII":
            MessageLookupByLibrary.simpleMessage("Obesidad Clase II"),
        "nutritionalStatusObeseClassIII":
            MessageLookupByLibrary.simpleMessage("Obesidad Clase III"),
        "nutritionalStatusPreObesity":
            MessageLookupByLibrary.simpleMessage("Preobesidad"),
        "nutritionalStatusRiskAverage":
            MessageLookupByLibrary.simpleMessage("Promedio"),
        "nutritionalStatusRiskIncreased":
            MessageLookupByLibrary.simpleMessage("Aumentado"),
        "nutritionalStatusRiskLabel": m23,
        "nutritionalStatusRiskLow": MessageLookupByLibrary.simpleMessage(
            "Bajo \n(pero con riesgo aumentado de \notros problemas clínicos)"),
        "nutritionalStatusRiskModerate":
            MessageLookupByLibrary.simpleMessage("Moderado"),
        "nutritionalStatusRiskSevere":
            MessageLookupByLibrary.simpleMessage("Severo"),
        "nutritionalStatusRiskVerySevere":
            MessageLookupByLibrary.simpleMessage("Muy severo"),
        "nutritionalStatusUnderweight":
            MessageLookupByLibrary.simpleMessage("Bajo peso"),
        "offDisclaimer": MessageLookupByLibrary.simpleMessage(
            "Los datos proporcionados por esta aplicación se obtienen de la base de datos de Open Food Facts. No se ofrecen garantías sobre la exactitud, integridad o fiabilidad de la información proporcionada. Los datos se proporcionan \"tal cual\" y la fuente original de los mismos (Open Food Facts) no se hace responsable de los daños derivados del uso de los mismos."),
        "onboardingActivityQuestionSubtitle":
            MessageLookupByLibrary.simpleMessage(
                "¿Cómo de activo eres? (sin contar entrenamientos)"),
        "onboardingBirthdayHint":
            MessageLookupByLibrary.simpleMessage("Introduce fecha"),
        "onboardingBirthdayQuestionSubtitle":
            MessageLookupByLibrary.simpleMessage("¿Cuándo es tu cumpleaños?"),
        "onboardingEnterBirthdayLabel":
            MessageLookupByLibrary.simpleMessage("Fecha de nacimiento"),
        "onboardingGenderQuestionSubtitle":
            MessageLookupByLibrary.simpleMessage("¿Cuál es tu género?"),
        "onboardingGoalQuestionSubtitle": MessageLookupByLibrary.simpleMessage(
            "¿Cuál es tu objetivo de peso actual?"),
        "onboardingHeightExampleHintCm":
            MessageLookupByLibrary.simpleMessage("ej. 170"),
        "onboardingHeightExampleHintFt":
            MessageLookupByLibrary.simpleMessage("ej. 5.8"),
        "onboardingHeightQuestionSubtitle":
            MessageLookupByLibrary.simpleMessage("¿Cuál es tu altura actual?"),
        "onboardingIntroDescription": MessageLookupByLibrary.simpleMessage(
            "Para empezar, la aplicación necesita información sobre ti para calcular tu objetivo diario de calorías.\nToda la información se guarda de forma segura en tu dispositivo."),
        "onboardingKcalPerDayLabel":
            MessageLookupByLibrary.simpleMessage("kcal al día"),
        "onboardingOverviewLabel":
            MessageLookupByLibrary.simpleMessage("Resumen"),
        "onboardingSaveUserError": MessageLookupByLibrary.simpleMessage(
            "Entrada incorrecta, por favor inténtalo de nuevo"),
        "onboardingWeightExampleHintKg":
            MessageLookupByLibrary.simpleMessage("ej. 60"),
        "onboardingWeightExampleHintLbs":
            MessageLookupByLibrary.simpleMessage("ej. 132"),
        "onboardingWeightQuestionSubtitle":
            MessageLookupByLibrary.simpleMessage("¿Cuál es tu peso actual?"),
        "onboardingWelcomeLabel":
            MessageLookupByLibrary.simpleMessage("Bienvenido a"),
        "onboardingWrongHeightLabel": MessageLookupByLibrary.simpleMessage(
            "Introduce una altura correcta"),
        "onboardingWrongWeightLabel":
            MessageLookupByLibrary.simpleMessage("Introduce un peso correcto"),
        "onboardingYourGoalLabel":
            MessageLookupByLibrary.simpleMessage("Tu objetivo de calorías:"),
        "onboardingYourMacrosGoalLabel": MessageLookupByLibrary.simpleMessage(
            "Tus objetivos de macronutrientes:"),
        "ozUnit": MessageLookupByLibrary.simpleMessage("oz"),
        "paAmericanFootballGeneral":
            MessageLookupByLibrary.simpleMessage("fútbol americano"),
        "paAmericanFootballGeneralDesc":
            MessageLookupByLibrary.simpleMessage("toque, bandera, general"),
        "paArcheryGeneral":
            MessageLookupByLibrary.simpleMessage("tiro con arco"),
        "paArcheryGeneralDesc": MessageLookupByLibrary.simpleMessage("no caza"),
        "paAutoRacing": MessageLookupByLibrary.simpleMessage("automovilismo"),
        "paAutoRacingDesc": MessageLookupByLibrary.simpleMessage("monoplaza"),
        "paBackpackingGeneral":
            MessageLookupByLibrary.simpleMessage("mochilero"),
        "paBackpackingGeneralDesc":
            MessageLookupByLibrary.simpleMessage("general"),
        "paBadmintonGeneral": MessageLookupByLibrary.simpleMessage("bádminton"),
        "paBadmintonGeneralDesc": MessageLookupByLibrary.simpleMessage(
            "individual y dobles social, general"),
        "paBasketballGeneral":
            MessageLookupByLibrary.simpleMessage("baloncesto"),
        "paBasketballGeneralDesc":
            MessageLookupByLibrary.simpleMessage("general"),
        "paBicyclingGeneral": MessageLookupByLibrary.simpleMessage("ciclismo"),
        "paBicyclingGeneralDesc":
            MessageLookupByLibrary.simpleMessage("general"),
        "paBicyclingMountainGeneral":
            MessageLookupByLibrary.simpleMessage("ciclismo de montaña"),
        "paBicyclingMountainGeneralDesc":
            MessageLookupByLibrary.simpleMessage("general"),
        "paBicyclingStationaryGeneral":
            MessageLookupByLibrary.simpleMessage("bicicleta estática"),
        "paBicyclingStationaryGeneralDesc":
            MessageLookupByLibrary.simpleMessage("general"),
        "paBilliardsGeneral": MessageLookupByLibrary.simpleMessage("billar"),
        "paBilliardsGeneralDesc":
            MessageLookupByLibrary.simpleMessage("general"),
        "paBowlingGeneral": MessageLookupByLibrary.simpleMessage("bolos"),
        "paBowlingGeneralDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paBoxingBag": MessageLookupByLibrary.simpleMessage("boxeo"),
        "paBoxingBagDesc":
            MessageLookupByLibrary.simpleMessage("saco de boxeo"),
        "paBoxingGeneral": MessageLookupByLibrary.simpleMessage("boxeo"),
        "paBoxingGeneralDesc":
            MessageLookupByLibrary.simpleMessage("en el ring, general"),
        "paBroomball": MessageLookupByLibrary.simpleMessage("broomball"),
        "paBroomballDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paCalisthenicsGeneral":
            MessageLookupByLibrary.simpleMessage("calistenia"),
        "paCalisthenicsGeneralDesc": MessageLookupByLibrary.simpleMessage(
            "esfuerzo ligero o moderado, general (ej. ejercicios de espalda)"),
        "paCanoeingGeneral": MessageLookupByLibrary.simpleMessage("piragüismo"),
        "paCanoeingGeneralDesc":
            MessageLookupByLibrary.simpleMessage("remo, por placer, general"),
        "paCatch": MessageLookupByLibrary.simpleMessage("fútbol o béisbol"),
        "paCatchDesc":
            MessageLookupByLibrary.simpleMessage("jugar a atrapar la pelota"),
        "paCheerleading": MessageLookupByLibrary.simpleMessage("animación"),
        "paCheerleadingDesc": MessageLookupByLibrary.simpleMessage(
            "movimientos de gimnasia, competitivo"),
        "paChildrenGame":
            MessageLookupByLibrary.simpleMessage("juegos infantiles"),
        "paChildrenGameDesc": MessageLookupByLibrary.simpleMessage(
            "(ej. rayuela, dodgeball, juegos de patio, t-ball, canicas), esfuerzo moderado"),
        "paClimbingHillsNoLoadGeneral":
            MessageLookupByLibrary.simpleMessage("subir colinas, sin carga"),
        "paClimbingHillsNoLoadGeneralDesc":
            MessageLookupByLibrary.simpleMessage("sin carga"),
        "paCricket": MessageLookupByLibrary.simpleMessage("críquet"),
        "paCricketDesc":
            MessageLookupByLibrary.simpleMessage("bateo, lanzamiento, fildeo"),
        "paCroquet": MessageLookupByLibrary.simpleMessage("cróquet"),
        "paCroquetDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paCurling": MessageLookupByLibrary.simpleMessage("curling"),
        "paCurlingDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paDancingAerobicGeneral":
            MessageLookupByLibrary.simpleMessage("aeróbico"),
        "paDancingAerobicGeneralDesc":
            MessageLookupByLibrary.simpleMessage("general"),
        "paDancingGeneral":
            MessageLookupByLibrary.simpleMessage("baile general"),
        "paDancingGeneralDesc": MessageLookupByLibrary.simpleMessage(
            "ej. disco, folk, danza irlandesa, baile en línea, polca, contra, country"),
        "paDartsWall": MessageLookupByLibrary.simpleMessage("dardos"),
        "paDartsWallDesc":
            MessageLookupByLibrary.simpleMessage("pared o césped"),
        "paDivingGeneral": MessageLookupByLibrary.simpleMessage("buceo"),
        "paDivingGeneralDesc": MessageLookupByLibrary.simpleMessage(
            "buceo a pulmón, con escafandra, general"),
        "paDivingSpringboardPlatform":
            MessageLookupByLibrary.simpleMessage("saltos"),
        "paDivingSpringboardPlatformDesc":
            MessageLookupByLibrary.simpleMessage("trampolín o plataforma"),
        "paFencing": MessageLookupByLibrary.simpleMessage("esgrima"),
        "paFencingDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paFrisbee": MessageLookupByLibrary.simpleMessage("jugar al frisbee"),
        "paFrisbeeDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paGeneralDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paGolfGeneral": MessageLookupByLibrary.simpleMessage("golf"),
        "paGolfGeneralDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paGymnasticsGeneral": MessageLookupByLibrary.simpleMessage("gimnasia"),
        "paGymnasticsGeneralDesc":
            MessageLookupByLibrary.simpleMessage("general"),
        "paHackySack": MessageLookupByLibrary.simpleMessage("hacky sack"),
        "paHackySackDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paHandballGeneral": MessageLookupByLibrary.simpleMessage("balonmano"),
        "paHandballGeneralDesc":
            MessageLookupByLibrary.simpleMessage("general"),
        "paHangGliding": MessageLookupByLibrary.simpleMessage("ala delta"),
        "paHangGlidingDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paHeadingBicycling": MessageLookupByLibrary.simpleMessage("ciclismo"),
        "paHeadingConditionalExercise": MessageLookupByLibrary.simpleMessage(
            "ejercicio de acondicionamiento"),
        "paHeadingDancing": MessageLookupByLibrary.simpleMessage("baile"),
        "paHeadingRunning": MessageLookupByLibrary.simpleMessage("correr"),
        "paHeadingSports": MessageLookupByLibrary.simpleMessage("deportes"),
        "paHeadingWalking": MessageLookupByLibrary.simpleMessage("caminar"),
        "paHeadingWaterActivities":
            MessageLookupByLibrary.simpleMessage("actividades acuáticas"),
        "paHeadingWinterActivities":
            MessageLookupByLibrary.simpleMessage("actividades de invierno"),
        "paHikingCrossCountry":
            MessageLookupByLibrary.simpleMessage("senderismo"),
        "paHikingCrossCountryDesc":
            MessageLookupByLibrary.simpleMessage("campo a través"),
        "paHockeyField":
            MessageLookupByLibrary.simpleMessage("hockey sobre césped"),
        "paHockeyFieldDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paHorseRidingGeneral":
            MessageLookupByLibrary.simpleMessage("equitación"),
        "paHorseRidingGeneralDesc":
            MessageLookupByLibrary.simpleMessage("general"),
        "paIceHockeyGeneral":
            MessageLookupByLibrary.simpleMessage("hockey sobre hielo"),
        "paIceHockeyGeneralDesc":
            MessageLookupByLibrary.simpleMessage("general"),
        "paIceSkatingGeneral":
            MessageLookupByLibrary.simpleMessage("patinaje sobre hielo"),
        "paIceSkatingGeneralDesc":
            MessageLookupByLibrary.simpleMessage("general"),
        "paJaiAlai": MessageLookupByLibrary.simpleMessage("jai alai"),
        "paJaiAlaiDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paJoggingGeneral": MessageLookupByLibrary.simpleMessage("trote"),
        "paJoggingGeneralDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paJuggling": MessageLookupByLibrary.simpleMessage("malabares"),
        "paJugglingDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paKayakingModerate": MessageLookupByLibrary.simpleMessage("kayak"),
        "paKayakingModerateDesc":
            MessageLookupByLibrary.simpleMessage("esfuerzo moderado"),
        "paKickball": MessageLookupByLibrary.simpleMessage("kickball"),
        "paKickballDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paLacrosse": MessageLookupByLibrary.simpleMessage("lacrosse"),
        "paLacrosseDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paLawnBowling":
            MessageLookupByLibrary.simpleMessage("bolos sobre césped"),
        "paLawnBowlingDesc":
            MessageLookupByLibrary.simpleMessage("bochas, al aire libre"),
        "paMartialArtsModerate":
            MessageLookupByLibrary.simpleMessage("artes marciales"),
        "paMartialArtsModerateDesc": MessageLookupByLibrary.simpleMessage(
            "diferentes tipos, ritmo moderado (ej. judo, jujitsu, karate, kick boxing, tae kwan do, tai-bo, Muay Thai)"),
        "paMartialArtsSlower":
            MessageLookupByLibrary.simpleMessage("artes marciales"),
        "paMartialArtsSlowerDesc": MessageLookupByLibrary.simpleMessage(
            "diferentes tipos, ritmo lento, principiantes, práctica"),
        "paMotoCross": MessageLookupByLibrary.simpleMessage("motocross"),
        "paMotoCrossDesc": MessageLookupByLibrary.simpleMessage(
            "deportes de motor off-road, quad, general"),
        "paMountainClimbing": MessageLookupByLibrary.simpleMessage("escalada"),
        "paMountainClimbingDesc":
            MessageLookupByLibrary.simpleMessage("escalada en roca o montaña"),
        "paOrienteering": MessageLookupByLibrary.simpleMessage("orientación"),
        "paOrienteeringDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paPaddleBoarding": MessageLookupByLibrary.simpleMessage("paddle surf"),
        "paPaddleBoardingDesc": MessageLookupByLibrary.simpleMessage("de pie"),
        "paPaddleBoat": MessageLookupByLibrary.simpleMessage("pedaló"),
        "paPaddleBoatDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paPaddleball": MessageLookupByLibrary.simpleMessage("pádel"),
        "paPaddleballDesc":
            MessageLookupByLibrary.simpleMessage("informal, general"),
        "paPoloHorse": MessageLookupByLibrary.simpleMessage("polo"),
        "paPoloHorseDesc": MessageLookupByLibrary.simpleMessage("a caballo"),
        "paRacquetball": MessageLookupByLibrary.simpleMessage("ráquetbol"),
        "paRacquetballDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paResistanceTraining": MessageLookupByLibrary.simpleMessage(
            "entrenamiento de resistencia"),
        "paResistanceTrainingDesc": MessageLookupByLibrary.simpleMessage(
            "levantamiento de pesas, pesas libres, nautilus o universal"),
        "paRodeoSportGeneralModerate":
            MessageLookupByLibrary.simpleMessage("deportes de rodeo"),
        "paRodeoSportGeneralModerateDesc":
            MessageLookupByLibrary.simpleMessage("general, esfuerzo moderado"),
        "paRollerbladingLight":
            MessageLookupByLibrary.simpleMessage("patinaje en línea"),
        "paRollerbladingLightDesc":
            MessageLookupByLibrary.simpleMessage("patinaje en línea"),
        "paRopeJumpingGeneral":
            MessageLookupByLibrary.simpleMessage("saltar a la cuerda"),
        "paRopeJumpingGeneralDesc": MessageLookupByLibrary.simpleMessage(
            "ritmo moderado, 100-120 saltos/min, general"),
        "paRopeSkippingGeneral":
            MessageLookupByLibrary.simpleMessage("saltar a la cuerda"),
        "paRopeSkippingGeneralDesc":
            MessageLookupByLibrary.simpleMessage("general"),
        "paRugbyCompetitive": MessageLookupByLibrary.simpleMessage("rugby"),
        "paRugbyCompetitiveDesc":
            MessageLookupByLibrary.simpleMessage("unión, equipo, competitivo"),
        "paRugbyNonCompetitive": MessageLookupByLibrary.simpleMessage("rugby"),
        "paRugbyNonCompetitiveDesc":
            MessageLookupByLibrary.simpleMessage("toque, no competitivo"),
        "paRunningGeneral": MessageLookupByLibrary.simpleMessage("correr"),
        "paRunningGeneralDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paSailingGeneral": MessageLookupByLibrary.simpleMessage("vela"),
        "paSailingGeneralDesc": MessageLookupByLibrary.simpleMessage(
            "navegación a vela y tabla, windsurf, navegación sobre hielo, general"),
        "paShuffleboard": MessageLookupByLibrary.simpleMessage("tejo"),
        "paShuffleboardDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paSkateboardingGeneral":
            MessageLookupByLibrary.simpleMessage("skateboarding"),
        "paSkateboardingGeneralDesc":
            MessageLookupByLibrary.simpleMessage("general, esfuerzo moderado"),
        "paSkatingRoller":
            MessageLookupByLibrary.simpleMessage("patinaje sobre ruedas"),
        "paSkatingRollerDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paSkiingGeneral": MessageLookupByLibrary.simpleMessage("esquí"),
        "paSkiingGeneralDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paSkiingWaterWakeboarding":
            MessageLookupByLibrary.simpleMessage("esquí acuático"),
        "paSkiingWaterWakeboardingDesc":
            MessageLookupByLibrary.simpleMessage("esquí acuático o wakeboard"),
        "paSkydiving": MessageLookupByLibrary.simpleMessage("paracaidismo"),
        "paSkydivingDesc": MessageLookupByLibrary.simpleMessage(
            "paracaidismo, salto base, puenting"),
        "paSnorkeling": MessageLookupByLibrary.simpleMessage("snorkel"),
        "paSnorkelingDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paSnowShovingModerate":
            MessageLookupByLibrary.simpleMessage("quitar nieve"),
        "paSnowShovingModerateDesc":
            MessageLookupByLibrary.simpleMessage("a mano, esfuerzo moderado"),
        "paSoccerGeneral": MessageLookupByLibrary.simpleMessage("fútbol"),
        "paSoccerGeneralDesc":
            MessageLookupByLibrary.simpleMessage("informal, general"),
        "paSoftballBaseballGeneral":
            MessageLookupByLibrary.simpleMessage("softball / béisbol"),
        "paSoftballBaseballGeneralDesc": MessageLookupByLibrary.simpleMessage(
            "lanzamiento rápido o lento, general"),
        "paSquashGeneral": MessageLookupByLibrary.simpleMessage("squash"),
        "paSquashGeneralDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paSurfing": MessageLookupByLibrary.simpleMessage("surf"),
        "paSurfingDesc":
            MessageLookupByLibrary.simpleMessage("body o tabla, general"),
        "paSwimmingGeneral": MessageLookupByLibrary.simpleMessage("natación"),
        "paSwimmingGeneralDesc": MessageLookupByLibrary.simpleMessage(
            "mantenerse a flote, esfuerzo moderado, general"),
        "paTableTennisGeneral":
            MessageLookupByLibrary.simpleMessage("tenis de mesa"),
        "paTableTennisGeneralDesc":
            MessageLookupByLibrary.simpleMessage("tenis de mesa, ping-pong"),
        "paTaiChiQiGongGeneral":
            MessageLookupByLibrary.simpleMessage("tai chi, qi gong"),
        "paTaiChiQiGongGeneralDesc":
            MessageLookupByLibrary.simpleMessage("general"),
        "paTennisGeneral": MessageLookupByLibrary.simpleMessage("tenis"),
        "paTennisGeneralDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paTrackField": MessageLookupByLibrary.simpleMessage("atletismo"),
        "paTrackField1Desc": MessageLookupByLibrary.simpleMessage(
            "(ej. lanzamiento de peso, disco, martillo)"),
        "paTrackField2Desc": MessageLookupByLibrary.simpleMessage(
            "(ej. salto de altura, longitud, triple salto, jabalina, pértiga)"),
        "paTrackField3Desc":
            MessageLookupByLibrary.simpleMessage("(ej. obstáculos, vallas)"),
        "paTrampolineLight": MessageLookupByLibrary.simpleMessage("trampolín"),
        "paTrampolineLightDesc":
            MessageLookupByLibrary.simpleMessage("recreativo"),
        "paUnicyclingGeneral":
            MessageLookupByLibrary.simpleMessage("monociclismo"),
        "paUnicyclingGeneralDesc":
            MessageLookupByLibrary.simpleMessage("general"),
        "paVolleyballGeneral": MessageLookupByLibrary.simpleMessage("voleibol"),
        "paVolleyballGeneralDesc": MessageLookupByLibrary.simpleMessage(
            "no competitivo, equipo de 6-9 miembros, general"),
        "paWalkingForPleasure": MessageLookupByLibrary.simpleMessage("caminar"),
        "paWalkingForPleasureDesc":
            MessageLookupByLibrary.simpleMessage("por placer"),
        "paWalkingTheDog":
            MessageLookupByLibrary.simpleMessage("pasear al perro"),
        "paWalkingTheDogDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paWallyball": MessageLookupByLibrary.simpleMessage("wallyball"),
        "paWallyballDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paWaterAerobics":
            MessageLookupByLibrary.simpleMessage("ejercicio acuático"),
        "paWaterAerobicsDesc": MessageLookupByLibrary.simpleMessage(
            "aeróbic acuático, calistenia acuática"),
        "paWaterPolo": MessageLookupByLibrary.simpleMessage("waterpolo"),
        "paWaterPoloDesc": MessageLookupByLibrary.simpleMessage("general"),
        "paWaterVolleyball":
            MessageLookupByLibrary.simpleMessage("vóley acuático"),
        "paWaterVolleyballDesc":
            MessageLookupByLibrary.simpleMessage("general"),
        "paWateraerobicsCalisthenics":
            MessageLookupByLibrary.simpleMessage("aeróbic acuático"),
        "paWateraerobicsCalisthenicsDesc": MessageLookupByLibrary.simpleMessage(
            "aeróbic acuático, calistenia acuática"),
        "paWrestling": MessageLookupByLibrary.simpleMessage("lucha"),
        "paWrestlingDesc": MessageLookupByLibrary.simpleMessage("general"),
        "palActiveDescriptionLabel": MessageLookupByLibrary.simpleMessage(
            "Mayormente de pie o caminando en el trabajo y actividades activas de tiempo libre"),
        "palActiveLabel": MessageLookupByLibrary.simpleMessage("Activo"),
        "palLowActiveDescriptionLabel": MessageLookupByLibrary.simpleMessage(
            "ej. sentado o de pie en el trabajo y actividades ligeras de tiempo libre"),
        "palLowLActiveLabel":
            MessageLookupByLibrary.simpleMessage("Poco activo"),
        "palSedentaryDescriptionLabel": MessageLookupByLibrary.simpleMessage(
            "ej. trabajo de oficina y actividades de tiempo libre mayormente sentado"),
        "palSedentaryLabel": MessageLookupByLibrary.simpleMessage("Sedentario"),
        "palVeryActiveDescriptionLabel": MessageLookupByLibrary.simpleMessage(
            "Mayormente caminando, corriendo o cargando peso en el trabajo y actividades activas de tiempo libre"),
        "palVeryActiveLabel":
            MessageLookupByLibrary.simpleMessage("Muy activo"),
        "per100gmlLabel": MessageLookupByLibrary.simpleMessage("Por 100g/ml"),
        "perServingLabel": MessageLookupByLibrary.simpleMessage("Por ración"),
        "privacyPolicyLabel":
            MessageLookupByLibrary.simpleMessage("Política de privacidad"),
        "profileBodyData":
            MessageLookupByLibrary.simpleMessage("Datos corporales"),
        "profileBodyDataSubtitle": MessageLookupByLibrary.simpleMessage(
            "Peso, altura, edad y sexo para que el cálculo base siga fino."),
        "profileBodyProgress":
            MessageLookupByLibrary.simpleMessage("Progreso corporal"),
        "profileBodyProgressSubtitle": MessageLookupByLibrary.simpleMessage(
            "Tendencia de peso, media 7d y cintura"),
        "profileCalculationBase": MessageLookupByLibrary.simpleMessage(
            "Base de cálculo para objetivos, seguimiento y sugerencias."),
        "profileChangePhoto":
            MessageLookupByLibrary.simpleMessage("Cambiar foto"),
        "profileCurrentPhase": m24,
        "profileFocusCardio": MessageLookupByLibrary.simpleMessage(
            "Hoy el reparto busca energía suficiente sin meter hidrato de más."),
        "profileFocusLowerBody": MessageLookupByLibrary.simpleMessage(
            "Hoy el reparto sube hidratos para sostener una sesión dura de pierna."),
        "profileFocusRest": MessageLookupByLibrary.simpleMessage(
            "Hoy el reparto recorta hidrato y mantiene proteína alta para recuperar."),
        "profileFocusUpperBody": MessageLookupByLibrary.simpleMessage(
            "Hoy el reparto mantiene buen combustible y recuperación limpia para torso."),
        "profileGenderLabel": MessageLookupByLibrary.simpleMessage("Sexo"),
        "profileGoalAndStrategy":
            MessageLookupByLibrary.simpleMessage("Objetivo y estrategia"),
        "profileGoalAndStrategySubtitle": MessageLookupByLibrary.simpleMessage(
            "Lo que cambies aquí impacta en calorías, macros y ajustes del día."),
        "profileGoalGain": MessageLookupByLibrary.simpleMessage("Volumen"),
        "profileGoalGainDesc": MessageLookupByLibrary.simpleMessage(
            "Superávit medido para empujar entreno, recuperación y progresión."),
        "profileGoalLose": MessageLookupByLibrary.simpleMessage("Definición"),
        "profileGoalLoseDesc": MessageLookupByLibrary.simpleMessage(
            "Déficit corto y controlado para bajar grasa sin comprometer rendimiento ni masa muscular."),
        "profileGoalMaintain": MessageLookupByLibrary.simpleMessage("Recomp."),
        "profileGoalMaintainDesc": MessageLookupByLibrary.simpleMessage(
            "Mantén el peso estable mientras priorizas fuerza, rendimiento y adherencia."),
        "profileLabel": MessageLookupByLibrary.simpleMessage("Perfil"),
        "profilePhotoOptions":
            MessageLookupByLibrary.simpleMessage("Opciones de foto"),
        "profileRemovePhoto":
            MessageLookupByLibrary.simpleMessage("Eliminar foto"),
        "profileSportsProfile":
            MessageLookupByLibrary.simpleMessage("Perfil deportivo"),
        "profileYourProfile": MessageLookupByLibrary.simpleMessage("Tu perfil"),
        "profileYourProfileSubtitle": MessageLookupByLibrary.simpleMessage(
            "Ajusta tus datos base para que calorías, macros y recomendaciones sean coherentes."),
        "proteinLabel": MessageLookupByLibrary.simpleMessage("proteínas"),
        "quantityLabel": MessageLookupByLibrary.simpleMessage("Cantidad"),
        "readLabel": MessageLookupByLibrary.simpleMessage(
            "He leído y acepto la política de privacidad."),
        "recentlyAddedLabel": MessageLookupByLibrary.simpleMessage("Recientes"),
        "recipeLibraryAddedSnackbar": m25,
        "recipeLibraryEmpty": MessageLookupByLibrary.simpleMessage(
            "Aun no hay comidas guardadas.\nGuarda comidas como recetas para reutilizarlas."),
        "recipeLibraryFavorite":
            MessageLookupByLibrary.simpleMessage("Favorita"),
        "recipeLibraryIngredientsCount": m26,
        "recipeLibraryMarkFavorite":
            MessageLookupByLibrary.simpleMessage("Marcar favorita"),
        "recipeLibraryRemoveFavorite":
            MessageLookupByLibrary.simpleMessage("Quitar favorita"),
        "recipeLibrarySearchHint":
            MessageLookupByLibrary.simpleMessage("Buscar comidas guardadas"),
        "recipeLibraryServingsCount": m27,
        "recipeLibraryTitle":
            MessageLookupByLibrary.simpleMessage("Comidas guardadas"),
        "recipeSavedSnackbar":
            MessageLookupByLibrary.simpleMessage("Receta guardada"),
        "reportErrorDialogText": MessageLookupByLibrary.simpleMessage(
            "¿Quieres reportar un error al desarrollador?"),
        "retryLabel": MessageLookupByLibrary.simpleMessage("Reintentar"),
        "saturatedFatLabel":
            MessageLookupByLibrary.simpleMessage("grasas saturadas"),
        "scanProductLabel":
            MessageLookupByLibrary.simpleMessage("Escanear producto"),
        "searchDefaultLabel": MessageLookupByLibrary.simpleMessage(
            "Por favor, introduce una palabra de búsqueda"),
        "searchFoodPage": MessageLookupByLibrary.simpleMessage("Comida"),
        "searchLabel": MessageLookupByLibrary.simpleMessage("Buscar"),
        "searchProductsPage": MessageLookupByLibrary.simpleMessage("Productos"),
        "searchResultsLabel":
            MessageLookupByLibrary.simpleMessage("Resultados de búsqueda"),
        "selectGenderDialogLabel":
            MessageLookupByLibrary.simpleMessage("Selecciona género"),
        "selectHeightDialogLabel":
            MessageLookupByLibrary.simpleMessage("Selecciona altura"),
        "selectPalCategoryLabel": MessageLookupByLibrary.simpleMessage(
            "Selecciona el nivel de actividad"),
        "selectWeightDialogLabel":
            MessageLookupByLibrary.simpleMessage("Selecciona peso"),
        "sendAnonymousUserData": MessageLookupByLibrary.simpleMessage(
            "Enviar datos de uso anónimos"),
        "servingLabel": MessageLookupByLibrary.simpleMessage("Ración"),
        "servingSizeLabelImperial":
            MessageLookupByLibrary.simpleMessage("Tamaño ración (oz/fl oz)"),
        "servingSizeLabelMetric":
            MessageLookupByLibrary.simpleMessage("Tamaño ración (g/ml)"),
        "servingsLabel": MessageLookupByLibrary.simpleMessage("Raciones"),
        "settingAboutLabel": MessageLookupByLibrary.simpleMessage("Acerca de"),
        "settingFeedbackLabel":
            MessageLookupByLibrary.simpleMessage("Feedback"),
        "settingsAiCallsPhoto": m28,
        "settingsAiCallsText": m29,
        "settingsAiCallsTotal": m30,
        "settingsAiCostDescription": MessageLookupByLibrary.simpleMessage(
            "Basado en uso real de tokens por petición en backend."),
        "settingsAiCostLabel":
            MessageLookupByLibrary.simpleMessage("Coste de IA"),
        "settingsAiCostMonth": m31,
        "settingsAiCostToday": m32,
        "settingsAiCostTotal": m33,
        "settingsCalculationsLabel":
            MessageLookupByLibrary.simpleMessage("Cálculos"),
        "settingsDisclaimerLabel":
            MessageLookupByLibrary.simpleMessage("Descargo de responsabilidad"),
        "settingsDistanceLabel":
            MessageLookupByLibrary.simpleMessage("Distancia"),
        "settingsImperialLabel":
            MessageLookupByLibrary.simpleMessage("Imperial (lbs, ft, oz)"),
        "settingsLabel": MessageLookupByLibrary.simpleMessage("Ajustes"),
        "settingsLanguageEnglish":
            MessageLookupByLibrary.simpleMessage("Inglés"),
        "settingsLanguageLabel": MessageLookupByLibrary.simpleMessage("Idioma"),
        "settingsLanguageSpanish":
            MessageLookupByLibrary.simpleMessage("Español"),
        "settingsLanguageSystemDefaultLabel":
            MessageLookupByLibrary.simpleMessage("Predeterminado del sistema"),
        "settingsLicensesLabel":
            MessageLookupByLibrary.simpleMessage("Licencias"),
        "settingsMassLabel": MessageLookupByLibrary.simpleMessage("Masa"),
        "settingsMetricLabel":
            MessageLookupByLibrary.simpleMessage("Métrico (kg, cm, ml)"),
        "settingsPrivacySettings":
            MessageLookupByLibrary.simpleMessage("Ajustes de privacidad"),
        "settingsReportErrorLabel":
            MessageLookupByLibrary.simpleMessage("Reportar error"),
        "settingsResetLabel": MessageLookupByLibrary.simpleMessage("Reiniciar"),
        "settingsSelectLanguageTitle":
            MessageLookupByLibrary.simpleMessage("Seleccionar idioma"),
        "settingsSourceCodeLabel":
            MessageLookupByLibrary.simpleMessage("Código fuente"),
        "settingsSystemLabel": MessageLookupByLibrary.simpleMessage("Sistema"),
        "settingsThemeDarkLabel":
            MessageLookupByLibrary.simpleMessage("Oscuro"),
        "settingsThemeLabel": MessageLookupByLibrary.simpleMessage("Tema"),
        "settingsThemeLightLabel":
            MessageLookupByLibrary.simpleMessage("Claro"),
        "settingsThemeSystemDefaultLabel":
            MessageLookupByLibrary.simpleMessage("Predeterminado del sistema"),
        "settingsUnitsLabel": MessageLookupByLibrary.simpleMessage("Unidades"),
        "settingsVolumeLabel": MessageLookupByLibrary.simpleMessage("Volumen"),
        "snackExample": MessageLookupByLibrary.simpleMessage(
            "ej. manzana, helado, chocolate..."),
        "snackLabel": MessageLookupByLibrary.simpleMessage("Snack"),
        "sugarLabel": MessageLookupByLibrary.simpleMessage("azúcar"),
        "suppliedLabel": MessageLookupByLibrary.simpleMessage("ingerido"),
        "todayLabel": MessageLookupByLibrary.simpleMessage("Hoy"),
        "unitLabel": MessageLookupByLibrary.simpleMessage("Unidad"),
        "weeklyInsightsAdherence":
            MessageLookupByLibrary.simpleMessage("Adherencia"),
        "weeklyInsightsAdjustmentSuccess": m34,
        "weeklyInsightsApplyAdjustment": m35,
        "weeklyInsightsAverages":
            MessageLookupByLibrary.simpleMessage("Promedios semanales"),
        "weeklyInsightsCheckup":
            MessageLookupByLibrary.simpleMessage("Chequeo semanal inteligente"),
        "weeklyInsightsCoverage":
            MessageLookupByLibrary.simpleMessage("Cobertura"),
        "weeklyInsightsError": MessageLookupByLibrary.simpleMessage(
            "No se pudo cargar el resumen semanal."),
        "weeklyInsightsNoFrequentMeals": MessageLookupByLibrary.simpleMessage(
            "No se detectaron comidas repetidas esta semana."),
        "weeklyInsightsOvereatingPattern":
            MessageLookupByLibrary.simpleMessage("Patrón de sobreingesta"),
        "weeklyInsightsProteinConsistency":
            MessageLookupByLibrary.simpleMessage("Consistencia de proteína"),
        "weeklyInsightsRegisteredDays": m36,
        "weeklyInsightsSummary":
            MessageLookupByLibrary.simpleMessage("Resumen"),
        "weeklyInsightsTitle":
            MessageLookupByLibrary.simpleMessage("Resumen semanal"),
        "weeklyInsightsTopMeals":
            MessageLookupByLibrary.simpleMessage("Comidas más frecuentes"),
        "weeklyInsightsTrackedDays": m37,
        "weeklyInsightsTrend": m38,
        "weightLabel": MessageLookupByLibrary.simpleMessage("Peso"),
        "yearsLabel": m39
      };
}
