import {
  Alert,
  Box,
  Button,
  CircularProgress,
  Dialog,
  DialogActions,
  DialogContent,
  DialogTitle,
  FormControl,
  InputLabel,
  MenuItem,
  Portal,
  Select,
  Snackbar,
  Switch,
  TextField,
  Typography,
} from "@mui/material";
import Header from "../../components/Header";
import { tokens } from "../../theme";
import { useTheme } from "@mui/material/styles";
import { useEffect, useMemo, useState } from "react";
import api from "../../api/axios";

const PARAM_LABELS = {
  school_name: "Nom de l'établissement",
  school_year: "Année scolaire",
  inscription_fee: "Frais d'inscription (TND)",
  frais_inscription: "Frais d'inscription (TND)",
  max_capacity: "Capacité maximale",
  kindergarten_address: "Adresse",
  contact_email: "Email",
  contact_phone: "Téléphone",
  facebook_link: "Facebook",
  instagram_link: "Instagram",
  whatsapp_link: "WhatsApp",
};

const HIDDEN_PARAMS = ["ai_enabled", "Exceptions dejeuner : verification enfant", "inscriptions_open"];

function getPlanningLabel(startYear, endYear) {
  return `${startYear}/${endYear}`;
}

function mapPlanningFromApi(planning) {
  const startYear = Number(planning.startYear ?? planning.start_year);
  const endYear = Number(planning.endYear ?? planning.end_year);
  const startDate = typeof (planning.startDate ?? planning.start_date) === "string"
    ? (planning.startDate ?? planning.start_date).slice(0, 10)
    : "";
  const endDate = typeof (planning.endDate ?? planning.end_date) === "string"
    ? (planning.endDate ?? planning.end_date).slice(0, 10)
    : "";

  return {
    id: planning.id,
    startYear,
    endYear,
    startDate,
    endDate,
    label: planning.label || getPlanningLabel(startYear, endYear),
    isActive: !planning.is_archived,
    isArchived: !!planning.is_archived,
  };
}

function getDefaultPlanning(planningRows, referenceDate) {
  if (!Array.isArray(planningRows) || planningRows.length === 0) return null;

  const activePlanning = planningRows.find((planning) => planning.isActive);
  if (activePlanning) return activePlanning;

  const todayTime = referenceDate.getTime();
  const currentPlanning = planningRows.find((planning) => {
    if (!planning.startDate || !planning.endDate) return false;
    const startTime = new Date(`${planning.startDate}T00:00:00`).getTime();
    const endTime = new Date(`${planning.endDate}T23:59:59`).getTime();
    return startTime <= todayTime && todayTime <= endTime;
  });
  if (currentPlanning) return currentPlanning;

  return planningRows.slice().sort((a, b) => {
    const aTime = new Date(`${a.endDate || a.startDate || "1900-01-01"}T00:00:00`).getTime();
    const bTime = new Date(`${b.endDate || b.startDate || "1900-01-01"}T00:00:00`).getTime();
    return bTime - aTime;
  })[0];
}

function validatePlanningDates(startDate, endDate) {
  if (!startDate || !endDate) return null;
  const start = new Date(`${startDate}T00:00:00`);
  const end = new Date(`${endDate}T00:00:00`);
  if (Number.isNaN(start.getTime()) || Number.isNaN(end.getTime()) || end < start) return null;
  const startYear = start.getFullYear();
  const endYear = end.getFullYear();
  if (startYear < 2000 || startYear > 2100 || endYear < 2000 || endYear > 2100) return null;
  return { startYear, endYear, startDate, endDate };
}

function getLabel(name) {
  return PARAM_LABELS[name] || String(name).replace(/_/g, " ").replace(/\b\w/g, (letter) => letter.toUpperCase());
}

function getInputType(name) {
  const normalized = String(name).toLowerCase();
  if (normalized.includes("fee") || normalized.includes("capacity") || normalized.includes("amount") || normalized.includes("prix") || normalized.includes("frais") || normalized.includes("enfant") || normalized.includes("tarif")) return "number";
  return normalized.includes("email") ? "email" : "text";
}

function sanitizeNumericInput(value) {
  const sanitized = String(value).replace(/[^0-9.]/g, "");
  const firstDotIndex = sanitized.indexOf(".");
  if (firstDotIndex === -1) return sanitized;
  return `${sanitized.slice(0, firstDotIndex + 1)}${sanitized.slice(firstDotIndex + 1).replace(/\./g, "")}`;
}

function getParamCategory(name) {
  const normalized = String(name).toLowerCase();
  if (normalized === "school_name" || normalized.includes("address") || normalized.includes("adresse") || normalized.includes("school_year")) return "identity";
  if (normalized.includes("dejeuner") || normalized.includes("déjeuner") || normalized.includes("gouter") || normalized.includes("goûter") || normalized.includes("cantine") || normalized.includes("meal") || normalized.includes("repas") || normalized.includes("tarif") || normalized.includes("prix")) return "meals";
  if (normalized.includes("email") || normalized.includes("phone") || normalized.includes("tel") || normalized.includes("facebook") || normalized.includes("instagram") || normalized.includes("whatsapp") || normalized.includes("contact") || normalized.includes("site") || normalized.includes("website")) return "contact";
  if (normalized.includes("frais") || normalized.includes("fee") || normalized.includes("capacity") || normalized.includes("amount")) return "fees";
  return "other";
}

