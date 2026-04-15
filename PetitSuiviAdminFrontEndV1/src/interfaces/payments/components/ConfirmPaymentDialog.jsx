import { Dialog, DialogTitle, DialogContent, DialogActions, Button, Typography, useTheme } from "@mui/material";
import { formatCurrency } from "../utils/formatters";
import { getPrimaryButtonSx } from "../utils/styles";

/**
 * @file components/ConfirmPaymentDialog.jsx
 * Small confirmation modal displayed before persisting any payment.
 */
const ConfirmPaymentDialog = ({
  open,
  onClose,
  confirmPayData,
  txSubmitting,
  onConfirmStandard,
  onConfirmMonthly,
  colors,
}) => {
  const theme = useTheme();
  const isDark = theme.palette.mode === "dark";

  return (
    <Dialog
      open={open}
      onClose={() => !txSubmitting && onClose()}
      maxWidth="xs"
      fullWidth
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
        }}
      >
        Confirmer le paiement
      </DialogTitle>
      <DialogContent sx={{ mt: 2 }}>
        <Typography>
          {confirmPayData?.type === "standard" ? (
            <>
              Voulez-vous confirmer le paiement de{" "}
              <strong>
                {confirmPayData ? formatCurrency(confirmPayData.amount) : ""}
              </strong>
              {confirmPayData?.targetMonthLabel && (
                <>
                  {" "}
                  pour le mois de{" "}
                  <strong>{confirmPayData.targetMonthLabel}</strong>
                </>
              )}{" "}
              ?
            </>
          ) : (
            <>
              Voulez-vous confirmer le paiement de{" "}
              <strong>
                {confirmPayData ? formatCurrency(confirmPayData.amount) : ""}
              </strong>{" "}
              pour le mois de <strong>{confirmPayData?.targetMonthLabel}</strong>{" "}
              ?
            </>
          )}
        </Typography>
      </DialogContent>
      <DialogActions sx={{ p: 2, borderTop: `1px solid ${isDark ? "rgba(148,163,184,0.18)" : "#e2e8f0"}` }}>
        <Button
          onClick={onClose}
          disabled={txSubmitting}
          sx={{ color: isDark ? colors.grey[100] : "#334155" }}
        >
          Annuler
        </Button>
        <Button
          onClick={() => {
            if (confirmPayData?.type === "standard") {
              onConfirmStandard();
            } else if (confirmPayData) {
              onConfirmMonthly(
                confirmPayData.row,
                confirmPayData.amount,
                confirmPayData.targetMonthValue,
              );
              onClose();
            }
          }}
          variant="contained"
          disabled={txSubmitting}
          sx={getPrimaryButtonSx(isDark)}
        >
          {txSubmitting ? "Traitement..." : "Confirmer"}
        </Button>
      </DialogActions>
    </Dialog>
  );
};

export default ConfirmPaymentDialog;
