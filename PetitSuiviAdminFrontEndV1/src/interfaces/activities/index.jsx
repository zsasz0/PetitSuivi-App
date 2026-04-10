/**
 * @file activities/index.jsx
 * @description Activity Planning and Library Interface.
 * Allows administrators to plan activities across the school year and manage
 * a global library of activities with associated criteria.
 *
 * @state activeTab - Tracks selected tab (Planned, Criteria, All).
 * @state plannings - List of all plannings/school years.
 * @state activitiesList - Activities planned for the current year.
 * @state allActivities - Master catalog of standard activities.
 * @state criteriaList - Master list of activity evaluation criteria.
 *
 * @endpoint GET /admin/plannings - Retrieves all academic plannings.
 * @endpoint GET /admin/classes - Retrieves all registered classes.
 * @endpoint GET /admin/criteria - Retrieves global evaluation criteria.
 * @endpoint GET /admin/activities - Retrieves the activity catalog.
 * @endpoint GET /admin/parameters - Checks 'ai_enabled' status.
 * @endpoint GET /admin/plannings/{id}/activities - Retrieves planned activities.
 * @endpoint POST /admin/plannings/{id}/activities - Books an activity to a class.
 * @endpoint DELETE /admin/plannings/{id}/activities/{activityId} - Unbooks an activity.
 * @endpoint POST /admin/criteria - Creates a new criterion.
 * @endpoint DELETE /admin/criteria/{id} - Deletes a criterion.
 * @endpoint POST /admin/activities - Adds activity to the global catalog.
 * @endpoint PUT /admin/activities/{id} - Edits an existing catalog activity.
 * @endpoint DELETE /admin/activities/{id} - Removes an activity from the catalog.
 * @endpoint POST /admin/ai/suggest-activity-criteria - Suggests criteria via AI.
 */

import React, { useState, useEffect, useMemo, useCallback } from "react";
import { useSearchParams } from "react-router-dom";
import {
  Box,
  Typography,
  Button,
  FormControl,
  Select,
  MenuItem,
  Tabs,
  Tab,
  TextField,
  InputLabel,
  Chip,
  CircularProgress,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Alert,
  IconButton,
  Autocomplete,
  Portal,
  Snackbar,
  Tooltip,
} from "@mui/material";
import {
  DataGrid,
  GridToolbarContainer,
  GridToolbarFilterButton,
} from "@mui/x-data-grid";
import ExpandLessIcon from "@mui/icons-material/ExpandLess";
import ExpandMoreIcon from "@mui/icons-material/ExpandMore";
import CloseIcon from "@mui/icons-material/Close";
import DeleteOutlineIcon from "@mui/icons-material/DeleteOutline";
import EditOutlinedIcon from "@mui/icons-material/EditOutlined";
import AddRoundedIcon from "@mui/icons-material/AddRounded";
import TaskAltOutlinedIcon from "@mui/icons-material/TaskAltOutlined";
import MenuBookOutlinedIcon from "@mui/icons-material/MenuBookOutlined";
import EventRepeatOutlinedIcon from "@mui/icons-material/EventRepeatOutlined";
import AcUnitIcon from "@mui/icons-material/AcUnit";
import WaterIcon from "@mui/icons-material/Water";
import LocalFloristIcon from "@mui/icons-material/LocalFlorist";
import SpaIcon from "@mui/icons-material/Spa";
import YardIcon from "@mui/icons-material/Yard";
import WbSunnyIcon from "@mui/icons-material/WbSunny";
import BeachAccessIcon from "@mui/icons-material/BeachAccess";
import LandscapeIcon from "@mui/icons-material/Landscape";
import ForestIcon from "@mui/icons-material/Forest";
import EnergySavingsLeafIcon from "@mui/icons-material/EnergySavingsLeaf";
import ParkIcon from "@mui/icons-material/Park";
import FestivalIcon from "@mui/icons-material/Festival";
import { useTheme } from "@mui/material/styles";

import Header from "../../components/Header";
import { tokens } from "../../theme";
import api from "../../api/axios";
import { getAdminPrimaryButtonSx, getAdminSecondaryButtonSx } from "../../utils/adminActionButtons";

const TAB_MAP = { planned: 0, criteria: 1, all: 2 };
const TAB_KEYS = ["planned", "criteria", "all"];

const normalizeCriterionName = (name) =>
  (name || "")
    .toLowerCase()
    .trim()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "");

const toUniqueIntegerIds = (arr) => [
  ...new Set((arr || []).map(Number).filter((n) => Number.isInteger(n))),
];

function parseSuggestedCriterionIds(rawOutput, criteriaList) {
  const allowedIds = new Set(
    criteriaList.map((c) => Number(c.id)).filter((id) => Number.isInteger(id)),
  );
  const criteriaByName = new Map(
    criteriaList.map((c) => [normalizeCriterionName(c.name), Number(c.id)]),
  );
  const sanitize = (ids) =>
    toUniqueIntegerIds(ids).filter((id) => allowedIds.has(id));
  const mapNames = (names) =>
    toUniqueIntegerIds(
      (Array.isArray(names) ? names : [names])
        .map((n) => criteriaByName.get(normalizeCriterionName(n)))
        .filter(Boolean),
    );
  const text = String(rawOutput || "").trim();
  if (!text) return [];
  const clean = text
    .replace(/^```(?:json)?\s*/i, "")
    .replace(/\s*```$/i, "")
    .trim();
  const tryParse = (c) => {
    if (!c) return [];
    if (Array.isArray(c)) {
      const n = sanitize(c);
      return n.length > 0 ? n : sanitize(mapNames(c));
    }
    if (typeof c === "object") {
      for (const k of [
        "criteriaIds",
        "criterionIds",
        "ids",
        "criteria",
        "suggestedCriteria",
      ]) {
        if (k in c) {
          const r = tryParse(c[k]);
          if (r.length > 0) return r;
        }
      }
    }
    return [];
  };
  try {
    const p = JSON.parse(clean);
    const s = tryParse(p);
    if (s.length > 0) return s;
  } catch {}
  const fromText = sanitize((clean.match(/\b\d+\b/g) || []).map(Number));
  if (fromText.length > 0) return fromText;
  const low = normalizeCriterionName(clean);
  return sanitize(
    criteriaList
      .filter((c) => low.includes(normalizeCriterionName(c.name)))
      .map((c) => Number(c.id)),
  );
}

const MONTHS_FR = [
  "Janvier",
  "Février",
  "Mars",
  "Avril",
  "Mai",
  "Juin",
  "Juillet",
  "Août",
  "Septembre",
  "Octobre",
  "Novembre",
  "Décembre",
];
const MONTH_ICONS = [
  <AcUnitIcon />,
  <WaterIcon />,
  <LocalFloristIcon />,
  <SpaIcon />,
  <YardIcon />,
  <WbSunnyIcon />,
  <BeachAccessIcon />,
  <LandscapeIcon />,
  <ForestIcon />,
  <EnergySavingsLeafIcon />,
  <ParkIcon />,
  <FestivalIcon />,
];
const WEEKDAYS_FR = ["Lun", "Mar", "Mer", "Jeu", "Ven", "Sam", "Dim"];

const TIMELINE_COLORS = [
  "#3b82f6",
  "#ef4444",
  "#10b981",
  "#f59e0b",
  "#8b5cf6",
  "#ec4899",
  "#14b8a6",
  "#f97316",
];

const getCurrentPlanningId = (planningRows) => {
  if (!planningRows.length) return null;

  const today = new Date().toISOString().slice(0, 10);
  const currentPlanning = planningRows.find((planning) => {
    const startDate = planning.startDate || planning.start_date;
    const endDate = planning.endDate || planning.end_date;
    return startDate && endDate && startDate <= today && endDate >= today;
  });

  return currentPlanning?.id || planningRows.find((planning) => planning.is_active)?.id || planningRows[0].id;
};

const normalizeActivityTitle = (value) => String(value || "").trim().toLowerCase();

const ActivitiesFilterToolbar = ({ colors, isDark }) => {
  const toolbarBg = isDark ? "rgba(148, 163, 184, 0.08)" : "#eef2f7";
  const border = isDark ? "rgba(148, 163, 184, 0.16)" : "rgba(148, 163, 184, 0.28)";

  return (
    <GridToolbarContainer
      sx={{
        px: "16px",
        py: "14px",
        borderBottom: `1px solid ${border}`,
        backgroundColor: toolbarBg,
      }}
    >
      <GridToolbarFilterButton
        sx={{
          borderRadius: "999px",
          px: "14px",
          py: "6px",
          textTransform: "none",
          fontWeight: 700,
          color: colors.grey[200],
          border: `1px solid ${border}`,
          backgroundColor: isDark ? "rgba(15, 23, 42, 0.42)" : "rgba(255,255,255,0.82)",
        }}
      />
    </GridToolbarContainer>
  );
};

const parseTimeToMinutes = (t) => {
  if (!t) return null;
  const [h, m] = t.split(":").map(Number);
  if (isNaN(h) || isNaN(m)) return null;
  return h * 60 + m;
};

const formatMinutesToHourLabel = (m) => {
  const h = Math.floor(m / 60);
  const mm = m % 60;
  return `${String(h).padStart(2, "0")}:${String(mm).padStart(2, "0")}`;
};

const getTimelineWindow = (activities) => {
  let minStart = 8 * 60;
  let maxEnd = 16 * 60;
  if (!activities || activities.length === 0)
    return { start: minStart, end: maxEnd };
  for (const a of activities) {
    const start = parseTimeToMinutes(a.startTime);
    const end = parseTimeToMinutes(a.endTime);
    if (start !== null) minStart = Math.min(minStart, start);
    if (end !== null) maxEnd = Math.max(maxEnd, end);
  }
  return {
    start: Math.max(0, minStart - 30),
    end: Math.min(24 * 60, maxEnd + 30),
  };
};

const getPlanningMonths = (planning) => {
  if (!planning) return [];
  const startDateStr = planning.start_date || planning.startDate;
  const endDateStr = planning.end_date || planning.endDate;
  if (!startDateStr || !endDateStr) return [];

  const start = new Date(`${startDateStr.slice(0, 10)}T00:00:00`);
  const end = new Date(`${endDateStr.slice(0, 10)}T00:00:00`);
  if (isNaN(start) || isNaN(end) || end < start) return [];

  const months = [];
  const cur = new Date(start.getFullYear(), start.getMonth(), 1);
  const endMonth = new Date(end.getFullYear(), end.getMonth(), 1);
  while (cur <= endMonth) {
    months.push(
      `${cur.getFullYear()}-${String(cur.getMonth() + 1).padStart(2, "0")}`,
    );
    cur.setMonth(cur.getMonth() + 1);
  }
  return months;
};

const getWeeksOfMonth = (year, month) => {
  const firstDay = new Date(year, month, 1);
  const lastDay = new Date(year, month + 1, 0);
  const weeks = [];
  let current = new Date(firstDay);
  const dayOfWeek = current.getDay();
  const mondayOffset = dayOfWeek === 0 ? -6 : 1 - dayOfWeek;
  current.setDate(current.getDate() + mondayOffset);

  while (current <= lastDay || current.getDay() !== 1) {
    const week = [];
    for (let i = 0; i < 7; i++) {
      week.push({
        date: new Date(current),
        dow: i,
        day: current.getDate(),
        inMonth: current.getMonth() === month,
        dateStr: `${current.getFullYear()}-${String(current.getMonth() + 1).padStart(2, "0")}-${String(current.getDate()).padStart(2, "0")}`,
      });
      current.setDate(current.getDate() + 1);
    }
    weeks.push(week);
    if (current > lastDay && current.getDay() === 1) break;
  }
  return weeks;
};

