import { useState, useCallback, useEffect } from "react";
import { useSearchParams } from "react-router-dom";
import { TAB_MAP } from "../utils/constants";

export const useUIStates = () => {
  const [searchParams, setSearchParams] = useSearchParams();
  const tabParam = searchParams.get("tab") || "planned";
  const [activeTab, setActiveTab] = useState(TAB_MAP[tabParam] ?? 0);
  
  const [expandedMonth, setExpandedMonth] = useState(null);
  const [weekModalInfo, setWeekModalInfo] = useState(null);
  const [selectedClassForWeekId, setSelectedClassForWeekId] = useState("");
  const [dayTimelineInfo, setDayTimelineInfo] = useState(null);
  const [visibleYear, setVisibleYear] = useState(null);

  const [toast, setToast] = useState({ open: false, message: "", severity: "info" });
  
  const [modals, setModals] = useState({
    plan: false,
    criteria: false,
    allActivity: false,
    edit: false,
    delete: false,
  });

  useEffect(() => {
    const tab = searchParams.get("tab") || "planned";
    const tabIndex = TAB_MAP[tab] ?? 0;
    if (tabIndex !== activeTab) setActiveTab(tabIndex);
  }, [searchParams, activeTab]);

  const showToast = useCallback((message, severity = "info") => {
    setToast({ open: true, message, severity });
  }, []);

  const closeToast = useCallback(() => {
    setToast((prev) => ({ ...prev, open: false }));
  }, []);
  
  const showAiUnavailableToast = useCallback((message) => {
    showToast(`${message} Pour continuer sans suggestion IA, désactivez le paramètre IA dans l'interface Paramètres puis poursuivez manuellement.`, "error");
  }, [showToast]);

  const openModal = useCallback((key) => setModals((m) => ({ ...m, [key]: true })), []);
  const closeModal = useCallback((key) => setModals((m) => ({ ...m, [key]: false })), []);

  return {
    searchParams, setSearchParams, tabParam, activeTab, setActiveTab,
    expandedMonth, setExpandedMonth,
    weekModalInfo, setWeekModalInfo,
    selectedClassForWeekId, setSelectedClassForWeekId,
    dayTimelineInfo, setDayTimelineInfo,
    visibleYear, setVisibleYear,
    toast, showToast, closeToast, showAiUnavailableToast,
    modals, openModal, closeModal, setModals
  };
};
