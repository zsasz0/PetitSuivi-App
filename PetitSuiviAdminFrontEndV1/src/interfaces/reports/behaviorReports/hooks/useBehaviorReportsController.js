import { useState, useEffect, useCallback, useMemo } from "react";
import { behaviorReportsService } from "../api/behaviorReportsService";
import { formatDate } from "../utils/formatters";

export const useBehaviorReportsController = () => {
  const [toast, setToast] = useState({ open: false, message: "", severity: "info" });
  const [plannings, setPlannings] = useState([]);
  const [selectedPlanningId, setSelectedPlanningId] = useState("");
  const [reportData, setReportData] = useState(null);
  const [loading, setLoading] = useState(false);
  const [aiEnabled, setAiEnabled] = useState(true);
  const [aiAnalysis, setAiAnalysis] = useState(null);
  const [isAnalyzing, setIsAnalyzing] = useState(false);
  const [analysisHistory, setAnalysisHistory] = useState([]);
  const [, setLoadingHistory] = useState(false);
  const [searchTerm, setSearchTerm] = useState("");
  const [expandedChild, setExpandedChild] = useState(null);
  const [isAiPanelOpen, setIsAiPanelOpen] = useState(false);

  useEffect(() => {
    const initData = async () => {
      try {
        const planningList = await behaviorReportsService.fetchPlannings();
        setPlannings(planningList);

        if (planningList.length > 0) {
          const sorted = [...planningList].sort((a, b) => {
            const aYear = Number(a.startYear || a.start_year) || 0;
            const bYear = Number(b.startYear || b.start_year) || 0;
            return bYear - aYear;
          });
          setSelectedPlanningId(sorted[0].id);
        }

        try {
          const isAiOn = await behaviorReportsService.fetchAiEnabled();
          setAiEnabled(isAiOn);
        } catch {
          // ignore specific AI fetch errors to keep default UI state
        }
      } catch (error) {
        console.error(error);
      }
    };
    initData();
  }, []);

  const fetchHistory = useCallback(async (planningId) => {
    try {
      setLoadingHistory(true);
      const history = await behaviorReportsService.fetchHistory(planningId);
      setAnalysisHistory(history);
    } catch {
      setAnalysisHistory([]);
    } finally {
      setLoadingHistory(false);
    }
  }, []);

  useEffect(() => {
    if (!selectedPlanningId) return;

    const loadReportData = async () => {
      setLoading(true);
      try {
        const data = await behaviorReportsService.fetchReport(selectedPlanningId);
        setReportData(data);
      } catch (error) {
        console.error(error);
      } finally {
        setLoading(false);
      }
    };

    loadReportData();
    fetchHistory(selectedPlanningId);
    setAiAnalysis(null);
    setExpandedChild(null);
    setIsAiPanelOpen(false);
  }, [selectedPlanningId, fetchHistory]);

  const allFlaggedChildren = useMemo(() => {
    if (!reportData?.classes) return [];

    const children = [];
    reportData.classes.forEach((schoolClass) => {
      schoolClass.children.forEach((child) => {
        if (child.signalements.length > 0) {
          children.push({
            ...child,
            class_name: schoolClass.class_name,
            class_id: schoolClass.class_id,
          });
        }
      });
    });

    return children;
  }, [reportData]);

  const filteredChildren = useMemo(() => {
    if (!searchTerm) return allFlaggedChildren;

    const normalizedTerm = searchTerm.toLowerCase();
    return allFlaggedChildren.filter(
      (child) =>
        (child.child_name || "").toLowerCase().includes(normalizedTerm) ||
        (child.class_name || "").toLowerCase().includes(normalizedTerm)
    );
  }, [allFlaggedChildren, searchTerm]);

  const totalSignalements = useMemo(
    () => allFlaggedChildren.reduce((sum, child) => sum + child.signalements.length, 0),
    [allFlaggedChildren]
  );

  const analyzedSignalementIds = useMemo(() => {
    const ids = new Set();
    analysisHistory.forEach((entry) => {
      (entry.analyzed_signalement_ids || []).forEach((id) => ids.add(id));
    });
    return ids;
  }, [analysisHistory]);

  const closeToast = () => setToast((prev) => ({ ...prev, open: false }));

  const handleAnalyze = async (forceAll = false) => {
    if (!reportData) return;

    setIsAnalyzing(true);
    setIsAiPanelOpen(true);

    try {
      const childrenToAnalyze = allFlaggedChildren;
      if (childrenToAnalyze.length === 0) {
        setToast({ open: true, message: "Aucun élève avec des signalements.", severity: "warning" });
        setAiAnalysis({ error: "Aucun élève avec des signalements." });
        return;
      }

      const childrenText = childrenToAnalyze
        .map((child) => {
          const signalements = child.signalements
            .filter((signalement) => forceAll || !analyzedSignalementIds.has(signalement.id))
            .map(
              (signalement) =>
                `- Type: ${signalement.alert_type} | "${signalement.comment || "Sans commentaire"}" (${formatDate(signalement.incident_time)})`
            )
            .join("\n  ");

          if (!signalements) return null;

          return `Élève: ${child.child_name} (Classe: ${child.class_name})\n  Signalements:\n  ${signalements}`;
        })
        .filter(Boolean)
        .join("\n\n");

      if (!childrenText) {
        setToast({ open: true, message: "Tous les signalements ont déjà été analysés.", severity: "info" });
        setAiAnalysis({ error: "Tous les signalements ont déjà été analysés." });
        return;
      }

      const response = await behaviorReportsService.requestAiAnalysis(childrenText);

      if (!response?.output) return;

      let jsonText = response.output.trim();
      const jsonMatch = jsonText.match(/```(?:json)?\s*([\s\S]*?)\s*```/i);
      if (jsonMatch) {
        jsonText = jsonMatch[1];
      } else {
        const firstBrace = jsonText.indexOf('{');
        const lastBrace = jsonText.lastIndexOf('}');
        if (firstBrace !== -1 && lastBrace !== -1) {
          jsonText = jsonText.substring(firstBrace, lastBrace + 1);
        }
      }
      jsonText = jsonText.trim();

      try {
        const parsed = JSON.parse(jsonText);
        setToast({ open: true, message: "Analyse terminée avec succès.", severity: "success" });
        setAiAnalysis(parsed);

        for (const child of childrenToAnalyze) {
          const childResult = (parsed.eleves || []).find(
            (student) => (student.nom || "").toLowerCase().trim() === (child.child_name || "").toLowerCase().trim()
          );

          if (!childResult) continue;

          const childSignalementIds = child.signalements.map((signalement) => signalement.id);
          await behaviorReportsService.saveAnalysisHistory(
            selectedPlanningId,
            child.child_id,
            childResult,
            childSignalementIds
          );
        }

        await fetchHistory(selectedPlanningId);
      } catch {
        setToast({ open: true, message: "Format JSON invalide retourné par l'IA.", severity: "error" });
        setAiAnalysis({ error: "Format JSON invalide.", raw: response.output });
      }
    } catch (error) {
      setToast({ open: true, message: `Erreur IA: ${error?.response?.data?.message || error.message}`, severity: "error" });
      setAiAnalysis({ error: `Erreur IA: ${error?.response?.data?.message || error.message}` });
    } finally {
      setIsAnalyzing(false);
    }
  };

  return {
    toast,
    closeToast,
    plannings,
    selectedPlanningId,
    setSelectedPlanningId,
    reportData,
    loading,
    aiEnabled,
    aiAnalysis,
    isAnalyzing,
    analysisHistory,
    searchTerm,
    setSearchTerm,
    expandedChild,
    setExpandedChild,
    isAiPanelOpen,
    setIsAiPanelOpen,
    allFlaggedChildren,
    filteredChildren,
    totalSignalements,
    analyzedSignalementIds,
    handleAnalyze
  };
};
