import {
  Alert,
  Autocomplete,
  Box,
  Button,
  Checkbox,
  Chip,
  CircularProgress,
  Dialog,
  DialogActions,
  DialogContent,
  DialogTitle,
  FormControlLabel,
  IconButton,
  Menu,
  MenuItem,
  Portal,
  Radio,
  RadioGroup,
  Snackbar,
  TextField,
  Tooltip,
  Typography,
} from "@mui/material";
import {
  DataGrid,
  GridToolbarContainer,
  GridToolbarFilterButton,
} from "@mui/x-data-grid";
import { useTheme } from "@mui/material";
import { useCallback, useEffect, useMemo, useState } from "react";
import AddCircleOutlineOutlinedIcon from "@mui/icons-material/AddCircleOutlineOutlined";
import CalendarMonthOutlinedIcon from "@mui/icons-material/CalendarMonthOutlined";
import CampaignOutlinedIcon from "@mui/icons-material/CampaignOutlined";
import CheckCircleOutlineOutlinedIcon from "@mui/icons-material/CheckCircleOutlineOutlined";
import DeleteOutlineIcon from "@mui/icons-material/DeleteOutline";
import EditOutlinedIcon from "@mui/icons-material/EditOutlined";
import EventAvailableOutlinedIcon from "@mui/icons-material/EventAvailableOutlined";
import MoreVertOutlinedIcon from "@mui/icons-material/MoreVertOutlined";
import PendingActionsOutlinedIcon from "@mui/icons-material/PendingActionsOutlined";
import ScheduleOutlinedIcon from "@mui/icons-material/ScheduleOutlined";
import api from "../../api/axios";
import Header from "../../components/Header";
import { tokens } from "../../theme";

const formatDate = (value) => {
  if (!value) return "-";
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return value;
  return date.toLocaleDateString("fr-FR");
};

const formatShortTime = (value) => (value || "").slice(0, 5) || "--:--";

const toEventDateTime = (date, time) => new Date(`${String(date).slice(0, 10)}T${String(time).slice(0, 5)}:00`);

const minutesDiff = (a, b) => Math.round((a.getTime() - b.getTime()) / 60000);

const formatRelativeTime = (minutes) => {
  if (minutes <= 0) return "maintenant";
  const hours = Math.floor(minutes / 60);
  const remaining = minutes % 60;
  if (hours <= 0) return `dans ${remaining} min`;
  if (remaining === 0) return `dans ${hours} h`;
  return `dans ${hours} h ${remaining} min`;
};

const getTimeProgressMeta = (event, now = new Date()) => {
  if (!event?.date || !event?.start_time || !event?.end_time) return null;

  const eventDate = String(event.date).slice(0, 10);
  const today = now.toISOString().slice(0, 10);
  if (eventDate !== today) return null;

  const start = toEventDateTime(event.date, event.start_time);
  const end = toEventDateTime(event.date, event.end_time);
  const total = Math.max(1, minutesDiff(end, start));

  if (now >= end) {
    return {
      label: "Terminé aujourd'hui",
      percent: 100,
      barColor: "rgba(148,163,184,0.65)",
      trackColor: "rgba(148,163,184,0.22)",
      isMuted: true,
      tooltip: "Événement terminé",
    };
  }

  if (now <= start) {
    return {
      label: `Commence ${formatRelativeTime(minutesDiff(start, now))}`,
      percent: 0,
      barColor: "rgba(148,163,184,0.65)",
      trackColor: "rgba(148,163,184,0.22)",
      isMuted: false,
      tooltip: `Débute ${formatRelativeTime(minutesDiff(start, now))}`,
    };
  }

  const elapsed = minutesDiff(now, start);
  return {
    label: `${Math.max(0, minutesDiff(end, now))} min restantes`,
    percent: Math.min(100, Math.max(0, Math.round((elapsed / total) * 100))),
    barColor: "#64748b",
    trackColor: "rgba(148,163,184,0.22)",
    isMuted: false,
    tooltip: "Événement en cours",
  };
};

const getStatusMeta = (status, colors, isDark) => {
  if (status === "executed") {
    return {
      label: "Exécuté",
      backgroundColor: isDark ? "rgba(34,197,94,0.18)" : "rgba(22,163,74,0.12)",
      color: isDark ? colors.greenAccent[300] : "#166534",
      borderColor: isDark ? "rgba(34,197,94,0.22)" : "rgba(22,163,74,0.18)",
    };
  }

  return {
    label: "En attente",
    backgroundColor: isDark ? "rgba(245,158,11,0.16)" : "rgba(245,158,11,0.12)",
    color: isDark ? "#fbbf24" : "#92400e",
    borderColor: isDark ? "rgba(245,158,11,0.22)" : "rgba(245,158,11,0.18)",
  };
};

