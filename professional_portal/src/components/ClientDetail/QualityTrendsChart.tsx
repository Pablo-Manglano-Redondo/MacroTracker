import React, { useMemo } from 'react';
import { Loader2, TrendingUp } from 'lucide-react';
import { useDiaryEntries } from '../../hooks/queries/useDiaryEntries';
import type { ProfessionalClient } from '../../types/database.types';
import { usePortalI18n } from '../../lib/portal-i18n';

interface QualityTrendsChartProps {
  client: ProfessionalClient;
}

interface DiaryEntryForCalc {
  kcal: number | null;
  protein: number | null;
  sugars: number | null;
  fiber: number | null;
  saturated_fat: number | null;
  nova_group: number | null;
  sodium: number | null;
  potassium: number | null;
  calcium: number | null;
  iron: number | null;
  vitamin_c: number | null;
  vitamin_d: number | null;
  amount: number;
  unit: string | null;
}

function calculateFoodQualityScore(entry: DiaryEntryForCalc): number {
  let score = 50.0;
  let knownSignals = 0;

  const energy = entry.kcal;
  const baseKcal = energy && energy > 0 ? energy : 100.0;

  if (entry.nova_group != null) {
    const nova = entry.nova_group;
    if (nova === 1) {
      score += 10.0;
    } else if (nova === 3) {
      score -= 10.0;
    } else if (nova === 4) {
      score -= 25.0;
    }
    knownSignals++;
  }

  let micronutrientsPresent = 0;
  if (entry.sodium != null && entry.sodium > 0) micronutrientsPresent++;
  if (entry.potassium != null && entry.potassium > 0) micronutrientsPresent++;
  if (entry.calcium != null && entry.calcium > 0) micronutrientsPresent++;
  if (entry.iron != null && entry.iron > 0) micronutrientsPresent++;
  if (entry.vitamin_c != null && entry.vitamin_c > 0) micronutrientsPresent++;
  if (entry.vitamin_d != null && entry.vitamin_d > 0) micronutrientsPresent++;

  if (micronutrientsPresent >= 3) {
    const bonus = micronutrientsPresent * 2.0;
    score += bonus;
    knownSignals++;
  }

  if (entry.fiber != null) {
    const fiberDensity = (entry.fiber / baseKcal) * 100.0;
    const normalized = normalizeLinear(fiberDensity, 0.0, 2.0);
    const contribution = normalized * 20.0;
    score += contribution;
    knownSignals++;
  }

  if (entry.protein != null) {
    const proteinDensity = (entry.protein / baseKcal) * 100.0;
    const normalized = normalizeLinear(proteinDensity, 0.0, 8.0);
    const contribution = normalized * 20.0;
    score += contribution;
    knownSignals++;
  }

  if (entry.sugars != null) {
    const sugarKcal = entry.sugars * 4.0;
    const sugarPct = (sugarKcal / baseKcal) * 100.0;
    const normalized = normalizeLinear(sugarPct, 10.0, 25.0);
    const contribution = normalized * -20.0;
    score += contribution;
    knownSignals++;
  }

  let densityKcal: number | null = null;
  if (entry.kcal != null && entry.amount && entry.unit) {
    const unit = entry.unit.toLowerCase();
    if (unit === 'g' || unit === 'ml' || unit === 'g/ml') {
      densityKcal = (entry.kcal / entry.amount) * 100;
    }
  }

  if (densityKcal != null) {
    let contribution = 0.0;
    if (densityKcal < 150.0) {
      contribution = 5.0;
    } else if (densityKcal > 350.0) {
      contribution = -10.0;
    }
    score += contribution;
    knownSignals++;
  }

  if (entry.saturated_fat != null) {
    const satFatKcal = entry.saturated_fat * 9.0;
    const satFatPct = (satFatKcal / baseKcal) * 100.0;
    const normalized = normalizeLinear(satFatPct, 10.0, 20.0);
    const contribution = normalized * -15.0;
    score += contribution;
    knownSignals++;
  }

  const bonusVal = balanceBonus(entry, baseKcal);
  score += bonusVal;

  return Math.min(Math.max(Math.round(score), 0), 100);
}

