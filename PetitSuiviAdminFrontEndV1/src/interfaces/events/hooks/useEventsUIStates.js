import { useState, useCallback } from "react";

export const useEventsUIStates = () => {
  const [loading, setLoading] = useState(true);
  const [dialogOpen, setDialogOpen] = useState(false);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [deletingEvent, setDeletingEvent] = useState(null);
  const [actionMenuPosition, setActionMenuPosition] = useState(null);
  const [actionMenuEvent, setActionMenuEvent] = useState(null);
  const [toast, setToast] = useState({ open: false, message: "", severity: "info" });

  const showToast = useCallback((message, severity = "info") => setToast({ open: true, message, severity }), []);
  
  const closeToast = useCallback((_, reason) => {
    if (reason === "clickaway") return;
    setToast((prev) => ({ ...prev, open: false }));
  }, []);

  const openActionMenu = useCallback((event, row) => {
    const rect = event.currentTarget.getBoundingClientRect();
    const menuWidth = 210;
    const viewportPadding = 8;
    const left = Math.max(viewportPadding, Math.min(rect.right - menuWidth, window.innerWidth - menuWidth - viewportPadding));
    const top = Math.max(viewportPadding, Math.min(rect.bottom + 4, window.innerHeight - 200));
    setActionMenuPosition({ top, left });
    setActionMenuEvent(row);
  }, []);

  const closeActionMenu = useCallback(() => {
    setActionMenuPosition(null);
    setActionMenuEvent(null);
  }, []);

  return {
    loading, setLoading,
    dialogOpen, setDialogOpen,
    deleteDialogOpen, setDeleteDialogOpen,
    deletingEvent, setDeletingEvent,
    actionMenuPosition, setActionMenuPosition,
    actionMenuEvent, setActionMenuEvent,
    toast, setToast,
    showToast, closeToast,
    openActionMenu, closeActionMenu,
  };
};