const getStyles = (colors, isDark) => ({
  statCard: {
    backgroundColor: colors.primary[400],
    display: "flex",
    alignItems: "center",
    gap: "14px",
    p: "16px 18px",
    borderRadius: "14px",
    border: `1px solid ${colors.primary[500]}`,
    boxShadow: "0px 10px 24px rgba(0, 0, 0, 0.08)",
  },
  statIcon: {
    width: 48,
    height: 48,
    borderRadius: "14px",
    display: "inline-flex",
    alignItems: "center",
    justifyContent: "center",
    flexShrink: 0,
  },
  dataGrid: {
    "& .MuiDataGrid-root": {
      border: `1px solid ${colors.primary[500]}`,
      borderRadius: "16px",
      overflow: "hidden",
      backgroundColor: colors.primary[400],
    },
    "& .MuiDataGrid-cell": {
      borderBottom: `1px solid ${colors.primary[500]}`,
      display: "flex",
      alignItems: "center",
    },
    "& .name-column--cell": { color: colors.greenAccent[300] },
    "& .MuiDataGrid-columnHeaders": {
      backgroundColor: isDark ? "#334155" : "#eef2f7",
      borderBottom: `1px solid ${colors.primary[500]}`,
      color: isDark ? colors.grey[100] : "#0f172a",
    },
    "& .MuiDataGrid-columnHeaderTitle": { fontWeight: 700 },
    "& .MuiDataGrid-virtualScroller": { backgroundColor: colors.primary[400] },
    "& .MuiDataGrid-footerContainer": {
      borderTop: `1px solid ${colors.primary[500]}`,
      backgroundColor: isDark ? "#334155" : "#eef2f7",
      color: isDark ? colors.grey[100] : "#0f172a",
    },
    "& .MuiDataGrid-toolbarContainer": {
      padding: "12px 14px",
      borderBottom: `1px solid ${colors.primary[500]}`,
      gap: "8px",
      backgroundColor: isDark ? "rgba(51,65,85,0.24)" : "rgba(238,242,247,0.88)",
    },
    "& .MuiDataGrid-toolbarContainer .MuiButton-text": {
      color: `${isDark ? colors.grey[100] : "#0f172a"} !important`,
    },
    "& .MuiDataGrid-row": {
      transition: "background 0.2s",
      "&:hover": { backgroundColor: `${colors.primary[500]} !important` },
    },
    "& .MuiDataGrid-cell:focus, & .MuiDataGrid-columnHeader:focus": { outline: "none" },
  },
  dialogPaper: {
    backgroundColor: colors.primary[400],
    color: colors.grey[100],
    borderRadius: "16px",
    boxShadow: "0px 0px 15px rgba(0,0,0,0.5)",
  },
  dialogTitle: {
    fontWeight: 700,
    borderBottom: `1px solid ${colors.primary[500]}`,
  },
  dialogActions: {
    p: "16px",
    borderTop: `1px solid ${colors.primary[500]}`,
  },
  formCard: {
    backgroundColor: isDark ? colors.primary[500] : "rgba(255,255,255,0.98)",
    border: `1px solid ${isDark ? colors.primary[600] : "rgba(148,163,184,0.22)"}`,
    borderRadius: "16px",
    padding: "18px",
    boxShadow: isDark ? "0 12px 28px rgba(0,0,0,0.12)" : "0 14px 32px rgba(15,23,42,0.08)",
  },
  floatingField: {
    "& .MuiOutlinedInput-root": {
      borderRadius: "12px",
      backgroundColor: isDark ? colors.primary[400] : "#f8fafc",
    },
    "& .MuiInputLabel-root": {
      color: colors.grey[300],
      fontWeight: 600,
    },
    "& .MuiInputLabel-root.Mui-focused": {
      color: isDark ? "#94a3b8" : "#475569",
    },
    "& .MuiOutlinedInput-notchedOutline": { borderColor: colors.primary[600] },
    "& .MuiOutlinedInput-root:hover .MuiOutlinedInput-notchedOutline": { borderColor: colors.grey[400] },
    "& .MuiOutlinedInput-root.Mui-focused .MuiOutlinedInput-notchedOutline": {
      borderColor: isDark ? "#94a3b8" : "#475569",
      borderWidth: "1px",
    },
  },
  conflictBox: {
    p: "12px",
    borderRadius: "12px",
    backgroundColor: "rgba(239,68,68,0.1)",
    border: "1px solid rgba(239,68,68,0.3)",
  },
  errorBox: {
    color: colors.redAccent[500],
    p: "10px 12px",
    borderRadius: "12px",
    backgroundColor: "rgba(239,68,68,0.1)",
  },
  submitBtn: {
    backgroundColor: isDark ? "#475569" : "#334155",
    color: "#fff",
    fontWeight: 700,
    textTransform: "none",
    "&:hover": { backgroundColor: isDark ? "#64748b" : "#475569" },
  },
  deleteBtn: {
    backgroundColor: colors.redAccent[600],
    color: "#fff",
    fontWeight: 700,
    textTransform: "none",
    "&:hover": { backgroundColor: colors.redAccent[700] },
  },
  menuPaper: {
    backgroundColor: colors.primary[400],
    color: colors.grey[100],
    borderRadius: "14px",
    border: `1px solid ${colors.primary[500]}`,
    boxShadow: "0 16px 32px rgba(15,23,42,0.18)",
  },
});

