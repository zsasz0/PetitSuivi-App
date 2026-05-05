import { useState, useCallback } from "react";
import { postTransaction, patchToggleFrais } from "../api/paymentService";
import { getMonthsInRange, formatCurrency } from "../utils/formatters";

export const usePaymentsTransactions = ({ ui, data }) => {
  const [historyRow, setHistoryRow] = useState(null);
  const [invoiceRow, setInvoiceRow] = useState(null);
  const [receiptData, setReceiptData] = useState(null);
  const [confirmPayData, setConfirmPayData] = useState(null);
  const [txAmount, setTxAmount] = useState("");
  const [txDate, setTxDate] = useState(new Date().toISOString().slice(0, 10));
  const [txTargetMonth, setTxTargetMonth] = useState("");
  const [txError, setTxError] = useState("");
  const [txSubmitting, setTxSubmitting] = useState(false);

  const { setIsConfirmPayOpen, setIsHistoryDialogOpen } = ui;
  const { loadPayments, setPaymentsRows } = data;

  const handleConfirmTransaction = useCallback(async () => {
    try {
      setTxSubmitting(true);
      setTxError("");
      const payload = { amount: confirmPayData.amount, date: confirmPayData.date };
      if (confirmPayData.targetMonth) payload.target_month = confirmPayData.targetMonth;
      await postTransaction(historyRow.inscriptionId, historyRow.childId, payload);
      await loadPayments();

      setPaymentsRows((prev) => {
        const updatedRow = prev.find((r) => r.inscriptionId === historyRow.inscriptionId && r.childId === historyRow.childId);
        if (updatedRow && updatedRow.id === historyRow?.id) setHistoryRow(updatedRow);
        return prev;
      });

      setTxAmount("");
      setIsConfirmPayOpen(false);
      setConfirmPayData(null);
    } catch (error) {
      console.error("Failed to submit transaction", error);
      setTxError(error?.response?.data?.message || "Erreur lors de la transaction.");
    } finally {
      setTxSubmitting(false);
    }
  }, [confirmPayData, historyRow, loadPayments, setPaymentsRows, setIsConfirmPayOpen]);

  const submitTransaction = useCallback(async (e) => {
    e.preventDefault();
    if (!historyRow) return;

    if (historyRow.reachedTxLimit) { setTxError("Limite de transactions atteinte."); return; }
    const amountValue = Number(txAmount);
    if (!amountValue || amountValue <= 0) { setTxError("Veuillez saisir un montant valide."); return; }
    if (historyRow.paymentMethod === "oneShot" && Math.round(amountValue * 100) !== Math.round(historyRow.totalAmount * 100)) {
      setTxError("Le montant doit être égal au montant total."); return;
    }
    if (amountValue > historyRow.remaining) {
      setTxError(`Le montant ne peut pas dépasser ${formatCurrency(historyRow.remaining)}.`); return;
    }
    if (historyRow.paymentMethod === "monthlyPartial" && !txTargetMonth) {
      setTxError("Veuillez sélectionner le mois concerné par ce paiement."); return;
    }

    setConfirmPayData({
      type: "standard", amount: amountValue, date: txDate,
      targetMonth: historyRow.paymentMethod === "monthlyPartial" ? txTargetMonth : null,
      targetMonthLabel: historyRow.paymentMethod === "monthlyPartial" ? getMonthsInRange(historyRow.planningStartDate, historyRow.planningEndDate).find((m) => m.value === txTargetMonth)?.label : null,
    });
    setIsConfirmPayOpen(true);
  }, [historyRow, txAmount, txDate, txTargetMonth, setIsConfirmPayOpen]);

  const handleToggleFrais = useCallback(async (inscriptionId, currentVal) => {
    try {
      const nextVal = !currentVal;
      const response = await patchToggleFrais(inscriptionId, nextVal);
      const newAmount = response.data?.data?.frais_inscription_amount;
      setPaymentsRows((prev) => prev.map((row) => row.inscriptionId === inscriptionId ? { ...row, fraisAmount: newAmount !== null ? Number(newAmount) : 0 } : row));
    } catch (error) {
      console.error("Failed to toggle frais inscription", error);
      alert("Erreur lors de la modification des frais d'inscription.");
    }
  }, [setPaymentsRows]);

  const handleHistoryClick = useCallback((row) => {
    setHistoryRow(row);
    setTxAmount(row?.paymentMethod === "oneShot" ? String(row?.totalAmount || "") : "");
    setTxDate(new Date().toISOString().slice(0, 10));
    setTxTargetMonth("");
    setTxError("");
    setIsHistoryDialogOpen(true);
  }, [setIsHistoryDialogOpen]);

  const handlePayMonth = useCallback(async (row, monthlyAmount, targetMonth) => {
    try {
      setTxSubmitting(true);
      await postTransaction(row.inscriptionId, row.childId, {
        amount: Math.round(monthlyAmount * 100) / 100, date: new Date().toISOString().slice(0, 10), target_month: targetMonth,
      });
      await loadPayments();

      setPaymentsRows((prev) => {
        const updatedRow = prev.find((r) => r.inscriptionId === row.inscriptionId && r.childId === row.childId);
        if (updatedRow && updatedRow.id === historyRow?.id) setHistoryRow(updatedRow);
        return prev;
      });
    } catch (error) {
      console.error("Failed to add monthly payment", error);
      alert("Erreur lors du paiement mensuel.");
    } finally {
      setTxSubmitting(false);
    }
  }, [historyRow?.id, loadPayments, setPaymentsRows]);

  return {
    historyRow, setHistoryRow,
    invoiceRow, setInvoiceRow,
    receiptData, setReceiptData,
    confirmPayData, setConfirmPayData,
    txAmount, setTxAmount,
    txDate, setTxDate,
    txTargetMonth, setTxTargetMonth,
    txError, setTxError,
    txSubmitting, setTxSubmitting,
    handleConfirmTransaction,
    submitTransaction,
    handleToggleFrais,
    handleHistoryClick,
    handlePayMonth,
  };
};
