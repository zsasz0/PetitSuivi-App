import { useState, useMemo, useEffect } from "react";
import { parametersService } from "../api/parametersService";
import {
  HIDDEN_PARAMS,
  getParamCategory,
  getInputType,
} from "../utils/parametersUtils";

export const useParametersData = ({ ui, planningsData }) => {
  const [params, setParams] = useState([]);
  const [aiEnabled, setAiEnabled] = useState(true);
  const [aiParamId, setAiParamId] = useState(null);
  const [inscriptionsOpen, setInscriptionsOpen] = useState(true);
  const [inscriptionsParamId, setInscriptionsParamId] = useState(null);
  const [signature, setSignature] = useState({ url: "", isDefault: true });
  // init data
  useEffect(() => {
    const fetchAll = async () => {
      try {
        ui.setLoading(true);
        const [paramsRes, planningsRes, signatureRes] = await Promise.all([
          parametersService.fetchParameters().catch(() => ({ data: { data: [] } })),
          parametersService.fetchPlannings().catch(() => ({ data: { data: [] } })),
          parametersService.fetchSignature().catch(() => ({ data: { data: null } })),
        ]);

        const data = paramsRes.data?.data || paramsRes.data || [];
        const arr = Array.isArray(data) ? data : [];

        const aiParam = arr.find((p) => p.name === "ai_enabled");
        if (aiParam) {
          setAiParamId(aiParam.id);
          setAiEnabled(aiParam.value === "true" || aiParam.value === "1");
        }

        const inscParam = arr.find((p) => p.name === "inscriptions_open");
        if (inscParam) {
          setInscriptionsParamId(inscParam.id);
          setInscriptionsOpen(inscParam.value === "true" || inscParam.value === "1");
        }

        setParams(arr.map((p) => ({ id: p.id, name: p.name || "", value: p.value ?? "" })));
        const signatureData = signatureRes.data?.data || null;
        setSignature({
          url: signatureData?.url || "",
          isDefault: Boolean(signatureData?.is_default ?? true),
        });
        planningsData.hydratePlannings(planningsRes.data?.data || []);
      } catch (err) {
        ui.setError(err?.response?.data?.message || "Erreur de chargement.");
      } finally {
        ui.setLoading(false);
      }
    };
    fetchAll();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const visibleParams = useMemo(() => params.filter((p) => !HIDDEN_PARAMS.includes(p.name)), [params]);
  
  const groupedParams = useMemo(() => {
    return visibleParams.reduce((acc, p) => {
      const category = getParamCategory(p.name);
      acc[category].push(p);
      return acc;
    }, { identity: [], meals: [], contact: [], fees: [], other: [] });
  }, [visibleParams]);

  const hasParamValidationError = visibleParams.some((p) => {
    const isNumber = getInputType(p.name) === "number";
    return isNumber && !/^\d*\.?\d*$/.test(p.value);
  });

  const handleChange = (id, newValue) => {
    setParams((prev) => prev.map((p) => (p.id === id ? { ...p, value: newValue } : p)));
  };

  const handleToggleAi = async () => {
    if (!aiParamId) return;
    const newValue = !aiEnabled;
    ui.setSavingAi(true);
    try {
      await parametersService.updateParameters([{ id: aiParamId, value: newValue ? "true" : "false" }]);
      setAiEnabled(newValue);
      setParams((prev) => prev.map((p) => (p.id === aiParamId ? { ...p, value: newValue ? "true" : "false" } : p)));
      ui.showToast(newValue ? "Le module IA a été activé." : "Le module IA a été désactivé.");
    } catch (err) {
      ui.showToast(err?.response?.data?.message || "Erreur lors du changement du module IA.", "error");
    } finally {
      ui.setSavingAi(false);
      ui.closeToggleConfirm();
    }
  };

  const handleToggleInscriptions = async () => {
    if (!inscriptionsParamId) return;
    const newValue = !inscriptionsOpen;
    ui.setSavingInscriptions(true);
    try {
      await parametersService.updateParameters([{ id: inscriptionsParamId, value: newValue ? "true" : "false" }]);
      setInscriptionsOpen(newValue);
      setParams((prev) => prev.map((p) => (p.id === inscriptionsParamId ? { ...p, value: newValue ? "true" : "false" } : p)));
      ui.showToast(newValue ? "Les inscriptions sont ouvertes." : "Les inscriptions sont maintenant fermées.");
    } catch (err) {
      ui.showToast(err?.response?.data?.message || "Erreur lors du changement de l'état des inscriptions.", "error");
    } finally {
      ui.setSavingInscriptions(false);
      ui.closeToggleConfirm();
    }
  };

  const handleSaveParams = async () => {
    ui.setSaving(true);
    ui.setError("");
    ui.setSuccess("");
    try {
      await parametersService.updateParameters(params.map((p) => ({ id: p.id, value: p.value })));
      ui.setSuccess("Paramètres enregistrés avec succès.");
      ui.showToast("Paramètres enregistrés avec succès.");
      setTimeout(() => ui.setSuccess(""), 3000);
    } catch (err) {
      const message = err?.response?.data?.message || "Erreur lors de l'enregistrement.";
      ui.setError(message);
      ui.showToast(message, "error");
    } finally {
      ui.setSaving(false);
    }
  };

  const handleUploadSignature = async (file) => {
    if (!file) return;
    ui.setUploadingSignature(true);
    try {
      const response = await parametersService.uploadSignature(file);
      const signatureData = response.data?.data || null;
      setSignature({
        url: signatureData?.url || "",
        isDefault: Boolean(signatureData?.is_default),
      });
      ui.showToast("Signature enregistrée avec succès.");
    } catch (err) {
      ui.showToast(err?.response?.data?.message || "Erreur lors de l'envoi de la signature.", "error");
    } finally {
      ui.setUploadingSignature(false);
    }
  };

  const handleDeleteSignature = async () => {
    ui.setDeletingSignature(true);
    try {
      const response = await parametersService.deleteSignature();
      const signatureData = response.data?.data || null;
      setSignature({
        url: signatureData?.url || "",
        isDefault: Boolean(signatureData?.is_default ?? true),
      });
      ui.showToast("Signature par défaut restaurée.");
    } catch (err) {
      ui.showToast(err?.response?.data?.message || "Erreur lors de la suppression de la signature.", "error");
    } finally {
      ui.setDeletingSignature(false);
    }
  };

  return {
    params, setParams,
    aiEnabled,
    inscriptionsOpen,
    signature,
    visibleParams,
    groupedParams,
    hasParamValidationError,
    handleChange,
    handleToggleAi,
    handleToggleInscriptions,
    handleUploadSignature,
    handleDeleteSignature,
    handleSaveParams,
  };
};
