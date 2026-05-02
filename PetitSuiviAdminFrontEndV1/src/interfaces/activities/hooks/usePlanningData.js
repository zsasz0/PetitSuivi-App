import { useState, useCallback, useEffect, useMemo } from "react";
import { activitiesApi } from "../api/activitiesApi";
import { getCurrentPlanningId, getPlanningMonths, getTimelineWindow } from "../utils/activitiesUtils";

export const usePlanningData = ({ dayTimelineInfo, selectedClassForWeekId, setVisibleYear }) => {
  const [loading, setLoading] = useState(true);
  const [plannings, setPlannings] = useState([]);
  const [selectedPlanningId, setSelectedPlanningId] = useState(null);
  const [activitiesList, setActivitiesList] = useState([]);
  const [allActivities, setAllActivities] = useState([]);
  const [criteriaList, setCriteriaList] = useState([]);
  const [allClassesData, setAllClassesData] = useState([]);
  const [classOptions, setClassOptions] = useState([]);
  const [aiEnabled, setAiEnabled] = useState(true);

  const fetchAiEnabled = useCallback(async () => {
    try {
      const res = await activitiesApi.getParameters();
      const data = res.data?.data || res.data || [];
      const aiParam = (Array.isArray(data) ? data : []).find((p) => p.name === "ai_enabled");
      const isEnabled = aiParam ? (aiParam.value === "true" || aiParam.value === "1") : aiEnabled;
      setAiEnabled(isEnabled);
      return isEnabled;
    } catch {
      return aiEnabled;
    }
  }, [aiEnabled]);

  const loadData = useCallback(async () => {
    try {
      setLoading(true);
      const [planningsRes, classesRes, criteriaRes, activitiesRes] = await Promise.all([
        activitiesApi.getPlannings(),
        activitiesApi.getClasses(),
        activitiesApi.getCriteria(),
        activitiesApi.getActivities(),
      ]);
      const planningRows = planningsRes.data?.data || [];
      setPlannings(planningRows);
      if (planningRows.length > 0) setSelectedPlanningId(getCurrentPlanningId(planningRows));
      setAllClassesData(classesRes.data?.data || []);
      setCriteriaList((criteriaRes.data?.data || []).map((c) => ({
        id: c.id,
        name: c.name,
        isUsed: Boolean(c.is_used),
        usageCount: Number(c.usage_count || 0),
      })));
      setAllActivities(
        (activitiesRes.data?.data || []).map((a) => ({
          id: a.id, title: a.title || "", description: a.description || "",
          isUsedInPlanning: Boolean(a.is_used_in_planning),
          planningUsageCount: Number(a.planning_usage_count || 0),
          criteriaIds: (a.criteria || []).map((c) => c.id),
          criteriaNames: (a.criteria || []).map((c) => c.name).join(", ") || "-",
        }))
      );
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  }, []);

  const fetchPlanned = useCallback(async () => {
    if (!selectedPlanningId) return;
    try {
      const res = await activitiesApi.getPlannedActivities(selectedPlanningId);
      const data = (res.data?.data || []).map((a) => ({
        id: a.id, title: a.title || "", description: a.description || "",
        date: (a.date || "").slice(0, 10), startTime: (a.start_time || "").slice(0, 5), endTime: (a.end_time || "").slice(0, 5),
        status: a.status || "pending", className: (a.classes || []).map((c) => c.name).join(", ") || "Toutes",
        classIds: (a.classes || []).map((c) => c.id),
        teacherName: a.teacher ? `${a.teacher.firstName || ""} ${a.teacher.lastName || ""}`.trim() : "Admin",
      }));
      setActivitiesList(data);
    } catch (err) {
      console.error(err);
    }
  }, [selectedPlanningId]);

  useEffect(() => { loadData(); fetchAiEnabled(); }, [loadData, fetchAiEnabled]);
  useEffect(() => { fetchPlanned(); }, [selectedPlanningId, fetchPlanned]);

  const criteriaNameMap = useMemo(() => Object.fromEntries(criteriaList.map((c) => [c.id, c.name])), [criteriaList]);
  const selectedPlanning = useMemo(() => plannings.find((p) => String(p.id) === String(selectedPlanningId)), [plannings, selectedPlanningId]);
  const isArchived = selectedPlanning?.is_archived === true || selectedPlanning?.is_archived === 1;

  useEffect(() => {
    if (!selectedPlanning) return;
    const startYear = selectedPlanning.start_date ? new Date(selectedPlanning.start_date).getFullYear() : null;
    const validClasses = allClassesData.filter((c) => (c.is_archived && !isArchived) ? false : (!startYear ? true : c.year === startYear));
    setClassOptions(validClasses.map((c) => ({ id: c.id, name: c.name, label: c.is_archived ? `${c.name} (Archivée)` : c.name, creation_year: c.year })));
  }, [selectedPlanning, allClassesData, isArchived]);

  const activityMap = useMemo(() => {
    const map = {};
    activitiesList.forEach((a) => { if (!map[a.date]) map[a.date] = []; map[a.date].push(a); });
    return map;
  }, [activitiesList]);

  const monthActivityCounts = useMemo(() => {
    const counts = {};
    activitiesList.forEach((a) => { if (a.date) { const key = a.date.slice(0, 7); counts[key] = (counts[key] || 0) + 1; }});
    return counts;
  }, [activitiesList]);

  const today = useMemo(() => new Date(), []);
  const planningStartYear = selectedPlanning?.startDate ? new Date(selectedPlanning.startDate).getFullYear() : selectedPlanning?.start_date ? new Date(selectedPlanning.start_date).getFullYear() : today.getFullYear();
  const planningEndYear = selectedPlanning?.endDate ? new Date(selectedPlanning.endDate).getFullYear() : selectedPlanning?.end_date ? new Date(selectedPlanning.end_date).getFullYear() : planningStartYear + 1;
  const planningMonthKeys = useMemo(() => new Set(getPlanningMonths(selectedPlanning)), [selectedPlanning]);

  useEffect(() => { setVisibleYear(planningStartYear); }, [planningStartYear, setVisibleYear]);

  const dayTimelineActivities = useMemo(() => {
    if (!dayTimelineInfo?.dateStr) return [];
    return (activityMap[dayTimelineInfo.dateStr] || [])
      .filter((a) => !selectedClassForWeekId || (a.classIds || []).includes(Number(selectedClassForWeekId)))
      .sort((a, b) => (a.startTime || "").localeCompare(b.startTime || ""));
  }, [activityMap, dayTimelineInfo, selectedClassForWeekId]);

  const timelineWindow = useMemo(() => getTimelineWindow(dayTimelineActivities), [dayTimelineActivities]);

  return {
    loading, plannings, setPlannings, selectedPlanningId, setSelectedPlanningId,
    activitiesList, setActivitiesList, allActivities, setAllActivities,
    criteriaList, setCriteriaList, classOptions, aiEnabled, fetchAiEnabled, fetchPlanned,
    criteriaNameMap, selectedPlanning, isArchived, activityMap, monthActivityCounts,
    planningStartYear, planningEndYear, planningMonthKeys, dayTimelineActivities, timelineWindow, today
  };
};