const Activities = () => {
  const theme = useTheme();
  const colors = tokens(theme.palette.mode);
  const isDark = theme.palette.mode === "dark";
  const [searchParams, setSearchParams] = useSearchParams();
  const tabParam = searchParams.get("tab") || "planned";
  const [activeTab, setActiveTab] = useState(TAB_MAP[tabParam] ?? 0);
  const [, setLoading] = useState(true);

  const [plannings, setPlannings] = useState([]);
  const [selectedPlanningId, setSelectedPlanningId] = useState(null);
  const [activitiesList, setActivitiesList] = useState([]);
  const [allActivities, setAllActivities] = useState([]);
  const [criteriaList, setCriteriaList] = useState([]);
  // used to populate the class dropdown in the add activity form
  const [allClassesData, setAllClassesData] = useState([]);
  const [classOptions, setClassOptions] = useState([]);

  // Calendar state
  const [expandedMonth, setExpandedMonth] = useState(null);

  // Week Dialog state
  const [weekModalInfo, setWeekModalInfo] = useState(null); // { year, month, weekIndex, weekDates }
  const [selectedClassForWeekId, setSelectedClassForWeekId] = useState("");

  // Day Timeline Dialog state
  const [dayTimelineInfo, setDayTimelineInfo] = useState(null); // { dateStr, dow, day, month, year }

  // Add activity Form inside Dialog
  const [planModalOpen, setPlanModalOpen] = useState(false);
  const [addActivityForm, setAddActivityForm] = useState({
    activityId: "",
    date: "",
    startTime: "",
    endTime: "",
    classIds: [],
  });
  const [addActivityError, setAddActivityError] = useState("");
  const [addActivitySaving, setAddActivitySaving] = useState(false);

  const [newCriteriaName, setNewCriteriaName] = useState("");
  const [addCriteriaError, setAddCriteriaError] = useState("");
  const [addCriteriaSaving, setAddCriteriaSaving] = useState(false);
  const [isCriteriaDialogOpen, setIsCriteriaDialogOpen] = useState(false);

  const [addAllActivityForm, setAddAllActivityForm] = useState({
    title: "",
    description: "",
    criteriaIds: [],
  });
  const [addAllActivityError, setAddAllActivityError] = useState("");
  const [addAllActivitySaving, setAddAllActivitySaving] = useState(false);
  const [suggestingCriteria, setSuggestingCriteria] = useState(false);
  const [maxSuggestedCriteria, setMaxSuggestedCriteria] = useState(2);
  const [isAllActivityDialogOpen, setIsAllActivityDialogOpen] = useState(false);

  // AI enabled
  const [aiEnabled, setAiEnabled] = useState(true);
  const [toast, setToast] = useState({ open: false, message: "", severity: "info" });

  const [isEditDialogOpen, setIsEditDialogOpen] = useState(false);
  const [editingActivity, setEditingActivity] = useState(null);
  const [editForm, setEditForm] = useState({
    title: "",
    description: "",
    criteriaIds: [],
  });
  const [editFormError, setEditFormError] = useState("");

  const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false);
  const [deletingItem, setDeletingItem] = useState(null);
  const [deleteType, setDeleteType] = useState("");

  useEffect(() => {
    /**
     * This function will load all the data from the backend.
     *
     * @returns {void}
     */
    const load = async () => {
      try {
        setLoading(true);
        const [planningsRes, classesRes, criteriaRes, activitiesRes] =
          await Promise.all([
            api.get("/admin/plannings").catch(() => ({ data: { data: [] } })),
            api.get("/admin/classes").catch(() => ({ data: { data: [] } })),
            api.get("/admin/criteria").catch(() => ({ data: { data: [] } })),
            api.get("/admin/activities").catch(() => ({ data: { data: [] } })),
          ]);
        const planningRows = planningsRes.data?.data || [];
        setPlannings(planningRows);
        if (planningRows.length > 0) setSelectedPlanningId(getCurrentPlanningId(planningRows));
        const fetchedClasses = classesRes.data?.data || [];
        setAllClassesData(fetchedClasses);
        setCriteriaList(
          (criteriaRes.data?.data || []).map((c) => ({
            id: c.id,
            name: c.name,
          })),
        );
        setAllActivities(
          (activitiesRes.data?.data || []).map((a) => ({
            id: a.id,
            title: a.title || "",
            description: a.description || "",
            criteriaIds: (a.criteria || []).map((c) => c.id),
            criteriaNames:
              (a.criteria || []).map((c) => c.name).join(", ") || "-",
          })),
        );
      } catch (err) {
        console.error(err);
      } finally {
        setLoading(false);
      }
    };
    const fetchAiEnabled = async () => {
      try {
        const res = await api.get("/admin/parameters");
        const data = res.data?.data || res.data || [];
        const arr = Array.isArray(data) ? data : [];
        const aiParam = arr.find((p) => p.name === "ai_enabled");
        if (aiParam)
          setAiEnabled(aiParam.value === "true" || aiParam.value === "1");
      } catch {
        /* ignore */
      }
    };
    load();
    fetchAiEnabled();
  }, []);

  const closeToast = () => {
    setToast((prev) => ({ ...prev, open: false }));
  };

  const showToast = (message, severity = "info") => {
    setToast({ open: true, message, severity });
  };

  const fetchLatestAiEnabled = useCallback(async () => {
    try {
      const res = await api.get("/admin/parameters");
      const data = res.data?.data || res.data || [];
      const arr = Array.isArray(data) ? data : [];
      const aiParam = arr.find((p) => p.name === "ai_enabled");
      const enabled = aiParam ? (aiParam.value === "true" || aiParam.value === "1") : aiEnabled;
      setAiEnabled(enabled);
      return enabled;
    } catch {
      return aiEnabled;
    }
  }, [aiEnabled]);

  const showAiUnavailableToast = (message) => {
    showToast(
      `${message} Pour continuer sans suggestion IA, désactivez le paramètre IA dans l'interface Paramètres puis poursuivez manuellement.`,
      "error",
    );
  };

  const fetchPlanned = useCallback(async () => {
    if (!selectedPlanningId) return;
    try {
      const res = await api.get(
        `/admin/plannings/${selectedPlanningId}/activities`,
      );
      const data = (res.data?.data || []).map((a) => ({
        id: a.id,
        title: a.title || "",
        description: a.description || "",
        date: (a.date || "").slice(0, 10),
        startTime: (a.start_time || "").slice(0, 5),
        endTime: (a.end_time || "").slice(0, 5),
        status: a.status || "pending",
        className: (a.classes || []).map((c) => c.name).join(", ") || "Toutes",
        classIds: (a.classes || []).map((c) => c.id),
        teacherName: a.teacher
          ? `${a.teacher.firstName || ""} ${a.teacher.lastName || ""}`.trim()
          : "Admin",
      }));
      setActivitiesList(data);
    } catch (err) {
      console.error(err);
    }
  }, [selectedPlanningId]);

  // Sync activeTab when URL search params change (e.g., sidebar navigation)
  useEffect(() => {
    const tab = searchParams.get("tab") || "planned";
    const tabIndex = TAB_MAP[tab] ?? 0;
    if (tabIndex !== activeTab) setActiveTab(tabIndex);
  }, [searchParams, activeTab]);

  useEffect(() => {
    fetchPlanned();
  }, [selectedPlanningId, fetchPlanned]);

  const criteriaNameMap = useMemo(() => {
    const map = {};
    criteriaList.forEach((c) => {
      map[c.id] = c.name;
    });
    return map;
  }, [criteriaList]);

  const selectedPlanning = useMemo(
    () => plannings.find((p) => String(p.id) === String(selectedPlanningId)),
    [plannings, selectedPlanningId],
  );
  const isArchived =
    selectedPlanning?.is_archived === true ||
    selectedPlanning?.is_archived === 1;

  // Update class options when selected planning changes to map only the relevant classes
  useEffect(() => {
    if (!selectedPlanning) return;

    const startYear = selectedPlanning.start_date
      ? new Date(selectedPlanning.start_date).getFullYear()
      : null;

    const validClasses = allClassesData.filter((c) => {
      if (c.is_archived && !isArchived) return false;
      if (!startYear) return true; // fallback if no dates
      return c.year === startYear;
    });

    setClassOptions(
      validClasses.map((c) => ({
        id: c.id,
        name: c.name,
        label: c.is_archived ? `${c.name} (Archivée)` : c.name,
        creation_year: c.year,
      })),
    );
  }, [selectedPlanning, allClassesData]);

  const activityMap = useMemo(() => {
    const map = {};
    activitiesList.forEach((a) => {
      if (!map[a.date]) map[a.date] = [];
      map[a.date].push(a);
    });
    return map;
  }, [activitiesList]);

  const monthActivityCounts = useMemo(() => {
    const counts = {};
    activitiesList.forEach((a) => {
      if (!a.date) return;
      const key = a.date.slice(0, 7); // "YYYY-MM"
      counts[key] = (counts[key] || 0) + 1;
    });
    return counts;
  }, [activitiesList]);

  const today = new Date();
  const planningStartYear = selectedPlanning?.startDate
    ? new Date(selectedPlanning.startDate).getFullYear()
    : selectedPlanning?.start_date
      ? new Date(selectedPlanning.start_date).getFullYear()
      : today.getFullYear();
  const planningEndYear = selectedPlanning?.endDate
    ? new Date(selectedPlanning.endDate).getFullYear()
    : selectedPlanning?.end_date
      ? new Date(selectedPlanning.end_date).getFullYear()
      : planningStartYear + 1;
  const [visibleYear, setVisibleYear] = useState(planningStartYear);
  useEffect(() => {
    setVisibleYear(planningStartYear);
  }, [planningStartYear]);

  const planningMonthKeys = useMemo(
    () => new Set(getPlanningMonths(selectedPlanning)),
    [selectedPlanning],
  );

  // Derived timeline activities
  const dayTimelineActivities = useMemo(() => {
    if (!dayTimelineInfo?.dateStr) return [];
    return (activityMap[dayTimelineInfo.dateStr] || [])
      .filter((a) => {
        if (!selectedClassForWeekId) return false;
        return (a.classIds || []).includes(Number(selectedClassForWeekId));
      })
      .sort((a, b) => (a.startTime || "").localeCompare(b.startTime || ""));
  }, [activityMap, dayTimelineInfo, selectedClassForWeekId]);

  const timelineWindow = useMemo(
    () => getTimelineWindow(dayTimelineActivities),
    [dayTimelineActivities],
  );

  const isWeekendDate = (dateStr) => {
    if (!dateStr) return false;
    const [year, month, day] = dateStr.split("-").map(Number);
    const date = new Date(year, (month || 1) - 1, day || 1);
    const dayOfWeek = date.getDay();
    return dayOfWeek === 0 || dayOfWeek === 6;
  };

  // === TAB 0: Planned Activities ===
  const handleAddActivity = async (e) => {
    e.preventDefault();
    if (isArchived) return;
    setAddActivityError("");
    setAddActivitySaving(true);
    if (isWeekendDate(addActivityForm.date)) {
      setAddActivityError(
        "Les activités ne peuvent être planifiées que du lundi au vendredi.",
      );
      setAddActivitySaving(false);
      return;
    }
    const selectedActivity = allActivities.find(
      (a) => a.id === Number(addActivityForm.activityId),
    );
    if (!selectedActivity) {
      setAddActivityError("Sélectionnez une activité.");
      setAddActivitySaving(false);
      return;
    }
    if (
      addActivityForm.startTime &&
      addActivityForm.endTime &&
      addActivityForm.startTime >= addActivityForm.endTime
    ) {
      setAddActivityError("L'heure de début doit être avant l'heure de fin.");
      setAddActivitySaving(false);
      return;
    }
    try {
      await api.post(`/admin/plannings/${selectedPlanningId}/activities`, {
        title: selectedActivity.title,
        description: selectedActivity.description || null,
        date: addActivityForm.date,
        start_time: addActivityForm.startTime || null,
        end_time: addActivityForm.endTime || null,
        class_ids: addActivityForm.classIds,
        criteria_ids: selectedActivity.criteriaIds || [],
        status: "approved",
        template_id: selectedActivity.id,
      });
      await fetchPlanned();
      setPlanModalOpen(false);
      setAddActivityForm({
        activityId: "",
        date: "",
        startTime: "",
        endTime: "",
        classIds: [],
      });
    } catch (err) {
      setAddActivityError(err?.response?.data?.message || "Erreur.");
    } finally {
      setAddActivitySaving(false);
    }
  };

  const openAddForDate = (dateStr) => {
    if (dateStr && isWeekendDate(dateStr)) {
      alert(
        "Les activités ne peuvent être planifiées que du lundi au vendredi.",
      );
      return;
    }
    setAddActivityForm({
      activityId: "",
      date: dateStr || "",
      startTime: "09:00",
      endTime: "11:00",
      classIds: selectedClassForWeekId ? [Number(selectedClassForWeekId)] : [],
    });
    setPlanModalOpen(true);
  };

  // === TAB 1: Criteria ===
  const handleAddCriteria = async (e) => {
    e.preventDefault();
    setAddCriteriaError("");
    if (!newCriteriaName.trim()) return;
    setAddCriteriaSaving(true);
    try {
      const res = await api.post("/admin/criteria", {
        name: newCriteriaName.trim(),
      });
      const newC = res.data?.data || res.data;
      setCriteriaList((prev) => [...prev, { id: newC.id, name: newC.name }]);
      setNewCriteriaName("");
      setIsCriteriaDialogOpen(false);
    } catch (err) {
      setAddCriteriaError(err?.response?.data?.message || "Erreur.");
    } finally {
      setAddCriteriaSaving(false);
    }
  };

  const handleDeleteCriteria = (criteria) => {
    setDeletingItem(criteria);
    setDeleteType("criteria");
    setIsDeleteDialogOpen(true);
  };

  // === TAB 2: All Activities ===
  const handleAddAllActivity = async (e) => {
    e.preventDefault();
    setAddAllActivityError("");
    const normalizedTitle = normalizeActivityTitle(addAllActivityForm.title);
    if (!normalizedTitle) {
      setAddAllActivityError("Le titre de l'activité est requis.");
      return;
    }
    const duplicateActivity = allActivities.find(
      (activity) => normalizeActivityTitle(activity.title) === normalizedTitle,
    );
    if (duplicateActivity) {
      setAddAllActivityError("Une activité avec ce nom existe déjà.");
      return;
    }
    setAddAllActivitySaving(true);
    try {
      const res = await api.post("/admin/activities", {
        title: addAllActivityForm.title.trim(),
        description: addAllActivityForm.description.trim() || null,
        criteria_ids: addAllActivityForm.criteriaIds,
      });
      const newA = res.data?.data || res.data;
      setAllActivities((prev) => [
        ...prev,
        {
          id: newA.id,
          title: newA.title || "",
          description: newA.description || "",
          criteriaIds: (newA.criteria || []).map((c) => c.id),
          criteriaNames:
            (newA.criteria || []).map((c) => c.name).join(", ") || "-",
        },
      ]);
      setAddAllActivityForm({ title: "", description: "", criteriaIds: [] });
      setIsAllActivityDialogOpen(false);
    } catch (err) {
      setAddAllActivityError(err?.response?.data?.message || "Erreur.");
    } finally {
      setAddAllActivitySaving(false);
    }
  };

  const handleSuggestCriteria = useCallback(async () => {
    const title = addAllActivityForm.title.trim();
    const description = (addAllActivityForm.description || "").trim();
    const safeMax = Math.max(
      1,
      Math.min(
        criteriaList.length || 1,
        Number.isInteger(Number(maxSuggestedCriteria))
          ? Number(maxSuggestedCriteria)
          : 2,
      ),
    );
    if (!title && !description) {
      alert("Ajoutez un titre ou une description d'abord.");
      return;
    }
    if (criteriaList.length === 0) {
      alert("Aucun critère disponible.");
      return;
    }
    const criteriaLines = criteriaList
      .map((c) => `- ${c.id}: ${c.name}`)
      .join("\n");
    try {
      const latestAiEnabled = await fetchLatestAiEnabled();
      if (!latestAiEnabled) {
        showToast("L'IA est désactivée. Vous pouvez continuer sans suggestion automatique.", "warning");
        return;
      }
      setSuggestingCriteria(true);
      const response = await api.post("/admin/ai/suggest-activity-criteria", {
        title,
        description,
        safeMax,
        criteriaLines,
        max_tokens: 180,
      });
      const output = String(response?.data?.output || "").trim();
      const fallbackRaw = response?.data?.raw?.choices?.[0]?.message?.content;
      const fallback =
        typeof fallbackRaw === "string" ? fallbackRaw.trim() : "";
      const suggestedIds = parseSuggestedCriterionIds(
        output || fallback,
        criteriaList,
      ).slice(0, safeMax);
      if (suggestedIds.length === 0) {
        showToast("L'IA n'a pas retourné de critères. Sélectionnez-les manuellement pour continuer.", "warning");
        return;
      }
      setAddAllActivityForm((prev) => ({
        ...prev,
        criteriaIds: [
          ...new Set([...(prev.criteriaIds || []), ...suggestedIds]),
        ].slice(0, safeMax),
      }));
    } catch (err) {
      console.error("AI criteria suggestion failed", err);
      showAiUnavailableToast(err?.response?.data?.message || "Échec de la suggestion IA.");
    } finally {
      setSuggestingCriteria(false);
    }
  }, [addAllActivityForm, criteriaList, maxSuggestedCriteria, fetchLatestAiEnabled]);

  const handleEditActivityClick = (activity) => {
    setEditingActivity(activity);
    setEditForm({
      title: activity.title,
      description: activity.description,
      criteriaIds: activity.criteriaIds,
    });
    setEditFormError("");
    setIsEditDialogOpen(true);
  };

  const handleEditSubmit = async (e) => {
    e.preventDefault();
    setEditFormError("");
    const normalizedTitle = normalizeActivityTitle(editForm.title);
    const duplicateActivity = allActivities.find(
      (activity) =>
        activity.id !== editingActivity.id &&
        normalizeActivityTitle(activity.title) === normalizedTitle,
    );
    if (duplicateActivity) {
      setEditFormError("Une activité avec ce nom existe déjà.");
      return;
    }
    try {
      await api.put(`/admin/activities/${editingActivity.id}`, {
        title: editForm.title.trim(),
        description: editForm.description.trim() || null,
        criteria_ids: editForm.criteriaIds,
      });
      setIsEditDialogOpen(false);
      const res = await api.get("/admin/activities");
      setAllActivities(
        (res.data?.data || []).map((a) => ({
          id: a.id,
          title: a.title || "",
          description: a.description || "",
          criteriaIds: (a.criteria || []).map((c) => c.id),
          criteriaNames:
            (a.criteria || []).map((c) => c.name).join(", ") || "-",
        })),
      );
    } catch (err) {
      setEditFormError(err?.response?.data?.message || "Erreur.");
    }
  };

  const handleSuggestCriteriaForEdit = useCallback(async () => {
    const title = editForm.title.trim();
    const description = (editForm.description || "").trim();
    const safeMax = Math.max(
      1,
      Math.min(
        criteriaList.length || 1,
        Number.isInteger(Number(maxSuggestedCriteria))
          ? Number(maxSuggestedCriteria)
          : 2,
      ),
    );
    if (!title && !description) {
      alert("Ajoutez un titre ou une description d'abord.");
      return;
    }
    if (criteriaList.length === 0) {
      alert("Aucun critère disponible.");
      return;
    }
    const criteriaLines = criteriaList
      .map((c) => `- ${c.id}: ${c.name}`)
      .join("\n");
    try {
      const latestAiEnabled = await fetchLatestAiEnabled();
      if (!latestAiEnabled) {
        showToast("L'IA est désactivée. Vous pouvez continuer sans suggestion automatique.", "warning");
        return;
      }
      setSuggestingCriteria(true);
      const response = await api.post("/admin/ai/suggest-activity-criteria", {
        title,
        description,
        safeMax,
        criteriaLines,
        max_tokens: 180,
      });
      const output = String(response?.data?.output || "").trim();
      const fallbackRaw = response?.data?.raw?.choices?.[0]?.message?.content;
      const fallback =
        typeof fallbackRaw === "string" ? fallbackRaw.trim() : "";
      const suggestedIds = parseSuggestedCriterionIds(
        output || fallback,
        criteriaList,
      ).slice(0, safeMax);
      if (suggestedIds.length === 0) {
        showToast("L'IA n'a pas retourné de critères. Sélectionnez-les manuellement pour continuer.", "warning");
        return;
      }
      setEditForm((prev) => ({
        ...prev,
        criteriaIds: [
          ...new Set([...(prev.criteriaIds || []), ...suggestedIds]),
        ].slice(0, safeMax),
      }));
    } catch (err) {
      console.error("AI criteria suggestion failed", err);
      showAiUnavailableToast(err?.response?.data?.message || "Échec de la suggestion IA.");
    } finally {
      setSuggestingCriteria(false);
    }
  }, [editForm, criteriaList, maxSuggestedCriteria, fetchLatestAiEnabled]);

  const handleDeleteActivity = (activity) => {
    setDeletingItem(activity);
    setDeleteType("activity");
    setIsDeleteDialogOpen(true);
  };

  const handleDeletePlannedActivity = async (activityId) => {
    if (isArchived) return;
    if (!window.confirm("Supprimer cette activité planifiée ?")) return;
    try {
      await api.delete(
        `/admin/plannings/${selectedPlanningId}/activities/${activityId}`,
      );
      await fetchPlanned();
    } catch (err) {
      alert(err?.response?.data?.message || "Erreur lors de la suppression.");
    }
  };

  // Function handleToggleStatus was not used except for its definition.

  const handleDeleteConfirm = async () => {
    try {
      if (deleteType === "criteria") {
        await api.delete(`/admin/criteria/${deletingItem.id}`);
        setCriteriaList((prev) => prev.filter((c) => c.id !== deletingItem.id));
      } else if (deleteType === "activity") {
        await api.delete(`/admin/activities/${deletingItem.id}`);
        setAllActivities((prev) =>
          prev.filter((a) => a.id !== deletingItem.id),
        );
      }
      setIsDeleteDialogOpen(false);
      setDeletingItem(null);
    } catch (err) {
      alert(err?.response?.data?.message || "Erreur.");
    }
  };

  const getStatusLabel = (s) => {
    const n = (s || "").toLowerCase();
    if (n === "approved") return "✓ Approuvée";
    if (n === "pending") return "◷ En attente";
    if (n === "rejected") return "✕ Rejetée";
    if (n === "executed") return "✓ Exécutée";
    if (n === "not_executed") return "✕ Non exécutée";
    return s;
  };

  const getStatusColor = (s) => {
    const n = (s || "").toLowerCase();
    if (n === "approved" || n === "executed") return colors.greenAccent[500];
    if (n === "pending") return "#f59e0b";
    if (n === "rejected" || n === "not_executed") return colors.redAccent[500];
    return colors.grey[300];
  };

  const styles = getStyles(colors, isDark);

  const criteriaColumns = [
    {
      field: "id",
      headerName: "ID",
      flex: 0.28,
      minWidth: 64,
      align: "center",
      headerAlign: "center",
    },
    {
      field: "name",
      headerName: "Nom du critère",
      flex: 1,
      cellClassName: "name-column--cell",
      minWidth: 200,
      renderCell: ({ value }) => (
        <Box display="flex" alignItems="center" height="100%" py="8px">
          <Typography fontWeight={700} color={colors.grey[100]}>
            {value}
          </Typography>
        </Box>
      ),
    },
    {
      field: "actions",
      headerName: "Actions",
      flex: 0.34,
      minWidth: 96,
      align: "center",
      headerAlign: "center",
      sortable: false,
      filterable: false,
      renderCell: ({ row }) => (
        <Tooltip title="Supprimer">
          <IconButton
            size="small"
            onClick={() => handleDeleteCriteria(row)}
            sx={styles.dangerIconButton}
          >
            <DeleteOutlineIcon fontSize="small" />
          </IconButton>
        </Tooltip>
      ),
    },
  ];

  const allActivityColumns = [
    {
      field: "id",
      headerName: "ID",
      flex: 0.25,
      minWidth: 64,
      align: "center",
      headerAlign: "center",
    },
    {
      field: "title",
      headerName: "Titre",
      flex: 0.9,
      cellClassName: "name-column--cell",
      minWidth: 150,
      renderCell: ({ value }) => (
        <Box display="flex" alignItems="center" height="100%" py="8px">
          <Typography fontWeight={700} color={colors.grey[100]}>
            {value}
          </Typography>
        </Box>
      ),
    },
    {
      field: "description",
      headerName: "Description",
      flex: 1.45,
      minWidth: 260,
      sortable: false,
      renderCell: ({ value }) => (
        <Box display="flex" alignItems="center" height="100%" py="8px" width="100%">
          <Typography
            color={colors.grey[300]}
            fontSize="0.9rem"
            lineHeight={1.55}
            sx={{
              display: "-webkit-box",
              WebkitLineClamp: 3,
              WebkitBoxOrient: "vertical",
              overflow: "hidden",
            }}
          >
            {value || "Aucune description"}
          </Typography>
        </Box>
      ),
    },
    {
      field: "criteriaNames",
      headerName: "Critères",
      flex: 1,
      minWidth: 220,
      sortable: false,
      renderCell: ({ row }) => {
        const names = (row.criteriaIds || [])
          .map((id) => criteriaNameMap[id])
          .filter(Boolean);
        const visibleNames = names.slice(0, 2);

        return (
          <Box display="flex" alignItems="center" height="100%" py="8px" width="100%">
            <Box display="flex" flexWrap="wrap" gap="6px">
              {visibleNames.map((name) => (
                <Chip key={name} label={name} size="small" sx={styles.criteriaTagChip} />
              ))}
              {names.length > visibleNames.length && (
                <Chip label={`+${names.length - visibleNames.length}`} size="small" sx={styles.criteriaCountChip} />
              )}
              {names.length === 0 && <Typography color={colors.grey[500]}>-</Typography>}
            </Box>
          </Box>
        );
      },
    },
    {
      field: "actions",
      headerName: "Actions",
      flex: 0.38,
      minWidth: 112,
      align: "center",
      headerAlign: "center",
      sortable: false,
      filterable: false,
      renderCell: ({ row }) => (
        <Box display="flex" gap="6px">
          <Tooltip title="Éditer">
            <IconButton
              size="small"
              onClick={() => handleEditActivityClick(row)}
              sx={styles.subtleIconButton}
            >
              <EditOutlinedIcon fontSize="small" />
            </IconButton>
          </Tooltip>
          <Tooltip title="Supprimer">
            <IconButton
              size="small"
              onClick={() => handleDeleteActivity(row)}
              sx={styles.dangerIconButton}
            >
              <DeleteOutlineIcon fontSize="small" />
            </IconButton>
          </Tooltip>
        </Box>
      ),
    },
  ];

  const allProps = {
    theme,
    colors,
    isDark,
    searchParams,
    setSearchParams,
    tabParam,
    activeTab,
    setActiveTab,
    plannings,
    setPlannings,
    selectedPlanningId,
    setSelectedPlanningId,
    activitiesList,
    setActivitiesList,
    allActivities,
    setAllActivities,
    criteriaList,
    setCriteriaList,
    allClassesData,
    setAllClassesData,
    classOptions,
    setClassOptions,
    expandedMonth,
    setExpandedMonth,
    weekModalInfo,
    setWeekModalInfo,
    selectedClassForWeekId,
    setSelectedClassForWeekId,
    dayTimelineInfo,
    setDayTimelineInfo,
    planModalOpen,
    setPlanModalOpen,
    addActivityForm,
    setAddActivityForm,
    addActivityError,
    setAddActivityError,
    addActivitySaving,
    setAddActivitySaving,
    newCriteriaName,
    setNewCriteriaName,
    addCriteriaError,
    setAddCriteriaError,
    addCriteriaSaving,
    setAddCriteriaSaving,
    isCriteriaDialogOpen,
    setIsCriteriaDialogOpen,
    addAllActivityForm,
    setAddAllActivityForm,
    addAllActivityError,
    setAddAllActivityError,
    addAllActivitySaving,
    setAddAllActivitySaving,
    suggestingCriteria,
    setSuggestingCriteria,
    maxSuggestedCriteria,
    setMaxSuggestedCriteria,
    isAllActivityDialogOpen,
    setIsAllActivityDialogOpen,
    aiEnabled,
    setAiEnabled,
    isEditDialogOpen,
    setIsEditDialogOpen,
    editingActivity,
    setEditingActivity,
    editForm,
    setEditForm,
    editFormError,
    setEditFormError,
    isDeleteDialogOpen,
    setIsDeleteDialogOpen,
    deletingItem,
    setDeletingItem,
    deleteType,
    setDeleteType,
    fetchPlanned,
    criteriaNameMap,
    selectedPlanning,
    isArchived,
    activityMap,
    monthActivityCounts,
    today,
    planningStartYear,
    planningEndYear,
    visibleYear,
    setVisibleYear,
    planningMonthKeys,
    dayTimelineActivities,
    timelineWindow,
    isWeekendDate,
    handleAddActivity,
    openAddForDate,
    handleAddCriteria,
    handleDeleteCriteria,
    handleAddAllActivity,
    handleSuggestCriteria,
    handleEditActivityClick,
    handleEditSubmit,
    handleSuggestCriteriaForEdit,
    handleDeleteActivity,
    handleDeletePlannedActivity,
    handleDeleteConfirm,
    getStatusLabel,
    getStatusColor,
    criteriaColumns,
    allActivityColumns,
    styles,
    MONTHS_FR,
    WEEKDAYS_FR,
    MONTH_ICONS,
    getWeeksOfMonth,
    getTimelineWindow,
    getPlanningMonths,
    formatMinutesToHourLabel,
    parseTimeToMinutes,
  };

  return (
    <Box m="20px">
      <Header title="ACTIVITÉS" />

      {/* AI Disabled Banner */}
      {!aiEnabled && (
        <Box
          mb="15px"
          p="12px"
          borderRadius="8px"
          backgroundColor="rgba(239,68,68,0.1)"
          border="1px solid rgba(239,68,68,0.3)"
          display="flex"
          alignItems="center"
          gap="10px"
        >
          <Typography fontSize="18px">⚠️</Typography>
          <Typography color={colors.redAccent[400]} fontSize="0.85rem">
            <strong>IA désactivée</strong> — La suggestion automatique de
            critères par IA n'est pas disponible. Vous pouvez toujours
            sélectionner les critères manuellement.
          </Typography>
        </Box>
      )}

      {/* Planning selector */}
      <Box sx={{ ...styles.toolbarShell, width: { xs: "100%", md: "fit-content" } }}>
        <Box sx={styles.toolbarGroup}>
          <Typography sx={styles.toolbarLabel}>Année scolaire</Typography>
          <FormControl variant="outlined" size="small" sx={styles.selectControl}>
          <Select
            value={selectedPlanningId ? String(selectedPlanningId) : ""}
            onChange={(e) => setSelectedPlanningId(e.target.value)}
          >
            {plannings.map((p) => (
              <MenuItem key={p.id} value={String(p.id)}>
                {p.label ||
                  `${p.startDate || p.start_date} — ${p.endDate || p.end_date}`}
              </MenuItem>
            ))}
          </Select>
          </FormControl>
        </Box>
      </Box>

      {/* Tabs */}
      <Box sx={styles.tabsWrap}>
        <Tabs
          value={activeTab}
          onChange={(_, v) => {
            setActiveTab(v);
            setSearchParams({ tab: TAB_KEYS[v] });
          }}
          variant="scrollable"
          allowScrollButtonsMobile
          sx={styles.tabsSx}
        >
          <Tab label="Activités Planifiées" />
          <Tab label="Critères d'évaluation" />
          <Tab label="Toutes les activités" />
        </Tabs>
      </Box>

      {activeTab === 0 && <PlannedActivitiesTab {...allProps} />}

      {activeTab === 1 && <CriteriaTab {...allProps} />}

      {activeTab === 2 && <AllActivitiesTab {...allProps} />}

      {<WeekDialogComponent {...allProps} />}

      {<DayTimelineDialogComponent {...allProps} />}

      {<PlanActivityDialogComponent {...allProps} />}

      {<AddCriteriaDialogComponent {...allProps} />}

      {<AddAllActivityDialogComponent {...allProps} />}

      {<DeleteDialogComponent {...allProps} />}

      {<EditActivityDialogComponent {...allProps} />}

      <Portal>
        <Snackbar
          open={toast.open}
          autoHideDuration={5000}
          onClose={closeToast}
          anchorOrigin={{ vertical: "top", horizontal: "right" }}
          sx={{ zIndex: 2001 }}
        >
          <Alert
            onClose={closeToast}
            severity={toast.severity}
            variant="outlined"
            sx={{
              width: "100%",
              maxWidth: "420px",
              alignItems: "center",
              borderRadius: "14px",
              boxShadow: "0 12px 28px rgba(15,23,42,0.12)",
              backgroundColor: isDark ? "rgba(17,24,39,0.96)" : "rgba(255,250,242,0.98)",
              color: isDark ? colors.grey[100] : "#3f2a12",
              borderColor: "rgba(245,158,11,0.35)",
            }}
          >
            {toast.message}
          </Alert>
        </Snackbar>
      </Portal>
    </Box>
  );
};

