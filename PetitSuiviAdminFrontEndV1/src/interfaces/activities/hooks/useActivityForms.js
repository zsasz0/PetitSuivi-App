import { useState, useCallback } from "react";
import { activitiesApi } from "../api/activitiesApi";
import { normalizeActivityTitle, parseSuggestedCriterionIds, isWeekendDate } from "../utils/activitiesUtils";

export const useActivityForms = ({ ui, data }) => {
  const { openModal, closeModal, showToast, showAiUnavailableToast, selectedClassForWeekId } = ui;
  const { isArchived, allActivities, selectedPlanningId, criteriaList, fetchAiEnabled, fetchPlanned, setCriteriaList, setAllActivities } = data;

  const [addActivityForm, setAddActivityForm] = useState({ activityId: "", date: "", startTime: "", endTime: "", classIds: [] });
  const [addActivityError, setAddActivityError] = useState("");
  const [addActivitySaving, setAddActivitySaving] = useState(false);

  const [newCriteriaName, setNewCriteriaName] = useState("");
  const [addCriteriaError, setAddCriteriaError] = useState("");
  const [addCriteriaSaving, setAddCriteriaSaving] = useState(false);

  const [addAllActivityForm, setAddAllActivityForm] = useState({ title: "", description: "", criteriaIds: [] });
  const [addAllActivityError, setAddAllActivityError] = useState("");
  const [addAllActivitySaving, setAddAllActivitySaving] = useState(false);

  const [suggestingCriteria, setSuggestingCriteria] = useState(false);
  const [maxSuggestedCriteria, setMaxSuggestedCriteria] = useState(2);

  const [editingActivity, setEditingActivity] = useState(null);
  const [editForm, setEditForm] = useState({ title: "", description: "", criteriaIds: [] });
  const [editFormError, setEditFormError] = useState("");

  const [deletingItem, setDeletingItem] = useState(null);
  const [deleteType, setDeleteType] = useState("");

  const handleAddActivity = async (e) => {
    e.preventDefault();
    if (isArchived) return;
    setAddActivitySaving(true);
    if (isWeekendDate(addActivityForm.date)) {
      showToast("Les activités ne peuvent être planifiées que du lundi au vendredi.", "error");
      setAddActivitySaving(false);
      return;
    }
    const selectedActivity = allActivities.find((a) => a.id === Number(addActivityForm.activityId));
    if (!selectedActivity) { showToast("Sélectionnez une activité.", "error"); setAddActivitySaving(false); return; }
    if (addActivityForm.startTime && addActivityForm.endTime && addActivityForm.startTime >= addActivityForm.endTime) {
      showToast("L'heure de début doit être avant l'heure de fin.", "error"); setAddActivitySaving(false); return;
    }
    try {
      await activitiesApi.addPlannedActivity(selectedPlanningId, {
        title: selectedActivity.title, description: selectedActivity.description || null,
        date: addActivityForm.date, start_time: addActivityForm.startTime || null, end_time: addActivityForm.endTime || null,
        class_ids: addActivityForm.classIds, criteria_ids: selectedActivity.criteriaIds || [],
        status: "approved", template_id: selectedActivity.id,
      });
      await fetchPlanned();
      closeModal("plan");
      showToast("Activité planifiée avec succès.", "success");
      setAddActivityForm({ activityId: "", date: "", startTime: "", endTime: "", classIds: [] });
    } catch (err) {
      showToast(err?.response?.data?.message || "Erreur.", "error");
    } finally {
      setAddActivitySaving(false);
    }
  };

  const openAddForDate = (dateStr) => {
    if (dateStr && isWeekendDate(dateStr)) {
      showToast("Les activités ne peuvent être planifiées que du lundi au vendredi.", "error"); return;
    }
    setAddActivityForm({ activityId: "", date: dateStr || "", startTime: "09:00", endTime: "11:00", classIds: selectedClassForWeekId ? [Number(selectedClassForWeekId)] : [] });
    openModal("plan");
  };

  const handleAddCriteria = async (e) => {
    e.preventDefault();
    if (!newCriteriaName.trim()) return;
    setAddCriteriaSaving(true);
    try {
      const res = await activitiesApi.addCriteria({ name: newCriteriaName.trim() });
      const newC = res.data?.data || res.data;
      setCriteriaList((prev) => [...prev, { id: newC.id, name: newC.name }]);
      setNewCriteriaName("");
      showToast("Critère ajouté avec succès.", "success");
      closeModal("criteria");
    } catch (err) {
      showToast(err?.response?.data?.message || "Erreur.", "error");
    } finally {
      setAddCriteriaSaving(false);
    }
  };

  const handleDeleteCriteria = (criteria) => { setDeletingItem(criteria); setDeleteType("criteria"); openModal("delete"); };

  const handleAddAllActivity = async (e) => {
    e.preventDefault();
    const normalizedTitle = normalizeActivityTitle(addAllActivityForm.title);
    if (!normalizedTitle) { showToast("Le titre de l'activité est requis.", "error"); return; }
    if (allActivities.find((activity) => normalizeActivityTitle(activity.title) === normalizedTitle)) {
      showToast("Une activité avec ce nom existe déjà.", "error"); return;
    }
    setAddAllActivitySaving(true);
    try {
      const res = await activitiesApi.addActivity({ title: addAllActivityForm.title.trim(), description: addAllActivityForm.description.trim() || null, criteria_ids: addAllActivityForm.criteriaIds });
      const newA = res.data?.data || res.data;
      setAllActivities((prev) => [...prev, { id: newA.id, title: newA.title || "", description: newA.description || "", criteriaIds: (newA.criteria || []).map((c) => c.id), criteriaNames: (newA.criteria || []).map((c) => c.name).join(", ") || "-" }]);
      setAddAllActivityForm({ title: "", description: "", criteriaIds: [] });
      showToast("Activité créée avec succès.", "success");
      closeModal("allActivity");
    } catch (err) {
      showToast(err?.response?.data?.message || "Erreur.", "error");
    } finally {
      setAddAllActivitySaving(false);
    }
  };

  const handleSuggest = useCallback(async (formState, setFormState) => {
    const title = formState.title.trim();
    const description = (formState.description || "").trim();
    const safeMax = Math.max(1, Math.min(criteriaList.length || 1, Number.isInteger(Number(maxSuggestedCriteria)) ? Number(maxSuggestedCriteria) : 2));
    if (!title && !description) { showToast("Ajoutez un titre ou une description d'abord.", "error"); return; }
    if (criteriaList.length === 0) { showToast("Aucun critère disponible.", "error"); return; }
    const criteriaLines = criteriaList.map((c) => `- ${c.id}: ${c.name}`).join("\n");
    
    try {
      const latestAiEnabled = await fetchAiEnabled();
      if (!latestAiEnabled) { showToast("L'IA est désactivée.", "warning"); return; }
      setSuggestingCriteria(true);
      const response = await activitiesApi.suggestCriteria({ title, description, safeMax, criteriaLines, max_tokens: 180 });
      const output = String(response?.data?.output || "").trim();
      const fallbackRaw = response?.data?.raw?.choices?.[0]?.message?.content;
      const fallback = typeof fallbackRaw === "string" ? fallbackRaw.trim() : "";
      const suggestedIds = parseSuggestedCriterionIds(output || fallback, criteriaList).slice(0, safeMax);
      if (suggestedIds.length === 0) { showToast("L'IA n'a pas retourné de critères.", "warning"); return; }
      
      setFormState((prev) => ({ ...prev, criteriaIds: [...new Set([...(prev.criteriaIds || []), ...suggestedIds])].slice(0, safeMax) }));
    } catch (err) {
      showAiUnavailableToast(err?.response?.data?.message || "Échec de la suggestion IA.");
    } finally {
      setSuggestingCriteria(false);
    }
  }, [criteriaList, maxSuggestedCriteria, fetchAiEnabled, showToast, showAiUnavailableToast]);

  const handleSuggestCriteria = () => handleSuggest(addAllActivityForm, setAddAllActivityForm);
  const handleSuggestCriteriaForEdit = () => handleSuggest(editForm, setEditForm);

  const handleEditActivityClick = (activity) => {
    setEditingActivity(activity);
    setEditForm({ title: activity.title, description: activity.description, criteriaIds: activity.criteriaIds });
    openModal("edit");
  };

  const handleEditSubmit = async (e) => {
    e.preventDefault();
    const normalizedTitle = normalizeActivityTitle(editForm.title);
    if (allActivities.find((activity) => activity.id !== editingActivity.id && normalizeActivityTitle(activity.title) === normalizedTitle)) {
      showToast("Une activité avec ce nom existe déjà.", "error"); return;
    }
    try {
      await activitiesApi.updateActivity(editingActivity.id, { title: editForm.title.trim(), description: editForm.description.trim() || null, criteria_ids: editForm.criteriaIds });
      closeModal("edit");
      showToast("Activité modifiée avec succès.", "success");
      const res = await activitiesApi.getActivities();
      setAllActivities((res.data?.data || []).map((a) => ({ id: a.id, title: a.title || "", description: a.description || "", criteriaIds: (a.criteria || []).map((c) => c.id), criteriaNames: (a.criteria || []).map((c) => c.name).join(", ") || "-" })));
    } catch (err) {
      showToast(err?.response?.data?.message || "Erreur.", "error");
    }
  };

  const handleDeleteActivity = (activity) => { setDeletingItem(activity); setDeleteType("activity"); openModal("delete"); };

  const handleDeletePlannedActivity = async (activityId) => {
    if (isArchived) return;
    if (!window.confirm("Supprimer cette activité planifiée ?")) return;
    try { 
      await activitiesApi.deletePlannedActivity(selectedPlanningId, activityId); 
      showToast("Activité supprimée avec succès.", "success");
      await fetchPlanned(); 
    } catch (err) { showToast(err?.response?.data?.message || "Erreur lors de la suppression.", "error"); }
  };

  const handleDeleteConfirm = async () => {
    try {
      if (deleteType === "criteria") { await activitiesApi.deleteCriteria(deletingItem.id); setCriteriaList((prev) => prev.filter((c) => c.id !== deletingItem.id)); }
      else if (deleteType === "activity") { await activitiesApi.deleteActivity(deletingItem.id); setAllActivities((prev) => prev.filter((a) => a.id !== deletingItem.id)); }
      showToast("Élément supprimé avec succès.", "success");
      closeModal("delete"); setDeletingItem(null);
    } catch (err) { showToast(err?.response?.data?.message || "Erreur.", "error"); }
  };

  return {
    addActivityForm, setAddActivityForm, addActivityError, setAddActivityError, addActivitySaving,
    newCriteriaName, setNewCriteriaName, addCriteriaError, setAddCriteriaError, addCriteriaSaving,
    addAllActivityForm, setAddAllActivityForm, addAllActivityError, setAddAllActivityError, addAllActivitySaving,
    suggestingCriteria, maxSuggestedCriteria, setMaxSuggestedCriteria,
    editingActivity, editForm, setEditForm, editFormError, setEditFormError,
    deletingItem, deleteType, setDeleteType,
    handleAddActivity, openAddForDate, handleAddCriteria, handleDeleteCriteria, handleAddAllActivity,
    handleSuggestCriteria, handleSuggestCriteriaForEdit, handleEditActivityClick, handleEditSubmit,
    handleDeleteActivity, handleDeletePlannedActivity, handleDeleteConfirm,
  };
};
