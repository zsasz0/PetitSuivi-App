/**
 * @file payments/index.jsx
 * @description Payment Transaction Management Interface — Admin Ledger.
 *
 * PURPOSE:
 * Manages financial transactions for nursery inscriptions. Administrators can
 * view the payment status of each enrolled child (paid / partial / pending),
 * record new payment instalments (monthly or one-shot), toggle the annual
 * inscription fee checkbox, and track cumulative payment progress against
 * the total amount due per inscription.
 */
import React from "react";
import {
  Box,
  Typography,
  MenuItem,
  Select,
  FormControl,
  InputLabel,
} from "@mui/material";
import { useTheme } from "@mui/material";
import Header from "../../components/Header";
import { tokens } from "../../theme";
import PaymentInvoiceDialog from "./components/PaymentInvoiceDialog";
import PaymentReceiptDialog from "./components/PaymentReceiptDialog";
import StatsCards from "./components/StatsCards";
import PaymentsDataGrid from "./components/PaymentsDataGrid";
import RecentTransactionsPanel from "./components/RecentTransactionsPanel";
import ConfirmPaymentDialog from "./components/ConfirmPaymentDialog";
import TransactionHistoryDialog from "./components/TransactionHistoryDialog";
import { getPaymentColumns } from "./components/PaymentColumns";
import { usePaymentsController } from "./hooks/usePaymentsController";

/**
 * Payments Component
 * Primary ledger interface for tracking student payment statuses,
 * recording installments, and managing administrative fees.
 * @component
 * @returns {JSX.Element} The rendered global Payments ledger.
 */
const Payments = () => {
  const theme = useTheme();
  const colors = tokens(theme.palette.mode);
  const isDark = theme.palette.mode === "dark";

  const {
    loading,
    error,
    selectedYear,
    setSelectedYear,
    planningsList,
    filteredRows,
    stats,
    allTransactions,
    isHistoryDialogOpen,
    setIsHistoryDialogOpen,
    historyRow,
    txAmount,
    setTxAmount,
    txDate,
    setTxDate,
    txTargetMonth,
    setTxTargetMonth,
    txError,
    submitTransaction,
    isInvoiceDialogOpen,
    setIsInvoiceDialogOpen,
    setInvoiceRow,
    invoiceRow,
    isReceiptDialogOpen,
    setIsReceiptDialogOpen,
    receiptData,
    setReceiptData,
    companyParams,
    signatureUrl,
    isConfirmPayOpen,
    setIsConfirmPayOpen,
    confirmPayData,
    setConfirmPayData,
    txSubmitting,
    handleConfirmTransaction,
    handleToggleFrais,
    handleHistoryClick,
    handlePayMonth,
  } = usePaymentsController();

  const columns = React.useMemo(() => getPaymentColumns({
    theme,
    colors,
    handleToggleFrais,
    handleHistoryClick,
  }), [theme, colors, handleToggleFrais, handleHistoryClick]);

  return (
    <Box m="20px">
      <Box display="flex" justifyContent="space-between" alignItems="center">
        <Header title="PAIEMENTS" />
        <FormControl variant="filled" sx={{ minWidth: 200, mb: "20px" }}>
          <InputLabel id="year-filter-label" sx={{ color: colors.grey[100] }}>
            Année Scolaire
          </InputLabel>
          <Select
            labelId="year-filter-label"
            value={selectedYear}
            onChange={(e) => setSelectedYear(e.target.value)}
            sx={{
              color: colors.grey[100],
              backgroundColor: colors.primary[400],
            }}
          >
            <MenuItem value="all">Toutes les années</MenuItem>
            {planningsList.map((p) => (
              <MenuItem key={p.id} value={p.id}>
                {p.label}
              </MenuItem>
            ))}
          </Select>
        </FormControl>
      </Box>

      {error && (
        <Typography color={colors.redAccent[500]} mb="12px">
          {error}
        </Typography>
      )}

      <StatsCards stats={stats} colors={colors} isDark={theme.palette.mode === "dark"} />

      <PaymentsDataGrid
        loading={loading}
        rows={filteredRows}
        columns={columns}
        colors={colors}
        isDark={theme.palette.mode === "dark"}
      />

      <RecentTransactionsPanel
        allTransactions={allTransactions}
        colors={colors}
      />

      <TransactionHistoryDialog
        open={isHistoryDialogOpen}
        onClose={() => setIsHistoryDialogOpen(false)}
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
        handlePayMonth={handlePayMonth}
        setInvoiceRow={setInvoiceRow}
        setIsInvoiceDialogOpen={setIsInvoiceDialogOpen}
        setReceiptData={setReceiptData}
        setIsReceiptDialogOpen={setIsReceiptDialogOpen}
        setIsConfirmPayOpen={setIsConfirmPayOpen}
        setConfirmPayData={setConfirmPayData}
        colors={colors}
        isDark={isDark}
      />

      <PaymentInvoiceDialog
        open={isInvoiceDialogOpen}
        onClose={() => setIsInvoiceDialogOpen(false)}
        invoiceData={invoiceRow}
        companyParams={companyParams}
        signatureUrl={signatureUrl}
      />
      <PaymentReceiptDialog
        open={isReceiptDialogOpen}
        onClose={() => setIsReceiptDialogOpen(false)}
        receiptData={receiptData}
        companyParams={companyParams}
        signatureUrl={signatureUrl}
      />

      <ConfirmPaymentDialog
        open={isConfirmPayOpen}
        onClose={() => setIsConfirmPayOpen(false)}
        confirmPayData={confirmPayData}
        txSubmitting={txSubmitting}
        onConfirmStandard={handleConfirmTransaction}
        onConfirmMonthly={handlePayMonth}
        colors={colors}
      />
    </Box>
  );
};

export default Payments;