function getStyles(colors, isDark) {
  return {
    card: {
      backgroundColor: colors.primary[400],
      borderRadius: "16px",
      padding: "22px",
      boxShadow: "0 12px 28px rgba(15,23,42,0.08)",
      border: `1px solid ${colors.primary[500]}`,
      height: "100%",
      display: "flex",
      flexDirection: "column",
    },
    featureCard: (enabled) => ({
      backgroundColor: isDark ? colors.primary[500] : "rgba(255,255,255,0.96)",
      borderRadius: "14px",
      border: `1px solid ${isDark ? colors.primary[600] : "rgba(148,163,184,0.18)"}`,
      padding: "16px",
      opacity: enabled ? 1 : 0.42,
      filter: enabled ? "none" : "grayscale(0.25)",
      transition: "opacity 0.2s ease, filter 0.2s ease",
      height: "100%",
      display: "flex",
      flexDirection: "column",
      justifyContent: "flex-start",
    }),
    subtlePanel: (enabled) => ({
      backgroundColor: isDark ? colors.primary[500] : "rgba(248,250,252,0.9)",
      borderRadius: "14px",
      border: `1px solid ${colors.primary[500]}`,
      padding: "16px",
      opacity: enabled ? 1 : 0.42,
      filter: enabled ? "none" : "grayscale(0.35)",
      transition: "opacity 0.2s ease, filter 0.2s ease",
      flex: 1,
      display: "flex",
      flexDirection: "column",
    }),
    field: {
      "& .MuiOutlinedInput-root": {
        borderRadius: "12px",
        backgroundColor: isDark ? colors.primary[500] : "#f8fafc",
        minHeight: 54,
        alignItems: "flex-start",
      },
      "& .MuiOutlinedInput-input": {
        paddingTop: "16px",
        paddingBottom: "16px",
      },
      "& .MuiInputBase-inputMultiline": {
        paddingTop: "16px",
        paddingBottom: "16px",
      },
      "& .MuiInputLabel-root": {
        color: colors.grey[300],
        fontWeight: 600,
        transformOrigin: "top left",
      },
      "& .MuiInputLabel-root.Mui-focused": {
        color: isDark ? "#94a3b8" : "#475569",
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
      "& .MuiFormHelperText-root": {
        minHeight: 20,
        marginLeft: 0,
        marginRight: 0,
      },
    },
    primaryBtn: {
      backgroundColor: isDark ? "#475569" : "#334155",
      color: "#fff",
      fontWeight: 700,
      textTransform: "none",
      borderRadius: "999px",
      paddingInline: "18px",
      boxShadow: "none",
      "&:hover": { backgroundColor: isDark ? "#64748b" : "#475569", boxShadow: "none" },
    },
    secondaryBtn: {
      borderRadius: "999px",
      textTransform: "none",
      fontWeight: 700,
      boxShadow: "none",
    },
    switch: (enabled) => ({
      "& .MuiSwitch-switchBase.Mui-checked": { color: colors.greenAccent[500] },
      "& .MuiSwitch-switchBase.Mui-checked + .MuiSwitch-track": { backgroundColor: colors.greenAccent[500] },
      "& .MuiSwitch-track": { backgroundColor: enabled ? colors.greenAccent[500] : colors.redAccent[500] },
      transform: "scale(1.15)",
    }),
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
      padding: "16px",
      borderTop: `1px solid ${colors.primary[500]}`,
    },
  };
}

const ToggleFeatureList = ({ title, description, features, enabled, colors, styles }) => (
  <Box sx={{ ...styles.featureCard(enabled), width: "100%", maxWidth: 440 }}>
    <Typography variant="subtitle2" fontWeight="700" color={colors.grey[100]} mb="6px">{title}</Typography>
    <Typography variant="body2" color={colors.grey[300]} mb="12px">{description}</Typography>
    <Box display="flex" flexDirection="column" gap="8px">
      {features.map((feature) => (
        <Box key={feature.label} display="grid" gridTemplateColumns="14px 1fr" gap="10px" alignItems="start">
          <Box mt="7px" width="6px" height="6px" borderRadius="999px" bgcolor={enabled ? colors.greenAccent[400] : colors.grey[500]} />
          <Box>
            <Typography variant="body2" color={colors.grey[100]} fontWeight="600">{feature.label}</Typography>
            <Typography variant="caption" color={colors.grey[400]}>{feature.desc}</Typography>
          </Box>
        </Box>
      ))}
    </Box>
  </Box>
);

