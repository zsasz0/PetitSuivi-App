import { Box, Typography, Checkbox, Button } from "@mui/material";
import { formatCurrency, parseYearMonth, formatMonthLabel, getTargetMonthKey } from "../utils/formatters";
import { getNeutralSurfaceSx, getSecondaryButtonSx } from "../utils/styles";

/**
 * @file components/MonthlySchedulePanel.jsx
 * Renders the monthly payment schedule checkboxes inside the history dialog.
 */
const MonthlySchedulePanel = ({
  historyRow,
  txSubmitting,
  handlePayMonth,
  setReceiptData,
  setIsReceiptDialogOpen,
  setIsConfirmPayOpen,
  setConfirmPayData,
  colors,
  isDark
}) => {
  if (!historyRow) return null;

  const start = parseYearMonth(historyRow.planningStartDate);
  const end = parseYearMonth(historyRow.planningEndDate);
  if (!start || !end) return null;

  let monthsCount = (end.year - start.year) * 12;
  monthsCount -= start.month;
  monthsCount += end.month;
  monthsCount += 1;
  if (monthsCount <= 0 || isNaN(monthsCount)) monthsCount = 10;

  const monthlyAmount = historyRow.totalAmount / monthsCount;

  const monthsList = [];
  let currentYear = start.year;
  let currentMonth = start.month;
  for (let i = 0; i < monthsCount; i++) {
    const mName = formatMonthLabel(currentYear, currentMonth);
    const monthValue = `${currentYear}-${String(currentMonth).padStart(2, "0")}`;
    monthsList.push({
      index: i,
      label: mName.charAt(0).toUpperCase() + mName.slice(1),
      value: monthValue,
      date: new Date(currentYear, currentMonth - 1, 1),
    });

    currentMonth += 1;
    if (currentMonth > 12) {
      currentMonth = 1;
      currentYear += 1;
    }
  }

  const txs = historyRow.transactions || [];
  const transactionsByMonth = new Map();

  txs.forEach((tx) => {
    const targetMonthKey = getTargetMonthKey(tx?.target_month);
    if (!targetMonthKey) return;

    transactionsByMonth.set(targetMonthKey, tx);
  });

  const firstUnpaidIndex = monthsList.findIndex((month) => {
    return !transactionsByMonth.has(month.value) && !transactionsByMonth.has(month.value.slice(5));
  });

  return (
    <Box display="flex" flexDirection="column" gap="8px" mt="15px">
      {historyRow.fraisAmount > 0 && (
        <Box
          display="flex"
          justifyContent="space-between"
          p="10px 15px"
          sx={getNeutralSurfaceSx(isDark)}
          borderRadius="8px"
          alignItems="center"
        >
          <Box>
            <Typography color={isDark ? colors.grey[200] : "#334155"}>
              {historyRow.inscriptionDate}
            </Typography>
            <Typography
              variant="caption"
              color={isDark ? colors.grey[400] : "#64748b"}
              fontWeight="bold"
            >
              Frais Annuel d'Inscription
            </Typography>
          </Box>
          <Box display="flex" alignItems="center" gap="12px">
            <Typography fontWeight="bold" color={isDark ? colors.grey[100] : "#0f172a"}>
              +{formatCurrency(historyRow.fraisAmount)}
            </Typography>
            <Button
              variant="outlined"
              size="small"
              onClick={() => {
                setReceiptData({
                  ...historyRow,
                  transaction: {
                    id: "FRAIS",
                    value: historyRow.fraisAmount,
                    payment_date: historyRow.paymentDate || historyRow.inscriptionDate,
                    date: historyRow.paymentDate || historyRow.inscriptionDate,
                    isFrais: true,
                  },
                });
                setIsReceiptDialogOpen(true);
              }}
              sx={{ ...getSecondaryButtonSx(colors, isDark), py: "2px", minWidth: "auto", fontSize: "11px" }}
            >
              Reçu
            </Button>
          </Box>
        </Box>
      )}

      <Typography
        variant="h6"
        color={isDark ? colors.grey[100] : "#0f172a"}
        mb="5px"
        fontWeight="bold"
      >
        Échéancier Mensuel ({formatCurrency(monthlyAmount)} / mois)
      </Typography>
      {monthsList.map((m, i) => {
        const txForMonth = transactionsByMonth.get(m.value) || transactionsByMonth.get(m.value.slice(5)) || null;
        const isPaid = Boolean(txForMonth);
        const isNext = !isPaid && (firstUnpaidIndex === -1 ? false : i === firstUnpaidIndex);

        return (
          <Box
            key={m.index}
            display="flex"
            justifyContent="space-between"
            p="10px 15px"
            sx={getNeutralSurfaceSx(isDark)}
            borderRadius="8px"
            alignItems="center"
          >
            <Box display="flex" alignItems="center" gap="10px">
              <Checkbox
                checked={isPaid}
                disabled={isPaid || !isNext || txSubmitting}
                onChange={() => {
                  setConfirmPayData({
                    type: "monthly",
                    amount: monthlyAmount,
                    targetMonthValue: m.value,
                    targetMonthLabel: m.label,
                    row: historyRow,
                  });
                  setIsConfirmPayOpen(true);
                }}
                sx={{
                  color: isNext ? (isDark ? colors.grey[300] : "#64748b") : colors.grey[500],
                  "&.Mui-checked": { color: isDark ? colors.grey[100] : "#0f172a" },
                }}
              />
              <Box>
                <Typography
                  color={isDark ? colors.grey[100] : "#0f172a"}
                  fontWeight={isPaid ? "bold" : "normal"}
                >
                  {m.label}
                </Typography>
                {isPaid && txForMonth && (
                  <Typography variant="caption" color={isDark ? colors.grey[400] : "#64748b"}>
                    Payé le {txForMonth.date}
                  </Typography>
                )}
              </Box>
            </Box>

            {isPaid && txForMonth && (
              <Box display="flex" alignItems="center" gap="12px">
                <Typography fontWeight="bold" color={isDark ? colors.grey[100] : "#0f172a"}>
                  +{formatCurrency(txForMonth.value || monthlyAmount)}
                </Typography>
                <Button
                  variant="outlined"
                  size="small"
                  onClick={() => {
                    setReceiptData({
                      ...historyRow,
                      transaction: txForMonth,
                      targetMonthLabel: m.label,
                    });
                    setIsReceiptDialogOpen(true);
                  }}
                  sx={{ ...getSecondaryButtonSx(colors, isDark), py: "2px", minWidth: "auto", fontSize: "11px" }}
                >
                  Reçu
                </Button>
              </Box>
            )}
          </Box>
        );
      })}
    </Box>
  );
};

export default MonthlySchedulePanel;