const getStyles = (colors, isDark) => {
  const surface = isDark ? "rgba(15, 23, 32, 0.88)" : "rgba(255, 255, 255, 0.82)";
  const surfaceAlt = isDark ? "rgba(19, 28, 39, 0.92)" : "#f8fafc";
  const border = isDark ? "rgba(148, 163, 184, 0.16)" : "rgba(148, 163, 184, 0.28)";
  const headerBg = isDark ? "rgba(148, 163, 184, 0.08)" : "#eef2f7";

  return {
    toolbarShell: {
      mb: "18px",
      px: { xs: "14px", md: "18px" },
      py: { xs: "14px", md: "16px" },
      borderRadius: "18px",
      background: surface,
      border: `1px solid ${border}`,
      display: "flex",
      alignItems: { xs: "stretch", md: "center" },
      justifyContent: "flex-start",
      gap: "14px",
      flexDirection: { xs: "column", md: "row" },
      boxShadow: isDark ? "0 16px 30px rgba(2, 6, 23, 0.24)" : "0 14px 28px rgba(148, 163, 184, 0.16)",
    },
    toolbarGroup: {
      display: "flex",
      alignItems: { xs: "stretch", sm: "center" },
      gap: "12px",
      flexDirection: { xs: "column", sm: "row" },
    },
    toolbarLabel: {
      fontSize: "0.82rem",
      fontWeight: 700,
      color: colors.grey[300],
      whiteSpace: "nowrap",
    },
    selectControl: {
      minWidth: 210,
      "& .MuiOutlinedInput-root": {
        borderRadius: "12px",
        backgroundColor: surfaceAlt,
      },
    },
    tabsWrap: {
      borderBottom: `1px solid ${border}`,
      mb: "20px",
      px: { xs: 0, md: 1 },
    },
    tabsSx: {
      minHeight: 46,
      "& .MuiTab-root": {
        color: colors.grey[300],
        fontSize: "0.95rem",
        textTransform: "none",
        fontWeight: 600,
        opacity: 1,
        minHeight: 46,
        px: 0,
        mr: 3,
      },
      "& .Mui-selected": {
        color: `${colors.greenAccent[400]} !important`,
        fontWeight: 800,
      },
      "& .MuiTabs-indicator": {
        backgroundColor: colors.greenAccent[500],
        height: "4px",
        borderRadius: "999px",
      },
    },
    summaryGrid: {
      display: "grid",
      gridTemplateColumns: { xs: "1fr", md: "repeat(3, minmax(0, 1fr))" },
      gap: "14px",
      mb: "18px",
    },
    summaryCard: (accent) => ({
      display: "flex",
      alignItems: "center",
      justifyContent: "space-between",
      gap: "14px",
      px: "18px",
      py: "16px",
      borderRadius: "18px",
      background: surface,
      border: `1px solid ${border}`,
      boxShadow: isDark ? "0 18px 34px rgba(2, 6, 23, 0.26)" : "0 16px 32px rgba(148, 163, 184, 0.16)",
      borderLeft: `4px solid ${accent}`,
    }),
    summaryLabel: {
      fontSize: "0.78rem",
      letterSpacing: "0.04em",
      textTransform: "uppercase",
      color: colors.grey[400],
      mb: "4px",
    },
    summaryValue: {
      fontSize: "1.45rem",
      lineHeight: 1,
      fontWeight: 800,
      color: colors.grey[100],
    },
    summaryIconWrap: (accent) => ({
      width: 42,
      height: 42,
      borderRadius: "14px",
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      backgroundColor: `${accent}12`,
      border: `1px solid ${accent}28`,
      color: accent,
      flexShrink: 0,
    }),
    sectionCard: {
      borderRadius: "22px",
      background: surface,
      border: `1px solid ${border}`,
      boxShadow: isDark ? "0 18px 34px rgba(2, 6, 23, 0.28)" : "0 16px 32px rgba(148, 163, 184, 0.16)",
      overflow: "hidden",
    },
    sectionHeader: {
      px: { xs: "16px", md: "22px" },
      py: { xs: "16px", md: "18px" },
      display: "flex",
      justifyContent: "space-between",
      alignItems: { xs: "flex-start", md: "center" },
      gap: "14px",
      flexDirection: { xs: "column", md: "row" },
      borderBottom: `1px solid ${border}`,
    },
    sectionTitle: {
      fontSize: "1.04rem",
      fontWeight: 800,
      color: colors.grey[100],
    },
    sectionSubtitle: {
      mt: "4px",
      fontSize: "0.84rem",
      color: colors.grey[400],
      lineHeight: 1.6,
    },
    sectionActionButton: {
      minHeight: 40,
      px: "16px",
      ...getAdminPrimaryButtonSx(),
    },
    datagridSx: {
      borderRadius: "22px",
      overflow: "hidden",
      border: `1px solid ${border}`,
      backgroundColor: surface,
      "& .MuiDataGrid-root": { border: "none", backgroundColor: "transparent" },
      "& .MuiDataGrid-main": { borderRadius: 0 },
      "& .MuiDataGrid-cell": {
        borderBottom: `1px solid ${border}`,
        color: colors.grey[100],
        py: "16px",
        alignItems: "center",
      },
      "& .MuiDataGrid-columnHeaders": {
        backgroundColor: headerBg,
        borderBottom: `1px solid ${border}`,
      },
      "& .MuiDataGrid-columnHeader": {
        color: colors.grey[300],
        fontSize: "0.78rem",
        fontWeight: 800,
        textTransform: "uppercase",
        letterSpacing: "0.05em",
      },
      "& .MuiDataGrid-columnSeparator": { color: border },
      "& .MuiDataGrid-virtualScroller": { backgroundColor: surface },
      "& .MuiDataGrid-row": {
        transition: "background-color 0.2s ease",
        "&:hover": {
          backgroundColor: isDark ? "rgba(30, 41, 59, 0.58) !important" : "rgba(241, 245, 249, 0.92) !important",
        },
      },
      "& .MuiDataGrid-footerContainer": {
        borderTop: `1px solid ${border}`,
        backgroundColor: surfaceAlt,
      },
      "& .MuiTablePagination-root, & .MuiTablePagination-selectLabel, & .MuiTablePagination-displayedRows": {
        color: colors.grey[300],
      },
      "& .MuiIconButton-root": { color: colors.grey[300] },
      "& .MuiDataGrid-toolbarContainer .MuiButton-text": {
        color: `${colors.grey[100]} !important`,
      },
      "& .name-column--cell": { color: colors.grey[100] },
    },
    subtleIconButton: {
      width: 32,
      height: 32,
      borderRadius: "10px",
      border: `1px solid ${border}`,
      backgroundColor: surfaceAlt,
      color: colors.grey[200],
      "&:hover": {
        backgroundColor: isDark ? "rgba(30, 41, 59, 0.82)" : "#eef2f7",
      },
    },
    dangerIconButton: {
      width: 32,
      height: 32,
      borderRadius: "10px",
      border: `1px solid ${isDark ? "rgba(248, 113, 113, 0.16)" : "rgba(248, 113, 113, 0.18)"}`,
      backgroundColor: isDark ? "rgba(127, 29, 29, 0.14)" : "rgba(254, 226, 226, 0.72)",
      color: colors.redAccent[400],
      "&:hover": {
        backgroundColor: isDark ? "rgba(127, 29, 29, 0.22)" : "rgba(254, 226, 226, 0.92)",
      },
    },
    criteriaTagChip: {
      backgroundColor: isDark ? "rgba(20, 184, 166, 0.14)" : "rgba(13, 148, 136, 0.10)",
      color: colors.greenAccent[400],
      border: `1px solid ${isDark ? "rgba(45, 212, 191, 0.16)" : "rgba(13, 148, 136, 0.16)"}`,
      fontWeight: 700,
    },
    criteriaCountChip: {
      backgroundColor: headerBg,
      color: colors.grey[300],
      border: `1px solid ${border}`,
      fontWeight: 700,
    },
    formCard: {
      mt: "20px",
      borderRadius: "22px",
      background: surface,
      border: `1px solid ${border}`,
      boxShadow: isDark ? "0 18px 34px rgba(2, 6, 23, 0.28)" : "0 16px 32px rgba(148, 163, 184, 0.16)",
      p: { xs: "18px", md: "22px" },
    },
    formHeaderRow: {
      display: "flex",
      alignItems: "center",
      gap: "12px",
      mb: "18px",
    },
    formIconWrap: (accent = colors.greenAccent[500]) => ({
      width: 40,
      height: 40,
      borderRadius: "14px",
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      backgroundColor: `${accent}14`,
      border: `1px solid ${accent}2a`,
      color: accent,
      flexShrink: 0,
    }),
    formTitle: {
      fontSize: "1rem",
      fontWeight: 800,
      color: colors.grey[100],
    },
    formSubtitle: {
      mt: "4px",
      fontSize: "0.84rem",
      color: colors.grey[400],
      lineHeight: 1.6,
    },
    filledInputSx: {
      "& .MuiFilledInput-root, & .MuiOutlinedInput-root": {
        borderRadius: "14px",
        backgroundColor: surfaceAlt,
      },
      "& .MuiInputBase-input, & .MuiSelect-select": {
        color: isDark ? colors.grey[100] : "#0f172a",
      },
      "& .MuiInputLabel-root": {
        color: colors.grey[400],
        fontWeight: 600,
        px: "6px",
        backgroundColor: surfaceAlt,
        borderRadius: "999px",
      },
      "& .MuiInputLabel-root.Mui-focused": {
        color: isDark ? "#94a3b8" : "#475569",
        backgroundColor: surfaceAlt,
      },
      "& .MuiInputLabel-root.MuiInputLabel-shrink": {
        color: isDark ? colors.grey[300] : "#475569",
        backgroundColor: surfaceAlt,
      },
      "& .MuiOutlinedInput-notchedOutline": {
        borderColor: colors.primary[600],
      },
      "& .MuiOutlinedInput-root:hover .MuiOutlinedInput-notchedOutline": {
        borderColor: colors.grey[400],
      },
      "& .MuiOutlinedInput-root.Mui-focused .MuiOutlinedInput-notchedOutline": {
        borderColor: isDark ? "#94a3b8" : "#475569",
        borderWidth: "1px",
      },
    },
    helperPanel: {
      display: "flex",
      alignItems: "center",
      gap: "12px",
      mt: "8px",
      p: "12px 14px",
      borderRadius: "14px",
      backgroundColor: surfaceAlt,
      border: `1px solid ${border}`,
      flexWrap: "wrap",
    },
    helperLabel: {
      fontSize: "0.78rem",
      fontWeight: 700,
      color: colors.grey[300],
      whiteSpace: "nowrap",
    },
    primaryButton: {
      minHeight: 40,
      px: "18px",
      ...getAdminPrimaryButtonSx(),
    },
    secondaryButton: {
      minHeight: 40,
      px: "16px",
      ...getAdminSecondaryButtonSx(),
    },
    monthNavCard: {
      display: "inline-flex",
      alignItems: "center",
      justifyContent: "center",
      gap: "14px",
      px: "16px",
      py: "10px",
      borderRadius: "999px",
      background: surface,
      border: `1px solid ${border}`,
      boxShadow: isDark ? "0 12px 24px rgba(2, 6, 23, 0.20)" : "0 10px 20px rgba(148, 163, 184, 0.12)",
    },
    monthNavButton: {
      minWidth: 36,
      width: 36,
      height: 36,
      borderRadius: "999px",
      color: colors.grey[100],
      border: `1px solid ${border}`,
      backgroundColor: surfaceAlt,
    },
    calendarGrid: {
      display: "grid",
      gridTemplateColumns: { xs: "1fr", md: "repeat(2, minmax(0, 1fr))", xl: "repeat(3, minmax(0, 1fr))" },
      gap: "16px",
      mb: "20px",
    },
    monthCard: (isInPlanning, isCurrentMonth) => ({
      backgroundColor: isInPlanning ? surface : isDark ? "rgba(30, 41, 59, 0.48)" : "rgba(241, 245, 249, 0.88)",
      opacity: isInPlanning ? 1 : 0.68,
      borderRadius: "18px",
      overflow: "hidden",
      boxShadow: isDark ? "0 14px 26px rgba(2, 6, 23, 0.20)" : "0 12px 24px rgba(148, 163, 184, 0.14)",
      border: isCurrentMonth ? `1px solid ${colors.greenAccent[500]}` : `1px solid ${border}`,
    }),
    monthHeader: (isInPlanning) => ({
      cursor: isInPlanning ? "pointer" : "default",
      transition: "background-color 0.2s ease",
      "&:hover": {
        backgroundColor: isInPlanning ? (isDark ? "rgba(30, 41, 59, 0.64)" : "rgba(241, 245, 249, 0.92)") : "inherit",
      },
    }),
    dialogPaper: {
      backgroundColor: colors.primary[400],
      color: colors.grey[100],
      borderRadius: "12px",
    },
  };
};

