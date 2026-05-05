import { Box, Typography } from "@mui/material";
import { getStyles } from "../utils/styles";
import { useMemo, useRef } from "react";
import { Bar, BarChart, CartesianGrid, Cell, Legend, Pie, PieChart, ResponsiveContainer, Tooltip, XAxis, YAxis } from "recharts";
import { FINANCE_COLORS } from "../utils/constants";
import { formatAmount, formatMonth, isFutureMonth } from "../utils/formatters";
import InsightsOutlinedIcon from "@mui/icons-material/InsightsOutlined";
import PaidOutlinedIcon from "@mui/icons-material/PaidOutlined";

export const FinanceTooltip = ({ active, payload, label, isMonthly = false }) => {
  if (!active || !payload?.length) return null;

  return (
    <Box
      sx={{
        backgroundColor: "rgba(15, 23, 32, 0.96)",
        color: "#f8fafc",
        border: "1px solid rgba(148, 163, 184, 0.18)",
        borderRadius: "14px",
        p: "10px 12px",
        minWidth: 160,
        boxShadow: "0 16px 28px rgba(2, 6, 23, 0.28)",
      }}
    >
      <Typography sx={{ fontSize: "0.8rem", fontWeight: 700, mb: 0.75 }}>{isMonthly ? formatMonth(label) : label}</Typography>
      {payload.map((entry) => (
        <Box key={entry.dataKey || entry.name} display="flex" alignItems="center" justifyContent="space-between" gap="12px" mb={0.5}>
          <Box display="flex" alignItems="center" gap="8px">
            <Box sx={{ width: 8, height: 8, borderRadius: "999px", backgroundColor: entry.color || entry.fill }} />
            <Typography sx={{ fontSize: "0.78rem", color: "rgba(248,250,252,0.76)" }}>{entry.name}</Typography>
          </Box>
          <Typography sx={{ fontSize: "0.82rem", fontWeight: 700 }}>{formatAmount(entry.value)}</Typography>
        </Box>
      ))}
    </Box>
  );
};

export const MonthlyLegend = ({ colors, isDark, payload }) => {
  const styles = getStyles(colors, isDark);

  if (!payload?.length) return null;

  return (
    <Box sx={styles.monthlyLegendRow}>
      {payload.map((entry) => {
        const label = entry.value || entry.dataKey;
        const color = label === "Non payé" ? FINANCE_COLORS.pending : FINANCE_COLORS.paid;

        return (
          <Box key={label} sx={styles.monthlyLegendItem}>
            <Box sx={styles.monthlyLegendMarker(color)} />
            <Typography sx={styles.monthlyLegendText(color)}>{label}</Typography>
          </Box>
        );
      })}
    </Box>
  );
};

export const CollectionProgressCard = ({ colors, isDark, summary }) => {
  const styles = getStyles(colors, isDark);
  const totalExpected = Number(summary?.total_expected || 0);
  const totalPaid = Number(summary?.total_paid || 0);
  const totalPending = Number(summary?.total_pending || 0);
  const paidPercent = totalExpected > 0 ? Math.min((totalPaid / totalExpected) * 100, 100) : 0;
  const pendingPercent = totalExpected > 0 ? Math.min((totalPending / totalExpected) * 100, 100) : 0;

  return (
    <Box sx={[styles.chartCard, styles.progressCard]}>
      <Box sx={styles.progressCardBody}>
        <Box sx={styles.sectionTitleRow}>
          <Box>
            <Typography sx={styles.sectionTitle}>Progression de collecte</Typography>
            <Typography sx={styles.sectionSubtitle}>Lecture rapide du montant collecté par rapport au revenu attendu.</Typography>
          </Box>
          <Box sx={styles.metricBadgeWrap}>
            <InsightsOutlinedIcon sx={{ fontSize: 18, color: colors.greenAccent[400] }} />
          </Box>
        </Box>

        <Box sx={styles.progressTrack}>
          <Box sx={styles.progressPaid(paidPercent)} />
          <Box sx={styles.progressPending(Math.max(0, pendingPercent), paidPercent)} />
        </Box>

        <Box sx={styles.progressLegendRow}>
          <Box sx={styles.progressLegendItem}>
            <Box sx={styles.progressLegendDot(FINANCE_COLORS.paid)} />
            <Typography sx={styles.progressLegendLabel}>Collecté</Typography>
            <Typography sx={styles.progressLegendValue}>{paidPercent.toFixed(1)}%</Typography>
          </Box>
          <Box sx={styles.progressLegendItem}>
            <Box sx={styles.progressLegendDot(FINANCE_COLORS.pending)} />
            <Typography sx={styles.progressLegendLabel}>En attente</Typography>
            <Typography sx={styles.progressLegendValue}>{pendingPercent.toFixed(1)}%</Typography>
          </Box>
        </Box>
      </Box>
    </Box>
  );
};