const ToggleCard = ({ title, subtitle, enabled, saving, onToggleRequest, features, colors, styles }) => (
  <Box sx={styles.card}>
    <Box display="flex" justifyContent="space-between" alignItems="flex-start" gap="16px">
      <Box>
        <Typography variant="h5" fontWeight="700" color={colors.grey[100]}>{title}</Typography>
        <Typography variant="body2" color={colors.grey[300]} mt="4px">{subtitle}</Typography>
      </Box>
      <Box display="flex" alignItems="center" gap="12px">
        {saving && <CircularProgress size={18} sx={{ color: colors.grey[300] }} />}
        <Switch checked={enabled} onChange={onToggleRequest} disabled={saving} sx={styles.switch(enabled)} />
      </Box>
    </Box>

    <Box mt="18px" sx={styles.subtlePanel(enabled)}>
      <Typography variant="caption" color={colors.grey[400]} fontWeight="700" textTransform="uppercase" letterSpacing="0.5px" mb="12px" display="block">
        Fonctionnalités affectées
      </Typography>
      <Box
        display="grid"
        gridTemplateColumns={features.length > 1 ? { xs: "1fr", md: "repeat(2, minmax(0, 1fr))" } : "1fr"}
        gap="12px"
        sx={{
          flex: 1,
          alignItems: "center",
          justifyItems: "center",
          alignContent: "center",
          maxWidth: features.length > 1 ? "100%" : 460,
          mx: "auto",
          width: "100%",
        }}
      >
        {features.map((group) => (
          <ToggleFeatureList key={group.title} title={group.title} description={group.description} features={group.items} enabled={enabled} colors={colors} styles={styles} />
        ))}
      </Box>
    </Box>
  </Box>
);

const PlanningSection = ({
  plannings,
  selectedPlanningId,
  setSelectedPlanningId,
  planningForm,
  setPlanningForm,
  planningMessage,
  savingPlanning,
  handleSavePlanning,
  handleCreatePlanning,
  handleRemovePlanning,
  selectedPlanning,
  archiveError,
  archiveResult,
  archiveLoading,
  onArchiveRequest,
  colors,
  styles,
}) => (
  <Box sx={styles.card}>
    <Typography variant="h5" fontWeight="700" color={colors.grey[100]} mb="6px">Cycle scolaire</Typography>
    <Typography variant="body2" color={colors.grey[300]} mb="18px">Gérez l'année active, créez la suivante et clôturez l'année en cours depuis un seul panneau.</Typography>

    {planningMessage.text && (
      <Alert severity={planningMessage.type === "success" ? "success" : "error"} sx={{ mb: "16px" }}>
        {planningMessage.text}
      </Alert>
    )}

    <Box display="grid" gridTemplateColumns={{ xs: "1fr", xl: "1.1fr 0.9fr" }} gap="18px">
      <Box sx={styles.featureCard(true)}>
        <Typography variant="subtitle2" fontWeight="700" color={colors.grey[100]} mb="14px">Année scolaire sélectionnée</Typography>
        <Box component="form" onSubmit={handleSavePlanning} display="flex" flexDirection="column" gap="16px">
          <FormControl fullWidth>
            <InputLabel shrink>Choisir l'année scolaire</InputLabel>
            <Select
              value={selectedPlanningId || ""}
              onChange={(e) => setSelectedPlanningId(e.target.value)}
              label="Choisir l'année scolaire"
              sx={styles.field}
            >
              <MenuItem value="" disabled>Sélectionner une année</MenuItem>
              {plannings.map((planning) => (
                <MenuItem key={planning.id} value={planning.id}>
                  {planning.label || getPlanningLabel(planning.startYear, planning.endYear)} {planning.isArchived ? "(Archivée)" : ""}
                </MenuItem>
              ))}
            </Select>
          </FormControl>

          <Box display="grid" gridTemplateColumns={{ xs: "1fr", md: "repeat(3, minmax(0, 1fr))" }} gap="16px">
            <TextField fullWidth variant="outlined" type="date" label="Date de début" value={planningForm.startDate} onChange={(e) => setPlanningForm((prev) => ({ ...prev, startDate: e.target.value }))} InputLabelProps={{ shrink: true }} sx={styles.field} />
            <TextField fullWidth variant="outlined" type="date" label="Date de fin" value={planningForm.endDate} onChange={(e) => setPlanningForm((prev) => ({ ...prev, endDate: e.target.value }))} InputLabelProps={{ shrink: true }} sx={styles.field} />
            <TextField fullWidth variant="outlined" type="text" label="Label" value={planningForm.label || (() => {
              const valid = validatePlanningDates(planningForm.startDate, planningForm.endDate);
              return valid ? getPlanningLabel(valid.startYear, valid.endYear) : "";
            })()} onChange={(e) => setPlanningForm((prev) => ({ ...prev, label: e.target.value }))} placeholder="ex: 2026/2027" InputLabelProps={{ shrink: true }} sx={styles.field} />
          </Box>

          <Box display="flex" justifyContent="flex-end" gap="10px" flexWrap="wrap">
            <Button variant="outlined" color="error" onClick={handleRemovePlanning} disabled={savingPlanning || !selectedPlanningId} sx={styles.secondaryBtn}>Supprimer</Button>
            <Button variant="outlined" onClick={handleCreatePlanning} disabled={savingPlanning || !planningForm.startDate || !planningForm.endDate} sx={styles.secondaryBtn}>Créer une nouvelle année</Button>
            <Button type="submit" variant="contained" disabled={savingPlanning || !selectedPlanningId} sx={styles.primaryBtn}>
              {savingPlanning ? "Enregistrement..." : "Enregistrer"}
            </Button>
          </Box>
        </Box>
      </Box>

      <Box sx={styles.featureCard(!(selectedPlanning?.isArchived))}>
        <Typography variant="subtitle2" fontWeight="700" color={colors.grey[100]} mb="8px">Clôture de l'année</Typography>
        <Typography variant="body2" color={colors.grey[300]} mb="12px">
          Archive toutes les inscriptions et classes de l'année en cours. Utilisez cette action seulement lorsque le cycle est terminé.
        </Typography>

        {selectedPlanning?.isArchived ? (
          <Alert severity="success" sx={{ mb: "16px" }}>
            Cette année scolaire est déjà archivée. Créez une nouvelle année pour relancer les inscriptions.
          </Alert>
        ) : (
          <>
            {archiveError && <Alert severity="error" sx={{ mb: "12px" }}>{archiveError}</Alert>}
            {archiveResult && (
              <Alert severity="success" sx={{ mb: "12px" }}>
                {archiveResult.message}<br />
                Inscriptions archivées : {archiveResult.stats?.inscriptions_archived || 0}<br />
                Classes archivées : {archiveResult.stats?.classes_archived || 0}
              </Alert>
            )}
            <Button variant="contained" onClick={onArchiveRequest} disabled={archiveLoading || !!archiveResult || selectedPlanning?.isArchived} sx={{ ...styles.primaryBtn, backgroundColor: colors.redAccent[600], "&:hover": { backgroundColor: colors.redAccent[700] } }}>
              {archiveLoading ? "Archivage en cours..." : "Archiver l'année scolaire"}
            </Button>
          </>
        )}
      </Box>
    </Box>
  </Box>
);