// --- Subcomponents ---

const PlannedActivitiesTab = (props) => {
  const {
    theme,
    colors,
    searchParams,
    setSearchParams,
    tabParam,
    activeTab,
    setActiveTab,
    plannings,
    setPlannings,
    selectedPlanningId,
    setSelectedPlanningId,
    activitiesList,
    setActivitiesList,
    allActivities,
    setAllActivities,
    criteriaList,
    setCriteriaList,
    allClassesData,
    setAllClassesData,
    classOptions,
    setClassOptions,
    expandedMonth,
    setExpandedMonth,
    weekModalInfo,
    setWeekModalInfo,
    selectedClassForWeekId,
    setSelectedClassForWeekId,
    dayTimelineInfo,
    setDayTimelineInfo,
    planModalOpen,
    setPlanModalOpen,
    addActivityForm,
    setAddActivityForm,
    addActivityError,
    setAddActivityError,
    addActivitySaving,
    setAddActivitySaving,
    newCriteriaName,
    setNewCriteriaName,
    addCriteriaError,
    setAddCriteriaError,
    addCriteriaSaving,
    setAddCriteriaSaving,
    isCriteriaDialogOpen,
    setIsCriteriaDialogOpen,
    addAllActivityForm,
    setAddAllActivityForm,
    addAllActivityError,
    setAddAllActivityError,
    addAllActivitySaving,
    setAddAllActivitySaving,
    suggestingCriteria,
    setSuggestingCriteria,
    maxSuggestedCriteria,
    setMaxSuggestedCriteria,
    aiEnabled,
    setAiEnabled,
    isEditDialogOpen,
    setIsEditDialogOpen,
    editingActivity,
    setEditingActivity,
    editForm,
    setEditForm,
    editFormError,
    setEditFormError,
    isDeleteDialogOpen,
    setIsDeleteDialogOpen,
    deletingItem,
    setDeletingItem,
    deleteType,
    setDeleteType,
    fetchPlanned,
    criteriaNameMap,
    selectedPlanning,
    isArchived,
    activityMap,
    monthActivityCounts,
    today,
    planningStartYear,
    planningEndYear,
    visibleYear,
    setVisibleYear,
    planningMonthKeys,
    dayTimelineActivities,
    timelineWindow,
    isWeekendDate,
    handleAddActivity,
    openAddForDate,
    handleAddCriteria,
    handleDeleteCriteria,
    handleAddAllActivity,
    handleSuggestCriteria,
    handleEditActivityClick,
    handleEditSubmit,
    handleSuggestCriteriaForEdit,
    handleDeleteActivity,
    handleDeletePlannedActivity,
    handleDeleteConfirm,
    getStatusLabel,
    getStatusColor,
    criteriaColumns,
    allActivityColumns,
    styles,
    MONTHS_FR,
    WEEKDAYS_FR,
    MONTH_ICONS,
    getWeeksOfMonth,
    getTimelineWindow,
    getPlanningMonths,
    formatMinutesToHourLabel,
    parseTimeToMinutes,
  } = props;
  return (
    <>
      <Box sx={styles.sectionCard} mb="18px">
        <Box sx={styles.sectionHeader}>
          <Box>
            <Typography sx={styles.sectionTitle}>Planning annuel des activités</Typography>
            <Typography sx={styles.sectionSubtitle}>
              Ouvrez un mois, puis une semaine, pour planifier vos activités avec une navigation plus fluide.
            </Typography>
          </Box>
          {!isArchived && (
            <Button
              variant="contained"
              startIcon={<AddRoundedIcon fontSize="small" />}
              onClick={() => openAddForDate("")}
              sx={styles.sectionActionButton}
            >
              Planifier une activité
            </Button>
          )}
        </Box>
      </Box>

      <Box sx={styles.summaryGrid}>
        {[
          {
            label: "Total planifiées",
            value: activitiesList.length,
            accent: colors.greenAccent[500],
            icon: <EventRepeatOutlinedIcon fontSize="small" />,
          },
          {
            label: "Exécutées",
            value: activitiesList.filter((a) => a.status === "executed").length,
            accent: colors.blueAccent[400],
            icon: <TaskAltOutlinedIcon fontSize="small" />,
          },
          {
            label: "Non exécutées",
            value: activitiesList.filter((a) => a.status !== "executed").length,
            accent: colors.redAccent[400],
            icon: <DeleteOutlineIcon fontSize="small" />,
          },
        ].map((item) => (
          <Box key={item.label} sx={styles.summaryCard(item.accent)}>
            <Box>
              <Typography sx={styles.summaryLabel}>{item.label}</Typography>
              <Typography sx={styles.summaryValue}>{item.value}</Typography>
            </Box>
            <Box sx={styles.summaryIconWrap(item.accent)}>{item.icon}</Box>
          </Box>
        ))}
      </Box>

      {/* Year Navigation */}
      <Box display="flex" justifyContent="center" mb="20px">
        <Box sx={styles.monthNavCard}>
        <Button
          disabled={visibleYear <= planningStartYear}
          onClick={() =>
            setVisibleYear((y) => Math.max(planningStartYear, y - 1))
          }
          sx={styles.monthNavButton}
        >
          ←
        </Button>
        <Typography variant="h4" fontWeight="bold" color={colors.grey[100]}>
          {visibleYear}
        </Typography>
        <Button
          disabled={visibleYear >= planningEndYear}
          onClick={() =>
            setVisibleYear((y) => Math.min(planningEndYear, y + 1))
          }
          sx={styles.monthNavButton}
        >
          →
        </Button>
        </Box>
      </Box>

      {/* Calendar Grid: 4 rows × 3 columns */}
      <Box sx={styles.calendarGrid}>
        {Array.from({ length: 12 }, (_, monthIdx) => {
          const monthKey = `${visibleYear}-${String(monthIdx + 1).padStart(2, "0")}`;
          const isInPlanning = planningMonthKeys.has(monthKey);
          const actCount = monthActivityCounts[monthKey] || 0;
          const isExpanded = expandedMonth === monthKey;
          const isCurrentMonth =
            today.getFullYear() === visibleYear &&
            today.getMonth() === monthIdx;
          const weeks = isExpanded
            ? getWeeksOfMonth(visibleYear, monthIdx)
            : [];

          return (
            <Box
              key={monthKey}
              sx={styles.monthCard(isInPlanning, isCurrentMonth)}
            >
              {/* Month Header */}
              <Box
                display="flex"
                alignItems="center"
                justifyContent="space-between"
                p="16px"
                sx={styles.monthHeader(isInPlanning)}
                onClick={() => {
                  if (isInPlanning)
                    setExpandedMonth(isExpanded ? null : monthKey);
                }}
              >
                <Box display="flex" alignItems="center" gap="10px">
                  <Box
                    sx={{
                      display: "flex",
                      alignItems: "center",
                      justifyContent: "center",
                      color: colors.greenAccent[400],
                    }}
                  >
                    {MONTH_ICONS[monthIdx]}
                  </Box>
                  <Box>
                    <Typography fontWeight="bold" color={colors.grey[100]}>
                      {MONTHS_FR[monthIdx]}
                    </Typography>
                    {actCount > 0 && isInPlanning && (
                      <Typography
                        variant="caption"
                        color={colors.greenAccent[400]}
                      >
                        {actCount} activité{actCount > 1 ? "s" : ""}
                      </Typography>
                    )}
                    {!isInPlanning && (
                      <Typography
                        variant="caption"
                        color={colors.grey[500]}
                        fontStyle="italic"
                        display="block"
                      >
                        Hors planning
                      </Typography>
                    )}
                  </Box>
                </Box>
                {isInPlanning && (
                  <IconButton size="small" sx={{ color: colors.grey[300] }}>
                    {isExpanded ? <ExpandLessIcon /> : <ExpandMoreIcon />}
                  </IconButton>
                )}
              </Box>

              {/* Expanded: List Weeks */}
              {isExpanded && (
                <Box px="16px" pb="16px">
                  {weeks.map((week, wi) => {
                    const planStartStr =
                      selectedPlanning?.start_date?.slice(0, 10) ||
                      selectedPlanning?.startDate?.slice(0, 10) ||
                      "0000-00-00";
                    const planEndStr =
                      selectedPlanning?.end_date?.slice(0, 10) ||
                      selectedPlanning?.endDate?.slice(0, 10) ||
                      "9999-99-99";

                    const filteredWeek = week.filter(
                      (d) =>
                        d.dateStr >= planStartStr && d.dateStr <= planEndStr,
                    );

                    if (filteredWeek.length === 0) return null;

                    const startD = filteredWeek[0];
                    const endD = filteredWeek[filteredWeek.length - 1];
                    const startMonth = startD.date.getMonth();
                    const endMonth = endD.date.getMonth();

                    let startStr = `${startD.day}`;
                    if (
                      startMonth !== endMonth ||
                      startD.dateStr === endD.dateStr
                    ) {
                      startStr += ` ${MONTHS_FR[startMonth]}`;
                    }
                    const endStr = `${endD.day} ${MONTHS_FR[endMonth]}`;

                    const displayRange =
                      startD.dateStr === endD.dateStr
                        ? startStr
                        : `${startStr} – ${endStr}`;

                    const weekDatesStr = filteredWeek
                      .filter((d) => d.inMonth)
                      .map((d) => d.dateStr);
                    const weekActivities = weekDatesStr.flatMap(
                      (ds) => activityMap[ds] || [],
                    );

                    return (
                      <Box
                        key={wi}
                        mb="8px"
                        backgroundColor={colors.primary[500]}
                        borderRadius="8px"
                        p="12px"
                        sx={{
                          cursor: "pointer",
                          border: `1px solid transparent`,
                          "&:hover": { borderColor: colors.greenAccent[500] },
                        }}
                        onClick={() => {
                          setWeekModalInfo({
                            year: visibleYear,
                            month: monthIdx,
                            weekIndex: wi + 1,
                            week: filteredWeek,
                          });
                          setSelectedClassForWeekId("");
                        }}
                      >
                        <Typography fontWeight="bold" color={colors.grey[200]}>
                          Semaine {wi + 1}: {displayRange}
                          {weekActivities.length > 0 && (
                            <Typography
                              component="span"
                              color={colors.greenAccent[400]}
                              ml="8px"
                              fontSize="0.8rem"
                            >
                              ({weekActivities.length})
                            </Typography>
                          )}
                        </Typography>
                      </Box>
                    );
                  })}
                </Box>
              )}
            </Box>
          );
        })}
      </Box>
    </>
  );
};