export const PaymentStatusDonut = ({ colors, isDark, summary }) => {
  const styles = getStyles(colors, isDark);
  const data = [
    { name: "Payé", value: summary?.count_paid || 0, fill: FINANCE_COLORS.paid },
    { name: "Partiel", value: summary?.count_partial || 0, fill: FINANCE_COLORS.partial },
    { name: "En attente", value: summary?.count_pending || 0, fill: FINANCE_COLORS.pending },
  ];

  return (
    <Box sx={styles.chartCard}>
      <Box sx={styles.sectionTitleRow}>
        <Box>
          <Typography sx={styles.sectionTitle}>Distribution des statuts</Typography>
          <Typography sx={styles.sectionSubtitle}>Répartition des dossiers selon leur état de paiement.</Typography>
        </Box>
        <Box sx={styles.metricBadgeWrap}>
          <PaidOutlinedIcon sx={{ fontSize: 18, color: colors.greenAccent[400] }} />
        </Box>
      </Box>

      <Box sx={styles.donutWrap}>
        <ResponsiveContainer width="100%" height="100%">
          <PieChart>
            <Pie data={data} dataKey="value" nameKey="name" cx="50%" cy="50%" innerRadius={76} outerRadius={104} paddingAngle={2} strokeWidth={2}>
              {data.map((entry) => (
                <Cell key={entry.name} fill={entry.fill} stroke={isDark ? "#0f1720" : "#f8fafc"} />
              ))}
            </Pie>
            <Tooltip content={<FinanceTooltip />} />
            <Legend verticalAlign="bottom" iconType="circle" wrapperStyle={{ paddingTop: 12 }} />
          </PieChart>
        </ResponsiveContainer>
        <Box sx={styles.donutCenterLabel}>
          <Typography sx={styles.donutCenterTitle}>Collecté</Typography>
          <Typography sx={styles.donutCenterValue}>{formatAmount(summary?.total_paid || 0)}</Typography>
          <Typography sx={styles.donutCenterCurrency}>TND</Typography>
        </Box>
      </Box>
    </Box>
  );
};

