import {
  Alert,
  Box,
  Button,
  CircularProgress,
  Menu,
  MenuItem,
  Portal,
  Snackbar,
} from "@mui/material";
import { useTheme } from "@mui/material";
import AddCircleOutlineOutlinedIcon from "@mui/icons-material/AddCircleOutlineOutlined";
import CheckCircleOutlineOutlinedIcon from "@mui/icons-material/CheckCircleOutlineOutlined";
import DeleteOutlineIcon from "@mui/icons-material/DeleteOutline";
import EditOutlinedIcon from "@mui/icons-material/EditOutlined";
import Header from "../../../components/Header";
import { tokens } from "../../../theme";

import { useEventsController } from "../hooks/useEventsController";
import StatsCards from "./StatsCards";
import EventDataGrid from "./EventDataGrid";
import EventFormDialog from "./EventFormDialog";
import EventDeleteDialog from "./EventDeleteDialog";
import { getStyles } from "../utils/styles";

const Events = () => {
  const theme = useTheme();
  const colors = tokens(theme.palette.mode);
  const isDark = theme.palette.mode === "dark";

  const {
    loading,
    events,
    classes,
    teachers,
    children,
    dialogOpen,
    setDialogOpen,
    editingEvent,
    form,
    setForm,
    formError,
    saving,
    conflictInfo,
    selectedClasses,
    setSelectedClasses,
    selectedTeachers,
    setSelectedTeachers,
    selectedChildren,
    setSelectedChildren,
    notifTargetMode,
    setNotifTargetMode,
    deleteDialogOpen,
    setDeleteDialogOpen,
    deletingEvent,
    actionMenuPosition,
    actionMenuEvent,
    toast,
    stats,
    handleCreate,
    handleEdit,
    handleSubmitEvent,
    handleDelete,
    handleDeleteConfirm,
    handleToggleStatus,
    openActionMenu,
    closeActionMenu,
    closeToast
  } = useEventsController();

  if (loading) {
    return (
      <Box m="20px" display="flex" justifyContent="center" alignItems="center" height="60vh">
        <CircularProgress sx={{ color: colors.greenAccent[500] }} />
      </Box>
    );
  }

  return (
    <Box m="20px">
      <Box display="flex" justifyContent="space-between" alignItems="center" mb="20px">
        <Header title="ÉVÉNEMENTS" subtitle="Gérer les événements scolaires" />
        <Button variant="contained" startIcon={<AddCircleOutlineOutlinedIcon />} onClick={handleCreate} sx={{ backgroundColor: isDark ? "#475569" : "#334155", color: "#fff", fontWeight: 700, textTransform: "none", px: "20px", py: "10px", borderRadius: "999px", "&:hover": { backgroundColor: isDark ? "#64748b" : "#475569" } }}>
          Créer un événement
        </Button>
      </Box>

      <StatsCards stats={stats} colors={colors} isDark={isDark} />

      <EventDataGrid events={events} colors={colors} isDark={isDark} openActionMenu={openActionMenu} />

      <EventFormDialog
        open={dialogOpen}
        onClose={() => setDialogOpen(false)}
        editingEvent={editingEvent}
        form={form}
        setForm={setForm}
        onSubmit={handleSubmitEvent}
        formError={formError}
        conflictInfo={conflictInfo}
        saving={saving}
        colors={colors}
        isDark={isDark}
        classes={classes}
        teachers={teachers}
        children={children}
        selectedClasses={selectedClasses}
        setSelectedClasses={setSelectedClasses}
        selectedTeachers={selectedTeachers}
        setSelectedTeachers={setSelectedTeachers}
        selectedChildren={selectedChildren}
        setSelectedChildren={setSelectedChildren}
        notifTargetMode={notifTargetMode}
        setNotifTargetMode={setNotifTargetMode}
      />

      <EventDeleteDialog
        open={deleteDialogOpen}
        onClose={() => setDeleteDialogOpen(false)}
        deletingEvent={deletingEvent}
        onConfirm={handleDeleteConfirm}
        colors={colors}
        isDark={isDark}
      />

      <Menu
        open={Boolean(actionMenuPosition && actionMenuEvent)}
        onClose={closeActionMenu}
        anchorReference="none"
        transitionDuration={0}
        MenuListProps={{ autoFocusItem: false }}
        PaperProps={{
          sx: {
            ...getStyles(colors, isDark).menuPaper,
            width: 220,
            position: "fixed",
            top: actionMenuPosition?.top ?? 0,
            left: actionMenuPosition?.left ?? 0,
          },
        }}
      >
        <MenuItem onClick={() => handleEdit(actionMenuEvent)}>
          <Box display="flex" alignItems="center" gap="10px"><EditOutlinedIcon fontSize="small" /><span>Modifier</span></Box>
        </MenuItem>
        <MenuItem onClick={() => handleToggleStatus(actionMenuEvent)}>
          <Box display="flex" alignItems="center" gap="10px"><CheckCircleOutlineOutlinedIcon fontSize="small" /><span>{actionMenuEvent?.status === "executed" ? "Remettre en attente" : "Marquer exécuté"}</span></Box>
        </MenuItem>
        <MenuItem onClick={() => handleDelete(actionMenuEvent)} sx={{ color: colors.redAccent[400] }}>
          <Box display="flex" alignItems="center" gap="10px"><DeleteOutlineIcon fontSize="small" /><span>Supprimer</span></Box>
        </MenuItem>
      </Menu>

      <Portal>
        <Snackbar open={toast.open} autoHideDuration={5000} onClose={closeToast} anchorOrigin={{ vertical: "top", horizontal: "right" }} sx={{ zIndex: 2001 }}>
          <Alert onClose={closeToast} severity={toast.severity} variant="outlined" sx={{ width: "100%", maxWidth: "420px", alignItems: "center", borderRadius: "14px", boxShadow: "0 12px 28px rgba(15,23,42,0.12)", backgroundColor: isDark ? "rgba(17,24,39,0.96)" : "rgba(255,250,242,0.98)", color: isDark ? colors.grey[100] : "#3f2a12", borderColor: toast.severity === "error" ? "rgba(239,68,68,0.35)" : "rgba(245,158,11,0.35)" }}>
            {toast.message}
          </Alert>
        </Snackbar>
      </Portal>
    </Box>
  );
};

export default Events;