const CriteriaTab = (props) => {
  const {
    theme,
    colors,
    searchParams,
    setSearchParams,
    tabParam,
    activeTab,
    setActiveTab,
    plannings,
    setPlannings,
    selectedPlanningId,
    setSelectedPlanningId,
    activitiesList,
    setActivitiesList,
    allActivities,
    setAllActivities,
    criteriaList,
    setCriteriaList,
    allClassesData,
    setAllClassesData,
    classOptions,
    setClassOptions,
    expandedMonth,
    setExpandedMonth,
    weekModalInfo,
    setWeekModalInfo,
    selectedClassForWeekId,
    setSelectedClassForWeekId,
    dayTimelineInfo,
    setDayTimelineInfo,
    planModalOpen,
    setPlanModalOpen,
    addActivityForm,
    setAddActivityForm,
    addActivityError,
    setAddActivityError,
    addActivitySaving,
    setAddActivitySaving,
    newCriteriaName,
    setNewCriteriaName,
    addCriteriaError,
    setAddCriteriaError,
    addCriteriaSaving,
    setAddCriteriaSaving,
    isCriteriaDialogOpen,
    setIsCriteriaDialogOpen,
    addAllActivityForm,
    setAddAllActivityForm,
    addAllActivityError,
    setAddAllActivityError,
    addAllActivitySaving,
    setAddAllActivitySaving,
    suggestingCriteria,
    setSuggestingCriteria,
    maxSuggestedCriteria,
    setMaxSuggestedCriteria,
    isAllActivityDialogOpen,
    setIsAllActivityDialogOpen,
    aiEnabled,
    setAiEnabled,
    isEditDialogOpen,
    setIsEditDialogOpen,
    editingActivity,
    setEditingActivity,
    editForm,
    setEditForm,
    editFormError,
    setEditFormError,
    isDeleteDialogOpen,
    setIsDeleteDialogOpen,
    deletingItem,
    setDeletingItem,
    deleteType,
    setDeleteType,
    fetchPlanned,
    criteriaNameMap,
    selectedPlanning,
    isArchived,
    activityMap,
    monthActivityCounts,
    today,
    planningStartYear,
    planningEndYear,
    visibleYear,
    setVisibleYear,
    planningMonthKeys,
    dayTimelineActivities,
    timelineWindow,
    isWeekendDate,
    handleAddActivity,
    openAddForDate,
    handleAddCriteria,
    handleDeleteCriteria,
    handleAddAllActivity,
    handleSuggestCriteria,
    handleEditActivityClick,
    handleEditSubmit,
    handleSuggestCriteriaForEdit,
    handleDeleteActivity,
    handleDeletePlannedActivity,
    handleDeleteConfirm,
    getStatusLabel,
    getStatusColor,
    criteriaColumns,
    allActivityColumns,
    styles,
    MONTHS_FR,
    WEEKDAYS_FR,
    MONTH_ICONS,
    getWeeksOfMonth,
    getTimelineWindow,
    getPlanningMonths,
    formatMinutesToHourLabel,
    parseTimeToMinutes,
  } = props;
  return (
    <>
      <Box sx={styles.sectionCard}>
        <Box sx={styles.sectionHeader}>
          <Box>
            <Typography sx={styles.sectionTitle}>Critères d'évaluation</Typography>
            <Typography sx={styles.sectionSubtitle}>
              Gérez une bibliothèque plus lisible de critères avec une liste compacte et des actions discrètes.
            </Typography>
          </Box>
          <Button
            variant="contained"
            startIcon={<AddRoundedIcon fontSize="small" />}
            onClick={() => {
              setAddCriteriaError("");
              setNewCriteriaName("");
              setIsCriteriaDialogOpen(true);
            }}
            sx={styles.sectionActionButton}
          >
            Ajouter un critère
          </Button>
        </Box>
        <Box height="60vh" sx={styles.datagridSx}>
          <DataGrid
            rows={criteriaList}
            columns={criteriaColumns}
            components={{ Toolbar: ActivitiesFilterToolbar }}
            componentsProps={{ toolbar: { colors, isDark: theme.palette.mode === "dark" } }}
            pageSize={10}
            rowsPerPageOptions={[10, 50, 100]}
            disableSelectionOnClick
            rowHeight={74}
          />
        </Box>
      </Box>
    </>
  );
};

const AllActivitiesTab = (props) => {
  const {
    theme,
    colors,
    searchParams,
    setSearchParams,
    tabParam,
    activeTab,
    setActiveTab,
    plannings,
    setPlannings,
    selectedPlanningId,
    setSelectedPlanningId,
    activitiesList,
    setActivitiesList,
    allActivities,
    setAllActivities,
    criteriaList,
    setCriteriaList,
    allClassesData,
    setAllClassesData,
    classOptions,
    setClassOptions,
    expandedMonth,
    setExpandedMonth,
    weekModalInfo,
    setWeekModalInfo,
    selectedClassForWeekId,
    setSelectedClassForWeekId,
    dayTimelineInfo,
    setDayTimelineInfo,
    planModalOpen,
    setPlanModalOpen,
    addActivityForm,
    setAddActivityForm,
    addActivityError,
    setAddActivityError,
    addActivitySaving,
    setAddActivitySaving,
    newCriteriaName,
    setNewCriteriaName,
    addCriteriaError,
    setAddCriteriaError,
    addCriteriaSaving,
    setAddCriteriaSaving,
    isCriteriaDialogOpen,
    setIsCriteriaDialogOpen,
    addAllActivityForm,
    setAddAllActivityForm,
    addAllActivityError,
    setAddAllActivityError,
    addAllActivitySaving,
    setAddAllActivitySaving,
    suggestingCriteria,
    setSuggestingCriteria,
    maxSuggestedCriteria,
    setMaxSuggestedCriteria,
    isAllActivityDialogOpen,
    setIsAllActivityDialogOpen,
    aiEnabled,
    setAiEnabled,
    isEditDialogOpen,
    setIsEditDialogOpen,
    editingActivity,
    setEditingActivity,
    editForm,
    setEditForm,
    editFormError,
    setEditFormError,
    isDeleteDialogOpen,
    setIsDeleteDialogOpen,
    deletingItem,
    setDeletingItem,
    deleteType,
    setDeleteType,
    fetchPlanned,
    criteriaNameMap,
    selectedPlanning,
    isArchived,
    activityMap,
    monthActivityCounts,
    today,
    planningStartYear,
    planningEndYear,
    visibleYear,
    setVisibleYear,
    planningMonthKeys,
    dayTimelineActivities,
    timelineWindow,
    isWeekendDate,
    handleAddActivity,
    openAddForDate,
    handleAddCriteria,
    handleDeleteCriteria,
    handleAddAllActivity,
    handleSuggestCriteria,
    handleEditActivityClick,
    handleEditSubmit,
    handleSuggestCriteriaForEdit,
    handleDeleteActivity,
    handleDeletePlannedActivity,
    handleDeleteConfirm,
    getStatusLabel,
    getStatusColor,
    criteriaColumns,
    allActivityColumns,
    styles,
    MONTHS_FR,
    WEEKDAYS_FR,
    MONTH_ICONS,
    getWeeksOfMonth,
    getTimelineWindow,
    getPlanningMonths,
    formatMinutesToHourLabel,
    parseTimeToMinutes,
  } = props;
  return (
    <>
      <Box sx={styles.sectionCard}>
        <Box sx={styles.sectionHeader}>
          <Box>
            <Typography sx={styles.sectionTitle}>Bibliothèque d'activités</Typography>
            <Typography sx={styles.sectionSubtitle}>
              Des descriptions plus respirantes, des critères sous forme de tags et des actions compactes pour libérer la table.
            </Typography>
          </Box>
          <Button
            variant="contained"
            startIcon={<AddRoundedIcon fontSize="small" />}
            onClick={() => {
              setAddAllActivityError("");
              setAddAllActivityForm({ title: "", description: "", criteriaIds: [] });
              setIsAllActivityDialogOpen(true);
            }}
            sx={styles.sectionActionButton}
          >
            Ajouter une activité
          </Button>
        </Box>
        <Box height="60vh" sx={styles.datagridSx}>
          <DataGrid
            rows={allActivities}
            columns={allActivityColumns}
            components={{ Toolbar: ActivitiesFilterToolbar }}
            componentsProps={{ toolbar: { colors, isDark: theme.palette.mode === "dark" } }}
            pageSize={10}
            rowsPerPageOptions={[10, 50, 100]}
            disableSelectionOnClick
            rowHeight={92}
          />
        </Box>
      </Box>
    </>
  );
};

const AddCriteriaDialogComponent = (props) => {
  const {
    colors,
    styles,
    isCriteriaDialogOpen,
    setIsCriteriaDialogOpen,
    newCriteriaName,
    setNewCriteriaName,
    addCriteriaError,
    setAddCriteriaError,
    addCriteriaSaving,
    handleAddCriteria,
  } = props;

  const handleClose = () => {
    setIsCriteriaDialogOpen(false);
    setAddCriteriaError("");
    setNewCriteriaName("");
  };

  return (
    <Dialog open={isCriteriaDialogOpen} onClose={handleClose} fullWidth maxWidth="sm" PaperProps={{ sx: styles.dialogPaper }}>
      <DialogTitle sx={{ ...styles.dialogTitle, display: "flex", alignItems: "center", justifyContent: "space-between" }}>
        <Box>
          <Typography fontWeight="bold" fontSize="1.1rem">Ajouter un critère</Typography>
          <Typography variant="body2" color={colors.grey[300]} mt="4px">
            Ajoutez un nouveau critère dans une fiche plus propre, comme sur la gestion des classes.
          </Typography>
        </Box>
        <IconButton onClick={handleClose} sx={{ color: colors.grey[100] }}>
          <CloseIcon />
        </IconButton>
      </DialogTitle>
      <form onSubmit={handleAddCriteria}>
        <DialogContent sx={{ mt: 2 }}>
          <Box sx={styles.formCard}>
            {addCriteriaError && (
              <Typography color={colors.redAccent[500]} textAlign="center" mb="16px">
                {addCriteriaError}
              </Typography>
            )}
            <TextField
              variant="outlined"
              label="Nom du critère"
              value={newCriteriaName}
              onChange={(e) => setNewCriteriaName(e.target.value)}
              fullWidth
              required
              InputLabelProps={{ shrink: true }}
              sx={styles.filledInputSx}
            />
          </Box>
        </DialogContent>
        <DialogActions sx={styles.dialogActions}>
          <Button onClick={handleClose} sx={{ color: colors.grey[100] }}>Annuler</Button>
          <Button type="submit" variant="contained" disabled={addCriteriaSaving} sx={styles.primaryButton}>
            {addCriteriaSaving ? "Ajout..." : "Ajouter le critère"}
          </Button>
        </DialogActions>
      </form>
    </Dialog>
  );
};

const AddAllActivityDialogComponent = (props) => {
  const {
    theme,
    colors,
    styles,
    criteriaList,
    criteriaNameMap,
    addAllActivityForm,
    setAddAllActivityForm,
    addAllActivityError,
    setAddAllActivityError,
    addAllActivitySaving,
    handleAddAllActivity,
    suggestingCriteria,
    maxSuggestedCriteria,
    setMaxSuggestedCriteria,
    handleSuggestCriteria,
    aiEnabled,
    isAllActivityDialogOpen,
    setIsAllActivityDialogOpen,
  } = props;

  const handleClose = () => {
    setIsAllActivityDialogOpen(false);
    setAddAllActivityError("");
    setAddAllActivityForm({ title: "", description: "", criteriaIds: [] });
  };

  return (
    <Dialog open={isAllActivityDialogOpen} onClose={handleClose} fullWidth maxWidth="md" PaperProps={{ sx: styles.dialogPaper }}>
      <DialogTitle sx={{ ...styles.dialogTitle, display: "flex", alignItems: "center", justifyContent: "space-between" }}>
        <Box>
          <Typography fontWeight="bold" fontSize="1.1rem">Ajouter une activité</Typography>
          <Typography variant="body2" color={colors.grey[300]} mt="4px">
            Créez une activité dans la bibliothèque avec une mise en page plus douce et plus lisible.
          </Typography>
        </Box>
        <IconButton onClick={handleClose} sx={{ color: colors.grey[100] }}>
          <CloseIcon />
        </IconButton>
      </DialogTitle>
      <form onSubmit={handleAddAllActivity}>
        <DialogContent sx={{ mt: 2 }}>
          <Box sx={styles.formCard}>
            {addAllActivityError && (
              <Typography color={colors.redAccent[500]} textAlign="center" mb="16px">
                {addAllActivityError}
              </Typography>
            )}
            <Box display="flex" flexDirection="column" gap="16px">
              <TextField
                variant="outlined"
                label="Titre de l'activité"
                value={addAllActivityForm.title}
                onChange={(e) => setAddAllActivityForm((f) => ({ ...f, title: e.target.value }))}
                fullWidth
                required
                InputLabelProps={{ shrink: true }}
                sx={styles.filledInputSx}
              />
              <TextField
                variant="outlined"
                label="Description"
                multiline
                rows={3}
                value={addAllActivityForm.description}
                onChange={(e) => setAddAllActivityForm((f) => ({ ...f, description: e.target.value }))}
                fullWidth
                InputLabelProps={{ shrink: true }}
                sx={styles.filledInputSx}
              />
              <FormControl variant="outlined" fullWidth sx={styles.filledInputSx}>
                <InputLabel shrink>Sélectionner les critères</InputLabel>
                <Select
                  multiple
                  value={addAllActivityForm.criteriaIds}
                  onChange={(e) => setAddAllActivityForm((f) => ({ ...f, criteriaIds: e.target.value }))}
                  label="Sélectionner les critères"
                  renderValue={(sel) => (
                    <Box display="flex" flexWrap="wrap" gap="4px">
                      {sel.map((id) => (
                        <Chip
                          key={id}
                          label={criteriaNameMap[id] || id}
                          size="small"
                          sx={{
                            backgroundColor: theme.palette.mode === "dark" ? "rgba(20, 184, 166, 0.14)" : "rgba(13, 148, 136, 0.10)",
                            color: colors.greenAccent[400],
                            border: `1px solid ${theme.palette.mode === "dark" ? "rgba(45, 212, 191, 0.16)" : "rgba(13, 148, 136, 0.16)"}`,
                            fontWeight: 700,
                          }}
                        />
                      ))}
                    </Box>
                  )}
                  MenuProps={{
                    PaperProps: {
                      sx: {
                        backgroundColor: colors.primary[400],
                        backgroundImage: "none",
                        borderRadius: "12px",
                        boxShadow: "0 8px 32px rgba(0,0,0,0.3)",
                        p: 1,
                      },
                    },
                  }}
                >
                  {criteriaList.map((c) => {
                    const isSelected = addAllActivityForm.criteriaIds.includes(c.id);
                    return (
                      <MenuItem
                        key={c.id}
                        value={c.id}
                        sx={{
                          display: "flex",
                          alignItems: "center",
                          gap: "12px",
                          borderRadius: "8px",
                          my: "4px",
                          transition: "all 0.2s",
                          backgroundColor: isSelected ? `${colors.greenAccent[500]}15` : "transparent",
                          "&:hover": {
                            backgroundColor: isSelected ? `${colors.greenAccent[500]}25` : "rgba(255,255,255,0.08)",
                          },
                        }}
                      >
                        <Box
                          sx={{
                            width: "20px",
                            height: "20px",
                            borderRadius: "5px",
                            flexShrink: 0,
                            border: `2px solid ${isSelected ? colors.greenAccent[500] : colors.grey[500]}`,
                            backgroundColor: isSelected ? colors.greenAccent[500] : "transparent",
                            display: "flex",
                            alignItems: "center",
                            justifyContent: "center",
                            transition: "all 0.2s ease-in-out",
                          }}
                        >
                          {isSelected && <Typography color="#fff" fontSize="12px" fontWeight="bold">✓</Typography>}
                        </Box>
                        <Typography color={isSelected ? colors.greenAccent[400] : colors.grey[100]} fontWeight={isSelected ? "bold" : "normal"}>
                          {c.name}
                        </Typography>
                      </MenuItem>
                    );
                  })}
                </Select>
              </FormControl>
              <Box sx={styles.helperPanel}>
                <Typography sx={styles.helperLabel}>Max critères :</Typography>
                <TextField
                  variant="outlined"
                  type="number"
                  size="small"
                  value={maxSuggestedCriteria}
                  onChange={(e) => {
                    const v = parseInt(e.target.value);
                    if (!v || v < 1) setMaxSuggestedCriteria(1);
                    else setMaxSuggestedCriteria(Math.min(v, criteriaList.length || 5));
                  }}
                  sx={{ width: 78, ...styles.filledInputSx }}
                  inputProps={{ min: 1, max: criteriaList.length || 5 }}
                />
                <Button variant="contained" onClick={handleSuggestCriteria} disabled={suggestingCriteria || !aiEnabled} sx={styles.secondaryButton}>
                  {suggestingCriteria ? (
                    <>
                      <CircularProgress size={16} sx={{ color: "#fff", mr: 1 }} /> Suggestion...
                    </>
                  ) : !aiEnabled ? (
                    "IA désactivée"
                  ) : (
                    "Suggérer des critères (AI)"
                  )}
                </Button>
              </Box>
            </Box>
          </Box>
        </DialogContent>
        <DialogActions sx={styles.dialogActions}>
          <Button onClick={handleClose} sx={{ color: colors.grey[100] }}>Annuler</Button>
          <Button type="submit" variant="contained" disabled={addAllActivitySaving} sx={styles.primaryButton}>
            {addAllActivitySaving ? "Ajout..." : "Ajouter l'activité"}
          </Button>
        </DialogActions>
      </form>
    </Dialog>
  );
};

