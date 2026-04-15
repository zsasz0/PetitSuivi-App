import { useState, useEffect, useCallback, useMemo } from "react";
import { behavioralHistoryService } from "../api/behavioralHistoryService";
import { ITEMS_PER_PAGE } from "../utils/constants";

export const useBehavioralHistoryController = () => {
  const [plannings, setPlannings] = useState([]);
  const [selectedPlanningId, setSelectedPlanningId] = useState("");
  const [analysisHistory, setAnalysisHistory] = useState([]);
  const [loadingHistory, setLoadingHistory] = useState(false);
  const [expandedHistoryId, setExpandedHistoryId] = useState(null);
  const [page, setPage] = useState(1);
  const [searchTerm, setSearchTerm] = useState("");

  useEffect(() => {
    const fetchPlannings = async () => {
      try {
        const planningList = await behavioralHistoryService.fetchPlannings();
        setPlannings(planningList);

        if (planningList.length > 0) {
          const sorted = [...planningList].sort((a, b) => {
            const aYear = Number(a.startYear || a.start_year) || 0;
            const bYear = Number(b.startYear || b.start_year) || 0;
            return bYear - aYear;
          });
          setSelectedPlanningId(sorted[0].id);
        }
      } catch (error) {
        console.error(error);
      }
    };

    fetchPlannings();
  }, []);

  const fetchHistory = useCallback(async (planningId) => {
    try {
      setLoadingHistory(true);
      const history = await behavioralHistoryService.fetchHistory(planningId);
      setAnalysisHistory(history);
    } catch {
      setAnalysisHistory([]);
    } finally {
      setLoadingHistory(false);
    }
  }, []);

  useEffect(() => {
    if (!selectedPlanningId) return;
    fetchHistory(selectedPlanningId);
    setPage(1);
    setExpandedHistoryId(null);
  }, [selectedPlanningId, fetchHistory]);

  useEffect(() => {
    setPage(1);
  }, [searchTerm]);

  const filteredHistory = useMemo(() => {
    if (!searchTerm) return analysisHistory;

    const normalizedTerm = searchTerm.toLowerCase();
    return analysisHistory.filter((entry) => {
      const fullName = `${entry.child_first_name || ""} ${entry.child_last_name || ""}`.toLowerCase();
      return fullName.includes(normalizedTerm);
    });
  }, [analysisHistory, searchTerm]);

  const totalPages = Math.max(1, Math.ceil(filteredHistory.length / ITEMS_PER_PAGE));

  const paginatedHistory = useMemo(() => {
    const start = (page - 1) * ITEMS_PER_PAGE;
    return filteredHistory.slice(start, start + ITEMS_PER_PAGE);
  }, [filteredHistory, page]);

  const stats = useMemo(() => {
    const totalAnalyses = filteredHistory.length;
    const uniqueChildren = new Set(
      filteredHistory.map((entry) => entry.child_id || `${entry.child_first_name}_${entry.child_last_name}`)
    ).size;
    const totalSignals = filteredHistory.reduce(
      (sum, entry) => sum + (entry.analyzed_signalement_ids?.length || 0),
      0
    );

    return { totalAnalyses, uniqueChildren, totalSignals };
  }, [filteredHistory]);

  return {
    plannings,
    selectedPlanningId,
    setSelectedPlanningId,
    analysisHistory,
    loadingHistory,
    expandedHistoryId,
    setExpandedHistoryId,
    page,
    setPage,
    searchTerm,
    setSearchTerm,
    filteredHistory,
    totalPages,
    paginatedHistory,
    stats,
  };
};
