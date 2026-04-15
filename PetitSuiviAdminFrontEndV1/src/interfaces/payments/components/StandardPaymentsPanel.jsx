import { Box, Typography, TextField, FormControl, InputLabel, Select, MenuItem, Button } from "@mui/material";
import { formatCurrency, getMonthsInRange } from "../utils/formatters";
import { getNeutralSurfaceSx, getPrimaryButtonSx, getSecondaryButtonSx } from "../utils/styles";

/**
 * @file components/StandardPaymentsPanel.jsx
 * Renders the standard non-monthly payment form + history inside the dialog.
 */
const StandardPaymentsPanel = ({
  historyRow,
  txAmount,
  setTxAmount,
  txDate,
  setTxDate,
  txTargetMonth,
  setTxTargetMonth,
  submitTransaction,
  txError,
  txSubmitting,
  setReceiptData,
  setIsReceiptDialogOpen,
  colors,
  isDark
}) => {
  if (!historyRow) return null;

  const hasNoTransactions =
    historyRow.transactions.length === 0 &&
    (!historyRow.fraisAmount || historyRow.fraisAmount <= 0);
  const canAddTransaction =
    historyRow.remaining > 0 && !historyRow.reachedTxLimit;

  return (
    <Box display="flex" flexDirection="column" gap="15px">
      {canAddTransaction && (
        <Box
          component="form"
          onSubmit={submitTransaction}
          p="15px"
          sx={getNeutralSurfaceSx(isDark)}
          display="flex"
          flexDirection="column"
          gap="12px"
        >
          <Typography variant="h6" fontWeight="bold" color={isDark ? colors.grey[100] : "#0f172a"}>
            Ajouter un paiement
          </Typography>
          {txError && (
            <Typography color={colors.redAccent[500]} fontSize="13px">
              {txError}
            </Typography>
          )}
          <Box display="flex" gap="10px" flexWrap="wrap">
            <TextField
              variant="filled"
              label="Montant"
              type="number"
              inputProps={{ min: 0.01, step: 0.01 }}
              value={txAmount}
              onChange={(e) => setTxAmount(e.target.value)}
              sx={{ flex: 1, minWidth: "120px" }}
              required
              size="small"
              disabled={historyRow.paymentMethod === "oneShot"}
            />
            {historyRow.paymentMethod !== "oneShot" && (
              <>
                <TextField
                  variant="filled"
                  label="Date"
                  type="date"
                  InputLabelProps={{ shrink: true }}
                  value={txDate}
                  onChange={(e) => setTxDate(e.target.value)}
                  sx={{ flex: 1, minWidth: "120px" }}
                  required
                  size="small"
                  inputProps={{ max: new Date().toISOString().slice(0, 10) }}
                />
                <FormControl
                  variant="filled"
                  size="small"
                  sx={{ flex: 1, minWidth: "150px" }}
                  required
                >
                  <InputLabel>Mois concerné</InputLabel>
                  <Select
                    value={txTargetMonth}
                    onChange={(e) => setTxTargetMonth(e.target.value)}
                    label="Mois concerné"
                  >
                    {getMonthsInRange(
                      historyRow.planningStartDate,
                      historyRow.planningEndDate,
                    ).map((m) => (
                      <MenuItem key={m.value} value={m.value}>
                        {m.label}
                      </MenuItem>
                    ))}
                  </Select>
                </FormControl>
              </>
            )}
          </Box>
          <Button
            type="submit"
            variant="contained"
            disabled={txSubmitting}
            sx={{ ...getPrimaryButtonSx(isDark), alignSelf: "flex-end" }}
          >
            {txSubmitting ? "..." : "Enregistrer"}
          </Button>
        </Box>
      )}

      <Typography variant="h6" fontWeight="bold" color={isDark ? colors.grey[100] : "#0f172a"}>
        Historique des versements
      </Typography>
      {hasNoTransactions ? (
        <Typography color={colors.grey[300]} textAlign="center" py="20px">
          Aucune transaction.
        </Typography>
      ) : (
        <Box display="flex" flexDirection="column" gap="8px">
          {historyRow?.fraisAmount > 0 && (
            <Box
              display="flex"
              justifyContent="space-between"
              p="10px 15px"
              sx={getNeutralSurfaceSx(isDark)}
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
                        payment_date: historyRow.inscriptionDate,
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
          {(historyRow?.transactions || []).map((tx, i) => (
            <Box
              key={i}
              display="flex"
              justifyContent="space-between"
              p="10px 15px"
              sx={getNeutralSurfaceSx(isDark)}
              alignItems="center"
            >
              <Box>
                <Typography color={isDark ? colors.grey[200] : "#334155"}>{tx.date}</Typography>
                <Typography variant="caption" color={isDark ? colors.grey[400] : "#64748b"}>
                  Paiement standard
                </Typography>
              </Box>
              <Box display="flex" alignItems="center" gap="12px">
                <Typography fontWeight="bold" color={isDark ? colors.grey[100] : "#0f172a"}>
                  +{formatCurrency(tx.value)}
                </Typography>
                <Button
                  variant="outlined"
                  size="small"
                  onClick={() => {
                    setReceiptData({ ...historyRow, transaction: tx });
                    setIsReceiptDialogOpen(true);
                  }}
                  sx={{ ...getSecondaryButtonSx(colors, isDark), py: "2px", minWidth: "auto", fontSize: "11px" }}
                >
                  Reçu
                </Button>
              </Box>
            </Box>
          ))}
        </Box>
      )}
    </Box>
  );
};

export default StandardPaymentsPanel;
