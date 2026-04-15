import React, { useMemo } from "react";
import {
  Box,
  Typography,
  Tab,
  Tabs,
  MenuItem,
  Select,
  FormControl,
  CircularProgress,
  IconButton,
  Tooltip,
  Snackbar,
  Alert,
  Portal,
} from "@mui/material";
import { useTheme } from "@mui/material/styles";
import ExtensionIcon from "@mui/icons-material/Extension";
import EditOutlinedIcon from "@mui/icons-material/EditOutlined";
import DeleteOutlineIcon from "@mui/icons-material/DeleteOutline";

import { useActivitiesController } from "../hooks/useActivitiesController";
import { getStyles } from "./ActivitiesStyles";
import { TAB_KEYS } from "../utils/constants";
import { getStatusLabel, getStatusColor } from "../utils/activitiesUtils";
import { tokens } from "../../../theme";
import Header from "../../../components/Header";

// Dialogs
import { WeekDialogComponent } from "./WeekDialogComponent";
import { DayTimelineDialogComponent } from "./DayTimelineDialogComponent";
import { PlanActivityDialogComponent } from "./PlanActivityDialogComponent";
import { AddCriteriaDialogComponent } from "./AddCriteriaDialogComponent";
import { AddAllActivityDialogComponent } from "./AddAllActivityDialogComponent";
import { EditActivityDialogComponent } from "./EditActivityDialogComponent";
import { DeleteDialogComponent } from "./DeleteDialogComponent";

// Tabs
import { PlannedActivitiesTab } from "./PlannedActivitiesTab";
import { CriteriaTab } from "./CriteriaTab";
import { AllActivitiesTab } from "./AllActivitiesTab";