const SettingsGroupCard = ({ title, description, params, columns = 2, colors, styles, handleChange, getInputType }) => {
  if (params.length === 0) return null;

  return (
    <Box sx={styles.featureCard(true)}>
      <Typography variant="h6" fontWeight="700" color={colors.grey[100]} mb="6px">{title}</Typography>
      <Typography variant="body2" color={colors.grey[300]} mb="16px">{description}</Typography>
      <Box display="grid" gridTemplateColumns={{ xs: "1fr", md: `repeat(${columns}, minmax(0, 1fr))` }} gap="16px" sx={{ flex: 1, alignItems: "start" }}>
        {params.map((param) => {
          const isNumber = getInputType(param.name) === "number";
          const isValid = !isNumber || /^\d*\.?\d*$/.test(param.value);
          const normalized = String(param.name).toLowerCase();
          const span = normalized.includes("address") || normalized.includes("adresse") ? { xs: "span 1", md: "span 2" } : { xs: "span 1", md: "span 1" };
          return (
            <Box key={param.id} gridColumn={span}>
              <TextField
                variant="outlined"
                label={getLabel(param.name)}
                value={param.value}
                onChange={(e) => handleChange(param.id, isNumber ? sanitizeNumericInput(e.target.value) : e.target.value)}
                type={isNumber ? "text" : getInputType(param.name)}
                fullWidth
                error={!isValid}
                helperText={!isValid ? "Seuls les nombres positifs sont autorisés" : " "}
                InputLabelProps={{ shrink: true }}
                sx={styles.field}
                inputProps={isNumber ? { inputMode: "decimal", pattern: "[0-9.]*" } : undefined}
              />
            </Box>
          );
        })}
      </Box>
    </Box>
  );
};

const ArchiveConfirmDialog = ({ open, onClose, onConfirm, colors, styles }) => (
  <Dialog open={open} onClose={onClose} PaperProps={{ sx: styles.dialogPaper }}>
    <DialogTitle sx={styles.dialogTitle}>Confirmer l'archivage</DialogTitle>
    <DialogContent sx={{ mt: 2 }}>
      <Typography>Êtes-vous sûr de vouloir archiver l'année scolaire en cours ? Cette action est irréversible et affectera toutes les inscriptions et classes actives.</Typography>
    </DialogContent>
    <DialogActions sx={styles.dialogActions}>
      <Button onClick={onClose} sx={{ color: colors.grey[300] }}>Annuler</Button>
      <Button onClick={onConfirm} variant="contained" sx={{ backgroundColor: colors.redAccent[600], color: "#fff", "&:hover": { backgroundColor: colors.redAccent[700] } }}>
        Confirmer l'archivage
      </Button>
    </DialogActions>
  </Dialog>
);