const WeekDialogComponent = (props) => {
  const {
    theme,
    colors,
    searchParams,
    setSearchParams,
    tabParam,
    activeTab,
    setActiveTab,
    plannings,
    setPlannings,
    selectedPlanningId,
    setSelectedPlanningId,
    activitiesList,
    setActivitiesList,
    allActivities,
    setAllActivities,
    criteriaList,
    setCriteriaList,
    allClassesData,
    setAllClassesData,
    classOptions,
    setClassOptions,
    expandedMonth,
    setExpandedMonth,
    weekModalInfo,
    setWeekModalInfo,
    selectedClassForWeekId,
    setSelectedClassForWeekId,
    dayTimelineInfo,
    setDayTimelineInfo,
    planModalOpen,
    setPlanModalOpen,
    addActivityForm,
    setAddActivityForm,
    addActivityError,
    setAddActivityError,
    addActivitySaving,
    setAddActivitySaving,
    newCriteriaName,
    setNewCriteriaName,
    addCriteriaSaving,
    setAddCriteriaSaving,
    addAllActivityForm,
    setAddAllActivityForm,
    addAllActivityError,
    setAddAllActivityError,
    addAllActivitySaving,
    setAddAllActivitySaving,
    suggestingCriteria,
    setSuggestingCriteria,
    maxSuggestedCriteria,
    setMaxSuggestedCriteria,
    aiEnabled,
    setAiEnabled,
    isEditDialogOpen,
    setIsEditDialogOpen,
    editingActivity,
    setEditingActivity,
    editForm,
    setEditForm,
    editFormError,
    setEditFormError,
    isDeleteDialogOpen,
    setIsDeleteDialogOpen,
    deletingItem,
    setDeletingItem,
    deleteType,
    setDeleteType,
    fetchPlanned,
    criteriaNameMap,
    selectedPlanning,
    isArchived,
    activityMap,
    monthActivityCounts,
    today,
    planningStartYear,
    planningEndYear,
    visibleYear,
    setVisibleYear,
    planningMonthKeys,
    dayTimelineActivities,
    timelineWindow,
    isWeekendDate,
    handleAddActivity,
    openAddForDate,
    handleAddCriteria,
    handleDeleteCriteria,
    handleAddAllActivity,
    handleSuggestCriteria,
    handleEditActivityClick,
    handleEditSubmit,
    handleSuggestCriteriaForEdit,
    handleDeleteActivity,
    handleDeletePlannedActivity,
    handleDeleteConfirm,
    getStatusLabel,
    getStatusColor,
    criteriaColumns,
    allActivityColumns,
    styles,
    MONTHS_FR,
    WEEKDAYS_FR,
    MONTH_ICONS,
    getWeeksOfMonth,
    getTimelineWindow,
    getPlanningMonths,
    formatMinutesToHourLabel,
    parseTimeToMinutes,
  } = props;
  return (
    <>
      <Dialog
        open={!!weekModalInfo}
        onClose={() => setWeekModalInfo(null)}
        fullWidth
        maxWidth="sm"
        PaperProps={{
          sx: {
            backgroundColor: colors.primary[400],
            color: colors.grey[100],
            borderRadius: "12px",
          },
        }}
      >
        <DialogTitle
          sx={{
            fontWeight: "bold",
            borderBottom: `1px solid ${colors.primary[500]}`,
          }}
        >
          {weekModalInfo &&
            `Semaine ${weekModalInfo.weekIndex} • ${MONTHS_FR[weekModalInfo.month]} ${weekModalInfo.year}`}
        </DialogTitle>
        <DialogContent sx={{ mt: 2 }}>
          <FormControl variant="filled" fullWidth sx={{ mb: "20px" }}>
            <InputLabel>Classe</InputLabel>
            <Select
              value={selectedClassForWeekId}
              onChange={(e) => setSelectedClassForWeekId(e.target.value)}
            >
              <MenuItem value="">
                <em>Sélectionner une classe</em>
              </MenuItem>
              {classOptions.map((c) => (
                <MenuItem key={c.id} value={c.id}>
                  {c.label} - date de création: {c.creation_year}
                </MenuItem>
              ))}
            </Select>
          </FormControl>

          {!selectedClassForWeekId ? (
            <Typography
              color={colors.grey[500]}
              fontStyle="italic"
              textAlign="center"
              py="20px"
            >
              Choisissez une classe pour charger les activités.
            </Typography>
          ) : (
            <Box display="flex" flexDirection="column" gap="10px">
              {weekModalInfo?.week?.map((dayInfo) => (
                <Box
                  key={dayInfo.dateStr}
                  p="16px"
                  borderRadius="8px"
                  backgroundColor={colors.primary[500]}
                  sx={{ cursor: "pointer", "&:hover": { opacity: 0.8 } }}
                  onClick={() => {
                    setDayTimelineInfo({
                      dateStr: dayInfo.dateStr,
                      day: dayInfo.day,
                      month: dayInfo.date.getMonth(),
                      year: dayInfo.date.getFullYear(),
                      dow: dayInfo.dow,
                    });
                    setWeekModalInfo(null);
                  }}
                >
                  <Typography fontWeight="bold" color={colors.grey[100]}>
                    {WEEKDAYS_FR[dayInfo.dow]} {dayInfo.day}{" "}
                    {MONTHS_FR[dayInfo.date.getMonth()]}
                  </Typography>
                </Box>
              ))}
            </Box>
          )}
        </DialogContent>
        <DialogActions
          sx={{ p: 2, borderTop: `1px solid ${colors.primary[500]}` }}
        >
          <Button
            onClick={() => setWeekModalInfo(null)}
            sx={{ color: colors.grey[100] }}
          >
            Fermer
          </Button>
        </DialogActions>
      </Dialog>
    </>
  );
};

const DayTimelineDialogComponent = (props) => {
  const {
    theme,
    colors,
    searchParams,
    setSearchParams,
    tabParam,
    activeTab,
    setActiveTab,
    plannings,
    setPlannings,
    selectedPlanningId,
    setSelectedPlanningId,
    activitiesList,
    setActivitiesList,
    allActivities,
    setAllActivities,
    criteriaList,
    setCriteriaList,
    allClassesData,
    setAllClassesData,
    classOptions,
    setClassOptions,
    expandedMonth,
    setExpandedMonth,
    weekModalInfo,
    setWeekModalInfo,
    selectedClassForWeekId,
    setSelectedClassForWeekId,
    dayTimelineInfo,
    setDayTimelineInfo,
    planModalOpen,
    setPlanModalOpen,
    addActivityForm,
    setAddActivityForm,
    addActivityError,
    setAddActivityError,
    addActivitySaving,
    setAddActivitySaving,
    newCriteriaName,
    setNewCriteriaName,
    addCriteriaSaving,
    setAddCriteriaSaving,
    addAllActivityForm,
    setAddAllActivityForm,
    addAllActivityError,
    setAddAllActivityError,
    addAllActivitySaving,
    setAddAllActivitySaving,
    suggestingCriteria,
    setSuggestingCriteria,
    maxSuggestedCriteria,
    setMaxSuggestedCriteria,
    aiEnabled,
    setAiEnabled,
    isEditDialogOpen,
    setIsEditDialogOpen,
    editingActivity,
    setEditingActivity,
    editForm,
    setEditForm,
    editFormError,
    setEditFormError,
    isDeleteDialogOpen,
    setIsDeleteDialogOpen,
    deletingItem,
    setDeletingItem,
    deleteType,
    setDeleteType,
    fetchPlanned,
    criteriaNameMap,
    selectedPlanning,
    isArchived,
    activityMap,
    monthActivityCounts,
    today,
    planningStartYear,
    planningEndYear,
    visibleYear,
    setVisibleYear,
    planningMonthKeys,
    dayTimelineActivities,
    timelineWindow,
    isWeekendDate,
    handleAddActivity,
    openAddForDate,
    handleAddCriteria,
    handleDeleteCriteria,
    handleAddAllActivity,
    handleSuggestCriteria,
    handleEditActivityClick,
    handleEditSubmit,
    handleSuggestCriteriaForEdit,
    handleDeleteActivity,
    handleDeletePlannedActivity,
    handleDeleteConfirm,
    getStatusLabel,
    getStatusColor,
    criteriaColumns,
    allActivityColumns,
    styles,
    MONTHS_FR,
    WEEKDAYS_FR,
    MONTH_ICONS,
    getWeeksOfMonth,
    getTimelineWindow,
    getPlanningMonths,
    formatMinutesToHourLabel,
    parseTimeToMinutes,
  } = props;
  return (
    <>
      <Dialog
        open={!!dayTimelineInfo}
        onClose={() => setDayTimelineInfo(null)}
        fullWidth
        maxWidth="md"
        PaperProps={{
          sx: {
            backgroundColor: colors.primary[400],
            color: colors.grey[100],
            borderRadius: "12px",
          },
        }}
      >
        <DialogTitle
          sx={{
            fontWeight: "bold",
            borderBottom: `1px solid ${colors.primary[500]}`,
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
          }}
        >
          {dayTimelineInfo &&
            `Horaires • ${WEEKDAYS_FR[dayTimelineInfo.dow]} ${dayTimelineInfo.day} ${MONTHS_FR[dayTimelineInfo.month]} ${dayTimelineInfo.year}`}
          <IconButton
            size="small"
            onClick={() => setDayTimelineInfo(null)}
            sx={{ color: colors.grey[100] }}
          >
            <CloseIcon />
          </IconButton>
        </DialogTitle>
        <DialogContent sx={{ mt: 2, minHeight: "400px" }}>
          <Box
            display="flex"
            justifyContent="space-between"
            alignItems="center"
            mb="20px"
          >
            <Typography variant="h5" color={colors.grey[100]} fontWeight="bold">
              {classOptions.find((c) => c.id === Number(selectedClassForWeekId))
                ?.name || "-"}
            </Typography>
            {!isArchived && (
              <Button
                variant="contained"
                onClick={() => openAddForDate(dayTimelineInfo?.dateStr)}
                sx={styles.primaryButton}
              >
                + Ajouter
              </Button>
            )}
          </Box>

          {dayTimelineActivities.length === 0 ? (
            <Typography
              color={colors.grey[500]}
              fontStyle="italic"
              textAlign="center"
              py="40px"
            >
              Aucune activité planifiée pour ce jour.
            </Typography>
          ) : (
            <Box>
              {/* Horizontal visual timeline */}
              <Box
                position="relative"
                height="50px"
                backgroundColor={colors.primary[500]}
                borderRadius="6px"
                mb="30px"
                overflow="hidden"
                border={`1px solid ${colors.primary[600]}`}
              >
                {dayTimelineActivities.map((act, idx) => {
                  const start = parseTimeToMinutes(act.startTime);
                  const end = parseTimeToMinutes(act.endTime);
                  const range = Math.max(
                    1,
                    timelineWindow.end - timelineWindow.start,
                  );
                  const safeStart =
                    start === null
                      ? timelineWindow.start
                      : Math.max(
                          timelineWindow.start,
                          Math.min(start, timelineWindow.end),
                        );
                  const safeEnd =
                    end === null
                      ? safeStart + 30
                      : Math.max(
                          safeStart + 15,
                          Math.min(end, timelineWindow.end),
                        );
                  const leftPct =
                    ((safeStart - timelineWindow.start) / range) * 100;
                  const widthPct = Math.max(
                    2,
                    ((safeEnd - safeStart) / range) * 100,
                  );
                  const color = TIMELINE_COLORS[idx % TIMELINE_COLORS.length];

                  return (
                    <Box
                      key={act.id}
                      position="absolute"
                      top="10%"
                      bottom="10%"
                      sx={{
                        left: `${leftPct}%`,
                        width: `${widthPct}%`,
                        backgroundColor: color,
                        borderRadius: "4px",
                        boxShadow: "0px 2px 5px rgba(0,0,0,0.2)",
                        "&:hover": { filter: "brightness(1.1)" },
                      }}
                      title={`${act.title} (${act.startTime || "--:--"} - ${act.endTime || "--:--"})`}
                    />
                  );
                })}
              </Box>

              <Box
                display="flex"
                justifyContent="space-between"
                color={colors.grey[400]}
                fontSize="0.75rem"
                mt="-25px"
                mb="20px"
              >
                <Typography>
                  {formatMinutesToHourLabel(timelineWindow.start)}
                </Typography>
                <Typography>
                  {formatMinutesToHourLabel(timelineWindow.end)}
                </Typography>
              </Box>

              {/* List of activities */}
              <Box display="flex" flexDirection="column" gap="10px">
                {dayTimelineActivities.map((act, idx) => {
                  const color = TIMELINE_COLORS[idx % TIMELINE_COLORS.length];
                  return (
                    <Box
                      key={act.id}
                      display="flex"
                      justifyContent="space-between"
                      alignItems="center"
                      p="15px"
                      borderLeft={`5px solid ${color}`}
                      backgroundColor={colors.primary[500]}
                      borderRadius="4px"
                    >
                      <Box>
                        <Typography
                          fontWeight="bold"
                          fontSize="16px"
                          color={colors.grey[100]}
                        >
                          {act.title}
                        </Typography>
                        <Typography color={colors.grey[300]}>
                          {act.startTime || "--:--"} — {act.endTime || "--:--"}
                        </Typography>
                      </Box>
                      <Box
                        display="flex"
                        alignItems="center"
                        gap="8px"
                        flexWrap="wrap"
                      >
                        <Chip
                          label={getStatusLabel(act.status)}
                          sx={{
                            backgroundColor: getStatusColor(act.status),
                            color: "#fff",
                            fontSize: "0.75rem",
                          }}
                        />
                        {!isArchived && (
                          <IconButton
                            color="error"
                            onClick={() => handleDeletePlannedActivity(act.id)}
                          >
                            <DeleteOutlineIcon />
                          </IconButton>
                        )}
                      </Box>
                    </Box>
                  );
                })}
              </Box>
            </Box>
          )}
        </DialogContent>
        <DialogActions
          sx={{ p: 2, borderTop: `1px solid ${colors.primary[500]}` }}
        >
          <Button
            onClick={() => setDayTimelineInfo(null)}
            sx={{ color: colors.grey[100] }}
          >
            Fermer
          </Button>
        </DialogActions>
      </Dialog>
    </>
  );
};