const Activities = () => {
  const theme = useTheme();
  const colors = tokens(theme.palette.mode);
  const isDark = theme.palette.mode === "dark";
  const styles = getStyles(colors, isDark);

  const controller = useActivitiesController();

  const {
    loading,
    toast,
    closeToast,
    setSearchParams,
    activeTab,
    setActiveTab,
    plannings,
    selectedPlanningId,
    setSelectedPlanningId,
    isArchived,
    handleEditActivityClick,
    handleDeletePlannedActivity,
    handleDeleteCriteria,
    handleDeleteActivity,
  } = controller;

  const plannedCols = useMemo(
    () => [
      { field: "title", headerName: "Titre", flex: 1.5,
        renderCell: (params) => (
          <Box display="flex" alignItems="center" gap="10px">
            <ExtensionIcon sx={{ color: colors.blueAccent[400], fontSize: "1.1rem" }} />
            <Typography fontWeight="bold" color={colors.grey[100]}>{params.value}</Typography>
          </Box>
        ),
      },
      { field: "date", headerName: "Date", flex: 0.8 },
      { field: "startTime", headerName: "Début", flex: 0.6 },
      { field: "endTime", headerName: "Fin", flex: 0.6 },
      { field: "className", headerName: "Classes Concerneés", flex: 1.2 },
      { field: "teacherName", headerName: "Créé par", flex: 1 },
      { field: "status", headerName: "État", flex: 0.8,
        renderCell: (params) => (
          <Typography
            sx={{
              display: "inline-block", px: "8px", py: "4px", borderRadius: "6px", fontSize: "0.75rem", fontWeight: "bold",
              backgroundColor: `${getStatusColor(params.value, colors)}22`, color: getStatusColor(params.value, colors), border: `1px solid ${getStatusColor(params.value, colors)}`,
            }}
          >
            {getStatusLabel(params.value)}
          </Typography>
        ),
      },
      { field: "actions", headerName: "Actions", flex: 0.5, sortable: false, disableColumnMenu: true,
        renderCell: (params) => {
          if (isArchived) return null;
          return (
            <Box display="flex" gap="8px">
              <Tooltip title="Supprimer">
                <IconButton onClick={(e) => { e.stopPropagation(); handleDeletePlannedActivity(params.row.id); }} sx={styles.dangerIconButton}>
                  <DeleteOutlineIcon sx={{ fontSize: "16px" }} />
                </IconButton>
              </Tooltip>
            </Box>
          );
        },
      },
    ],
    [colors, isArchived, handleDeletePlannedActivity, styles.dangerIconButton],
  );

  const criteriaCols = useMemo(
    () => [
      { field: "id", headerName: "ID", flex: 0.5 },
      { field: "name", headerName: "Nom", flex: 2,
        renderCell: (params) => <Typography fontWeight="bold" color={colors.grey[100]}>{params.value}</Typography>,
      },
      { field: "actions", headerName: "Actions", flex: 0.5, sortable: false, disableColumnMenu: true,
        renderCell: (params) => (
          <Box display="flex" gap="8px">
            <Tooltip title="Supprimer">
              <IconButton onClick={(e) => { e.stopPropagation(); handleDeleteCriteria(params.row); }} sx={styles.dangerIconButton}>
                <DeleteOutlineIcon sx={{ fontSize: "16px" }} />
              </IconButton>
            </Tooltip>
          </Box>
        ),
      },
    ],
    [colors, styles.dangerIconButton, handleDeleteCriteria],
  );

  const allActivCols = useMemo(
    () => [
      { field: "title", headerName: "Titre", flex: 1.5,
        renderCell: (params) => (
          <Box display="flex" alignItems="center" gap="10px">
            <Typography fontWeight="bold" color={colors.grey[100]}>{params.value}</Typography>
          </Box>
        ),
      },
      { field: "description", headerName: "Description", flex: 2 },
      { field: "criteriaNames", headerName: "Critères", flex: 1.5,
        renderCell: (params) => (
          <Typography variant="body2" color={colors.greenAccent[400]}>{params.value}</Typography>
        ),
      },
      { field: "actions", headerName: "Actions", flex: 1, sortable: false, disableColumnMenu: true,
        renderCell: (params) => (
          <Box display="flex" gap="8px">
            <Tooltip title="Modifier">
              <IconButton onClick={(e) => { e.stopPropagation(); handleEditActivityClick(params.row); }} sx={styles.subtleIconButton}>
                <EditOutlinedIcon sx={{ fontSize: "16px" }} />
              </IconButton>
            </Tooltip>
            <Tooltip title="Supprimer">
              <IconButton onClick={(e) => { e.stopPropagation(); handleDeleteActivity(params.row); }} sx={styles.dangerIconButton}>
                <DeleteOutlineIcon sx={{ fontSize: "16px" }} />
              </IconButton>
            </Tooltip>
          </Box>
        ),
      },
    ],
    [colors, styles.subtleIconButton, styles.dangerIconButton, handleEditActivityClick, handleDeleteActivity],
  );

  const handleTabChange = (event, newValue) => {
    setActiveTab(newValue);
    setSearchParams({ tab: TAB_KEYS[newValue] });
  };

  if (loading) {
    return (
      <Box display="flex" flexDirection="column" alignItems="center" justifyContent="center" height="70vh" gap="20px">
        <CircularProgress size={50} sx={{ color: colors.greenAccent[500] }} />
        <Typography color={colors.grey[300]} fontWeight="bold">Chargement des données...</Typography>
      </Box>
    );
  }

  return (
    <Box m="20px">
      <Header title="ACTIVITÉS" />

      {/* AI Disabled Banner */}
      {!controller.aiEnabled && (
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

      <Portal>
        <Snackbar open={toast.open} autoHideDuration={6000} onClose={closeToast} anchorOrigin={{ vertical: "top", horizontal: "right" }} sx={{ zIndex: 3000 }}>
          <Alert onClose={closeToast} severity={toast.severity} sx={{ width: "100%", borderRadius: "12px", fontSize: "1rem" }}>
            {toast.message}
          </Alert>
        </Snackbar>
      </Portal>

      <Box sx={{ ...styles.toolbarShell, width: { xs: "100%", md: "fit-content" } }}>
        <Box sx={styles.toolbarGroup}>
          <Typography sx={styles.toolbarLabel}>Année scolaire</Typography>
          <FormControl variant="outlined" size="small" sx={styles.selectControl}>
            <Select
              value={selectedPlanningId ? String(selectedPlanningId) : ""}
              displayEmpty
              onChange={(e) => setSelectedPlanningId(e.target.value)}
              sx={{ color: colors.grey[100], fontWeight: "bold" }}
            >
              {plannings.length === 0 && <MenuItem value="">Aucun planning</MenuItem>}
              {plannings.map((p) => {
                const label = p.label || `${p.startDate || p.start_date} — ${p.endDate || p.end_date}`;
                return (
                  <MenuItem key={p.id} value={String(p.id)}>
                    {p.is_archived ? `${label} (Archivé)` : label}
                  </MenuItem>
                );
              })}
            </Select>
          </FormControl>
        </Box>
      </Box>

      <Box sx={styles.tabsWrap}>
        <Tabs value={activeTab} onChange={(_, v) => handleTabChange(null, v)} sx={styles.tabsSx} variant="scrollable" allowScrollButtonsMobile>
          <Tab disableRipple label="Activités Planifiées" />
          <Tab disableRipple label="Critères d'évaluation" />
          <Tab disableRipple label="Toutes les activités" />
        </Tabs>
      </Box>



      {activeTab === 0 && (
        <PlannedActivitiesTab
          colors={colors}
          isDark={isDark}
          styles={styles}
          plannedCols={plannedCols}
          {...controller}
        />
      )}
      {activeTab === 1 && (
        <CriteriaTab
          colors={colors}
          isDark={isDark}
          styles={styles}
          criteriaCols={criteriaCols}
          {...controller}
        />
      )}
      {activeTab === 2 && (
        <AllActivitiesTab
          colors={colors}
          isDark={isDark}
          styles={styles}
          allActivCols={allActivCols}
          {...controller}
        />
      )}

      {/* Dialogs */}
      <WeekDialogComponent colors={colors} styles={styles} {...controller} />
      <DayTimelineDialogComponent colors={colors} styles={styles} {...controller} />
      <PlanActivityDialogComponent theme={theme} colors={colors} styles={styles} {...controller} />
      <AddCriteriaDialogComponent theme={theme} colors={colors} styles={styles} {...controller} />
      <AddAllActivityDialogComponent theme={theme} colors={colors} styles={styles} {...controller} />
      <EditActivityDialogComponent theme={theme} colors={colors} styles={styles} {...controller} />
      <DeleteDialogComponent colors={colors} styles={styles} {...controller} />

    </Box>
  );
};

export default Activities;