const ToggleConfirmDialog = ({ open, onClose, onConfirm, title, description, confirmLabel, colors, styles }) => (
  <Dialog open={open} onClose={onClose} PaperProps={{ sx: styles.dialogPaper }}>
    <DialogTitle sx={styles.dialogTitle}>{title}</DialogTitle>
    <DialogContent sx={{ mt: 2 }}>
      <Typography color={colors.grey[200]}>{description}</Typography>
    </DialogContent>
    <DialogActions sx={styles.dialogActions}>
      <Button onClick={onClose} sx={{ color: colors.grey[300] }}>Annuler</Button>
      <Button onClick={onConfirm} variant="contained" sx={styles.primaryBtn}>{confirmLabel}</Button>
    </DialogActions>
  </Dialog>
);

const Parameters = () => {
  const theme = useTheme();
  const colors = tokens(theme.palette.mode);
  const isDark = theme.palette.mode === "dark";
  const styles = getStyles(colors, isDark);

  const [params, setParams] = useState([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");

  const [aiEnabled, setAiEnabled] = useState(true);
  const [aiParamId, setAiParamId] = useState(null);
  const [savingAi, setSavingAi] = useState(false);

  const [inscriptionsOpen, setInscriptionsOpen] = useState(true);
  const [inscriptionsParamId, setInscriptionsParamId] = useState(null);
  const [savingInscriptions, setSavingInscriptions] = useState(false);

  const [archiveConfirmOpen, setArchiveConfirmOpen] = useState(false);
  const [archiveLoading, setArchiveLoading] = useState(false);
  const [archiveResult, setArchiveResult] = useState(null);
  const [archiveError, setArchiveError] = useState(null);

  const [plannings, setPlannings] = useState([]);
  const [selectedPlanningId, setSelectedPlanningId] = useState(null);
  const [planningForm, setPlanningForm] = useState({ startDate: "", endDate: "", label: "" });
  const [savingPlanning, setSavingPlanning] = useState(false);
  const [planningMessage, setPlanningMessage] = useState({ text: "", type: "" });

  const [toggleConfirm, setToggleConfirm] = useState({ open: false, type: null });
  const [toast, setToast] = useState({ open: false, message: "", severity: "success" });

  const hydratePlannings = (rows) => {
    const planningRows = (Array.isArray(rows) ? rows : []).map(mapPlanningFromApi);
    setPlannings(planningRows);
    setSelectedPlanningId((prev) => {
      if (prev && planningRows.some((planning) => planning.id === prev)) return prev;
      return getDefaultPlanning(planningRows, new Date())?.id ?? (planningRows[0]?.id || "");
    });
  };

  useEffect(() => {
    const fetchAll = async () => {
      try {
        setLoading(true);
        const [paramsRes, planningsRes] = await Promise.all([
          api.get("/admin/parameters").catch(() => ({ data: { data: [] } })),
          api.get("/admin/plannings").catch(() => ({ data: { data: [] } })),
        ]);

        const data = paramsRes.data?.data || paramsRes.data || [];
        const arr = Array.isArray(data) ? data : [];

        const aiParam = arr.find((param) => param.name === "ai_enabled");
        if (aiParam) {
          setAiParamId(aiParam.id);
          setAiEnabled(aiParam.value === "true" || aiParam.value === "1");
        }

        const inscParam = arr.find((param) => param.name === "inscriptions_open");
        if (inscParam) {
          setInscriptionsParamId(inscParam.id);
          setInscriptionsOpen(inscParam.value === "true" || inscParam.value === "1");
        }

        setParams(arr.map((param) => ({ id: param.id, name: param.name || "", value: param.value ?? "" })));
        hydratePlannings(planningsRes.data?.data || []);
      } catch (err) {
        setError(err?.response?.data?.message || "Erreur de chargement.");
      } finally {
        setLoading(false);
      }
    };
    fetchAll();
  }, []);

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

  const visibleParams = useMemo(() => params.filter((param) => !HIDDEN_PARAMS.includes(param.name)), [params]);
  const selectedPlanning = useMemo(() => plannings.find((planning) => planning.id === selectedPlanningId), [plannings, selectedPlanningId]);

  const groupedParams = useMemo(() => {
    return visibleParams.reduce((acc, param) => {
      const category = getParamCategory(param.name);
      acc[category].push(param);
      return acc;
    }, { identity: [], meals: [], contact: [], fees: [], other: [] });
  }, [visibleParams]);

  const hasParamValidationError = visibleParams.some((param) => {
    const isNumber = getInputType(param.name) === "number";
    return isNumber && !/^\d*\.?\d*$/.test(param.value);
  });

  const showToast = (message, severity = "success") => setToast({ open: true, message, severity });
  const closeToast = (_, reason) => {
    if (reason === "clickaway") return;
    setToast((prev) => ({ ...prev, open: false }));
  };

  const handleChange = (id, newValue) => {
    setParams((prev) => prev.map((param) => (param.id === id ? { ...param, value: newValue } : param)));
  };

  const confirmToggle = (type) => setToggleConfirm({ open: true, type });
  const closeToggleConfirm = () => setToggleConfirm({ open: false, type: null });

  const handleToggleAi = async () => {
    if (!aiParamId) return;
    const newValue = !aiEnabled;
    setSavingAi(true);
    try {
      await api.put("/admin/parameters", { parameters: [{ id: aiParamId, value: newValue ? "true" : "false" }] });
      setAiEnabled(newValue);
      setParams((prev) => prev.map((param) => (param.id === aiParamId ? { ...param, value: newValue ? "true" : "false" } : param)));
      showToast(newValue ? "Le module IA a été activé." : "Le module IA a été désactivé.");
    } catch (err) {
      showToast(err?.response?.data?.message || "Erreur lors du changement du module IA.", "error");
    } finally {
      setSavingAi(false);
      closeToggleConfirm();
    }
  };

  const handleToggleInscriptions = async () => {
    if (!inscriptionsParamId) return;
    const newValue = !inscriptionsOpen;
    setSavingInscriptions(true);
    try {
      await api.put("/admin/parameters", { parameters: [{ id: inscriptionsParamId, value: newValue ? "true" : "false" }] });
      setInscriptionsOpen(newValue);
      setParams((prev) => prev.map((param) => (param.id === inscriptionsParamId ? { ...param, value: newValue ? "true" : "false" } : param)));
      showToast(newValue ? "Les inscriptions sont ouvertes." : "Les inscriptions sont maintenant fermées.");
    } catch (err) {
      showToast(err?.response?.data?.message || "Erreur lors du changement de l'état des inscriptions.", "error");
    } finally {
      setSavingInscriptions(false);
      closeToggleConfirm();
    }
  };

  const handleArchiveYear = async () => {
    setArchiveConfirmOpen(false);
    setArchiveLoading(true);
    setArchiveError(null);
    setArchiveResult(null);
    try {
      const res = await api.post("/admin/plannings/archive-current-year");
      setArchiveResult(res.data);
      const planningsRes = await api.get("/admin/plannings").catch(() => ({ data: { data: [] } }));
      hydratePlannings(planningsRes.data?.data || []);
      showToast("L'année scolaire a été archivée.");
    } catch (err) {
      const message = err.response?.status === 409
        ? err.response.data?.message || "Des inscriptions en attente existent. Veuillez les résoudre avant d'archiver."
        : err.response?.data?.message || "Erreur lors de l'archivage de l'année.";
      setArchiveError(message);
      showToast(message, "error");
    } finally {
      setArchiveLoading(false);
    }
  };

  const handleSaveParams = async () => {
    setSaving(true);
    setError("");
    setSuccess("");
    try {
      await api.put("/admin/parameters", { parameters: params.map((param) => ({ id: param.id, value: param.value })) });
      setSuccess("Paramètres enregistrés avec succès.");
      showToast("Paramètres enregistrés avec succès.");
      setTimeout(() => setSuccess(""), 3000);
    } catch (err) {
      const message = err?.response?.data?.message || "Erreur lors de l'enregistrement.";
      setError(message);
      showToast(message, "error");
    } finally {
      setSaving(false);
    }
  };

  const handleSavePlanning = async (e) => {
    e.preventDefault();
    if (!selectedPlanningId) return setPlanningMessage({ text: "Sélectionnez une année scolaire.", type: "error" });

    const valid = validatePlanningDates(planningForm.startDate, planningForm.endDate);
    if (!valid) return setPlanningMessage({ text: "Dates de début/fin invalides.", type: "error" });

    const effectiveLabel = planningForm.label.trim() || getPlanningLabel(valid.startYear, valid.endYear);
    const duplicate = plannings.find((planning) => planning.id !== selectedPlanningId && (planning.label || getPlanningLabel(planning.startYear, planning.endYear)) === effectiveLabel);
    if (duplicate) return setPlanningMessage({ text: `Une année scolaire avec le label "${effectiveLabel}" existe déjà.`, type: "error" });

    setSavingPlanning(true);
    setPlanningMessage({ text: "", type: "" });
    try {
      const res = await api.put(`/admin/plannings/${selectedPlanningId}`, {
        startYear: valid.startYear,
        endYear: valid.endYear,
        startDate: valid.startDate,
        endDate: valid.endDate,
        label: planningForm.label.trim() || undefined,
      });
      const updated = mapPlanningFromApi(res.data?.data || {});
      setPlannings((prev) => prev.map((planning) => (planning.id === selectedPlanningId ? { ...planning, ...updated } : planning)));
      setPlanningMessage({ text: "Année scolaire mise à jour avec succès.", type: "success" });
      showToast("Année scolaire mise à jour avec succès.");
      setTimeout(() => setPlanningMessage({ text: "", type: "" }), 3000);
    } catch (err) {
      setPlanningMessage({ text: err?.response?.data?.message || "Échec de la mise à jour.", type: "error" });
    } finally {
      setSavingPlanning(false);
    }
  };

  const handleCreatePlanning = async () => {
    const valid = validatePlanningDates(planningForm.startDate, planningForm.endDate);
    if (!valid) return setPlanningMessage({ text: "Dates de début/fin invalides.", type: "error" });

    const effectiveLabel = planningForm.label.trim() || getPlanningLabel(valid.startYear, valid.endYear);
    const duplicate = plannings.find((planning) => (planning.label || getPlanningLabel(planning.startYear, planning.endYear)) === effectiveLabel);
    if (duplicate) return setPlanningMessage({ text: `Une année scolaire avec le label "${effectiveLabel}" existe déjà.`, type: "error" });

    setSavingPlanning(true);
    setPlanningMessage({ text: "", type: "" });
    try {
      const res = await api.post("/admin/plannings", {
        startYear: valid.startYear,
        endYear: valid.endYear,
        startDate: valid.startDate,
        endDate: valid.endDate,
        label: planningForm.label.trim() || undefined,
      });
      const created = mapPlanningFromApi(res.data?.data || {});
      setPlannings((prev) => [created, ...prev.filter((planning) => planning.id !== created.id)]);
      setSelectedPlanningId(created.id);
      setPlanningMessage({ text: "Nouvelle année scolaire créée.", type: "success" });
      showToast("Nouvelle année scolaire créée.");
      setTimeout(() => setPlanningMessage({ text: "", type: "" }), 3000);
    } catch (err) {
      setPlanningMessage({ text: err?.response?.data?.message || "Échec de la création.", type: "error" });
    } finally {
      setSavingPlanning(false);
    }
  };

  const handleRemovePlanning = async () => {
    if (!selectedPlanningId) return setPlanningMessage({ text: "Sélectionnez une année scolaire.", type: "error" });
    setSavingPlanning(true);
    setPlanningMessage({ text: "", type: "" });
    try {
      await api.delete(`/admin/plannings/${selectedPlanningId}`);
      const next = plannings.filter((planning) => planning.id !== selectedPlanningId);
      setPlannings(next);
      setSelectedPlanningId(next[0]?.id || "");
      setPlanningMessage({ text: "Année scolaire supprimée.", type: "success" });
      showToast("Année scolaire supprimée.");
      setTimeout(() => setPlanningMessage({ text: "", type: "" }), 3000);
    } catch (err) {
      setPlanningMessage({ text: err?.response?.data?.message || "Échec de la suppression.", type: "error" });
    } finally {
      setSavingPlanning(false);
    }
  };

  if (loading) {
    return (
      <Box m="20px" display="flex" justifyContent="center" alignItems="center" height="60vh">
        <CircularProgress sx={{ color: colors.greenAccent[500] }} />
      </Box>
    );
  }

  const toggleDialogContent = toggleConfirm.type === "inscriptions"
    ? {
        title: inscriptionsOpen ? "Fermer les inscriptions" : "Ouvrir les inscriptions",
        description: inscriptionsOpen
          ? "Cela désactivera la création de compte parent, l'ajout d'enfant et les réinscriptions depuis l'application parent."
          : "Cela réactivera toutes les fonctionnalités d'inscription pour les parents.",
        confirmLabel: inscriptionsOpen ? "Fermer" : "Ouvrir",
        onConfirm: handleToggleInscriptions,
      }
    : {
        title: aiEnabled ? "Désactiver l'IA" : "Activer l'IA",
        description: aiEnabled
          ? "Les analyses médicales, suggestions et détections automatiques seront mises hors service jusqu'à réactivation."
          : "Les modules d'assistance intelligente seront remis en service sur les écrans compatibles.",
        confirmLabel: aiEnabled ? "Désactiver" : "Activer",
        onConfirm: handleToggleAi,
      };

  return (
    <Box m="20px">
      <Header title="PARAMÈTRES" />

      <Box display="grid" gridTemplateColumns={{ xs: "1fr", xl: "repeat(2, minmax(0, 1fr))" }} gap="18px" mb="20px" alignItems="stretch">
        <ToggleCard
          title="Inscriptions"
          subtitle={inscriptionsOpen ? "Les inscriptions et ré-inscriptions sont ouvertes." : "Toutes les inscriptions sont fermées."}
          enabled={inscriptionsOpen}
          saving={savingInscriptions}
          onToggleRequest={() => confirmToggle("inscriptions")}
          features={[
            {
              title: "Parcours parent",
              description: "Fonctionnalités impactées quand les inscriptions changent d'état.",
              items: [
                { label: "Création de compte parent", desc: "Accès au parcours d'inscription." },
                { label: "Ajout d'enfant et inscription", desc: "Saisie du dossier enfant." },
                { label: "Ré-inscription", desc: "Passage à la nouvelle année scolaire." },
              ],
            },
          ]}
          colors={colors}
          styles={styles}
        />

        <ToggleCard
          title="Intelligence artificielle"
          subtitle={aiEnabled ? "Toutes les fonctionnalités IA sont actives." : "Toutes les fonctionnalités IA sont désactivées."}
          enabled={aiEnabled}
          saving={savingAi}
          onToggleRequest={() => confirmToggle("ai")}
          features={[
            {
              title: "Modules alimentés par l'IA",
              description: "Cette liste est informative : elle n'ouvre pas de configuration supplémentaire.",
              items: [
                { label: "Analyse médicale", desc: "Résumé IA des dossiers d'inscription." },
                { label: "Détection des exceptions", desc: "Repas et restrictions automatiques." },
                { label: "Suggestions de critères", desc: "Aide à la préparation des activités." },
                { label: "Analyse des signalements", desc: "Aide à la lecture des rapports." },
              ],
            },
          ]}
          colors={colors}
          styles={styles}
        />
      </Box>

      <Box sx={styles.card} mt="20px">
        <Typography variant="h5" fontWeight="700" color={colors.grey[100]} mb="6px">Réglages détaillés</Typography>
        <Typography variant="body2" color={colors.grey[300]} mb="18px">Tous les champs ci-dessous appartiennent à la même section. Modifiez-les librement, puis enregistrez l'ensemble en une seule fois.</Typography>

        <Box display="grid" gridTemplateColumns={{ xs: "1fr", xl: "repeat(2, minmax(0, 1fr))" }} gap="18px" alignItems="stretch">
          <SettingsGroupCard title="Identité de l'établissement" description="Nom, adresse et repères généraux de l'école." params={groupedParams.identity} columns={2} colors={colors} styles={styles} handleChange={handleChange} getInputType={getInputType} />
          <SettingsGroupCard title="Tarification des repas & frais" description="Centralisez les montants de restauration et les frais administratifs." params={[...groupedParams.fees, ...groupedParams.meals]} columns={2} colors={colors} styles={styles} handleChange={handleChange} getInputType={getInputType} />
          <SettingsGroupCard title="Coordonnées & réseaux" description="Regroupez les coordonnées et liens utiles dans une grille compacte." params={groupedParams.contact} columns={3} colors={colors} styles={styles} handleChange={handleChange} getInputType={getInputType} />
          <SettingsGroupCard title="Autres réglages" description="Réglages supplémentaires non couverts par les groupes principaux." params={groupedParams.other} columns={2} colors={colors} styles={styles} handleChange={handleChange} getInputType={getInputType} />
        </Box>

        <Box mt="20px" pt="18px" borderTop={`1px solid ${colors.primary[500]}`}>
          <Typography variant="h6" fontWeight="700" color={colors.grey[100]} mb="6px">Enregistrement</Typography>
          <Typography variant="body2" color={colors.grey[300]} mb="16px">Ce bouton enregistre tous les champs de cette section.</Typography>
        {error && <Alert severity="error" sx={{ mb: "12px" }}>{error}</Alert>}
        {success && <Alert severity="success" sx={{ mb: "12px" }}>{success}</Alert>}
        <Box display="flex" justifyContent="flex-end">
          <Button variant="contained" onClick={handleSaveParams} disabled={saving || visibleParams.length === 0 || hasParamValidationError} sx={styles.primaryBtn}>
            {saving ? "Enregistrement..." : "Enregistrer les paramètres"}
          </Button>
        </Box>
        </Box>
      </Box>

      <Box mt="20px">
        <PlanningSection
          plannings={plannings}
          selectedPlanningId={selectedPlanningId}
          setSelectedPlanningId={setSelectedPlanningId}
          planningForm={planningForm}
          setPlanningForm={setPlanningForm}
          planningMessage={planningMessage}
          savingPlanning={savingPlanning}
          handleSavePlanning={handleSavePlanning}
          handleCreatePlanning={handleCreatePlanning}
          handleRemovePlanning={handleRemovePlanning}
          selectedPlanning={selectedPlanning}
          archiveError={archiveError}
          archiveResult={archiveResult}
          archiveLoading={archiveLoading}
          onArchiveRequest={() => setArchiveConfirmOpen(true)}
          colors={colors}
          styles={styles}
        />
      </Box>

      <ArchiveConfirmDialog open={archiveConfirmOpen} onClose={() => setArchiveConfirmOpen(false)} onConfirm={handleArchiveYear} colors={colors} styles={styles} />

      <ToggleConfirmDialog open={toggleConfirm.open} onClose={closeToggleConfirm} onConfirm={toggleDialogContent.onConfirm} title={toggleDialogContent.title} description={toggleDialogContent.description} confirmLabel={toggleDialogContent.confirmLabel} colors={colors} styles={styles} />

      <Portal>
        <Snackbar open={toast.open} autoHideDuration={4000} onClose={closeToast} anchorOrigin={{ vertical: "top", horizontal: "right" }} sx={{ zIndex: 2001 }}>
          <Alert onClose={closeToast} severity={toast.severity} variant="outlined" sx={{ width: "100%", maxWidth: "420px", alignItems: "center", borderRadius: "14px", boxShadow: "0 12px 28px rgba(15,23,42,0.12)", backgroundColor: isDark ? "rgba(17,24,39,0.96)" : "rgba(255,250,242,0.98)", color: isDark ? colors.grey[100] : "#3f2a12", borderColor: toast.severity === "error" ? "rgba(239,68,68,0.35)" : "rgba(245,158,11,0.35)" }}>
            {toast.message}
          </Alert>
        </Snackbar>
      </Portal>
    </Box>
  );
};

export default Parameters;
