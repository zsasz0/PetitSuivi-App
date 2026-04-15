import { useState, useEffect, useMemo } from "react";
import { parametersService } from "../api/parametersService";
import {
  mapPlanningFromApi,
  getDefaultPlanning,
  validatePlanningDates,
  getPlanningLabel,
} from "../utils/parametersUtils";

export const usePlanningsData = ({ ui }) => {
  const [plannings, setPlannings] = useState([]);
  const [selectedPlanningId, setSelectedPlanningId] = useState(null);
  const [planningForm, setPlanningForm] = useState({ startDate: "", endDate: "", label: "" });

  const hydratePlannings = (rows) => {
    const planningRows = (Array.isArray(rows) ? rows : []).map(mapPlanningFromApi);
    setPlannings(planningRows);
    setSelectedPlanningId((prev) => {
      if (prev && planningRows.some((planning) => planning.id === prev)) return prev;
      return getDefaultPlanning(planningRows, new Date())?.id ?? (planningRows[0]?.id || "");
    });
  };

  useEffect(() => {
    const selected = plannings.find((planning) => planning.id === selectedPlanningId);
    if (!selected) {
      setPlanningForm({ startDate: "", endDate: "", label: "" });
      return;
    }
    setPlanningForm({
      startDate: selected.startDate || `${selected.startYear}-01-01`,
      endDate: selected.endDate || `${selected.endYear}-12-31`,
      label: selected.label || "",
    });
  }, [plannings, selectedPlanningId]);

  const selectedPlanning = useMemo(() => plannings.find((planning) => planning.id === selectedPlanningId), [plannings, selectedPlanningId]);

  const handleArchiveYear = async () => {
    ui.setArchiveConfirmOpen(false);
    ui.setArchiveLoading(true);
    ui.setArchiveError(null);
    ui.setArchiveResult(null);
    try {
      const res = await parametersService.archiveCurrentYear();
      ui.setArchiveResult(res.data);
      const planningsRes = await parametersService.fetchPlannings().catch(() => ({ data: { data: [] } }));
      hydratePlannings(planningsRes.data?.data || []);
      ui.showToast("L'année scolaire a été archivée.");
    } catch (err) {
      const message = err.response?.status === 409
        ? err.response.data?.message || "Des inscriptions en attente existent. Veuillez les résoudre avant d'archiver."
        : err.response?.data?.message || "Erreur lors de l'archivage de l'année.";
      ui.setArchiveError(message);
      ui.showToast(message, "error");
    } finally {
      ui.setArchiveLoading(false);
    }
  };

  const handleSavePlanning = async (e) => {
    e.preventDefault();
    if (!selectedPlanningId) return ui.setPlanningMessage({ text: "Sélectionnez une année scolaire.", type: "error" });

    const valid = validatePlanningDates(planningForm.startDate, planningForm.endDate);
    if (!valid) return ui.setPlanningMessage({ text: "Dates de début/fin invalides.", type: "error" });

    const effectiveLabel = planningForm.label.trim() || getPlanningLabel(valid.startYear, valid.endYear);
    const duplicate = plannings.find((planning) => planning.id !== selectedPlanningId && (planning.label || getPlanningLabel(planning.startYear, planning.endYear)) === effectiveLabel);
    if (duplicate) return ui.setPlanningMessage({ text: `Une année scolaire avec le label "${effectiveLabel}" existe déjà.`, type: "error" });

    ui.setSavingPlanning(true);
    ui.setPlanningMessage({ text: "", type: "" });
    try {
      const res = await parametersService.updatePlanning(selectedPlanningId, {
        startYear: valid.startYear,
        endYear: valid.endYear,
        startDate: valid.startDate,
        endDate: valid.endDate,
        label: planningForm.label.trim() || undefined,
      });
      const updated = mapPlanningFromApi(res.data?.data || {});
      setPlannings((prev) => prev.map((planning) => (planning.id === selectedPlanningId ? { ...planning, ...updated } : planning)));
      ui.setPlanningMessage({ text: "Année scolaire mise à jour avec succès.", type: "success" });
      ui.showToast("Année scolaire mise à jour avec succès.");
      setTimeout(() => ui.setPlanningMessage({ text: "", type: "" }), 3000);
    } catch (err) {
      ui.setPlanningMessage({ text: err?.response?.data?.message || "Échec de la mise à jour.", type: "error" });
    } finally {
      ui.setSavingPlanning(false);
    }
  };

  const handleCreatePlanning = async () => {
    const valid = validatePlanningDates(planningForm.startDate, planningForm.endDate);
    if (!valid) return ui.setPlanningMessage({ text: "Dates de début/fin invalides.", type: "error" });

    const effectiveLabel = planningForm.label.trim() || getPlanningLabel(valid.startYear, valid.endYear);
    const duplicate = plannings.find((planning) => (planning.label || getPlanningLabel(planning.startYear, planning.endYear)) === effectiveLabel);
    if (duplicate) return ui.setPlanningMessage({ text: `Une année scolaire avec le label "${effectiveLabel}" existe déjà.`, type: "error" });

    ui.setSavingPlanning(true);
    ui.setPlanningMessage({ text: "", type: "" });
    try {
      const res = await parametersService.createPlanning({
        startYear: valid.startYear,
        endYear: valid.endYear,
        startDate: valid.startDate,
        endDate: valid.endDate,
        label: planningForm.label.trim() || undefined,
      });
      const created = mapPlanningFromApi(res.data?.data || {});
      setPlannings((prev) => [created, ...prev.filter((planning) => planning.id !== created.id)]);
      setSelectedPlanningId(created.id);
      ui.setPlanningMessage({ text: "Nouvelle année scolaire créée.", type: "success" });
      ui.showToast("Nouvelle année scolaire créée.");
      setTimeout(() => ui.setPlanningMessage({ text: "", type: "" }), 3000);
    } catch (err) {
      ui.setPlanningMessage({ text: err?.response?.data?.message || "Échec de la création.", type: "error" });
    } finally {
      ui.setSavingPlanning(false);
    }
  };

  const requestRemovePlanning = () => {
    if (!selectedPlanningId) return ui.setPlanningMessage({ text: "Sélectionnez une année scolaire.", type: "error" });
    ui.setDeletePlanningConfirmOpen(true);
  };

  const handleRemovePlanning = async () => {
    ui.setDeletePlanningConfirmOpen(false);
    if (!selectedPlanningId) return;
    ui.setSavingPlanning(true);
    ui.setPlanningMessage({ text: "", type: "" });
    try {
      await parametersService.deletePlanning(selectedPlanningId);
      const next = plannings.filter((planning) => planning.id !== selectedPlanningId);
      setPlannings(next);
      setSelectedPlanningId(next[0]?.id || "");
      ui.setPlanningMessage({ text: "Année scolaire supprimée.", type: "success" });
      ui.showToast("Année scolaire supprimée.");
      setTimeout(() => ui.setPlanningMessage({ text: "", type: "" }), 3000);
    } catch (err) {
      const raw = err?.response?.data?.message || "";
      const isFkError = raw.includes("Integrity constraint violation") || raw.includes("foreign key constraint") || raw.includes("1451");
      const message = isFkError
        ? "Impossible de supprimer cette année scolaire car des classes ou des inscriptions y sont encore rattachées. Veuillez d'abord les supprimer ou les archiver."
        : raw || "Échec de la suppression.";
      ui.setPlanningMessage({ text: message, type: "error" });
      ui.showToast(message, "error");
    } finally {
      ui.setSavingPlanning(false);
    }
  };

  return {
    plannings, setPlannings,
    selectedPlanningId, setSelectedPlanningId,
    planningForm, setPlanningForm,
    selectedPlanning,
    hydratePlannings,
    handleArchiveYear,
    handleSavePlanning,
    handleCreatePlanning,
    requestRemovePlanning,
    handleRemovePlanning,
  };
};
