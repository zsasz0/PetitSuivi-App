import { useState } from "react";

export const usePaymentsUIStates = () => {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [isHistoryDialogOpen, setIsHistoryDialogOpen] = useState(false);
  const [isInvoiceDialogOpen, setIsInvoiceDialogOpen] = useState(false);
  const [isReceiptDialogOpen, setIsReceiptDialogOpen] = useState(false);
  const [isConfirmPayOpen, setIsConfirmPayOpen] = useState(false);

  return {
    loading, setLoading,
    error, setError,
    isHistoryDialogOpen, setIsHistoryDialogOpen,
    isInvoiceDialogOpen, setIsInvoiceDialogOpen,
    isReceiptDialogOpen, setIsReceiptDialogOpen,
    isConfirmPayOpen, setIsConfirmPayOpen,
  };
};