export const MonthlyStatusChart = ({ colors, isDark, data, onMonthClick }) => {
  const styles = getStyles(colors, isDark);
  const chartWrapRef = useRef(null);

  const chartData = useMemo(
    () =>
      (data || []).map((item) => ({
        month: item.month,
        paid: item.paid || 0,
        pending: (item.pending || 0) + (item.partial || 0),
        futurePending: isFutureMonth(item.month) && (item.paid || 0) === 0 && ((item.pending || 0) + (item.partial || 0)) > 0,
      })),
    [data]
  );

  const updateHoveredMonthVisual = (month) => {
    const root = chartWrapRef.current;
    if (!root) return;

    const cells = root.querySelectorAll("[data-month-key]");

    cells.forEach((cell) => {
      const cellMonth = cell.getAttribute("data-month-key");
      const cellType = cell.getAttribute("data-bar-type");
      const isFuture = cell.getAttribute("data-future") === "true";
      const isActive = month && cellMonth === month;

      if (!month) {
        cell.style.opacity = "1";
        cell.style.stroke = isFuture ? "#cbd5e1" : "transparent";
        cell.style.strokeWidth = isFuture ? "1" : "0";
        return;
      }

      cell.style.opacity = isActive ? "1" : cellType === "paid" ? "0.24" : "0.18";

      if (isActive) {
        cell.style.stroke = cellType === "paid"
          ? "rgba(23,133,93,0.68)"
          : isFuture
            ? "#cbd5e1"
            : "rgba(230,132,114,0.68)";
        cell.style.strokeWidth = "1";
      } else {
        cell.style.stroke = isFuture ? "#cbd5e1" : "transparent";
        cell.style.strokeWidth = isFuture ? "1" : "0";
      }
    });
  };

  return (
    <Box sx={styles.chartCard}>
      <Box sx={styles.sectionTitleRow}>
        <Box>
          <Typography sx={styles.sectionTitle}>Statut des paiements mensuels</Typography>
          <Typography sx={styles.sectionSubtitle}>Les mois à venir sont affichés avec un motif neutre plutôt qu'un signal d'alerte.</Typography>
        </Box>
        <Box sx={styles.helperPill}>Cliquer pour ouvrir le détail</Box>
      </Box>

      <Box sx={{ height: 340 }} ref={chartWrapRef} onMouseLeave={() => updateHoveredMonthVisual(null)}>
        {chartData.length > 0 ? (
          <ResponsiveContainer width="100%" height="100%">
            <BarChart
              data={chartData}
              margin={{ top: 20, right: 16, left: 0, bottom: 12 }}
            >
              <defs>
                <pattern id="futurePendingPattern" width="8" height="8" patternUnits="userSpaceOnUse" patternTransform="rotate(45)">
                  <rect width="8" height="8" fill="#eef2f7" />
                  <line x1="0" y1="0" x2="0" y2="8" stroke="#cbd5e1" strokeWidth="4" />
                </pattern>
              </defs>
              <CartesianGrid strokeDasharray="3 3" vertical={false} stroke={isDark ? "rgba(148,163,184,0.14)" : "rgba(148,163,184,0.26)"} />
              <XAxis dataKey="month" tick={{ fill: colors.grey[300], fontSize: 12 }} tickFormatter={formatMonth} axisLine={false} tickLine={false} />
              <YAxis tick={{ fill: colors.grey[300], fontSize: 12 }} axisLine={false} tickLine={false} />
              <Tooltip content={<FinanceTooltip isMonthly />} isAnimationActive={false} />
              <Legend verticalAlign="top" height={36} content={<MonthlyLegend colors={colors} isDark={isDark} />} />
              <Bar dataKey="paid" name="Payé" stackId="payments" radius={[8, 8, 0, 0]} isAnimationActive={false}>
                {chartData.map((entry) => (
                  <Cell
                    key={`paid-${entry.month}`}
                    fill={FINANCE_COLORS.paid}
                    data-month-key={entry.month}
                    data-bar-type="paid"
                    data-future="false"
                    onMouseEnter={() => updateHoveredMonthVisual(entry.month)}
                    onClick={() => onMonthClick(entry)}
                    style={{ cursor: "pointer" }}
                  />
                ))}
              </Bar>
              <Bar dataKey="pending" name="Non payé" stackId="payments" radius={[8, 8, 0, 0]} isAnimationActive={false}>
                {chartData.map((entry) => (
                  <Cell
                    key={`pending-${entry.month}`}
                    fill={entry.futurePending ? "url(#futurePendingPattern)" : FINANCE_COLORS.pending}
                    stroke={entry.futurePending ? "#cbd5e1" : "transparent"}
                    strokeWidth={entry.futurePending ? 1 : 0}
                    data-month-key={entry.month}
                    data-bar-type="pending"
                    data-future={entry.futurePending ? "true" : "false"}
                    onMouseEnter={() => updateHoveredMonthVisual(entry.month)}
                    onClick={() => onMonthClick(entry)}
                    style={{ cursor: "pointer" }}
                  />
                ))}
              </Bar>
            </BarChart>
          </ResponsiveContainer>
        ) : (
          <Box sx={styles.emptyChartState}>
            <Typography sx={styles.emptyChartTitle}>Aucune donnée disponible</Typography>
            <Typography sx={styles.emptyChartText}>Les données mensuelles apparaîtront ici dès qu'elles seront disponibles.</Typography>
          </Box>
        )}
      </Box>
    </Box>
  );
};
