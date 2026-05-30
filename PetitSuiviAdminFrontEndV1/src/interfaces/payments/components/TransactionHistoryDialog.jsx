import { Dialog, DialogTitle, DialogContent, DialogActions, Box, Button } from "@mui/material";
import { getPrimaryButtonSx } from "../utils/styles";
import MonthlySchedulePanel from "./MonthlySchedulePanel";
import StandardPaymentsPanel from "./StandardPaymentsPanel";

/**
 * @file components/TransactionHistoryDialog.jsx
 * Modal with monthly schedule or standard payment form.
 */
const TransactionHistoryDialog = ({
  open,
  onClose,
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
  handlePayMonth,
  setInvoiceRow,
  setIsInvoiceDialogOpen,
  setReceiptData,
  setIsReceiptDialogOpen,
  setIsConfirmPayOpen,
  setConfirmPayData,
  colors,
  isDark
}) => {
  return (
    <Dialog
      open={open}
      onClose={onClose}
      fullWidth
      maxWidth="sm"
      PaperProps={{
        sx: {
          backgroundColor: isDark ? "#111c2d" : "#ffffff",
          color: isDark ? colors.grey[100] : "#0f172a",
          borderRadius: "12px",
          border: `1px solid ${isDark ? "rgba(148,163,184,0.18)" : "#e2e8f0"}`,
        },
      }}
    >
      <DialogTitle
        sx={{
          fontWeight: "bold",
          borderBottom: `1px solid ${isDark ? "rgba(148,163,184,0.18)" : "#e2e8f0"}`,
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
        }}
      >
        <Box>Détails & Paiements – {historyRow?.name}</Box>
        <Button
          variant="contained"
          size="small"
          onClick={() => {
            setInvoiceRow(historyRow);
            setIsInvoiceDialogOpen(true);
          }}
          sx={getPrimaryButtonSx(isDark)}
        >
          Facture
        </Button>
      </DialogTitle>
      <DialogContent sx={{ mt: 2 }}>
        {historyRow && historyRow.paymentMethod === "monthlyPartial" ? (
          <MonthlySchedulePanel
            historyRow={historyRow}
            txSubmitting={txSubmitting}
            handlePayMonth={handlePayMonth}
            setReceiptData={setReceiptData}
            setIsReceiptDialogOpen={setIsReceiptDialogOpen}
            setIsConfirmPayOpen={setIsConfirmPayOpen}
            setConfirmPayData={setConfirmPayData}
            colors={colors}
            isDark={isDark}
          />
        ) : (
          <StandardPaymentsPanel
            historyRow={historyRow}
            txAmount={txAmount}
            setTxAmount={setTxAmount}
            txDate={txDate}
            setTxDate={setTxDate}
            txTargetMonth={txTargetMonth}
            setTxTargetMonth={setTxTargetMonth}
            submitTransaction={submitTransaction}
            txError={txError}
            txSubmitting={txSubmitting}
            setReceiptData={setReceiptData}
            setIsReceiptDialogOpen={setIsReceiptDialogOpen}
            colors={colors}
            isDark={isDark}
          />
        )}
      </DialogContent>
      <DialogActions
        sx={{ p: 2, borderTop: `1px solid ${isDark ? "rgba(148,163,184,0.18)" : "#e2e8f0"}` }}
      >
        <Button
          onClick={onClose}
          sx={{ color: isDark ? colors.grey[100] : "#334155" }}
        >
          Fermer
        </Button>
      </DialogActions>
    </Dialog>
  );
};

export default TransactionHistoryDialog;