function normalizeLinear(value: number, start: number, end: number): number {
  if (end <= start) return 0.0;
  const val = (value - start) / (end - start);
  return Math.min(Math.max(val, 0), 1);
}

function balanceBonus(entry: DiaryEntryForCalc, baseKcal: number): number {
  if (entry.protein == null || entry.fiber == null || entry.sugars == null || entry.kcal == null) {
    return 0.0;
  }
  const proteinDensity = (entry.protein / baseKcal) * 100.0;
  const fiberDensity = (entry.fiber / baseKcal) * 100.0;
  const sugarPct = (entry.sugars * 4.0 / baseKcal) * 100.0;

  if (fiberDensity >= 1.0 && proteinDensity >= 4.0 && sugarPct <= 10.0) {
    return 10.0;
  }
  if (fiberDensity >= 0.5 && proteinDensity >= 2.0 && sugarPct <= 15.0) {
    return 4.0;
  }
  return 0.0;
}

export const QualityTrendsChart: React.FC<QualityTrendsChartProps> = ({ client }) => {
  const { locale } = usePortalI18n();
  const { data: entries, isLoading, error } = useDiaryEntries(client.id);

  const isEs = locale?.toLowerCase().startsWith('es');

  const chartData = useMemo(() => {
    if (!entries || entries.length === 0) return [];

    // Group entries by date
    const grouped: Record<string, typeof entries> = {};
    for (const entry of entries) {
      (grouped[entry.entry_date] ??= []).push(entry);
    }

    // Calculate daily quality score
    const dailyScores = Object.entries(grouped).map(([date, dayEntries]) => {
      let weightedScoreSum = 0;
      let totalKcal = 0;
      let scoredMealsCount = 0;

      for (const entry of dayEntries) {
        // Can we score this meal?
        const hasSignal =
          entry.kcal != null ||
          entry.protein != null ||
          entry.sugars != null ||
          entry.fiber != null ||
          entry.saturated_fat != null ||
          entry.nova_group != null;

        if (!hasSignal) continue;

        const score = calculateFoodQualityScore(entry);
        const weight = entry.kcal && entry.kcal > 0 ? entry.kcal : 100.0; // fallback weight
        weightedScoreSum += score * weight;
        totalKcal += weight;
        scoredMealsCount++;
      }

      const finalScore = totalKcal > 0 ? Math.round(weightedScoreSum / totalKcal) : 50;

      return {
        date,
        score: finalScore,
      };
    });

    // Sort chronologically and take last 7 days
    return dailyScores.sort((a, b) => a.date.localeCompare(b.date)).slice(-7);
  }, [entries]);

  const avgScore = useMemo(() => {
    if (chartData.length === 0) return null;
    const sum = chartData.reduce((acc, d) => acc + d.score, 0);
    return Math.round(sum / chartData.length);
  }, [chartData]);

  if (isLoading) {
    return (
      <div className="flex h-36 items-center justify-center rounded-xl bg-muted/5">
        <Loader2 className="h-6 w-6 animate-spin text-primary" />
      </div>
    );
  }

  if (error || !entries || entries.length === 0 || chartData.length < 2) {
    return (
      <div className="portal-meta flex h-36 items-center justify-center rounded-xl bg-muted/5 text-muted-foreground text-center p-4">
        {isEs
          ? 'No hay suficientes datos de diario para calcular la tendencia de calidad'
          : 'Not enough diary data to calculate quality trend'}
      </div>
    );
  }

  const w = 400;
  const h = 140;
  const px = 40;
  const py = 20;

  const minVal = 0;
  const range = 100;

  const points = chartData.map((item, index) => {
    const x = px + (index / (chartData.length - 1)) * (w - px * 2);
    const y = h - py - ((item.score - minVal) / range) * (h - py * 2);
    return { x, y, ...item };
  });

  const pathD = points
    .map((point, idx) => `${idx === 0 ? 'M' : 'L'}${point.x.toFixed(1)},${point.y.toFixed(1)}`)
    .join(' ');

  const lastPoint = points[points.length - 1];
  const firstPoint = points[0];
  if (!lastPoint || !firstPoint) return null;

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <div>
          <h4 className="portal-card-heading text-foreground">
            {isEs ? 'Calidad Nutricional Diaria' : 'Daily Nutritional Quality'}
          </h4>
          <p className="portal-meta mt-1">
            {isEs
              ? `Promedio de 7 días: ${avgScore}/100`
              : `7-day average: ${avgScore}/100`}
          </p>
        </div>
        <div className="flex items-center gap-1.5 text-primary">
          <TrendingUp className="h-4 w-4" />
          <span className="text-xs font-bold">{avgScore}%</span>
        </div>
      </div>

      <svg viewBox={`0 0 ${w} ${h}`} className="h-auto w-full" preserveAspectRatio="xMidYMid meet">
        <defs>
          <linearGradient id="qualityLineGrad" x1="0%" y1="0%" x2="100%" y2="0%">
            <stop offset="0%" stopColor="#f59e0b" />
            <stop offset="50%" stopColor="#10b981" />
            <stop offset="100%" stopColor="#3b82f6" />
          </linearGradient>
          <linearGradient id="qualityAreaGrad" x1="0%" y1="0%" x2="0%" y2="100%">
            <stop offset="0%" stopColor="#10b981" stopOpacity="0.12" />
            <stop offset="100%" stopColor="#10b981" stopOpacity="0" />
          </linearGradient>
        </defs>

        {/* Grid lines */}
        <line x1={px} y1={py} x2={w - px} y2={py} stroke="rgba(255,255,255,0.05)" strokeDasharray="3 3" />
        <line
          x1={px}
          y1={py + (h - py * 2) / 2}
          x2={w - px}
          y2={py + (h - py * 2) / 2}
          stroke="rgba(255,255,255,0.05)"
          strokeDasharray="3 3"
        />
        <line x1={px} y1={h - py} x2={w - px} y2={h - py} stroke="rgba(255,255,255,0.05)" strokeDasharray="3 3" />

        {/* Y Axis Labels */}
        <text x={px - 8} y={py + 3} className="fill-muted-foreground text-[8px] font-semibold" textAnchor="end">
          100
        </text>
        <text x={px - 8} y={py + (h - py * 2) / 2 + 3} className="fill-muted-foreground text-[8px] font-semibold" textAnchor="end">
          50
        </text>
        <text x={px - 8} y={h - py + 3} className="fill-muted-foreground text-[8px] font-semibold" textAnchor="end">
          0
        </text>

        <path
          d={`${pathD} L ${lastPoint.x.toFixed(1)},${(h - py).toFixed(1)} L ${firstPoint.x.toFixed(1)},${(h - py).toFixed(1)} Z`}
          fill="url(#qualityAreaGrad)"
        />

        <path d={pathD} fill="none" stroke="url(#qualityLineGrad)" strokeWidth="2.5" strokeLinecap="round" />

        {points.map((point, idx) => (
          <g key={idx} className="group cursor-pointer">
            <circle cx={point.x} cy={point.y} r="4" className="fill-card stroke-primary" strokeWidth="2" />
            <circle cx={point.x} cy={point.y} r="8" className="fill-transparent transition-colors hover:fill-primary/20" />
          </g>
        ))}

        {points.map((point, idx) => {
          const parts = point.date.split('-');
          const label =
            parts.length === 3
              ? `${parseInt(parts[2] ?? '', 10)}/${parseInt(parts[1] ?? '', 10)}`
              : point.date;
          const shouldShow = idx % 2 === 0 || idx === points.length - 1;
          if (!shouldShow) return null;
          return (
            <text
              key={idx}
              x={point.x}
              y={h - 4}
              className="fill-muted-foreground text-[8px] font-medium"
              textAnchor="middle"
            >
              {idx === points.length - 1 ? (isEs ? 'Hoy' : 'Today') : label}
            </text>
          );
        })}
      </svg>
    </div>
  );
};