const PlanActivityDialogComponent = (props) => {
  const {
    theme,
    colors,
    searchParams,
    setSearchParams,
    tabParam,
    activeTab,
    setActiveTab,
    plannings,
    setPlannings,
    selectedPlanningId,
    setSelectedPlanningId,
    activitiesList,
    setActivitiesList,
    allActivities,
    setAllActivities,
    criteriaList,
    setCriteriaList,
    allClassesData,
    setAllClassesData,
    classOptions,
    setClassOptions,
    expandedMonth,
    setExpandedMonth,
    weekModalInfo,
    setWeekModalInfo,
    selectedClassForWeekId,
    setSelectedClassForWeekId,
    dayTimelineInfo,
    setDayTimelineInfo,
    planModalOpen,
    setPlanModalOpen,
    addActivityForm,
    setAddActivityForm,
    addActivityError,
    setAddActivityError,
    addActivitySaving,
    setAddActivitySaving,
    newCriteriaName,
    setNewCriteriaName,
    addCriteriaSaving,
    setAddCriteriaSaving,
    addAllActivityForm,
    setAddAllActivityForm,
    addAllActivityError,
    setAddAllActivityError,
    addAllActivitySaving,
    setAddAllActivitySaving,
    suggestingCriteria,
    setSuggestingCriteria,
    maxSuggestedCriteria,
    setMaxSuggestedCriteria,
    aiEnabled,
    setAiEnabled,
    isEditDialogOpen,
    setIsEditDialogOpen,
    editingActivity,
    setEditingActivity,
    editForm,
    setEditForm,
    editFormError,
    setEditFormError,
    isDeleteDialogOpen,
    setIsDeleteDialogOpen,
    deletingItem,
    setDeletingItem,
    deleteType,
    setDeleteType,
    fetchPlanned,
    criteriaNameMap,
    selectedPlanning,
    isArchived,
    activityMap,
    monthActivityCounts,
    today,
    planningStartYear,
    planningEndYear,
    visibleYear,
    setVisibleYear,
    planningMonthKeys,
    dayTimelineActivities,
    timelineWindow,
    isWeekendDate,
    handleAddActivity,
    openAddForDate,
    handleAddCriteria,
    handleDeleteCriteria,
    handleAddAllActivity,
    handleSuggestCriteria,
    handleEditActivityClick,
    handleEditSubmit,
    handleSuggestCriteriaForEdit,
    handleDeleteActivity,
    handleDeletePlannedActivity,
    handleDeleteConfirm,
    getStatusLabel,
    getStatusColor,
    criteriaColumns,
    allActivityColumns,
    styles,
    MONTHS_FR,
    WEEKDAYS_FR,
    MONTH_ICONS,
    getWeeksOfMonth,
    getTimelineWindow,
    getPlanningMonths,
    formatMinutesToHourLabel,
    parseTimeToMinutes,
  } = props;
  return (
    <>
      <Dialog
        open={planModalOpen}
        onClose={() => {
          setPlanModalOpen(false);
          setAddActivityError("");
        }}
        fullWidth
        maxWidth="sm"
        PaperProps={{ sx: styles.dialogPaper }}
      >
        <DialogTitle
          sx={{ ...styles.dialogTitle, display: "flex", alignItems: "center", justifyContent: "space-between", gap: "12px" }}
        >
          <Box>
            <Typography fontWeight="bold" fontSize="1.1rem">Planifier une activité</Typography>
            <Typography variant="body2" color={colors.grey[300]} mt="4px">
              Utilisez la même logique douce que dans les classes pour planifier proprement une activité.
            </Typography>
          </Box>
          <IconButton onClick={() => { setPlanModalOpen(false); setAddActivityError(""); }} sx={{ color: colors.grey[100] }}>
            <CloseIcon />
          </IconButton>
        </DialogTitle>
        <DialogContent sx={{ mt: 2, px: 3 }}>
          {addActivityError && (
            <Typography
              color={colors.redAccent[500]}
              mb="15px"
              textAlign="center"
              p="10px"
              borderRadius="8px"
              backgroundColor="rgba(239,68,68,0.1)"
            >
              {addActivityError}
            </Typography>
          )}
          <form id="plan-activity-form" onSubmit={handleAddActivity}>
            <Box sx={styles.formCard} display="flex" flexDirection="column" gap="20px" mt="10px">
              {/* Activity Selection */}
              <Box>
                <FormControl variant="outlined" fullWidth sx={styles.filledInputSx}>
                  <InputLabel shrink>Sélectionner une activité</InputLabel>
                  <Select
                    value={addActivityForm.activityId}
                    onChange={(e) =>
                      setAddActivityForm((f) => ({
                        ...f,
                        activityId: e.target.value,
                      }))
                    }
                    renderValue={(selectedId) => {
                      const a = allActivities.find(
                        (act) => act.id === selectedId,
                      );
                        return a ? a.title : "";
                    }}
                    label="Sélectionner une activité"
                    MenuProps={{
                      PaperProps: {
                        sx: {
                          backgroundColor: colors.primary[400],
                          backgroundImage: "none",
                          borderRadius: "12px",
                          boxShadow: "0 8px 32px rgba(0,0,0,0.3)",
                          p: 1,
                        },
                      },
                    }}
                  >
                    {allActivities.map((a) => {
                      const isSelected = addActivityForm.activityId === a.id;
                      return (
                        <MenuItem
                          key={a.id}
                          value={a.id}
                          sx={{
                            display: "flex",
                            alignItems: "center",
                            gap: "12px",
                            borderRadius: "8px",
                            my: "4px",
                            transition: "all 0.2s",
                            backgroundColor: isSelected
                              ? `${colors.blueAccent[500]}15`
                              : "transparent",
                            "&:hover": {
                              backgroundColor: isSelected
                                ? `${colors.blueAccent[500]}25`
                                : "rgba(255,255,255,0.08)",
                            },
                          }}
                        >
                          <Box
                            sx={{
                              width: "20px",
                              height: "20px",
                              borderRadius: "5px",
                              flexShrink: 0,
                              border: `2px solid ${isSelected ? colors.blueAccent[500] : colors.grey[500]}`,
                              backgroundColor: isSelected
                                ? colors.blueAccent[500]
                                : "transparent",
                              display: "flex",
                              alignItems: "center",
                              justifyContent: "center",
                              transition: "all 0.2s ease-in-out",
                            }}
                          >
                            {isSelected && (
                              <Typography
                                color="#fff"
                                fontSize="12px"
                                fontWeight="bold"
                              >
                                ✓
                              </Typography>
                            )}
                          </Box>
                          <Typography
                            color={
                              isSelected
                                ? colors.blueAccent[400]
                                : colors.grey[100]
                            }
                            fontWeight={isSelected ? "bold" : "normal"}
                          >
                            {a.title}
                          </Typography>
                        </MenuItem>
                      );
                    })}
                  </Select>
                </FormControl>
              </Box>

              {/* Date */}
              <Box>
                <TextField
                  variant="outlined"
                  label="Date"
                  type="date"
                  InputLabelProps={{ shrink: true }}
                  value={addActivityForm.date}
                  onChange={(e) => {
                    const nextDate = e.target.value;
                    setAddActivityForm((f) => ({ ...f, date: nextDate }));
                    if (isWeekendDate(nextDate)) {
                      setAddActivityError(
                        "Les activités ne peuvent être planifiées que du lundi au vendredi.",
                      );
                    } else {
                      setAddActivityError("");
                    }
                  }}
                  fullWidth
                  required
                  helperText="Les activités sont autorisées uniquement du lundi au vendredi."
                  sx={styles.filledInputSx}
                />
              </Box>

              {/* Time Range */}
              <Box>
                <Typography
                  variant="caption"
                  color={colors.grey[300]}
                  mb="6px"
                  display="block"
                  fontWeight="bold"
                  textTransform="uppercase"
                  letterSpacing="0.5px"
                >
                  🕐 Horaires
                </Typography>
                <Box display="grid" gridTemplateColumns="1fr 1fr" gap="12px">
                  {/* --- Heure début --- */}
                  <Box display="flex" gap="8px">
                    <Autocomplete
                      freeSolo
                      forcePopupIcon
                      disableClearable
                      options={Array.from({ length: 24 }).map((_, i) =>
                        String(i).padStart(2, "0"),
                      )}
                      value={
                        addActivityForm.startTime &&
                        addActivityForm.startTime.includes(":")
                          ? addActivityForm.startTime.split(":")[0]
                          : "09"
                      }
                      onInputChange={(e, val) => {
                        const m =
                          addActivityForm.startTime &&
                          addActivityForm.startTime.includes(":")
                            ? addActivityForm.startTime.split(":")[1]
                            : "00";
                        let newH = val.replace(/\D/g, "").substring(0, 2);
                        if (newH !== "" && parseInt(newH) > 23) newH = "23";
                        setAddActivityForm((f) => ({
                          ...f,
                          startTime: `${newH}:${m}`,
                        }));
                      }}
                      onBlur={() => {
                        let h =
                          addActivityForm.startTime &&
                          addActivityForm.startTime.includes(":")
                            ? addActivityForm.startTime.split(":")[0]
                            : "09";
                        const m =
                          addActivityForm.startTime &&
                          addActivityForm.startTime.includes(":")
                            ? addActivityForm.startTime.split(":")[1]
                            : "00";
                        if (!h) h = "09";
                        setAddActivityForm((f) => ({
                          ...f,
                          startTime: `${h.padStart(2, "0")}:${m.padStart(2, "0")}`,
                        }));
                      }}
                      renderInput={(params) => (
                        <TextField {...params} variant="outlined" label="Début (H)" InputLabelProps={{ shrink: true }} sx={styles.filledInputSx} />
                      )}
                      sx={{
                        flex: 1,
                        "& .MuiOutlinedInput-root": {
                          borderRadius: "12px",
                          backgroundColor: theme.palette.mode === "dark" ? colors.primary[400] : "#f8fafc",
                        },
                      }}
                      componentsProps={{
                        popper: {
                          modifiers: [{ name: "flip", enabled: false }],
                        },
                        paper: {
                          sx: {
                            backgroundColor: colors.primary[400],
                            borderRadius: "12px",
                            boxShadow: "0 8px 32px rgba(0,0,0,0.3)",
                            p: 1,
                          },
                        },
                      }}
                    />
                    <Autocomplete
                      freeSolo
                      forcePopupIcon
                      disableClearable
                      options={["00", "15", "30", "45"]}
                      value={
                        addActivityForm.startTime &&
                        addActivityForm.startTime.includes(":")
                          ? addActivityForm.startTime.split(":")[1]
                          : "00"
                      }
                      onInputChange={(e, val) => {
                        const h =
                          addActivityForm.startTime &&
                          addActivityForm.startTime.includes(":")
                            ? addActivityForm.startTime.split(":")[0]
                            : "09";
                        let newM = val.replace(/\D/g, "").substring(0, 2);
                        if (newM !== "" && parseInt(newM) > 59) newM = "59";
                        setAddActivityForm((f) => ({
                          ...f,
                          startTime: `${h}:${newM}`,
                        }));
                      }}
                      onBlur={() => {
                        const h =
                          addActivityForm.startTime &&
                          addActivityForm.startTime.includes(":")
                            ? addActivityForm.startTime.split(":")[0]
                            : "09";
                        let m =
                          addActivityForm.startTime &&
                          addActivityForm.startTime.includes(":")
                            ? addActivityForm.startTime.split(":")[1]
                            : "00";
                        if (!m) m = "00";
                        setAddActivityForm((f) => ({
                          ...f,
                          startTime: `${h.padStart(2, "0")}:${m.padStart(2, "0")}`,
                        }));
                      }}
                      renderInput={(params) => (
                        <TextField {...params} variant="outlined" label="Min" InputLabelProps={{ shrink: true }} sx={styles.filledInputSx} />
                      )}
                      sx={{
                        flex: 1,
                        "& .MuiOutlinedInput-root": {
                          borderRadius: "12px",
                          backgroundColor: theme.palette.mode === "dark" ? colors.primary[400] : "#f8fafc",
                        },
                      }}
                      componentsProps={{
                        popper: {
                          modifiers: [{ name: "flip", enabled: false }],
                        },
                        paper: {
                          sx: {
                            backgroundColor: colors.primary[400],
                            borderRadius: "12px",
                            boxShadow: "0 8px 32px rgba(0,0,0,0.3)",
                            p: 1,
                          },
                        },
                      }}
                    />
                  </Box>

                  {/* --- Heure fin --- */}
                  <Box display="flex" gap="8px">
                    <Autocomplete
                      freeSolo
                      forcePopupIcon
                      disableClearable
                      options={Array.from({ length: 24 }).map((_, i) =>
                        String(i).padStart(2, "0"),
                      )}
                      value={
                        addActivityForm.endTime &&
                        addActivityForm.endTime.includes(":")
                          ? addActivityForm.endTime.split(":")[0]
                          : "11"
                      }
                      onInputChange={(e, val) => {
                        const m =
                          addActivityForm.endTime &&
                          addActivityForm.endTime.includes(":")
                            ? addActivityForm.endTime.split(":")[1]
                            : "00";
                        let newH = val.replace(/\D/g, "").substring(0, 2);
                        if (newH !== "" && parseInt(newH) > 23) newH = "23";
                        setAddActivityForm((f) => ({
                          ...f,
                          endTime: `${newH}:${m}`,
                        }));
                      }}
                      onBlur={() => {
                        let h =
                          addActivityForm.endTime &&
                          addActivityForm.endTime.includes(":")
                            ? addActivityForm.endTime.split(":")[0]
                            : "11";
                        const m =
                          addActivityForm.endTime &&
                          addActivityForm.endTime.includes(":")
                            ? addActivityForm.endTime.split(":")[1]
                            : "00";
                        if (!h) h = "11";
                        setAddActivityForm((f) => ({
                          ...f,
                          endTime: `${h.padStart(2, "0")}:${m.padStart(2, "0")}`,
                        }));
                      }}
                      renderInput={(params) => (
                        <TextField {...params} variant="outlined" label="Fin (H)" InputLabelProps={{ shrink: true }} sx={styles.filledInputSx} />
                      )}
                      sx={{
                        flex: 1,
                        "& .MuiOutlinedInput-root": {
                          borderRadius: "12px",
                          backgroundColor: theme.palette.mode === "dark" ? colors.primary[400] : "#f8fafc",
                        },
                      }}
                      componentsProps={{
                        popper: {
                          modifiers: [{ name: "flip", enabled: false }],
                        },
                        paper: {
                          sx: {
                            backgroundColor: colors.primary[400],
                            borderRadius: "12px",
                            boxShadow: "0 8px 32px rgba(0,0,0,0.3)",
                            p: 1,
                          },
                        },
                      }}
                    />
                    <Autocomplete
                      freeSolo
                      forcePopupIcon
                      disableClearable
                      options={["00", "15", "30", "45"]}
                      value={
                        addActivityForm.endTime &&
                        addActivityForm.endTime.includes(":")
                          ? addActivityForm.endTime.split(":")[1]
                          : "00"
                      }
                      onInputChange={(e, val) => {
                        const h =
                          addActivityForm.endTime &&
                          addActivityForm.endTime.includes(":")
                            ? addActivityForm.endTime.split(":")[0]
                            : "11";
                        let newM = val.replace(/\D/g, "").substring(0, 2);
                        if (newM !== "" && parseInt(newM) > 59) newM = "59";
                        setAddActivityForm((f) => ({
                          ...f,
                          endTime: `${h}:${newM}`,
                        }));
                      }}
                      onBlur={() => {
                        const h =
                          addActivityForm.endTime &&
                          addActivityForm.endTime.includes(":")
                            ? addActivityForm.endTime.split(":")[0]
                            : "11";
                        let m =
                          addActivityForm.endTime &&
                          addActivityForm.endTime.includes(":")
                            ? addActivityForm.endTime.split(":")[1]
                            : "00";
                        if (!m) m = "00";
                        setAddActivityForm((f) => ({
                          ...f,
                          endTime: `${h.padStart(2, "0")}:${m.padStart(2, "0")}`,
                        }));
                      }}
                      renderInput={(params) => (
                        <TextField {...params} variant="outlined" label="Min" InputLabelProps={{ shrink: true }} sx={styles.filledInputSx} />
                      )}
                      sx={{
                        flex: 1,
                        "& .MuiOutlinedInput-root": {
                          borderRadius: "12px",
                          backgroundColor: theme.palette.mode === "dark" ? colors.primary[400] : "#f8fafc",
                        },
                      }}
                      componentsProps={{
                        popper: {
                          modifiers: [{ name: "flip", enabled: false }],
                        },
                        paper: {
                          sx: {
                            backgroundColor: colors.primary[400],
                            borderRadius: "12px",
                            boxShadow: "0 8px 32px rgba(0,0,0,0.3)",
                            p: 1,
                          },
                        },
                      }}
                    />
                  </Box>
                </Box>
              </Box>

              {/* Classes */}
              <Box>
                <FormControl variant="outlined" fullWidth sx={styles.filledInputSx}>
                  <InputLabel shrink>Sélectionner les classes</InputLabel>
                  <Select
                    multiple
                    value={addActivityForm.classIds}
                    onChange={(e) =>
                      setAddActivityForm((f) => ({
                        ...f,
                        classIds: e.target.value,
                      }))
                    }
                    renderValue={(sel) => (
                      <Box display="flex" flexWrap="wrap" gap="4px">
                        {sel.map((id) => {
                          const c = classOptions.find((x) => x.id === id);
                          return (
                            <Chip
                              key={id}
                              label={c?.name || id}
                              size="small"
                              sx={{
                                backgroundColor: theme.palette.mode === "dark" ? "rgba(20, 184, 166, 0.14)" : "rgba(13, 148, 136, 0.10)",
                                color: colors.greenAccent[400],
                                border: `1px solid ${theme.palette.mode === "dark" ? "rgba(45, 212, 191, 0.16)" : "rgba(13, 148, 136, 0.16)"}`,
                                fontWeight: 700,
                              }}
                            />
                          );
                        })}
                      </Box>
                    )}
                    label="Sélectionner les classes"
                    MenuProps={{
                      PaperProps: {
                        sx: {
                          backgroundColor: colors.primary[400],
                          backgroundImage: "none",
                          borderRadius: "12px",
                          boxShadow: "0 8px 32px rgba(0,0,0,0.3)",
                          p: 1,
                        },
                      },
                    }}
                  >
                    {classOptions.map((c) => {
                      const isSelected = addActivityForm.classIds.includes(
                        c.id,
                      );
                      return (
                        <MenuItem
                          key={c.id}
                          value={c.id}
                          sx={{
                            display: "flex",
                            alignItems: "center",
                            gap: "12px",
                            borderRadius: "8px",
                            my: "4px",
                            transition: "all 0.2s",
                            backgroundColor: isSelected
                              ? `${colors.blueAccent[500]}15`
                              : "transparent",
                            "&:hover": {
                              backgroundColor: isSelected
                                ? `${colors.blueAccent[500]}25`
                                : "rgba(255,255,255,0.08)",
                            },
                          }}
                        >
                          <Box
                            sx={{
                              width: "20px",
                              height: "20px",
                              borderRadius: "5px",
                              flexShrink: 0,
                              border: `2px solid ${isSelected ? colors.blueAccent[500] : colors.grey[500]}`,
                              backgroundColor: isSelected
                                ? colors.blueAccent[500]
                                : "transparent",
                              display: "flex",
                              alignItems: "center",
                              justifyContent: "center",
                              transition: "all 0.2s ease-in-out",
                            }}
                          >
                            {isSelected && (
                              <Typography
                                color="#fff"
                                fontSize="12px"
                                fontWeight="bold"
                              >
                                ✓
                              </Typography>
                            )}
                          </Box>
                          <Typography
                            color={
                              isSelected
                                ? colors.blueAccent[400]
                                : colors.grey[100]
                            }
                            fontWeight={isSelected ? "bold" : "normal"}
                          >
                            {c.name}
                          </Typography>
                        </MenuItem>
                      );
                    })}
                  </Select>
                </FormControl>
              </Box>
            </Box>
          </form>
        </DialogContent>
        <DialogActions sx={styles.dialogActions}>
          <Button
            onClick={() => { setPlanModalOpen(false); setAddActivityError(""); }}
            sx={{ color: colors.grey[100] }}
          >
            Annuler
          </Button>
          <Button
            type="submit"
            form="plan-activity-form"
            variant="contained"
            disabled={addActivitySaving}
            sx={styles.primaryButton}
          >
            {addActivitySaving ? "Planification..." : "Planifier l'activité"}
          </Button>
        </DialogActions>
      </Dialog>
    </>
  );
};

