import { useState } from "react";

export const useUIStates = () => {
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");

  const [savingAi, setSavingAi] = useState(false);
  const [savingInscriptions, setSavingInscriptions] = useState(false);
  const [uploadingSignature, setUploadingSignature] = useState(false);
  const [deletingSignature, setDeletingSignature] = useState(false);

  const [archiveConfirmOpen, setArchiveConfirmOpen] = useState(false);
  const [archiveLoading, setArchiveLoading] = useState(false);
  const [archiveResult, setArchiveResult] = useState(null);
  const [archiveError, setArchiveError] = useState(null);

  const [savingPlanning, setSavingPlanning] = useState(false);
  const [planningMessage, setPlanningMessage] = useState({ text: "", type: "" });
  const [deletePlanningConfirmOpen, setDeletePlanningConfirmOpen] = useState(false);

  const [toggleConfirm, setToggleConfirm] = useState({ open: false, type: null });
  const [toast, setToast] = useState({ open: false, message: "", severity: "success" });

  const showToast = (message, severity = "success") => setToast({ open: true, message, severity });
  const closeToast = (_, reason) => {
    if (reason === "clickaway") return;
    setToast((prev) => ({ ...prev, open: false }));
  };

  const confirmToggle = (type) => setToggleConfirm({ open: true, type });
  const closeToggleConfirm = () => setToggleConfirm({ open: false, type: null });

  return {
    loading, setLoading,
    saving, setSaving,
    error, setError,
    success, setSuccess,
    savingAi, setSavingAi,
    savingInscriptions, setSavingInscriptions,
    uploadingSignature, setUploadingSignature,
    deletingSignature, setDeletingSignature,
    archiveConfirmOpen, setArchiveConfirmOpen,
    archiveLoading, setArchiveLoading,
    archiveResult, setArchiveResult,
    archiveError, setArchiveError,
    savingPlanning, setSavingPlanning,
    planningMessage, setPlanningMessage,
    deletePlanningConfirmOpen, setDeletePlanningConfirmOpen,
    toggleConfirm, setToggleConfirm,
    toast, setToast,
    showToast, closeToast,
    confirmToggle, closeToggleConfirm,
  };
};
