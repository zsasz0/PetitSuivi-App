import {
    Alert,
    Box,
    Button,
    Checkbox,
    Chip,
    CircularProgress,
    Dialog,
    DialogActions,
    DialogContent,
    DialogTitle,
    FormControl,
    IconButton,
    MenuItem,
    Portal,
    Select,
    Snackbar,
    Tab,
    Tabs,
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
import ArchiveOutlinedIcon from "@mui/icons-material/ArchiveOutlined";
import AssignmentOutlinedIcon from "@mui/icons-material/AssignmentOutlined";
import CheckBoxOutlineBlankRoundedIcon from "@mui/icons-material/CheckBoxOutlineBlankRounded";
import CheckBoxRoundedIcon from "@mui/icons-material/CheckBoxRounded";
import FactCheckOutlinedIcon from "@mui/icons-material/FactCheckOutlined";
import MoreVertOutlinedIcon from "@mui/icons-material/MoreVertOutlined";
import PendingActionsOutlinedIcon from "@mui/icons-material/PendingActionsOutlined";
import PersonOutlineOutlinedIcon from "@mui/icons-material/PersonOutlineOutlined";
import { useEffect, useMemo, useRef, useState } from "react";
import api from "../../api/axios";
import Header from "../../components/Header";
import { tokens } from "../../theme";
import MedicalFormDocument from "./MedicalFormDocument";
import "./MedicalForm.css";

const mapPaymentMethod = (method) => {
    if (method === "monthlyPartial") return "Paiement mensuel";
    if (method === "oneShot") return "Paiement annuel";
    return method || "-";
};

const mapTypeLabel = (typeName) => {
    const normalized = String(typeName || "").trim().toLowerCase();
    if (normalized === "kindergarten") return "Maternelle";
    if (normalized === "preschool") return "Préscolaire";
    return typeName || "-";
};

const formatCurrency = (value) => {
    const amount = Number(value);
    if (!Number.isFinite(amount)) return "-";
    return `${new Intl.NumberFormat("fr-TN", { minimumFractionDigits: 2, maximumFractionDigits: 2 }).format(amount)} TND`;
};

const formatDate = (value) => {
    if (!value) return "-";
    const date = new Date(value);
    if (Number.isNaN(date.getTime())) return value;
    return date.toLocaleDateString("fr-FR");
};

const parseDateValue = (value) => {
    if (!value) return null;
    const date = new Date(value);
    return Number.isNaN(date.getTime()) ? null : date;
};

const isWithinPlanningMargin = (inscriptionDateValue, planningStartValue, planningEndValue) => {
    const inscriptionDate = parseDateValue(inscriptionDateValue);
    const planningStartDate = parseDateValue(planningStartValue);
    const planningEndDate = parseDateValue(planningEndValue);

    if (!inscriptionDate || !planningStartDate || !planningEndDate) {
        return false;
    }

    const effectiveStart = new Date(planningStartDate);
    effectiveStart.setMonth(effectiveStart.getMonth() - 2);

    return inscriptionDate >= effectiveStart && inscriptionDate <= planningEndDate;
};

const getStyles = (colors, isDark) => ({
    statsGrid: {
        display: "grid",
        gridTemplateColumns: { xs: "1fr", sm: "repeat(2, 1fr)", xl: "repeat(5, 1fr)" },
        gap: "14px",
        mb: "20px",
    },
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
    gridContainer: {
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
            backgroundColor: isDark ? "rgba(51, 65, 85, 0.24)" : "rgba(238, 242, 247, 0.88)",
        },
        "& .MuiDataGrid-toolbarContainer .MuiButton-text": {
            color: `${isDark ? colors.grey[100] : "#0f172a"} !important`,
        },
        "& .MuiDataGrid-cell:focus, & .MuiDataGrid-columnHeader:focus": { outline: "none" },
        "& .MuiDataGrid-row:last-of-type .MuiDataGrid-cell": { borderBottom: "none" },
    },
    dialogPaper: {
        backgroundColor: colors.primary[400],
        color: colors.grey[100],
        borderRadius: "16px",
        boxShadow: "0 18px 36px rgba(15,23,42,0.22)",
    },
    dialogTitle: {
        fontWeight: 700,
        fontSize: "1.15rem",
        borderBottom: `1px solid ${colors.primary[500]}`,
    },
    dialogActions: {
        p: 2,
        borderTop: `1px solid ${colors.primary[500]}`,
    },
    detailCard: {
        backgroundColor: isDark ? colors.primary[500] : "rgba(255,255,255,0.98)",
        border: `1px solid ${isDark ? colors.primary[600] : "rgba(148,163,184,0.22)"}`,
        borderRadius: "16px",
        padding: "18px",
        boxShadow: isDark ? "0 12px 28px rgba(0,0,0,0.12)" : "0 14px 32px rgba(15,23,42,0.08)",
        minHeight: "100%",
    },
    stackedCard: {
        backgroundColor: isDark ? colors.primary[500] : "rgba(255,255,255,0.98)",
        border: `1px solid ${isDark ? colors.primary[600] : "rgba(148, 163, 184, 0.22)"}`,
        borderRadius: "18px",
        padding: "18px",
        boxShadow: isDark ? "0 12px 28px rgba(0,0,0,0.12)" : "0 14px 32px rgba(15,23,42,0.08)",
    },
    topProfileCard: {
        background: isDark ? "linear-gradient(135deg, rgba(71,85,105,0.45), rgba(30,41,59,0.78))" : "linear-gradient(135deg, rgba(255,255,255,0.98), rgba(241,245,249,0.98))",
        border: `1px solid ${isDark ? "rgba(148,163,184,0.2)" : "rgba(203,213,225,0.95)"}`,
        borderRadius: "20px",
        padding: "22px",
        boxShadow: isDark ? "0 20px 40px rgba(2,6,23,0.24)" : "0 18px 40px rgba(15,23,42,0.10)",
    },
    metaGrid: {
        display: "grid",
        gridTemplateColumns: { xs: "1fr", sm: "repeat(2, minmax(0, 1fr))", xl: "repeat(3, minmax(0, 1fr))" },
        gap: "12px",
    },
    metaItem: {
        borderRadius: "14px",
        padding: "12px 14px",
        backgroundColor: isDark ? "rgba(255,255,255,0.03)" : "rgba(248,250,252,0.9)",
        border: `1px solid ${isDark ? "rgba(148,163,184,0.14)" : "rgba(226,232,240,0.95)"}`,
        minHeight: "78px",
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
    compactMenuPaper: {
        backgroundColor: colors.primary[400],
        color: colors.grey[100],
        borderRadius: "14px",
        border: `1px solid ${colors.primary[500]}`,
        boxShadow: "0 16px 32px rgba(15,23,42,0.18)",
    },
    neutralButton: {
        backgroundColor: isDark ? "#475569" : "#334155",
        color: "#fff",
        textTransform: "none",
        fontWeight: 700,
        boxShadow: "none",
        "&:hover": { backgroundColor: isDark ? "#64748b" : "#475569", boxShadow: "none" },
    },
    approveButton: {
        backgroundColor: isDark ? colors.greenAccent[500] : "#16a34a",
        color: "#fff",
        textTransform: "none",
        fontWeight: 700,
        boxShadow: "none",
        "&:hover": { backgroundColor: isDark ? colors.greenAccent[400] : "#15803d", boxShadow: "none" },
    },
    mutedButton: {
        borderColor: isDark ? "rgba(148,163,184,0.3)" : "rgba(148,163,184,0.35)",
        color: colors.grey[100],
        textTransform: "none",
        fontWeight: 700,
    },
    statusPill: (status) => {
        const palette = {
            approved: {
                backgroundColor: isDark ? "rgba(34,197,94,0.18)" : "rgba(22,163,74,0.12)",
                color: isDark ? colors.greenAccent[300] : "#166534",
                borderColor: isDark ? "rgba(34,197,94,0.22)" : "rgba(22,163,74,0.18)",
            },
            rejected: {
                backgroundColor: isDark ? "rgba(239,68,68,0.18)" : "rgba(220,38,38,0.12)",
                color: isDark ? colors.redAccent[300] : "#991b1b",
                borderColor: isDark ? "rgba(239,68,68,0.22)" : "rgba(220,38,38,0.18)",
            },
            pending: {
                backgroundColor: isDark ? "rgba(245,158,11,0.16)" : "rgba(245,158,11,0.12)",
                color: isDark ? "#fbbf24" : "#92400e",
                borderColor: isDark ? "rgba(245,158,11,0.22)" : "rgba(245,158,11,0.18)",
            },
        };
        return {
            px: "10px",
            py: "6px",
            borderRadius: "999px",
            border: "1px solid",
            fontWeight: 700,
            fontSize: "0.75rem",
            lineHeight: 1,
            display: "inline-flex",
            alignItems: "center",
            ...palette[status],
        };
    },
    assignBadge: {
        px: "10px",
        py: "6px",
        borderRadius: "999px",
        backgroundColor: isDark ? "rgba(148,163,184,0.16)" : "rgba(226,232,240,0.9)",
        color: isDark ? colors.grey[200] : "#475569",
        border: `1px solid ${isDark ? "rgba(148,163,184,0.24)" : "rgba(148,163,184,0.24)"}`,
        fontWeight: 700,
        fontSize: "0.75rem",
        textTransform: "none",
        boxShadow: "none",
        "&:hover": {
            backgroundColor: isDark ? "rgba(148,163,184,0.22)" : "rgba(203,213,225,0.9)",
            boxShadow: "none",
        },
    },
    medicalPreview: {
        maxHeight: "58vh",
        overflow: "auto",
        borderRadius: "14px",
        border: `1px solid ${colors.primary[500]}`,
        backgroundColor: isDark ? colors.primary[400] : "#ffffff",
        p: 1.5,
    },
    lockedPanel: {
        minHeight: "340px",
        borderRadius: "14px",
        border: `1px dashed ${isDark ? "rgba(148,163,184,0.32)" : "rgba(148,163,184,0.42)"}`,
        backgroundColor: isDark ? "rgba(255,255,255,0.02)" : "rgba(248,250,252,0.8)",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        opacity: 0.72,
        p: 3,
        textAlign: "center",
    },
    aiBlock: {
        borderRadius: "14px",
        border: `1px solid ${colors.primary[500]}`,
        backgroundColor: isDark ? colors.primary[400] : "#f8fafc",
        p: 2,
    },
    infoBadge: {
        px: "10px",
        py: "6px",
        borderRadius: "999px",
        backgroundColor: isDark ? "rgba(148,163,184,0.14)" : "rgba(226,232,240,0.8)",
        color: colors.grey[100],
        fontWeight: 700,
        fontSize: "0.75rem",
        lineHeight: 1,
        display: "inline-flex",
        alignItems: "center",
    },
});

const InscriptionsGridToolbar = ({ colors, isDark }) => (
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

const StatsCards = ({ stats, colors, styles, isDark }) => {
    const items = [
        {
            title: "Total inscriptions",
            value: stats.total,
            icon: <AssignmentOutlinedIcon />,
            iconBg: isDark ? "rgba(96,165,250,0.14)" : "rgba(37,99,235,0.12)",
            iconColor: isDark ? colors.blueAccent[300] : "#1d4ed8",
        },
        {
            title: "Approuvées",
            value: stats.approved,
            icon: <FactCheckOutlinedIcon />,
            iconBg: isDark ? "rgba(134,239,172,0.14)" : "rgba(22,163,74,0.12)",
            iconColor: isDark ? colors.greenAccent[300] : "#166534",
        },
        {
            title: "En attente",
            value: stats.pending,
            icon: <PendingActionsOutlinedIcon />,
            iconBg: isDark ? "rgba(245,158,11,0.14)" : "rgba(245,158,11,0.12)",
            iconColor: isDark ? "#fbbf24" : "#b45309",
        },
        {
            title: "Rejetées",
            value: stats.rejected,
            icon: <PersonOutlineOutlinedIcon />,
            iconBg: isDark ? "rgba(248,113,113,0.14)" : "rgba(220,38,38,0.12)",
            iconColor: isDark ? colors.redAccent[300] : "#991b1b",
        },
        {
            title: "Archivées",
            value: stats.archived,
            icon: <ArchiveOutlinedIcon />,
            iconBg: isDark ? "rgba(148,163,184,0.14)" : "rgba(148,163,184,0.14)",
            iconColor: isDark ? colors.grey[300] : "#64748b",
        },
    ];

    return (
        <Box sx={styles.statsGrid}>
            {items.map((item) => (
                <Box key={item.title} sx={styles.statCard}>
                    <Box sx={{ ...styles.statIcon, background: item.iconBg, color: item.iconColor }}>
                        {item.icon}
                    </Box>
                    <Box minWidth={0}>
                        <Typography variant="body2" color={colors.grey[300]}>{item.title}</Typography>
                        <Typography variant="h4" fontWeight="bold" color={colors.grey[100]} mt="4px">{item.value}</Typography>
                    </Box>
                </Box>
            ))}
        </Box>
    );
};

const AiDisabledBanner = ({ colors, isDark }) => (
    <Box mb="16px" p="12px 14px" borderRadius="12px" backgroundColor={isDark ? "rgba(239,68,68,0.12)" : "rgba(254,226,226,0.9)"} border="1px solid rgba(239,68,68,0.22)" display="flex" alignItems="center" gap="10px">
        <Typography fontSize="18px">⚠️</Typography>
        <Typography color={colors.redAccent[400]} fontSize="0.85rem">
            <strong>IA désactivée</strong> — l&apos;analyse médicale automatique sera ignorée pendant l&apos;approbation.
        </Typography>
    </Box>
);

const StatusBadge = ({ status, styles }) => {
    const labels = {
        approved: "Approuvée",
        pending: "En attente",
        rejected: "Rejetée",
    };
    return <Box component="span" sx={styles.statusPill(status)}>{labels[status] || status}</Box>;
};

const ClassAssignDialog = ({
    open,
    child,
    selectedClassId,
    onClassChange,
    classOptions,
    error,
    loading,
    onConfirm,
    onClose,
    colors,
    styles,
}) => (
    <Dialog open={open} onClose={loading ? undefined : onClose} fullWidth maxWidth="sm" PaperProps={{ sx: styles.dialogPaper }}>
        <DialogTitle sx={styles.dialogTitle}>Assigner une classe</DialogTitle>
        <DialogContent sx={{ mt: 2, display: "flex", flexDirection: "column", gap: "16px" }}>
            <Box sx={styles.detailCard}>
                <Typography variant="body2" color={colors.grey[300]} mb="12px">
                    Sélectionnez une classe pour <strong>{child?.name}</strong>.
                </Typography>
                <Typography variant="body2" color={colors.grey[300]} mb="16px">
                    Type souhaité : <strong>{child?.inscriptionType || "-"}</strong>
                </Typography>
                <FormControl fullWidth>
                    <Select
                        value={selectedClassId}
                        onChange={(event) => onClassChange(event.target.value)}
                        displayEmpty
                        sx={{ borderRadius: "12px", backgroundColor: colors.primary[500] }}
                        MenuProps={{ PaperProps: { sx: styles.compactMenuPaper } }}
                    >
                        <MenuItem value="" disabled>Sélectionner une classe</MenuItem>
                        {classOptions.map((schoolClass) => (
                            <MenuItem key={schoolClass.id} value={String(schoolClass.id)} disabled={schoolClass.isFull}>
                                {schoolClass.name} — {schoolClass.enrolled}/{schoolClass.capacity ?? "∞"}{schoolClass.isFull ? " — Classe complète" : ""}
                            </MenuItem>
                        ))}
                    </Select>
                </FormControl>
                {classOptions.length > 0 && classOptions.every((schoolClass) => schoolClass.isFull) && (
                    <Typography color={colors.redAccent[500]} mt={1}>Aucune classe disponible : toutes les classes correspondantes sont complètes.</Typography>
                )}
                {error && <Typography color={colors.redAccent[500]} mt={1}>{error}</Typography>}
            </Box>
        </DialogContent>
        <DialogActions sx={styles.dialogActions}>
            <Button onClick={onClose} sx={{ color: colors.grey[100] }} disabled={loading}>Annuler</Button>
            <Button onClick={onConfirm} variant="contained" disabled={!selectedClassId || loading} sx={styles.approveButton}>
                {loading ? <CircularProgress size={18} sx={{ color: "#fff" }} /> : "Confirmer"}
            </Button>
        </DialogActions>
    </Dialog>
);

const MealExceptionReviewBox = ({
    title,
    description,
    exceptions,
    loading,
    onScan,
    onToggle,
    colors,
    styles,
    isDark,
}) => (
    <Box sx={styles.aiBlock}>
        <Box display="flex" justifyContent="space-between" alignItems={{ xs: "flex-start", md: "center" }} gap="12px" flexDirection={{ xs: "column", md: "row" }} mb="12px">
            <Box>
                <Typography variant="caption" color={isDark ? colors.greenAccent[300] : "#166534"} fontWeight="700" mb="6px" display="block">
                    Détection des repas à risque
                </Typography>
                <Typography variant="body2" color={colors.grey[300]}>
                    {description}
                </Typography>
            </Box>
            <Button variant="outlined" onClick={onScan} disabled={loading} sx={styles.mutedButton}>
                {loading ? <CircularProgress size={18} sx={{ color: colors.grey[100] }} /> : title}
            </Button>
        </Box>

        {exceptions !== null && (
            <Box mt="10px" p="14px" borderRadius="12px" backgroundColor={isDark ? "rgba(255,255,255,0.02)" : "rgba(255,255,255,0.7)"} border={`1px solid ${colors.primary[500]}`}>
                {exceptions.length === 0 ? (
                    <Typography color={colors.greenAccent[400]} fontWeight="700">
                        Aucun repas problématique détecté.
                    </Typography>
                ) : (
                    <Box display="flex" flexDirection="column" gap="10px">
                        <Typography color={colors.redAccent[400]} fontWeight="700">
                            {exceptions.length} repas potentiellement problématique(s). Décochez les faux positifs.
                        </Typography>
                        {exceptions.map((exception, index) => (
                            <Box
                                key={`${exception.meal_id}-${index}`}
                                display="flex"
                                alignItems="flex-start"
                                gap="10px"
                                p="10px 12px"
                                borderRadius="12px"
                                backgroundColor={isDark ? "rgba(15,23,42,0.42)" : "rgba(248,250,252,0.92)"}
                                border={`1px solid ${isDark ? "rgba(148,163,184,0.16)" : "rgba(148,163,184,0.24)"}`}
                            >
                                <Checkbox
                                    checked={exception.checked !== false}
                                    onChange={(event) => onToggle(index, event.target.checked)}
                                    size="small"
                                    icon={<CheckBoxOutlineBlankRoundedIcon sx={{ color: isDark ? "rgba(148,163,184,0.78)" : "#94a3b8", fontSize: 22 }} />}
                                    checkedIcon={<CheckBoxRoundedIcon sx={{ color: isDark ? colors.greenAccent[300] : "#16a34a", fontSize: 22 }} />}
                                    sx={{
                                        p: 0.25,
                                        alignSelf: "flex-start",
                                        "&:hover": { backgroundColor: "transparent" },
                                    }}
                                />
                                <Box>
                                    <Typography color={colors.grey[100]} fontWeight="700" fontSize="0.92rem">
                                        Repas ID {exception.meal_id}
                                    </Typography>
                                    <Typography color={colors.grey[300]} fontSize="0.84rem" mt="4px">
                                        {exception.reason}
                                    </Typography>
                                </Box>
                            </Box>
                        ))}
                    </Box>
                )}
            </Box>
        )}
    </Box>
);

const ApprovalReviewDialog = ({
    open,
    child,
    dietary,
    health,
    mealExceptions,
    mealScanLoading,
    saving,
    onDietaryChange,
    onHealthChange,
    onScanMeals,
    onMealToggle,
    onConfirm,
    onClose,
    colors,
    styles,
    isDark,
}) => (
    <Dialog open={open} onClose={saving ? undefined : onClose} fullWidth maxWidth="md" PaperProps={{ sx: styles.dialogPaper }}>
        <DialogTitle sx={styles.dialogTitle}>Validation IA avant approbation</DialogTitle>
        <DialogContent sx={{ mt: 2 }}>
            <Box display="flex" flexDirection="column" gap="18px">
                <Box sx={styles.stackedCard}>
                    <Typography variant="h6" fontWeight="700">{child?.child?.name || child?.child?.child_full_name || child?.child?.childName || "Élève"}</Typography>
                    <Typography variant="body2" color={colors.grey[300]} mt="4px">
                        Vérifiez le résumé IA et les repas à risque avant de confirmer l'approbation.
                    </Typography>
                </Box>

                <Box display="grid" gridTemplateColumns={{ xs: "1fr", lg: "1fr 1fr" }} gap="18px">
                    <Box sx={styles.aiBlock}>
                        <Typography variant="caption" color={isDark ? colors.greenAccent[300] : "#166534"} fontWeight="700" mb="8px" display="block">
                            Résumé diététique
                        </Typography>
                        <TextField
                            fullWidth
                            multiline
                            minRows={6}
                            value={dietary}
                            onChange={(event) => onDietaryChange(event.target.value)}
                            InputLabelProps={{ shrink: true }}
                            sx={styles.floatingField}
                        />
                        <Box mt="12px" display="flex" gap="10px" flexWrap="wrap">
                            <Button variant="outlined" onClick={() => onDietaryChange("✅ Aucune restriction alimentaire détectée.")} sx={styles.mutedButton}>
                                Aucune restriction
                            </Button>
                        </Box>
                    </Box>
                    <Box sx={styles.aiBlock}>
                        <Typography variant="caption" color={isDark ? colors.blueAccent[300] : "#1d4ed8"} fontWeight="700" mb="8px" display="block">
                            Résumé santé générale
                        </Typography>
                        <TextField
                            fullWidth
                            multiline
                            minRows={6}
                            value={health}
                            onChange={(event) => onHealthChange(event.target.value)}
                            InputLabelProps={{ shrink: true }}
                            sx={styles.floatingField}
                        />
                        <Box mt="12px" display="flex" gap="10px" flexWrap="wrap">
                            <Button variant="outlined" onClick={() => onHealthChange("✅ Aucun problème de santé notable détecté.")} sx={styles.mutedButton}>
                                Aucun problème notable
                            </Button>
                        </Box>
                    </Box>
                </Box>

                <MealExceptionReviewBox
                    title="Scanner les repas"
                    description="Le scan tient compte du résumé diététique et des notes de santé ayant un impact alimentaire."
                    exceptions={mealExceptions}
                    loading={mealScanLoading}
                    onScan={onScanMeals}
                    onToggle={onMealToggle}
                    colors={colors}
                    styles={styles}
                    isDark={isDark}
                />
            </Box>
        </DialogContent>
        <DialogActions sx={styles.dialogActions}>
            <Button onClick={onClose} sx={{ color: colors.grey[100] }} disabled={saving}>Annuler</Button>
            <Button onClick={onConfirm} variant="contained" disabled={saving} sx={styles.approveButton}>
                {saving ? <CircularProgress size={18} sx={{ color: "#fff" }} /> : "Confirmer l'approbation"}
            </Button>
        </DialogActions>
    </Dialog>
);

const InscriptionDetailDialog = ({
    open,
    child,
    dietary,
    health,
    mealScanLoading,
    mealExceptions,
    mealReviewDirty,
    dirty,
    saving,
    aiEditMode,
    decisionLoading,
    onDietaryChange,
    onHealthChange,
    onScanMeals,
    onMealToggle,
    onSave,
    onEditToggle,
    onPrint,
    onClose,
    onApprove,
    onReject,
    onResetPending,
    onArchiveToggle,
    onOpenAssign,
    colors,
    styles,
    isDark,
    medicalDocRef,
}) => {
    if (!child) return null;

    const form = child.medicalApplication;
    const isEmpty = !form || typeof form !== "object" || Object.keys(form).length === 0;
    const formData = form?.form_data || form;
    const isFormDataEmpty = !formData || typeof formData !== "object" || Object.keys(formData).length === 0;
    const showTemplate = isEmpty || isFormDataEmpty;
    const isApproved = child.approval === "approved";

    return (
        <Dialog open={open} onClose={saving || decisionLoading ? undefined : onClose} fullWidth maxWidth="lg" PaperProps={{ sx: { ...styles.dialogPaper, minHeight: "82vh" } }}>
            <DialogTitle sx={styles.dialogTitle}>Fiche d'inscription</DialogTitle>
            <DialogContent sx={{ mt: 2 }}>
                <Box display="flex" flexDirection="column" gap="18px">
                    <Box sx={styles.topProfileCard}>
                        <Box display="flex" justifyContent="space-between" alignItems={{ xs: "flex-start", md: "center" }} flexDirection={{ xs: "column", md: "row" }} gap="16px">
                            <Box>
                                <Typography variant="h4" fontWeight="800">{child.name}</Typography>
                                <Box display="flex" alignItems="center" gap="8px" flexWrap="wrap" mt="8px">
                                    <Box component="span" sx={styles.infoBadge}>{child.age} ans</Box>
                                    <StatusBadge status={child.approval} styles={styles} />
                                    <Box component="span" sx={styles.infoBadge}>{child.parent}</Box>
                                </Box>
                            </Box>

                        </Box>
                        <Box sx={{ ...styles.metaGrid, mt: "18px" }}>
                            <Box sx={styles.metaItem}>
                                <Typography variant="caption" color={colors.grey[300]}>Type souhaité</Typography>
                                <Typography fontWeight="700" mt="6px">{child.inscriptionType}</Typography>
                            </Box>
                            <Box sx={styles.metaItem}>
                                <Typography variant="caption" color={colors.grey[300]}>Paiement</Typography>
                                <Typography fontWeight="700" mt="6px">{child.paymentMethod}</Typography>
                            </Box>
                            <Box sx={styles.metaItem}>
                                <Typography variant="caption" color={colors.grey[300]}>Montant total</Typography>
                                <Typography fontWeight="700" mt="6px">{child.totalAmount}</Typography>
                            </Box>
                            <Box sx={styles.metaItem}>
                                <Typography variant="caption" color={colors.grey[300]}>Inscriptions précédentes</Typography>
                                <Typography fontWeight="700" mt="6px">{child.previousInscriptions}</Typography>
                            </Box>
                            <Box sx={styles.metaItem}>
                                <Typography variant="caption" color={colors.grey[300]}>Classe</Typography>
                                <Box mt="8px">
                                    {child.approval === "approved" ? (
                                        child.inscriptionClass ? (
                                            <Chip
                                                label={child.inscriptionClass}
                                                size="small"
                                                sx={{
                                                    backgroundColor: isDark ? "rgba(34,197,94,0.18)" : "rgba(22,163,74,0.12)",
                                                    color: isDark ? colors.greenAccent[300] : "#166534",
                                                    border: `1px solid ${isDark ? "rgba(34,197,94,0.22)" : "rgba(22,163,74,0.18)"}`,
                                                    fontWeight: 700,
                                                }}
                                            />
                                        ) : (
                                            <Box component="span" sx={styles.infoBadge}>Non assignée</Box>
                                        )
                                    ) : (
                                        <Button variant="outlined" onClick={() => onOpenAssign(child)} sx={styles.assignBadge}>
                                            Assigner
                                        </Button>
                                    )}
                                </Box>
                            </Box>
                            <Box sx={styles.metaItem}>
                                <Typography variant="caption" color={colors.grey[300]}>Date d'inscription</Typography>
                                <Typography fontWeight="700" mt="6px">{child.inscriptionDate}</Typography>
                            </Box>
                        </Box>
                    </Box>

                    <Box sx={styles.stackedCard}>
                        <Typography variant="h6" fontWeight="700">Décision et archivage</Typography>
                        <Typography variant="body2" color={colors.grey[300]} mt="4px" mb="16px">
                            Prenez la décision administrative depuis cette carte, puis archivez l'inscription si nécessaire.
                        </Typography>
                        <Box display="flex" gap="10px" flexWrap="wrap">
                            <Button
                                variant={child.approval === "approved" ? "contained" : "outlined"}
                                onClick={() => onApprove(child)}
                                disabled={decisionLoading || child.approval === "approved"}
                                sx={child.approval === "approved" ? styles.approveButton : { ...styles.mutedButton, color: isDark ? colors.greenAccent[300] : "#166534", borderColor: isDark ? colors.greenAccent[400] : "#16a34a" }}
                            >
                                {decisionLoading && child.approval !== "approved" ? "Traitement..." : "Approuver"}
                            </Button>
                            <Button
                                variant={child.approval === "pending" ? "contained" : "outlined"}
                                onClick={() => onResetPending(child)}
                                disabled={decisionLoading || child.approval === "pending"}
                                sx={child.approval === "pending" ? styles.neutralButton : styles.mutedButton}
                            >
                                En attente
                            </Button>
                            <Button
                                variant={child.approval === "rejected" ? "contained" : "outlined"}
                                onClick={() => onReject(child)}
                                disabled={decisionLoading || child.approval === "rejected"}
                                sx={child.approval === "rejected" ? { ...styles.neutralButton, backgroundColor: colors.redAccent[500], "&:hover": { backgroundColor: colors.redAccent[400] } } : { ...styles.mutedButton, color: colors.redAccent[400], borderColor: colors.redAccent[400] }}
                            >
                                Rejeter
                            </Button>
                            <Button variant="outlined" onClick={() => onArchiveToggle(child)} disabled={decisionLoading} sx={styles.mutedButton}>
                                {child.is_archived ? "Désarchiver" : "Archiver"}
                            </Button>
                        </Box>
                    </Box>

                    <Box display="grid" gridTemplateColumns={{ xs: "1fr", lg: "1fr 1fr" }} gap="18px">
                        <Box sx={styles.stackedCard}>
                            <Box display="flex" justifyContent="space-between" alignItems={{ xs: "flex-start", md: "center" }} gap="12px" flexDirection={{ xs: "column", md: "row" }} mb="14px">
                                <Box>
                                    <Typography variant="h6" fontWeight="700">Dossier médical</Typography>
                                    <Typography variant="body2" color={colors.grey[300]} mt="4px">
                                        Fiche transmise lors de l'inscription.
                                    </Typography>
                                </Box>
                            </Box>
                            <Box ref={medicalDocRef} sx={styles.medicalPreview} className="medical-print-root">
                                <MedicalFormDocument
                                    form={showTemplate ? undefined : form}
                                    childName={child.name}
                                    parentName={child.parent}
                                    isTemplate={showTemplate}
                                />
                            </Box>
                            <Box mt="14px" display="flex" justifyContent="flex-end">
                                <Button onClick={onPrint} sx={{ color: isDark ? colors.blueAccent[300] : "#334155", textTransform: "none", fontWeight: 700 }}>
                                    Imprimer le dossier médical
                                </Button>
                            </Box>
                        </Box>

                        <Box sx={styles.stackedCard}>
                            <Typography variant="h6" fontWeight="700">Résumé IA</Typography>
                            <Typography variant="body2" color={colors.grey[300]} mt="4px" mb="14px">
                                {isApproved
                                    ? "La fiche est maintenant éditable. Modifiez puis sauvegardez les commentaires si nécessaire."
                                    : "Approuvez l'inscription pour générer et modifier la fiche de l'élève."}
                            </Typography>

                            {!isApproved ? (
                                <Box sx={styles.lockedPanel}>
                                    <Typography color={colors.grey[300]} maxWidth="320px">
                                        Approuvez l'inscription pour générer et modifier la fiche de l'élève.
                                    </Typography>
                                </Box>
                            ) : (
                                <Box display="flex" flexDirection="column" gap="16px">
                                    <Box sx={styles.aiBlock}>
                                        <Typography variant="caption" color={isDark ? colors.greenAccent[300] : "#166534"} fontWeight="700" mb="8px" display="block">
                                            Résumé diététique
                                        </Typography>
                                        <TextField
                                            fullWidth
                                            multiline
                                            minRows={6}
                                            value={dietary}
                                            onChange={(event) => onDietaryChange(event.target.value)}
                                            disabled={!aiEditMode}
                                            InputLabelProps={{ shrink: true }}
                                            sx={styles.floatingField}
                                        />
                                    </Box>
                                    <Box sx={styles.aiBlock}>
                                        <Typography variant="caption" color={isDark ? colors.blueAccent[300] : "#1d4ed8"} fontWeight="700" mb="8px" display="block">
                                            Résumé santé générale
                                        </Typography>
                                        <TextField
                                            fullWidth
                                            multiline
                                            minRows={6}
                                            value={health}
                                            onChange={(event) => onHealthChange(event.target.value)}
                                            disabled={!aiEditMode}
                                            InputLabelProps={{ shrink: true }}
                                            sx={styles.floatingField}
                                        />
                                    </Box>
                                    {aiEditMode && (
                                        <MealExceptionReviewBox
                                            title="Scanner les repas"
                                            description="Relancez le scan après modification pour recalculer les repas à risque de cet enfant."
                                            exceptions={mealExceptions}
                                            loading={mealScanLoading}
                                            onScan={onScanMeals}
                                            onToggle={onMealToggle}
                                            colors={colors}
                                            styles={styles}
                                            isDark={isDark}
                                        />
                                    )}
                                    <Box display="flex" justifyContent="flex-end" gap="10px" flexWrap="wrap">
                                        {!aiEditMode ? (
                                            <Button variant="outlined" onClick={onEditToggle} sx={styles.mutedButton}>
                                                Modifier la fiche
                                            </Button>
                                        ) : (
                                            <>
                                                <Button variant="outlined" onClick={onEditToggle} disabled={saving} sx={styles.mutedButton}>
                                                    Annuler
                                                </Button>
                                                <Button variant="contained" onClick={onSave} disabled={saving || (!dirty && !mealReviewDirty)} sx={styles.neutralButton}>
                                                    {saving ? "Sauvegarde..." : "Sauvegarder la fiche"}
                                                </Button>
                                            </>
                                        )}
                                    </Box>
                                </Box>
                            )}
                        </Box>
                    </Box>
                </Box>
            </DialogContent>
            <DialogActions sx={styles.dialogActions}>
                <Button onClick={onClose} sx={{ color: colors.grey[100] }}>Fermer</Button>
            </DialogActions>
        </Dialog>
    );
};

const Inscriptions = () => {
    const theme = useTheme();
    const colors = tokens(theme.palette.mode);
    const isDark = theme.palette.mode === "dark";
    const styles = getStyles(colors, isDark);

    const [inscriptionsList, setInscriptionsList] = useState([]);
    const [classesList, setClassesList] = useState([]);
    const [loading, setLoading] = useState(true);
    const [aiEnabled, setAiEnabled] = useState(true);
    const [inscriptionTab, setInscriptionTab] = useState("active");
    const [detailInscriptionId, setDetailInscriptionId] = useState(null);
    const [assignTargetId, setAssignTargetId] = useState(null);
    const [selectedClassId, setSelectedClassId] = useState("");
    const [classAssignError, setClassAssignError] = useState("");
    const [assignLoading, setAssignLoading] = useState(false);
    const [decisionLoading, setDecisionLoading] = useState(false);
    const [detailSaving, setDetailSaving] = useState(false);
    const [detailDietary, setDetailDietary] = useState("");
    const [detailHealth, setDetailHealth] = useState("");
    const [detailMealScanLoading, setDetailMealScanLoading] = useState(false);
    const [detailMealExceptions, setDetailMealExceptions] = useState(null);
    const [detailAiEditMode, setDetailAiEditMode] = useState(false);
    const [aiReviewContext, setAiReviewContext] = useState(null);
    const [aiReviewDietary, setAiReviewDietary] = useState("");
    const [aiReviewHealth, setAiReviewHealth] = useState("");
    const [aiReviewMealExceptions, setAiReviewMealExceptions] = useState(null);
    const [aiReviewMealScanLoading, setAiReviewMealScanLoading] = useState(false);
    const [aiReviewSaving, setAiReviewSaving] = useState(false);
    const [toast, setToast] = useState({ open: false, message: "", severity: "info" });
    const medicalDocRef = useRef(null);

    useEffect(() => {
        fetchInscriptions();
        fetchAiEnabled();
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, []);

    const mergedData = useMemo(() => (
        inscriptionsList.map((row) => {
            const inscriptionDate = row?.inscription_date || "";
            const parsedYear = inscriptionDate ? String(new Date(inscriptionDate).getFullYear()) : "";
            return {
                id: row?.id,
                inscriptionId: row?.id,
                childId: row?.child_id,
                name: row?.child_full_name || "Inconnu",
                age: row?.age ?? "-",
                parent: row?.parent?.full_name || "-",
                rawInscriptionDate: inscriptionDate,
                inscriptionDate: formatDate(inscriptionDate),
                inscriptionYear: parsedYear,
                approval: row?.status?.name || "pending",
                classId: row?.class?.id || null,
                inscriptionClass: row?.class?.name || "",
                inscriptionTypeId: row?.preferred_type?.id || null,
                inscriptionType: mapTypeLabel(row?.preferred_type?.name || row?.class?.type || ""),
                paymentMethod: mapPaymentMethod(row?.payment_method),
                totalAmount: formatCurrency(row?.total_amount),
                medicalApplication: row?.medical_file || null,
                dietary_comment: row?.dietary_comment || "",
                health_comment: row?.health_comment || "",
                is_archived: !!row?.is_archived,
                previousInscriptions: row?.previous_inscriptions_count || 0,
            };
        })
    ), [inscriptionsList]);

    const detailChild = useMemo(
        () => mergedData.find((row) => row.inscriptionId === detailInscriptionId) || null,
        [mergedData, detailInscriptionId]
    );

    const assignTargetChild = useMemo(
        () => mergedData.find((row) => row.inscriptionId === assignTargetId) || null,
        [mergedData, assignTargetId]
    );

    useEffect(() => {
        setDetailDietary(detailChild?.dietary_comment || "");
        setDetailHealth(detailChild?.health_comment || "");
        setDetailMealExceptions(null);
        setDetailMealScanLoading(false);
        setDetailAiEditMode(false);
    }, [detailChild?.inscriptionId, detailChild?.dietary_comment, detailChild?.health_comment]);

    const detailDirty = !!detailChild && (
        detailDietary !== (detailChild.dietary_comment || "") ||
        detailHealth !== (detailChild.health_comment || "")
    );

    const stats = useMemo(() => ({
        total: mergedData.length,
        approved: mergedData.filter((row) => row.approval === "approved").length,
        pending: mergedData.filter((row) => row.approval === "pending").length,
        rejected: mergedData.filter((row) => row.approval === "rejected").length,
        archived: mergedData.filter((row) => row.is_archived).length,
    }), [mergedData]);

    const activeRows = useMemo(() => mergedData.filter((row) => !row.is_archived), [mergedData]);
    const archivedRows = useMemo(() => mergedData.filter((row) => row.is_archived), [mergedData]);

    const classOptionsForAssign = useMemo(() => {
        if (!assignTargetChild) return [];
        const preferredTypeId = assignTargetChild.inscriptionTypeId ? Number(assignTargetChild.inscriptionTypeId) : null;
        const currentClassId = assignTargetChild.classId ? Number(assignTargetChild.classId) : null;
        return classesList
            .filter((schoolClass) => {
                const isNotArchived = !schoolClass.is_archived;
                const isPlanningActive = !schoolClass.planning_is_archived;
                const matchesType = preferredTypeId === null || Number(schoolClass?.type?.id) === preferredTypeId;
                const matchesPlanningWindow = isWithinPlanningMargin(
                    assignTargetChild.rawInscriptionDate,
                    schoolClass.planning_start_date,
                    schoolClass.planning_end_date,
                );
                return isNotArchived && isPlanningActive && matchesType && matchesPlanningWindow;
            })
            .map((schoolClass) => ({
                id: schoolClass.id,
                name: schoolClass.name,
                enrolled: Array.isArray(schoolClass.students) ? schoolClass.students.length : 0,
                capacity: schoolClass.capacity == null ? null : Number(schoolClass.capacity),
                isFull: schoolClass.capacity != null && Number(schoolClass.capacity) >= 0 && Array.isArray(schoolClass.students) && schoolClass.students.length >= Number(schoolClass.capacity) && Number(schoolClass.id) !== currentClassId,
            }));
    }, [classesList, assignTargetChild]);

    const showToast = (message, severity = "info") => {
        setToast({ open: true, message, severity });
    };

    const closeToast = (_, reason) => {
        if (reason === "clickaway") return;
        setToast((prev) => ({ ...prev, open: false }));
    };

    const closeAiReviewDialog = () => {
        if (aiReviewSaving) return;
        setAiReviewContext(null);
        setAiReviewDietary("");
        setAiReviewHealth("");
        setAiReviewMealExceptions(null);
        setAiReviewMealScanLoading(false);
    };

    const toggleMealExceptionChecked = (setState, index, checked) => {
        setState((prev) => Array.isArray(prev)
            ? prev.map((exception, exceptionIndex) => (
                exceptionIndex === index ? { ...exception, checked } : exception
            ))
            : prev);
    };

    const fetchMealExceptions = async (childId, dietaryComment, healthComment) => {
        const response = await api.post(`/admin/inscriptions/${childId}/scan-meals`, {
            dietary_comment: dietaryComment,
            health_comment: healthComment,
        });

        if (response.data?.success !== true) {
            throw new Error(response.data?.message || "Le scan des repas a échoué.");
        }

        const exceptions = Array.isArray(response.data?.exceptions) ? response.data.exceptions : [];
        return exceptions.map((exception) => ({ ...exception, checked: true }));
    };

    const saveMealExceptions = async (childId, mealExceptions) => {
        if (!childId || mealExceptions === null) return;

        const checkedExceptions = mealExceptions
            .filter((exception) => exception.checked !== false)
            .map((exception) => ({
                meal_id: exception.meal_id,
                reason: exception.reason,
            }));

        await api.post(`/admin/inscriptions/${childId}/save-food-exceptions`, {
            exceptions: checkedExceptions,
        });
    };

    const fetchAiEnabled = async () => {
        try {
            const response = await api.get("/admin/parameters");
            const data = response.data?.data || response.data || [];
            const arr = Array.isArray(data) ? data : [];
            const aiParam = arr.find((param) => param.name === "ai_enabled");
            const enabled = aiParam ? (aiParam.value === "true" || aiParam.value === "1") : false;
            setAiEnabled(enabled);
            return enabled;
        } catch (error) {
            console.error("Failed to fetch AI status:", error);
            return aiEnabled;
        }
    };

    const fetchInscriptions = async () => {
        try {
            setLoading(true);
            const response = await api.get("/admin/inscriptions");
            setInscriptionsList(Array.isArray(response.data?.data) ? response.data.data : []);
        } catch (error) {
            console.error("Failed to fetch inscriptions", error);
        } finally {
            setLoading(false);
        }
    };

    const loadClassesForAssign = async () => {
        try {
            const response = await api.get("/admin/classes");
            setClassesList(Array.isArray(response.data?.data) ? response.data.data : []);
        } catch (error) {
            console.error("Failed to load classes", error);
        }
    };

    const updateStatus = async (child, nextStatus, classId = null) => {
        if (!child?.inscriptionId) return { success: false, message: "Inscription introuvable." };
        try {
            const payload = { status: nextStatus };
            if (nextStatus === "approved" && classId) {
                payload.class_id = classId;
            } else if (nextStatus !== "approved") {
                payload.class_id = null;
            }
            await api.patch(`/admin/inscriptions/${child.inscriptionId}/status`, payload);
            return { success: true };
        } catch (error) {
            return { success: false, message: error?.response?.data?.message || "Échec de la mise à jour." };
        }
    };

    const openAssignDialog = async (child) => {
        setAssignTargetId(child.inscriptionId);
        setSelectedClassId(child.classId ? String(child.classId) : "");
        setClassAssignError("");
        await loadClassesForAssign();
    };

    const closeAssignDialog = () => {
        setAssignTargetId(null);
        setSelectedClassId("");
        setClassAssignError("");
    };

    const openDetailDialog = (row) => {
        setDetailInscriptionId(row.inscriptionId);
    };

    const closeDetailDialog = () => {
        if (detailSaving || decisionLoading) return;
        setDetailInscriptionId(null);
    };

    const handleSaveSummary = async () => {
        if (!detailChild?.childId) return;
        setDetailSaving(true);
        try {
            await api.put(`/admin/inscriptions/${detailChild.childId}/ai-comments`, {
                dietary_comment: detailDietary,
                health_comment: detailHealth,
            });
            await saveMealExceptions(detailChild.childId, detailMealExceptions);
            await fetchInscriptions();
            setDetailMealExceptions(null);
            setDetailAiEditMode(false);
            showToast("La fiche IA a été sauvegardée.", "success");
        } catch (error) {
            window.alert(error?.response?.data?.message || "Erreur lors de la sauvegarde de la fiche.");
        } finally {
            setDetailSaving(false);
        }
    };

    const handleDetailScanMeals = async () => {
        if (!detailChild?.childId) return;
        setDetailMealScanLoading(true);
        try {
            const exceptions = await fetchMealExceptions(detailChild.childId, detailDietary, detailHealth);
            setDetailMealExceptions(exceptions);
            if (exceptions.length === 0) {
                showToast("Aucun repas problématique détecté pour cet enfant.", "success");
            }
        } catch (error) {
            showToast(error?.response?.data?.message || error.message || "Erreur lors du scan des repas.", "error");
        } finally {
            setDetailMealScanLoading(false);
        }
    };

    const handlePrintMedical = () => {
        if (!medicalDocRef.current || !detailChild) return;

        const printableHtml = medicalDocRef.current.innerHTML;
        const stylesHtml = Array.from(document.querySelectorAll('style, link[rel="stylesheet"]'))
            .map((node) => node.outerHTML)
            .join("\n");

        const printFrame = document.createElement("iframe");
        printFrame.style.position = "fixed";
        printFrame.style.left = "-2000px";
        printFrame.style.top = "0";
        printFrame.style.width = "1200px";
        printFrame.style.height = "1600px";
        printFrame.style.border = "0";
        printFrame.style.opacity = "0";
        printFrame.style.pointerEvents = "none";
        printFrame.setAttribute("aria-hidden", "true");
        document.body.appendChild(printFrame);

        const frameWindow = printFrame.contentWindow;
        if (!frameWindow) {
            printFrame.remove();
            window.alert("Impossible d'ouvrir l'impression.");
            return;
        }

        frameWindow.document.open();
        frameWindow.document.write(`
            <!DOCTYPE html>
            <html lang="fr">
                <head>
                    <meta charset="utf-8" />
                    <title></title>
                    ${stylesHtml}
                    <style>
                        html, body {
                            margin: 0;
                            padding: 0;
                            background: #ffffff;
                            width: 100%;
                        }

                        body {
                            padding: 16px;
                            font-family: Tahoma, Arial, sans-serif;
                            color: #000;
                        }

                        .medical-print-shell {
                            max-width: 1100px;
                            margin: 0 auto;
                        }

                        .medical-print-root,
                        .medical-print-root * {
                            visibility: visible !important;
                        }

                        @media print {
                            body * {
                                visibility: hidden;
                            }

                            html, body {
                                background: #ffffff !important;
                            }

                            body {
                                padding: 0;
                            }

                            .medical-print-root,
                            .medical-print-root * {
                                visibility: visible !important;
                            }

                            .medical-print-root {
                                position: absolute;
                                left: 0;
                                top: 0;
                                width: 100%;
                            }

                            .medical-print-shell {
                                max-width: none;
                                margin: 0;
                            }

                            .mf-cover,
                            .mf-page {
                                break-after: page;
                                page-break-after: always;
                                break-inside: avoid-page;
                                page-break-inside: avoid;
                            }

                            .mf-page:last-of-type,
                            .mf-cover:last-of-type {
                                break-after: auto;
                                page-break-after: auto;
                            }

                            .mf-sign-strip {
                                display: grid !important;
                                grid-template-columns: 1.1fr 0.9fr 1.1fr !important;
                                gap: 20px !important;
                            }
                        }

                        @page {
                            size: A4 portrait;
                            margin: 8mm;
                        }
                    </style>
                </head>
                <body>
                    <div class="medical-print-root medical-print-shell">${printableHtml}</div>
                </body>
            </html>
        `);
        frameWindow.document.close();

        let didPrint = false;
        const cleanup = () => {
            window.removeEventListener("afterprint", cleanup);
            setTimeout(() => {
                printFrame.remove();
            }, 100);
        };

        const runPrint = () => {
            if (didPrint) return;
            didPrint = true;
            window.addEventListener("afterprint", cleanup, { once: true });
            frameWindow.focus();
            frameWindow.print();
            setTimeout(cleanup, 1500);
        };

        printFrame.onload = () => setTimeout(runPrint, 350);
    };

    const handleApproveFromDialog = async (child) => {
        await openAssignDialog(child);
    };

    const clearAiComments = async (childId) => {
        if (!childId) return;
        await api.put(`/admin/inscriptions/${childId}/ai-comments`, {
            dietary_comment: "",
            health_comment: "",
        });
    };

    const clearMealExceptions = async (childId) => {
        if (!childId) return;
        await api.post(`/admin/inscriptions/${childId}/save-food-exceptions`, {
            exceptions: [],
        });
    };

    const handleRejectFromDialog = async (child) => {
        if (!window.confirm("Êtes-vous sûr de vouloir rejeter cette inscription ?")) return;
        setDecisionLoading(true);
        try {
            const result = await updateStatus(child, "rejected");
            if (!result.success) {
                window.alert(result.message || "Échec.");
                return;
            }
            await clearAiComments(child.childId);
            await clearMealExceptions(child.childId);
            setDetailDietary("");
            setDetailHealth("");
            setDetailMealExceptions(null);
            await fetchInscriptions();
            showToast("L'inscription a été rejetée.", "warning");
        } catch (error) {
            window.alert(error?.response?.data?.message || "Erreur lors de la réinitialisation de l'inscription.");
        } finally {
            setDecisionLoading(false);
        }
    };

    const handleResetPending = async (child) => {
        setDecisionLoading(true);
        try {
            const result = await updateStatus(child, "pending");
            if (!result.success) {
                window.alert(result.message || "Échec.");
                return;
            }
            await clearAiComments(child.childId);
            await clearMealExceptions(child.childId);
            setDetailDietary("");
            setDetailHealth("");
            setDetailMealExceptions(null);
            await fetchInscriptions();
            showToast("L'inscription a été remise en attente.", "info");
        } catch (error) {
            window.alert(error?.response?.data?.message || "Erreur lors de la réinitialisation de l'inscription.");
        } finally {
            setDecisionLoading(false);
        }
    };

    const runApprovalFlow = async (child, classId) => {
        const medicalForm = child.medicalApplication;
        const hasMedicalForm = medicalForm && typeof medicalForm === "object" && Object.keys(medicalForm).length > 0;
        let nextDietary = child.dietary_comment || "";
        let nextHealth = child.health_comment || "";
        const aiCurrentlyEnabled = await fetchAiEnabled();

        if (aiCurrentlyEnabled && hasMedicalForm && child.childId) {
            try {
                const response = await api.post(`/admin/inscriptions/${child.childId}/rescan-medical`, { save_to_db: false });
                if (response.data?.success !== true) {
                    const aiError = new Error(response.data?.message || "Le module IA a échoué pendant l'approbation.");
                    aiError.code = "AI_APPROVAL_FAILED";
                    throw aiError;
                }
                nextDietary = response.data?.dietary_comment || "✅ Aucune restriction alimentaire détectée.";
                nextHealth = response.data?.health_comment || "✅ Aucun problème de santé notable détecté.";

                const mealExceptions = await fetchMealExceptions(child.childId, nextDietary, nextHealth);
                setAiReviewContext({ child, classId });
                setAiReviewDietary(nextDietary);
                setAiReviewHealth(nextHealth);
                setAiReviewMealExceptions(mealExceptions);
                return { success: true, reviewRequired: true };
            } catch (error) {
                const message = error?.response?.data?.message || "Le service IA a échoué pendant l'approbation.";
                const aiError = new Error(message);
                aiError.code = "AI_APPROVAL_FAILED";
                throw aiError;
            }
        }

        const result = await updateStatus(child, "approved", classId);
        if (!result.success) {
            return result;
        }

        setDetailDietary(nextDietary);
        setDetailHealth(nextHealth);
        return { success: true, reviewRequired: false };
    };

    const handleAiReviewScanMeals = async () => {
        if (!aiReviewContext?.child?.childId) return;
        setAiReviewMealScanLoading(true);
        try {
            const exceptions = await fetchMealExceptions(aiReviewContext.child.childId, aiReviewDietary, aiReviewHealth);
            setAiReviewMealExceptions(exceptions);
            if (exceptions.length === 0) {
                showToast("Aucun repas problématique détecté pour cet enfant.", "success");
            }
        } catch (error) {
            showToast(error?.response?.data?.message || error.message || "Erreur lors du scan des repas.", "error");
        } finally {
            setAiReviewMealScanLoading(false);
        }
    };

    const handleConfirmApprovalReview = async () => {
        if (!aiReviewContext?.child?.childId) return;
        setAiReviewSaving(true);
        try {
            await api.put(`/admin/inscriptions/${aiReviewContext.child.childId}/ai-comments`, {
                dietary_comment: aiReviewDietary,
                health_comment: aiReviewHealth,
            });
            await saveMealExceptions(aiReviewContext.child.childId, aiReviewMealExceptions);

            const result = await updateStatus(aiReviewContext.child, "approved", aiReviewContext.classId);
            if (!result.success) {
                showToast(result.message || "Erreur lors de l'approbation.", "error");
                return;
            }

            await fetchInscriptions();
            closeAiReviewDialog();
            setDetailDietary(aiReviewDietary);
            setDetailHealth(aiReviewHealth);
            showToast("L'inscription a été approuvée.", "success");
        } catch (error) {
            showToast(error?.response?.data?.message || error.message || "Erreur lors de l'approbation.", "error");
        } finally {
            setAiReviewSaving(false);
        }
    };

    const handleConfirmAssign = async () => {
        if (!assignTargetChild) return;
        if (!selectedClassId) {
            setClassAssignError("Veuillez sélectionner une classe.");
            return;
        }

        setAssignLoading(true);
        try {
            const result = await runApprovalFlow(assignTargetChild, Number(selectedClassId));
            if (!result.success) {
                setClassAssignError(result.message || "Erreur lors de l'approbation.");
                return;
            }
            if (result.reviewRequired) {
                closeAssignDialog();
                showToast("Analyse IA terminée. Vérifiez les repas à risque avant de confirmer.", "info");
                return;
            }
            await fetchInscriptions();
            closeAssignDialog();
            showToast("L'inscription a été approuvée.", "success");
        } catch (error) {
            const errorMessage = error?.response?.data?.message || error.message || "Erreur lors du traitement.";
            if (error?.code === "AI_APPROVAL_FAILED") {
                showToast(`${errorMessage} Pour bypass ce blocage, désactivez le paramètre IA dans l'interface Paramètres (mettre ai_enabled à false).`, "error");
                setClassAssignError("");
                return;
            }
            setClassAssignError(errorMessage);
        } finally {
            setAssignLoading(false);
        }
    };

    const handleToggleArchiveClick = async (inscription) => {
        setDecisionLoading(true);
        try {
            await api.patch(`/admin/inscriptions/${inscription.inscriptionId}/toggle-archive`);
            setInscriptionsList((prev) => prev.map((row) => (
                row.id === inscription.inscriptionId ? { ...row, is_archived: !row.is_archived } : row
            )));
            showToast(inscription.is_archived ? "L'inscription a été désarchivée." : "L'inscription a été archivée.", inscription.is_archived ? "success" : "warning");
        } catch (error) {
            window.alert(error.response?.data?.message || "Erreur lors de l'archivage.");
        } finally {
            setDecisionLoading(false);
        }
    };

    const columns = [
        {
            field: "name",
            headerName: "Nom",
            flex: 1.1,
            minWidth: 190,
            cellClassName: "name-column--cell",
            renderCell: ({ row }) => (
                <Box display="flex" flexDirection="column" justifyContent="center" minWidth={0} width="100%">
                    <Typography fontWeight="700" color={colors.grey[100]} noWrap>
                        {row.name}
                    </Typography>
                    <Typography variant="caption" color={colors.grey[300]} noWrap>
                        {row.parent}
                    </Typography>
                </Box>
            ),
        },
        { field: "age", headerName: "Âge", flex: 0.45, minWidth: 70, headerAlign: "center", align: "center" },
        {
            field: "previousInscriptions",
            headerName: "Hist.",
            flex: 0.55,
            minWidth: 90,
            headerAlign: "center",
            align: "center",
            renderCell: ({ row }) => row.previousInscriptions > 0
                ? <Typography fontWeight="700" color={colors.redAccent[400]}>{row.previousInscriptions}</Typography>
                : <Typography color={colors.grey[300]}>{row.previousInscriptions}</Typography>,
        },
        { field: "inscriptionType", headerName: "Type", flex: 0.75, minWidth: 120 },
        {
            field: "inscriptionClass",
            headerName: "Classe",
            flex: 1,
            minWidth: 160,
            sortable: false,
            renderCell: ({ row }) => {
                if (row.approval === "approved") {
                    return (
                        row.inscriptionClass ? (
                            <Chip
                                label={row.inscriptionClass}
                                size="small"
                                sx={{
                                    backgroundColor: isDark ? "rgba(34,197,94,0.18)" : "rgba(22,163,74,0.12)",
                                    color: isDark ? colors.greenAccent[300] : "#166534",
                                    border: `1px solid ${isDark ? "rgba(34,197,94,0.22)" : "rgba(22,163,74,0.18)"}`,
                                    fontWeight: 700,
                                }}
                            />
                        ) : (
                            <Box component="span" sx={styles.infoBadge}>Non assignée</Box>
                        )
                    );
                }

                return (
                    <Box component="span" sx={styles.assignBadge}>
                        Assigner
                    </Box>
                );
            },
        },
        { field: "paymentMethod", headerName: "Paiement", flex: 0.9, minWidth: 150 },
        { field: "totalAmount", headerName: "Montant", flex: 0.8, minWidth: 130 },
        {
            field: "approval",
            headerName: "Statut",
            flex: 0.8,
            minWidth: 130,
            renderCell: ({ row }) => <StatusBadge status={row.approval} styles={styles} />,
        },
        { field: "inscriptionDate", headerName: "Date d'inscription", flex: 0.9, minWidth: 140 },
        {
            field: "more",
            headerName: "Plus",
            flex: 0.35,
            minWidth: 90,
            sortable: false,
            filterable: false,
            disableExport: true,
            headerAlign: "right",
            align: "right",
            renderCell: ({ row }) => (
                <Box display="flex" justifyContent="flex-end" width="100%">
                    <Tooltip title="Plus">
                        <IconButton size="small" onClick={() => openDetailDialog(row)} sx={{ color: isDark ? colors.grey[200] : "#475569", backgroundColor: isDark ? "rgba(148,163,184,0.14)" : "rgba(226,232,240,0.8)", "&:hover": { backgroundColor: isDark ? "rgba(148,163,184,0.22)" : "rgba(203,213,225,0.9)" } }}>
                            <MoreVertOutlinedIcon fontSize="small" />
                        </IconButton>
                    </Tooltip>
                </Box>
            ),
        },
    ];

    return (
        <Box m="20px">
            <Header title="INSCRIPTIONS" />

            {!aiEnabled && <AiDisabledBanner colors={colors} isDark={isDark} />}

            <StatsCards stats={stats} colors={colors} styles={styles} isDark={isDark} />

            <Box display="flex" justifyContent="space-between" alignItems={{ xs: "flex-start", md: "center" }} flexDirection={{ xs: "column", md: "row" }} gap="12px" mb="14px">
                <Box>
                    <Typography variant="h5" fontWeight="bold" color={colors.grey[100]}>
                        Gestion des inscriptions
                    </Typography>
                    <Typography variant="body2" color={colors.grey[300]} mt="4px">
                        Ouvrez la fiche d&apos;un élève pour gérer les décisions, le dossier médical et le résumé IA sans surcharger le tableau.
                    </Typography>
                </Box>
                <Tabs
                    value={inscriptionTab}
                    onChange={(_, value) => setInscriptionTab(value)}
                    textColor="inherit"
                    indicatorColor="secondary"
                    sx={{
                        minHeight: 42,
                        "& .MuiTabs-flexContainer": { gap: "8px" },
                        "& .MuiTab-root": {
                            minHeight: 42,
                            borderRadius: "999px",
                            textTransform: "none",
                            fontWeight: 700,
                            color: colors.grey[300],
                            backgroundColor: colors.primary[400],
                            border: `1px solid ${colors.primary[500]}`,
                        },
                        "& .MuiTab-root.Mui-selected": {
                            color: isDark ? "#ffffff" : "#0f172a",
                            backgroundColor: isDark ? "#475569" : "#cbd5e1",
                        },
                        "& .MuiTabs-indicator": { display: "none" },
                    }}
                >
                    <Tab value="active" label={`Actives (${activeRows.length})`} />
                    <Tab value="archived" label={`Archivées (${archivedRows.length})`} />
                </Tabs>
            </Box>

            <Box height="66vh" sx={styles.gridContainer}>
                <DataGrid
                    loading={loading}
                    rows={inscriptionTab === "active" ? activeRows : archivedRows}
                    columns={columns}
                    pageSize={10}
                    rowsPerPageOptions={[10, 50, 100]}
                    disableSelectionOnClick
                    components={{ Toolbar: InscriptionsGridToolbar }}
                    componentsProps={{ toolbar: { colors, isDark } }}
                    initialState={{ columns: { columnVisibilityModel: { inscriptionYear: false } } }}
                />
            </Box>

            <ClassAssignDialog
                open={!!assignTargetChild}
                child={assignTargetChild}
                selectedClassId={selectedClassId}
                onClassChange={setSelectedClassId}
                classOptions={classOptionsForAssign}
                error={classAssignError}
                loading={assignLoading}
                onConfirm={handleConfirmAssign}
                onClose={closeAssignDialog}
                colors={colors}
                styles={styles}
            />

            <InscriptionDetailDialog
                open={!!detailChild}
                child={detailChild}
                dietary={detailDietary}
                health={detailHealth}
                dirty={detailDirty}
                saving={detailSaving}
                aiEditMode={detailAiEditMode}
                mealScanLoading={detailMealScanLoading}
                mealExceptions={detailMealExceptions}
                mealReviewDirty={detailMealExceptions !== null}
                decisionLoading={decisionLoading}
                onDietaryChange={setDetailDietary}
                onHealthChange={setDetailHealth}
                onScanMeals={handleDetailScanMeals}
                onMealToggle={(index, checked) => toggleMealExceptionChecked(setDetailMealExceptions, index, checked)}
                onSave={handleSaveSummary}
                onEditToggle={() => {
                    if (detailAiEditMode) {
                        setDetailDietary(detailChild?.dietary_comment || "");
                        setDetailHealth(detailChild?.health_comment || "");
                        setDetailMealExceptions(null);
                    }
                    setDetailAiEditMode((prev) => !prev);
                }}
                onPrint={handlePrintMedical}
                onClose={closeDetailDialog}
                onApprove={handleApproveFromDialog}
                onReject={handleRejectFromDialog}
                onResetPending={handleResetPending}
                onArchiveToggle={handleToggleArchiveClick}
                onOpenAssign={openAssignDialog}
                colors={colors}
                styles={styles}
                isDark={isDark}
                medicalDocRef={medicalDocRef}
            />

            <ApprovalReviewDialog
                open={!!aiReviewContext}
                child={aiReviewContext}
                dietary={aiReviewDietary}
                health={aiReviewHealth}
                mealExceptions={aiReviewMealExceptions}
                mealScanLoading={aiReviewMealScanLoading}
                saving={aiReviewSaving}
                onDietaryChange={setAiReviewDietary}
                onHealthChange={setAiReviewHealth}
                onScanMeals={handleAiReviewScanMeals}
                onMealToggle={(index, checked) => toggleMealExceptionChecked(setAiReviewMealExceptions, index, checked)}
                onConfirm={handleConfirmApprovalReview}
                onClose={closeAiReviewDialog}
                colors={colors}
                styles={styles}
                isDark={isDark}
            />

            <Portal>
                <Snackbar
                    open={toast.open}
                    autoHideDuration={5000}
                    onClose={closeToast}
                    anchorOrigin={{ vertical: "top", horizontal: "right" }}
                    sx={{ zIndex: 2001 }}
                >
                    <Alert onClose={closeToast} severity={toast.severity} variant="outlined" sx={{ width: "100%", maxWidth: "420px", alignItems: "center", borderRadius: "14px", boxShadow: "0 12px 28px rgba(15,23,42,0.12)", backgroundColor: isDark ? "rgba(17,24,39,0.96)" : "rgba(255,250,242,0.98)", color: isDark ? colors.grey[100] : "#3f2a12", borderColor: "rgba(245,158,11,0.35)" }}>
                        {toast.message}
                    </Alert>
                </Snackbar>
            </Portal>
        </Box>
    );
};

export default Inscriptions;