const DeleteDialogComponent = (props) => {
  const {
    theme,
    colors,
    searchParams,
    setSearchParams,
    tabParam,
    activeTab,
    setActiveTab,
    plannings,
    setPlannings,
    selectedPlanningId,
    setSelectedPlanningId,
    activitiesList,
    setActivitiesList,
    allActivities,
    setAllActivities,
    criteriaList,
    setCriteriaList,
    allClassesData,
    setAllClassesData,
    classOptions,
    setClassOptions,
    expandedMonth,
    setExpandedMonth,
    weekModalInfo,
    setWeekModalInfo,
    selectedClassForWeekId,
    setSelectedClassForWeekId,
    dayTimelineInfo,
    setDayTimelineInfo,
    planModalOpen,
    setPlanModalOpen,
    addActivityForm,
    setAddActivityForm,
    addActivityError,
    setAddActivityError,
    addActivitySaving,
    setAddActivitySaving,
    newCriteriaName,
    setNewCriteriaName,
    addCriteriaSaving,
    setAddCriteriaSaving,
    addAllActivityForm,
    setAddAllActivityForm,
    addAllActivityError,
    setAddAllActivityError,
    addAllActivitySaving,
    setAddAllActivitySaving,
    suggestingCriteria,
    setSuggestingCriteria,
    maxSuggestedCriteria,
    setMaxSuggestedCriteria,
    aiEnabled,
    setAiEnabled,
    isEditDialogOpen,
    setIsEditDialogOpen,
    editingActivity,
    setEditingActivity,
    editForm,
    setEditForm,
    editFormError,
    setEditFormError,
    isDeleteDialogOpen,
    setIsDeleteDialogOpen,
    deletingItem,
    setDeletingItem,
    deleteType,
    setDeleteType,
    fetchPlanned,
    criteriaNameMap,
    selectedPlanning,
    isArchived,
    activityMap,
    monthActivityCounts,
    today,
    planningStartYear,
    planningEndYear,
    visibleYear,
    setVisibleYear,
    planningMonthKeys,
    dayTimelineActivities,
    timelineWindow,
    handleAddActivity,
    openAddForDate,
    handleAddCriteria,
    handleDeleteCriteria,
    handleAddAllActivity,
    handleSuggestCriteria,
    handleEditActivityClick,
    handleEditSubmit,
    handleSuggestCriteriaForEdit,
    handleDeleteActivity,
    handleDeletePlannedActivity,
    handleDeleteConfirm,
    getStatusLabel,
    getStatusColor,
    criteriaColumns,
    allActivityColumns,
    styles,
    MONTHS_FR,
    WEEKDAYS_FR,
    MONTH_ICONS,
    getWeeksOfMonth,
    getTimelineWindow,
    getPlanningMonths,
    formatMinutesToHourLabel,
    parseTimeToMinutes,
  } = props;
  return (
    <>
      <Dialog
        open={isDeleteDialogOpen}
        onClose={() => setIsDeleteDialogOpen(false)}
        PaperProps={{
          sx: {
            backgroundColor: colors.primary[400],
            color: colors.grey[100],
            borderRadius: "12px",
          },
        }}
      >
        <DialogTitle
          sx={{
            fontWeight: "bold",
            borderBottom: `1px solid ${colors.primary[500]}`,
          }}
        >
          Confirmer la suppression
        </DialogTitle>
        <DialogContent sx={{ mt: 2 }}>
          <Typography color={colors.grey[200]}>
            Supprimer "{deletingItem?.name || deletingItem?.title}" ?
          </Typography>
        </DialogContent>
        <DialogActions
          sx={{ p: 2, borderTop: `1px solid ${colors.primary[500]}` }}
        >
          <Button
            onClick={() => setIsDeleteDialogOpen(false)}
            sx={{ color: colors.grey[100] }}
          >
            Annuler
          </Button>
          <Button
            onClick={handleDeleteConfirm}
            variant="contained"
            sx={{ backgroundColor: colors.redAccent[500], color: "#fff" }}
          >
            Supprimer
          </Button>
        </DialogActions>
      </Dialog>
    </>
  );
};

const EditActivityDialogComponent = (props) => {
  const {
    theme,
    colors,
    searchParams,
    setSearchParams,
    tabParam,
    activeTab,
    setActiveTab,
    plannings,
    setPlannings,
    selectedPlanningId,
    setSelectedPlanningId,
    activitiesList,
    setActivitiesList,
    allActivities,
    setAllActivities,
    criteriaList,
    setCriteriaList,
    allClassesData,
    setAllClassesData,
    classOptions,
    setClassOptions,
    expandedMonth,
    setExpandedMonth,
    weekModalInfo,
    setWeekModalInfo,
    selectedClassForWeekId,
    setSelectedClassForWeekId,
    dayTimelineInfo,
    setDayTimelineInfo,
    planModalOpen,
    setPlanModalOpen,
    addActivityForm,
    setAddActivityForm,
    addActivityError,
    setAddActivityError,
    addActivitySaving,
    setAddActivitySaving,
    newCriteriaName,
    setNewCriteriaName,
    addCriteriaSaving,
    setAddCriteriaSaving,
    addAllActivityForm,
    setAddAllActivityForm,
    addAllActivityError,
    setAddAllActivityError,
    addAllActivitySaving,
    setAddAllActivitySaving,
    suggestingCriteria,
    setSuggestingCriteria,
    maxSuggestedCriteria,
    setMaxSuggestedCriteria,
    aiEnabled,
    setAiEnabled,
    isEditDialogOpen,
    setIsEditDialogOpen,
    editingActivity,
    setEditingActivity,
    editForm,
    setEditForm,
    editFormError,
    setEditFormError,
    isDeleteDialogOpen,
    setIsDeleteDialogOpen,
    deletingItem,
    setDeletingItem,
    deleteType,
    setDeleteType,
    fetchPlanned,
    criteriaNameMap,
    selectedPlanning,
    isArchived,
    activityMap,
    monthActivityCounts,
    today,
    planningStartYear,
    planningEndYear,
    visibleYear,
    setVisibleYear,
    planningMonthKeys,
    dayTimelineActivities,
    timelineWindow,
    handleAddActivity,
    openAddForDate,
    handleAddCriteria,
    handleDeleteCriteria,
    handleAddAllActivity,
    handleSuggestCriteria,
    handleEditActivityClick,
    handleEditSubmit,
    handleSuggestCriteriaForEdit,
    handleDeleteActivity,
    handleDeletePlannedActivity,
    handleDeleteConfirm,
    getStatusLabel,
    getStatusColor,
    criteriaColumns,
    allActivityColumns,
    styles,
    MONTHS_FR,
    WEEKDAYS_FR,
    MONTH_ICONS,
    getWeeksOfMonth,
    getTimelineWindow,
    getPlanningMonths,
    formatMinutesToHourLabel,
    parseTimeToMinutes,
  } = props;
  return (
    <>
      <Dialog
        open={isEditDialogOpen}
        onClose={() => setIsEditDialogOpen(false)}
        fullWidth
        maxWidth="sm"
        PaperProps={{ sx: styles.dialogPaper }}
      >
        <DialogTitle
          sx={{ ...styles.dialogTitle, display: "flex", alignItems: "center", justifyContent: "space-between" }}
        >
          <Box>
            <Typography fontWeight="bold" fontSize="1.1rem">Éditer l'activité</Typography>
            <Typography variant="body2" color={colors.grey[300]} mt="4px">
              Modifiez l'activité avec le même langage visuel fluide que sur les classes.
            </Typography>
          </Box>
          <IconButton onClick={() => setIsEditDialogOpen(false)} sx={{ color: colors.grey[100] }}>
            <CloseIcon />
          </IconButton>
        </DialogTitle>
        <form onSubmit={handleEditSubmit}>
          <DialogContent
            sx={{
              mt: 2,
              display: "flex",
              flexDirection: "column",
              gap: "15px",
            }}
          >
            <Box sx={styles.formCard}>
              {editFormError && (
                <Typography color={colors.redAccent[500]} textAlign="center" mb="16px">
                  {editFormError}
                </Typography>
              )}
            <TextField
              variant="outlined"
              label="Titre"
              value={editForm.title}
              onChange={(e) =>
                setEditForm((f) => ({ ...f, title: e.target.value }))
              }
              fullWidth
              required
              InputLabelProps={{ shrink: true }}
              sx={styles.filledInputSx}
            />
            <TextField
              variant="outlined"
              label="Description"
              multiline
              rows={3}
              value={editForm.description}
              onChange={(e) =>
                setEditForm((f) => ({ ...f, description: e.target.value }))
              }
              fullWidth
              InputLabelProps={{ shrink: true }}
              sx={{ ...styles.filledInputSx, mt: 2 }}
            />
            <FormControl variant="outlined" fullWidth sx={{ ...styles.filledInputSx, mt: 2 }}>
              <InputLabel shrink>Critères</InputLabel>
              <Select
                multiple
                value={editForm.criteriaIds}
                onChange={(e) =>
                  setEditForm((f) => ({ ...f, criteriaIds: e.target.value }))
                }
                label="Critères"
                renderValue={(sel) => (
                  <Box display="flex" flexWrap="wrap" gap="4px">
                    {sel.map((id) => (
                      <Chip
                        key={id}
                        label={criteriaNameMap[id] || id}
                        size="small"
                        sx={{
                          backgroundColor: theme.palette.mode === "dark" ? "rgba(20, 184, 166, 0.14)" : "rgba(13, 148, 136, 0.10)",
                          color: colors.greenAccent[400],
                          border: `1px solid ${theme.palette.mode === "dark" ? "rgba(45, 212, 191, 0.16)" : "rgba(13, 148, 136, 0.16)"}`,
                          fontWeight: 700,
                        }}
                      />
                    ))}
                  </Box>
                )}
                MenuProps={{
                  PaperProps: {
                    sx: {
                      backgroundColor: colors.primary[400],
                      backgroundImage: "none",
                      borderRadius: "12px",
                      boxShadow: "0 8px 32px rgba(0,0,0,0.3)",
                      p: 1,
                    },
                  },
                }}
              >
                {criteriaList.map((c) => {
                  const isSelected = editForm.criteriaIds.includes(c.id);
                  return (
                    <MenuItem
                      key={c.id}
                      value={c.id}
                      sx={{
                        display: "flex",
                        alignItems: "center",
                        gap: "12px",
                        borderRadius: "8px",
                        my: "4px",
                        transition: "all 0.2s",
                        backgroundColor: isSelected
                          ? `${colors.greenAccent[500]}15`
                          : "transparent",
                        "&:hover": {
                          backgroundColor: isSelected
                            ? `${colors.greenAccent[500]}25`
                            : "rgba(255,255,255,0.08)",
                        },
                      }}
                    >
                      <Box
                        sx={{
                          width: "20px",
                          height: "20px",
                          borderRadius: "5px",
                          flexShrink: 0,
                          border: `2px solid ${isSelected ? colors.greenAccent[500] : colors.grey[500]}`,
                          backgroundColor: isSelected
                            ? colors.greenAccent[500]
                            : "transparent",
                          display: "flex",
                          alignItems: "center",
                          justifyContent: "center",
                          transition: "all 0.2s ease-in-out",
                        }}
                      >
                        {isSelected && (
                          <Typography
                            color="#fff"
                            fontSize="12px"
                            fontWeight="bold"
                          >
                            ✓
                          </Typography>
                        )}
                      </Box>
                      <Typography
                        color={
                          isSelected
                            ? colors.greenAccent[400]
                            : colors.grey[100]
                        }
                        fontWeight={isSelected ? "bold" : "normal"}
                      >
                        {c.name}
                      </Typography>
                    </MenuItem>
                  );
                })}
              </Select>
            </FormControl>

            {/* AI Criteria Suggestion for Edit */}
            <Box sx={{ ...styles.helperPanel, mt: 2 }}>
              <Typography sx={styles.helperLabel}>
                Max critères :
              </Typography>
              <TextField
                variant="outlined"
                type="number"
                size="small"
                value={maxSuggestedCriteria}
                onChange={(e) => {
                  const v = parseInt(e.target.value);
                  if (!v || v < 1) setMaxSuggestedCriteria(1);
                  else
                    setMaxSuggestedCriteria(
                      Math.min(v, criteriaList.length || 5),
                    );
                }}
                sx={{ width: 78, ...styles.filledInputSx }}
                inputProps={{ min: 1, max: criteriaList.length || 5 }}
              />
              <Button
                variant="contained"
                onClick={handleSuggestCriteriaForEdit}
                disabled={suggestingCriteria || !aiEnabled}
                sx={styles.secondaryButton}
              >
                {suggestingCriteria ? (
                  <>
                    <CircularProgress size={16} sx={{ color: "#fff", mr: 1 }} />{" "}
                    Suggestion...
                  </>
                ) : !aiEnabled ? (
                    "IA désactivée"
                ) : (
                    "Suggérer des critères (AI)"
                )}
              </Button>
            </Box>
            </Box>
          </DialogContent>
          <DialogActions sx={styles.dialogActions}>
            <Button
              onClick={() => setIsEditDialogOpen(false)}
              sx={{ color: colors.grey[100] }}
            >
              Annuler
            </Button>
            <Button
              type="submit"
              variant="contained"
              sx={styles.primaryButton}
            >
              Enregistrer
            </Button>
          </DialogActions>
        </form>
      </Dialog>
    </>
  );
};

export default Activities;
