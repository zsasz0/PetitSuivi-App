import { useState, useCallback, useEffect, useMemo } from "react";
import { eventsService } from "../api/eventsService";

export const useEventsData = ({ ui }) => {
  const [events, setEvents] = useState([]);
  const [classes, setClasses] = useState([]);
  const [teachers, setTeachers] = useState([]);
  const [children, setChildren] = useState([]);

  const { setToast, setLoading, setDeleteDialogOpen, setDeletingEvent, showToast, closeActionMenu, deletingEvent } = ui;

  const fetchEvents = useCallback(async () => {
    try {
      const data = await eventsService.getEvents();
      setEvents(data);
    } catch (err) {
      console.error("Error fetching events:", err);
      setToast({ open: true, message: err?.response?.data?.message || "Erreur lors du chargement des événements.", severity: "error" });
    }
  }, [setToast]);

  const fetchReferenceData = useCallback(async () => {
    try {
      const data = await eventsService.getReferenceData();
      setClasses(data.classes);
      setTeachers(data.teachers);
      setChildren(data.children);
    } catch (err) {
      console.error("Error fetching reference data:", err);
    }
  }, []);

  useEffect(() => {
    const init = async () => {
      setLoading(true);
      await Promise.all([fetchEvents(), fetchReferenceData()]);
      setLoading(false);
    };
    init();
  }, [fetchEvents, fetchReferenceData, setLoading]);

  const handleDeleteConfirm = async () => {
    if (!deletingEvent) return;
    try {
      await eventsService.deleteEvent(deletingEvent.id);
      setDeleteDialogOpen(false);
      setDeletingEvent(null);
      await fetchEvents();
      showToast("Événement supprimé.", "success");
    } catch (err) {
      showToast(err?.response?.data?.message || "Erreur lors de la suppression.", "error");
    }
  };

  const handleToggleStatus = async (event) => {
    closeActionMenu();
    const newStatus = event.status === "executed" ? "pending" : "executed";
    try {
      await eventsService.toggleStatus(event.id, newStatus);
      await fetchEvents();
      showToast(newStatus === "executed" ? "Événement marqué exécuté." : "Événement remis en attente.", "success");
    } catch (err) {
      showToast(err?.response?.data?.message || "Erreur lors de la mise à jour du statut.", "error");
    }
  };

  const stats = useMemo(() => {
    const today = new Date().toISOString().slice(0, 10);
    return {
      total: events.length,
      today: events.filter((event) => String(event.date).slice(0, 10) === today).length,
      executed: events.filter((event) => event.status === "executed").length,
      pending: events.filter((event) => event.status === "pending").length,
      notified: events.filter((event) => !!event.notifications_sent).length,
    };
  }, [events]);

  return {
    events, setEvents,
    classes, setClasses,
    teachers, setTeachers,
    children, setChildren,
    fetchEvents,
    fetchReferenceData,
    handleDeleteConfirm,
    handleToggleStatus,
    stats,
  };
};