const EventsGridToolbar = ({ colors, isDark }) => (
  <GridToolbarContainer sx={{ display: "flex", justifyContent: "flex-start", p: "10px 14px" }}>
    <GridToolbarFilterButton
      sx={{
        borderRadius: "999px",
        px: "12px",
        py: "4px",
        textTransform: "none",
        fontWeight: 700,
        color: isDark ? colors.grey[100] : "#0f172a",
        border: `1px solid ${isDark ? "rgba(148,163,184,0.24)" : "rgba(148,163,184,0.28)"}`,
        backgroundColor: isDark ? "rgba(51,65,85,0.24)" : "rgba(255,255,255,0.72)",
      }}
    />
  </GridToolbarContainer>
);

const StatsCards = ({ stats, colors, isDark }) => {
  const styles = getStyles(colors, isDark);
  const cards = [
    {
      label: "Total événements",
      value: stats.total,
      desc: "Toutes périodes confondues",
      color: isDark ? colors.blueAccent[300] : "#1d4ed8",
      bg: isDark ? "rgba(96,165,250,0.14)" : "rgba(37,99,235,0.12)",
      icon: <CalendarMonthOutlinedIcon />,
    },
    {
      label: "Aujourd'hui",
      value: stats.today,
      desc: "Événements de la journée",
      color: isDark ? colors.grey[200] : "#475569",
      bg: isDark ? "rgba(148,163,184,0.14)" : "rgba(148,163,184,0.14)",
      icon: <ScheduleOutlinedIcon />,
    },
    {
      label: "Exécutés",
      value: stats.executed,
      desc: "Terminés ou validés",
      color: isDark ? colors.greenAccent[300] : "#166534",
      bg: isDark ? "rgba(134,239,172,0.14)" : "rgba(22,163,74,0.12)",
      icon: <EventAvailableOutlinedIcon />,
    },
    {
      label: "En attente",
      value: stats.pending,
      desc: "À réaliser",
      color: isDark ? "#fbbf24" : "#92400e",
      bg: isDark ? "rgba(245,158,11,0.14)" : "rgba(245,158,11,0.12)",
      icon: <PendingActionsOutlinedIcon />,
    },
    {
      label: "Notifiés",
      value: stats.notified,
      desc: "Notifications envoyées",
      color: isDark ? colors.greenAccent[300] : "#166534",
      bg: isDark ? "rgba(134,239,172,0.14)" : "rgba(22,163,74,0.12)",
      icon: <CampaignOutlinedIcon />,
    },
  ];

  return (
    <Box display="grid" gridTemplateColumns={{ xs: "1fr", sm: "repeat(2, 1fr)", xl: "repeat(5, 1fr)" }} gap="14px" mb="20px">
      {cards.map((card) => (
        <Box key={card.label} sx={styles.statCard}>
          <Box sx={{ ...styles.statIcon, backgroundColor: card.bg, color: card.color }}>
            {card.icon}
          </Box>
          <Box minWidth={0}>
            <Typography variant="body2" color={colors.grey[300]}>{card.label}</Typography>
            <Typography variant="h4" fontWeight="bold" color={colors.grey[100]} mt="4px">{card.value}</Typography>
            <Typography variant="caption" color={colors.grey[400]}>{card.desc}</Typography>
          </Box>
        </Box>
      ))}
    </Box>
  );
};

const EventDataGrid = ({ events, columns, colors, isDark }) => {
  const styles = getStyles(colors, isDark);
  return (
    <Box height="65vh" sx={styles.dataGrid}>
      <DataGrid
        rows={events}
        columns={columns}
        components={{ Toolbar: EventsGridToolbar }}
        componentsProps={{ toolbar: { colors, isDark } }}
        pageSize={10}
        rowsPerPageOptions={[10, 50, 100]}
        disableSelectionOnClick
        getRowHeight={() => "auto"}
      />
    </Box>
  );
};

