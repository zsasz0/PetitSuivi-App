import { useState } from "react";
import { eventsService } from "../api/eventsService";
import { validateLettersAndSpaces } from "../../../utils/validation";

export const useEventsForms = ({ ui, data }) => {
  const [editingEvent, setEditingEvent] = useState(null);
  const [form, setForm] = useState({
    name: "",
    description: "",
    date: "",
    start_time: "09:00",
    end_time: "11:00",
    send_notifications: false,
  });
  const [formError, setFormError] = useState("");
  const [saving, setSaving] = useState(false);
  const [conflictInfo, setConflictInfo] = useState(null);

  const [selectedClasses, setSelectedClasses] = useState([]);
  const [selectedTeachers, setSelectedTeachers] = useState([]);
  const [selectedChildren, setSelectedChildren] = useState([]);
  const [notifTargetMode, setNotifTargetMode] = useState("classes");

  const resetNotificationState = () => {
    setSelectedClasses([]);
    setSelectedTeachers([]);
    setSelectedChildren([]);
    setNotifTargetMode("classes");
  };

  const handleCreate = () => {
    setEditingEvent(null);
    setForm({ name: "", description: "", date: "", start_time: "09:00", end_time: "11:00", send_notifications: false });
    setFormError("");
    setConflictInfo(null);
    resetNotificationState();
    ui.setDialogOpen(true);
  };

  const handleEdit = (event) => {
    ui.closeActionMenu();
    setEditingEvent(event);
    setForm({
      name: event.name || "",
      description: event.description || "",
      date: (event.date || "").slice(0, 10),
      start_time: (event.start_time || "").slice(0, 5),
      end_time: (event.end_time || "").slice(0, 5),
      send_notifications: false,
    });
    setFormError("");
    setConflictInfo(null);
    resetNotificationState();
    ui.setDialogOpen(true);
  };

  const hasNotificationTargets = () => {
    if (!form.send_notifications) return true;
    const targetCount = notifTargetMode === "classes" ? selectedClasses.length : selectedChildren.length;
    return targetCount > 0 || selectedTeachers.length > 0;
  };

  const handleSubmitEvent = async (e) => {
    e.preventDefault();
    setFormError("");
    setConflictInfo(null);

    if (!form.name.trim() || !form.description.trim() || !form.date || !form.start_time || !form.end_time) {
      setFormError("Veuillez remplir tous les champs (le nom, la description, la date et les horaires ne peuvent pas être vides).");
      return;
    }

    const nameError = validateLettersAndSpaces(form.name, "Le nom de l'événement");
    if (nameError) {
      setFormError(nameError);
      return;
    }

    const selectedDate = new Date(form.date);
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    if (selectedDate < today) {
      setFormError("La date de l'événement ne peut pas être dans le passé.");
      return;
    }

    if (form.start_time >= form.end_time) {
      setFormError("L'heure de fin doit être postérieure à l'heure de début.");
      return;
    }

    if (!hasNotificationTargets()) {
      setFormError("Sélectionnez au moins un destinataire ou désactivez les notifications.");
      return;
    }

    setSaving(true);
    try {
      const conflictData = await eventsService.checkConflict({
        date: form.date,
        start_time: form.start_time,
        end_time: form.end_time,
        exclude_event_id: editingEvent?.id || null,
      });

      if (conflictData?.has_conflict) {
        const actConflicts = (conflictData.activity_conflicts || []).map((conflict) => `• Activité "${conflict.title}" (${(conflict.startTime || "").slice(0, 5)} - ${(conflict.endTime || "").slice(0, 5)})`);
        const evtConflicts = (conflictData.event_conflicts || []).map((conflict) => `• Événement "${conflict.name}" (${(conflict.start_time || "").slice(0, 5)} - ${(conflict.end_time || "").slice(0, 5)})`);
        setConflictInfo([...actConflicts, ...evtConflicts].join("\n"));
        setSaving(false);
        return;
      }

      const payload = {
        name: form.name.trim(),
        description: form.description.trim() || null,
        date: form.date,
        start_time: form.start_time,
        end_time: form.end_time,
        send_notifications: form.send_notifications,
        notification_targets: form.send_notifications
          ? {
              classes: notifTargetMode === "classes" ? selectedClasses.map((schoolClass) => schoolClass.id) : [],
              teachers: selectedTeachers.map((teacher) => teacher.cin),
              children: notifTargetMode === "children" ? selectedChildren.map((child) => child.id) : [],
            }
          : { classes: [], teachers: [], children: [] },
      };

      if (editingEvent) {
        await eventsService.updateEvent(editingEvent.id, payload);
        ui.showToast(form.send_notifications ? "Événement mis à jour et notifications envoyées." : "Événement mis à jour.", "success");
      } else {
        await eventsService.createEvent(payload);
        ui.showToast(form.send_notifications ? "Événement créé et notifications envoyées." : "Événement créé.", "success");
      }

      ui.setDialogOpen(false);
      resetNotificationState();
      await data.fetchEvents();
    } catch (err) {
      setFormError(err?.response?.data?.message || "Erreur lors de la sauvegarde.");
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = (event) => {
    ui.closeActionMenu();
    ui.setDeletingEvent(event);
    ui.setDeleteDialogOpen(true);
  };

  return {
    editingEvent, setEditingEvent,
    form, setForm,
    formError, setFormError,
    saving, setSaving,
    conflictInfo, setConflictInfo,
    selectedClasses, setSelectedClasses,
    selectedTeachers, setSelectedTeachers,
    selectedChildren, setSelectedChildren,
    notifTargetMode, setNotifTargetMode,
    resetNotificationState,
    handleCreate,
    handleEdit,
    hasNotificationTargets,
    handleSubmitEvent,
    handleDelete,
  };
};