const EventFormDialog = ({
  open,
  onClose,
  editingEvent,
  form,
  setForm,
  onSubmit,
  formError,
  conflictInfo,
  saving,
  colors,
  isDark,
  classes,
  teachers,
  children,
  selectedClasses,
  setSelectedClasses,
  selectedTeachers,
  setSelectedTeachers,
  selectedChildren,
  setSelectedChildren,
  notifTargetMode,
  setNotifTargetMode,
}) => {
  const styles = getStyles(colors, isDark);
  const isNotifEnabled = !!form.send_notifications;

  return (
    <Dialog open={open} onClose={saving ? undefined : onClose} fullWidth maxWidth="lg" PaperProps={{ sx: styles.dialogPaper }}>
      <DialogTitle sx={styles.dialogTitle}>{editingEvent ? "Modifier l'événement" : "Créer un événement"}</DialogTitle>
      <DialogContent sx={{ mt: 2 }}>
        <form id="event-form" onSubmit={onSubmit}>
          <Box display="grid" gridTemplateColumns={{ xs: "1fr", xl: "1.05fr 0.95fr" }} gap="18px">
            <Box sx={styles.formCard}>
              <Typography variant="h6" fontWeight="700" mb="6px">Détails de l'événement</Typography>
              <Typography variant="body2" color={colors.grey[300]} mb="16px">
                Définissez le titre, le contenu et les horaires de l'événement dans une seule fiche.
              </Typography>
              <Box display="flex" flexDirection="column" gap="16px">
                <TextField
                  variant="outlined"
                  label="Nom de l'événement"
                  value={form.name}
                  onChange={(e) => setForm((prev) => ({ ...prev, name: e.target.value }))}
                  InputLabelProps={{ shrink: true }}
                  sx={styles.floatingField}
                  fullWidth
                  required
                />
                <TextField
                  variant="outlined"
                  label="Description"
                  multiline
                  minRows={4}
                  value={form.description}
                  onChange={(e) => setForm((prev) => ({ ...prev, description: e.target.value }))}
                  InputLabelProps={{ shrink: true }}
                  sx={styles.floatingField}
                  fullWidth
                  required
                />
                <Box display="grid" gridTemplateColumns={{ xs: "1fr", md: "repeat(3, minmax(0, 1fr))" }} gap="16px">
                  <TextField
                    variant="outlined"
                    label="Date"
                    type="date"
                    value={form.date}
                    onChange={(e) => setForm((prev) => ({ ...prev, date: e.target.value }))}
                    InputLabelProps={{ shrink: true }}
                    sx={styles.floatingField}
                    inputProps={{ min: new Date().toISOString().split("T")[0] }}
                    fullWidth
                    required
                  />
                  <TextField
                    variant="outlined"
                    label="Heure de début"
                    type="time"
                    value={form.start_time}
                    onChange={(e) => setForm((prev) => ({ ...prev, start_time: e.target.value }))}
                    InputLabelProps={{ shrink: true }}
                    sx={styles.floatingField}
                    fullWidth
                    required
                  />
                  <TextField
                    variant="outlined"
                    label="Heure de fin"
                    type="time"
                    value={form.end_time}
                    onChange={(e) => setForm((prev) => ({ ...prev, end_time: e.target.value }))}
                    InputLabelProps={{ shrink: true }}
                    sx={styles.floatingField}
                    fullWidth
                    required
                  />
                </Box>

                {conflictInfo && (
                  <Box sx={styles.conflictBox}>
                    <Typography color={colors.redAccent[400]} fontWeight="700" mb="8px">Conflit détecté</Typography>
                    <Typography color={colors.redAccent[300]} whiteSpace="pre-line" fontSize="0.85rem">{conflictInfo}</Typography>
                    <Typography color={colors.grey[300]} mt="8px" fontSize="0.8rem">Veuillez changer la date ou l'horaire pour éviter ce conflit.</Typography>
                  </Box>
                )}

                {formError && <Typography sx={styles.errorBox}>{formError}</Typography>}
              </Box>
            </Box>

            <Box sx={styles.formCard}>
              <Typography variant="h6" fontWeight="700" mb="6px">Notification</Typography>
              <Typography variant="body2" color={colors.grey[300]} mb="16px">
                Gérez immédiatement les destinataires dans la même fenêtre, sans deuxième popup.
              </Typography>

              <FormControlLabel
                control={
                  <Checkbox
                    checked={isNotifEnabled}
                    onChange={(e) => setForm((prev) => ({ ...prev, send_notifications: e.target.checked }))}
                    sx={{ color: colors.greenAccent[400], "&.Mui-checked": { color: colors.greenAccent[500] } }}
                  />
                }
                label="Envoyer une notification après l'enregistrement"
                sx={{ color: colors.grey[100], mb: "12px" }}
              />

              {isNotifEnabled ? (
                <Box display="flex" flexDirection="column" gap="16px">
                  <Box p="14px" borderRadius="12px" backgroundColor={colors.primary[500]} border={`1px solid ${colors.primary[600]}`}>
                    <Typography variant="subtitle2" color={colors.grey[300]} fontWeight="700" mb="8px">
                      Cible des notifications (Parents)
                    </Typography>
                    <RadioGroup row value={notifTargetMode} onChange={(e) => setNotifTargetMode(e.target.value)}>
                      <FormControlLabel value="classes" control={<Radio sx={{ color: colors.greenAccent[500], "&.Mui-checked": { color: colors.greenAccent[500] } }} />} label="Par classes" />
                      <FormControlLabel value="children" control={<Radio sx={{ color: colors.blueAccent[500], "&.Mui-checked": { color: colors.blueAccent[500] } }} />} label="Par enfants" />
                    </RadioGroup>
                  </Box>

                  {notifTargetMode === "classes" ? (
                    <Autocomplete
                      multiple
                      disableCloseOnSelect
                      options={classes}
                      getOptionLabel={(option) => option.name || ""}
                      value={selectedClasses}
                      onChange={(_, value) => setSelectedClasses(value)}
                      isOptionEqualToValue={(option, value) => option.id === value.id}
                      slotProps={{ paper: { sx: styles.menuPaper } }}
                      renderOption={(props, option, { selected }) => {
                        const { key, ...rest } = props;
                        return (
                          <li key={key || option.id} {...rest}>
                            <Checkbox checked={selected} sx={{ color: colors.grey[300], "&.Mui-checked": { color: colors.greenAccent[500] }, p: 0.5, mr: 1 }} />
                            <Typography>{option.name}</Typography>
                          </li>
                        );
                      }}
                      renderInput={(params) => (
                        <TextField
                          {...params}
                          variant="outlined"
                          label="Classes destinataires"
                          InputLabelProps={{ shrink: true }}
                          sx={styles.floatingField}
                        />
                      )}
                      renderTags={(value, getTagProps) =>
                        value.map((option, index) => (
                          <Chip {...getTagProps({ index })} key={option.id} label={option.name} sx={{ backgroundColor: colors.greenAccent[600], color: "#fff", fontWeight: 700 }} />
                        ))
                      }
                    />
                  ) : (
                    <Autocomplete
                      multiple
                      disableCloseOnSelect
                      options={children}
                      getOptionLabel={(option) => option.id === "ALL" ? option.name : `${option.name} (Parent: ${option.parentName})`}
                      value={selectedChildren}
                      onChange={(_, value) => {
                        if (value.some((opt) => opt.id === "ALL")) {
                          // Expand the synthetic "ALL" option into every real child ID so the backend only receives valid ChildIDs.
                          setSelectedChildren(children.filter((child) => child.id !== "ALL"));
                        } else {
                          setSelectedChildren(value);
                        }
                      }}
                      isOptionEqualToValue={(option, value) => option.id === value.id}
                      slotProps={{ paper: { sx: styles.menuPaper } }}
                      renderOption={(props, option, { selected }) => {
                        const { key, ...rest } = props;
                        const isAll = option.id === "ALL";
                        return (
                          <li key={key || option.id} {...rest} style={{ backgroundColor: isAll ? "rgba(139, 92, 246, 0.15)" : "transparent" }}>
                            <Checkbox checked={selected || isAll} sx={{ color: colors.grey[300], "&.Mui-checked": { color: "#8b5cf6" }, p: 0.5, mr: 1 }} />
                            <Box>
                              <Typography fontWeight={isAll ? 700 : 400} color={isAll ? "#a78bfa" : "inherit"}>{option.name}</Typography>
                              {!isAll && <Typography fontSize="0.75rem" color={colors.grey[400]}>Parent: {option.parentName}</Typography>}
                            </Box>
                          </li>
                        );
                      }}
                      renderInput={(params) => (
                        <TextField
                          {...params}
                          variant="outlined"
                          label="Enfants"
                          InputLabelProps={{ shrink: true }}
                          sx={styles.floatingField}
                        />
                      )}
                      renderTags={(value, getTagProps) =>
                        value.map((option, index) => (
                          <Chip {...getTagProps({ index })} key={option.id} label={option.name} sx={{ backgroundColor: "#8b5cf6", color: "#fff", fontWeight: 700 }} />
                        ))
                      }
                    />
                  )}

                  <Autocomplete
                    multiple
                    disableCloseOnSelect
                    options={teachers}
                    getOptionLabel={(option) => `${option.name} (${option.email})`}
                    value={selectedTeachers}
                    onChange={(_, value) => setSelectedTeachers(value)}
                    isOptionEqualToValue={(option, value) => option.cin === value.cin}
                    slotProps={{ paper: { sx: styles.menuPaper } }}
                    renderOption={(props, option, { selected }) => {
                      const { key, ...rest } = props;
                      return (
                        <li key={key || option.cin} {...rest}>
                          <Checkbox checked={selected} sx={{ color: colors.grey[300], "&.Mui-checked": { color: colors.greenAccent[500] }, p: 0.5, mr: 1 }} />
                          <Typography>{option.name} <Typography component="span" fontSize="0.8rem" color={colors.grey[400]}>({option.email})</Typography></Typography>
                        </li>
                      );
                    }}
                    renderInput={(params) => (
                      <TextField
                        {...params}
                        variant="outlined"
                        label="Enseignants"
                        InputLabelProps={{ shrink: true }}
                        sx={styles.floatingField}
                      />
                    )}
                    renderTags={(value, getTagProps) =>
                      value.map((option, index) => (
                        <Chip {...getTagProps({ index })} key={option.cin} label={option.name} sx={{ backgroundColor: colors.greenAccent[600], color: "#fff", fontWeight: 700 }} />
                      ))
                    }
                  />

                  {((notifTargetMode === "classes" ? selectedClasses.length === 0 : selectedChildren.length === 0) && selectedTeachers.length === 0) && (
                    <Typography color={colors.grey[500]} fontSize="0.85rem" textAlign="center">
                      Sélectionnez au moins un destinataire, ou désactivez les notifications.
                    </Typography>
                  )}
                </Box>
              ) : (
                <Box p="16px" borderRadius="12px" backgroundColor={colors.primary[500]} border={`1px solid ${colors.primary[600]}`}>
                  <Typography color={colors.grey[300]} fontSize="0.9rem">
                    Les détails de l'événement seront enregistrés sans envoi de notification.
                  </Typography>
                </Box>
              )}
            </Box>
          </Box>
        </form>
      </DialogContent>
      <DialogActions sx={styles.dialogActions}>
        <Button onClick={onClose} sx={{ color: colors.grey[300] }} disabled={saving}>Annuler</Button>
        <Button type="submit" form="event-form" variant="contained" disabled={saving} sx={styles.submitBtn}>
          {saving ? <CircularProgress size={20} sx={{ color: "#fff" }} /> : (editingEvent ? "Mettre à jour" : "Créer")}
        </Button>
      </DialogActions>
    </Dialog>
  );
};

const EventDeleteDialog = ({ open, onClose, deletingEvent, onConfirm, colors, isDark }) => {
  const styles = getStyles(colors, isDark);
  return (
    <Dialog open={open} onClose={onClose} maxWidth="xs" PaperProps={{ sx: styles.dialogPaper }}>
      <DialogTitle sx={styles.dialogTitle}>Confirmer la suppression</DialogTitle>
      <DialogContent sx={{ mt: 2 }}>
        <Typography color={colors.grey[300]}>
          Êtes-vous sûr de vouloir supprimer l'événement <strong>"{deletingEvent?.name}"</strong> ?
        </Typography>
      </DialogContent>
      <DialogActions sx={styles.dialogActions}>
        <Button onClick={onClose} sx={{ color: colors.grey[300] }}>Annuler</Button>
        <Button variant="contained" onClick={onConfirm} sx={styles.deleteBtn}>Supprimer</Button>
      </DialogActions>
    </Dialog>
  );
};

const Events = () => {
  const theme = useTheme();
  const colors = tokens(theme.palette.mode);
  const isDark = theme.palette.mode === "dark";

  const [loading, setLoading] = useState(true);
  const [events, setEvents] = useState([]);
  const [classes, setClasses] = useState([]);
  const [teachers, setTeachers] = useState([]);
  const [children, setChildren] = useState([]);

  const [dialogOpen, setDialogOpen] = useState(false);
  const [editingEvent, setEditingEvent] = useState(null);
  const [form, setForm] = useState({
    name: "",
    description: "",
    date: "",
    start_time: "09:00",
    end_time: "11:00",
    send_notifications: false,
  });
  const [formError, setFormError] = useState("");
  const [saving, setSaving] = useState(false);
  const [conflictInfo, setConflictInfo] = useState(null);

  const [selectedClasses, setSelectedClasses] = useState([]);
  const [selectedTeachers, setSelectedTeachers] = useState([]);
  const [selectedChildren, setSelectedChildren] = useState([]);
  const [notifTargetMode, setNotifTargetMode] = useState("classes");

  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [deletingEvent, setDeletingEvent] = useState(null);

  const [actionMenuPosition, setActionMenuPosition] = useState(null);
  const [actionMenuEvent, setActionMenuEvent] = useState(null);
  const [toast, setToast] = useState({ open: false, message: "", severity: "info" });

  const fetchEvents = useCallback(async () => {
    try {
      const res = await api.get("/admin/events");
      setEvents((res.data?.data || []).map((event) => ({ ...event, id: event.id })));
    } catch (err) {
      console.error("Error fetching events:", err);
      setToast({ open: true, message: err?.response?.data?.message || "Erreur lors du chargement des événements.", severity: "error" });
    }
  }, []);

  const fetchReferenceData = useCallback(async () => {
    try {
      const [classesRes, teachersRes, parentsRes] = await Promise.all([
        api.get("/admin/classes").catch(() => ({ data: { data: [] } })),
        api.get("/admin/teachers").catch(() => ({ data: { data: [] } })),
        api.get("/admin/parents").catch(() => ({ data: { data: [] } })),
      ]);

      setClasses((classesRes.data?.data || []).filter((schoolClass) => !schoolClass.is_archived).map((schoolClass) => ({ id: schoolClass.id, name: schoolClass.name })));
      setTeachers((teachersRes.data?.data || []).map((teacher) => ({
        cin: teacher.cin,
        name: `${teacher.firstName || ""} ${teacher.lastName || ""}`.trim(),
        email: teacher.email || "",
      })));

      const allChildren = [{ id: "ALL", name: "Envoyer à tous", parentName: "Tous les parents" }];
      (parentsRes.data?.data || []).forEach((parent) => {
        (parent.children || []).forEach((child, index) => {
          allChildren.push({
            id: child.id || child.ChildID || `${parent.cin || "parent"}-${index}-${child.firstName}`,
            name: `${child.firstName || ""} ${child.lastName || ""}`.trim(),
            parentName: `${parent.firstName || ""} ${parent.lastName || ""}`.trim(),
          });
        });
      });
      setChildren(allChildren);
    } catch (err) {
      console.error("Error fetching reference data:", err);
    }
  }, []);

  useEffect(() => {
    const init = async () => {
      setLoading(true);
      await Promise.all([fetchEvents(), fetchReferenceData()]);
      setLoading(false);
    };
    init();
  }, [fetchEvents, fetchReferenceData]);

  const showToast = (message, severity = "info") => setToast({ open: true, message, severity });
  const closeToast = (_, reason) => {
    if (reason === "clickaway") return;
    setToast((prev) => ({ ...prev, open: false }));
  };

  const resetNotificationState = () => {
    setSelectedClasses([]);
    setSelectedTeachers([]);
    setSelectedChildren([]);
    setNotifTargetMode("classes");
  };

  const handleCreate = () => {
    setEditingEvent(null);
    setForm({ name: "", description: "", date: "", start_time: "09:00", end_time: "11:00", send_notifications: false });
    setFormError("");
    setConflictInfo(null);
    resetNotificationState();
    setDialogOpen(true);
  };

  const handleEdit = (event) => {
    closeActionMenu();
    setEditingEvent(event);
    setForm({
      name: event.name || "",
      description: event.description || "",
      date: (event.date || "").slice(0, 10),
      start_time: (event.start_time || "").slice(0, 5),
      end_time: (event.end_time || "").slice(0, 5),
      send_notifications: false,
    });
    setFormError("");
    setConflictInfo(null);
    resetNotificationState();
    setDialogOpen(true);
  };

  const hasNotificationTargets = () => {
    if (!form.send_notifications) return true;
    const targetCount = notifTargetMode === "classes" ? selectedClasses.length : selectedChildren.length;
    return targetCount > 0 || selectedTeachers.length > 0;
  };

  const handleSubmitEvent = async (e) => {
    e.preventDefault();
    setFormError("");
    setConflictInfo(null);

    if (!form.name.trim() || !form.description.trim() || !form.date || !form.start_time || !form.end_time) {
      setFormError("Veuillez remplir tous les champs (le nom, la description, la date et les horaires ne peuvent pas être vides).");
      return;
    }

    const selectedDate = new Date(form.date);
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    if (selectedDate < today) {
      setFormError("La date de l'événement ne peut pas être dans le passé.");
      return;
    }

    if (form.start_time >= form.end_time) {
      setFormError("L'heure de fin doit être postérieure à l'heure de début.");
      return;
    }

    if (!hasNotificationTargets()) {
      setFormError("Sélectionnez au moins un destinataire ou désactivez les notifications.");
      return;
    }

    setSaving(true);
    try {
      const conflictRes = await api.get("/admin/events/check-conflict", {
        params: {
          date: form.date,
          start_time: form.start_time,
          end_time: form.end_time,
          exclude_event_id: editingEvent?.id || null,
        },
      });

      if (conflictRes.data?.has_conflict) {
        const actConflicts = (conflictRes.data.activity_conflicts || []).map((conflict) => `• Activité "${conflict.title}" (${(conflict.startTime || "").slice(0, 5)} - ${(conflict.endTime || "").slice(0, 5)})`);
        const evtConflicts = (conflictRes.data.event_conflicts || []).map((conflict) => `• Événement "${conflict.name}" (${(conflict.start_time || "").slice(0, 5)} - ${(conflict.end_time || "").slice(0, 5)})`);
        setConflictInfo([...actConflicts, ...evtConflicts].join("\n"));
        setSaving(false);
        return;
      }

      const payload = {
        name: form.name.trim(),
        description: form.description.trim() || null,
        date: form.date,
        start_time: form.start_time,
        end_time: form.end_time,
        send_notifications: form.send_notifications,
        notification_targets: form.send_notifications
          ? {
              classes: notifTargetMode === "classes" ? selectedClasses.map((schoolClass) => schoolClass.id) : [],
              teachers: selectedTeachers.map((teacher) => teacher.cin),
              children: notifTargetMode === "children" ? selectedChildren.map((child) => child.id) : [],
            }
          : { classes: [], teachers: [], children: [] },
      };

      if (editingEvent) {
        await api.put(`/admin/events/${editingEvent.id}`, payload);
        showToast(form.send_notifications ? "Événement mis à jour et notifications envoyées." : "Événement mis à jour.", "success");
      } else {
        await api.post("/admin/events", payload);
        showToast(form.send_notifications ? "Événement créé et notifications envoyées." : "Événement créé.", "success");
      }

      setDialogOpen(false);
      resetNotificationState();
      await fetchEvents();
    } catch (err) {
      setFormError(err?.response?.data?.message || "Erreur lors de la sauvegarde.");
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = (event) => {
    closeActionMenu();
    setDeletingEvent(event);
    setDeleteDialogOpen(true);
  };

  const handleDeleteConfirm = async () => {
    if (!deletingEvent) return;
    try {
      await api.delete(`/admin/events/${deletingEvent.id}`);
      setDeleteDialogOpen(false);
      setDeletingEvent(null);
      await fetchEvents();
      showToast("Événement supprimé.", "success");
    } catch (err) {
      showToast(err?.response?.data?.message || "Erreur lors de la suppression.", "error");
    }
  };

  const handleToggleStatus = async (event) => {
    closeActionMenu();
    const newStatus = event.status === "executed" ? "pending" : "executed";
    try {
      await api.patch(`/admin/events/${event.id}/status`, { status: newStatus });
      await fetchEvents();
      showToast(newStatus === "executed" ? "Événement marqué exécuté." : "Événement remis en attente.", "success");
    } catch (err) {
      showToast(err?.response?.data?.message || "Erreur lors de la mise à jour du statut.", "error");
    }
  };

  const openActionMenu = (event, row) => {
    const rect = event.currentTarget.getBoundingClientRect();
    const menuWidth = 210;
    const viewportPadding = 8;
    const left = Math.max(viewportPadding, Math.min(rect.right - menuWidth, window.innerWidth - menuWidth - viewportPadding));
    const top = Math.max(viewportPadding, Math.min(rect.bottom + 4, window.innerHeight - 200));
    setActionMenuPosition({ top, left });
    setActionMenuEvent(row);
  };

  const closeActionMenu = () => {
    setActionMenuPosition(null);
    setActionMenuEvent(null);
  };

  const stats = useMemo(() => {
    const today = new Date().toISOString().slice(0, 10);
    return {
      total: events.length,
      today: events.filter((event) => String(event.date).slice(0, 10) === today).length,
      executed: events.filter((event) => event.status === "executed").length,
      pending: events.filter((event) => event.status === "pending").length,
      notified: events.filter((event) => !!event.notifications_sent).length,
    };
  }, [events]);

  const columns = [
    { field: "id", headerName: "ID", flex: 0.35, minWidth: 70, headerAlign: "center", align: "center" },
    {
      field: "name",
      headerName: "Nom",
      flex: 1.2,
      minWidth: 220,
      cellClassName: "name-column--cell",
      renderCell: ({ row }) => (
        <Box display="flex" flexDirection="column" justifyContent="center" minWidth={0} width="100%" py="8px">
          <Typography fontWeight="700" color={colors.grey[100]} noWrap>{row.name}</Typography>
          <Typography variant="caption" color={colors.grey[300]} noWrap>{row.description || "Sans description"}</Typography>
        </Box>
      ),
    },
    {
      field: "date",
      headerName: "Date",
      flex: 0.7,
      minWidth: 120,
      renderCell: ({ row }) => <Typography>{formatDate(row.date)}</Typography>,
    },
    {
      field: "time",
      headerName: "Horaire",
      flex: 1.1,
      minWidth: 220,
      sortable: false,
      renderCell: ({ row }) => {
        const progress = getTimeProgressMeta(row, new Date());
        const timeLabel = `${formatShortTime(row.start_time)} - ${formatShortTime(row.end_time)}`;
        return (
          <Tooltip title={progress?.tooltip || timeLabel}>
            <Box width="100%" display="flex" flexDirection="column" justifyContent="center" py="8px">
              <Typography fontWeight="700" color={colors.grey[100]}>{timeLabel}</Typography>
              {progress ? (
                <>
                  <Typography variant="caption" color={progress.isMuted ? colors.grey[400] : colors.grey[300]} mt="2px">{progress.label}</Typography>
                  <Box mt="6px" height="4px" borderRadius="999px" overflow="hidden" sx={{ backgroundColor: progress.trackColor }}>
                    <Box height="100%" width={`${progress.percent}%`} borderRadius="999px" sx={{ backgroundColor: progress.barColor }} />
                  </Box>
                </>
              ) : (
                <Typography variant="caption" color={colors.grey[300]} mt="2px">Planifié</Typography>
              )}
            </Box>
          </Tooltip>
        );
      },
    },
    {
      field: "status",
      headerName: "Statut",
      flex: 0.8,
      minWidth: 140,
      renderCell: ({ row }) => {
        const meta = getStatusMeta(row.status, colors, isDark);
        return (
          <Box component="span" sx={{ px: "10px", py: "6px", borderRadius: "999px", border: "1px solid", fontWeight: 700, fontSize: "0.75rem", lineHeight: 1, display: "inline-flex", alignItems: "center", backgroundColor: meta.backgroundColor, color: meta.color, borderColor: meta.borderColor }}>
            {meta.label}
          </Box>
        );
      },
    },
    {
      field: "notifications_sent",
      headerName: "Notifié",
      flex: 0.65,
      minWidth: 120,
      renderCell: ({ row }) => (
        <Box component="span" sx={{ px: "10px", py: "6px", borderRadius: "999px", border: "1px solid", fontWeight: 700, fontSize: "0.75rem", lineHeight: 1, display: "inline-flex", alignItems: "center", backgroundColor: row.notifications_sent ? (isDark ? "rgba(34,197,94,0.18)" : "rgba(22,163,74,0.12)") : (isDark ? "rgba(148,163,184,0.14)" : "rgba(148,163,184,0.14)"), color: row.notifications_sent ? (isDark ? colors.greenAccent[300] : "#166534") : (isDark ? colors.grey[300] : "#64748b"), borderColor: row.notifications_sent ? (isDark ? "rgba(34,197,94,0.22)" : "rgba(22,163,74,0.18)") : (isDark ? "rgba(148,163,184,0.22)" : "rgba(148,163,184,0.18)") }}>
          {row.notifications_sent ? "Envoyé" : "Non envoyé"}
        </Box>
      ),
    },
    {
      field: "actions",
      headerName: "Plus",
      flex: 0.4,
      minWidth: 90,
      sortable: false,
      filterable: false,
      headerAlign: "right",
      align: "right",
      renderCell: ({ row }) => (
        <Box display="flex" justifyContent="flex-end" width="100%">
          <Tooltip title="Plus d'actions">
            <IconButton size="small" onClick={(event) => openActionMenu(event, row)} sx={{ color: colors.grey[200], backgroundColor: "rgba(148,163,184,0.14)", "&:hover": { backgroundColor: "rgba(148,163,184,0.22)" } }}>
              <MoreVertOutlinedIcon fontSize="small" />
            </IconButton>
          </Tooltip>
        </Box>
      ),
    },
  ];

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

      <EventDataGrid events={events} columns={columns} colors={colors} isDark={isDark} />

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
