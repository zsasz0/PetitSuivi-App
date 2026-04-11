/**
 * @file index.jsx
 * @description Teacher Account Management Interface.
 *
 * PURPOSE:
 * Provides a full-featured management panel for teacher accounts. Admins can
 * add new teachers, edit their details (name, email, password), archive or
 * reactivate them, and optionally send login credentials by email. The interface
 * also cross-references class assignments and today's activity schedule to
 * derive each teacher's real-time status (active in class, available, or archived).
 *
 * PROPS/STATE:
 * - `teachers`: Master list of teacher records mapped with real-time status.
 * - `loading`: Boolean marking API fetch state.
 * - `stats`: Derived object containing { total, active, available, archived }.
 * - Form States: Separate states for Add, Edit, and Delete workflows including validation dictionaries.
 *
 * API ENDPOINTS:
 * - GET `/admin/teachers`: Fetches all teacher accounts to populate the master grid.
 * - GET `/admin/classes`: Fetches all academic classes to cross-reference teacher assignments.
 * - GET `/admin/activities/by-date/{date}`: Fetches today's activities to check which teachers are actively teaching.
 * - POST `/admin/teachers`: Registers a new teacher account and optionally emails credentials.
 * - PUT `/admin/teachers/{cin}`: Updates a teacher's account details.
 * - PATCH `/admin/teachers/{cin}/toggle-archive`: Toggles the `is_archived` status of the teacher account.
 * - DELETE `/admin/teachers/{cin}`: Permanently removes a teacher account.
 */

import { Box, Button, Typography, Dialog, DialogTitle, DialogContent, DialogContentText, DialogActions, TextField, FormControlLabel, Switch, Tabs, Tab, IconButton, Tooltip, Snackbar, Alert, Menu, MenuItem } from "@mui/material";
import { DataGrid, GridToolbarContainer, GridToolbarFilterButton } from "@mui/x-data-grid";
import { tokens } from "../../theme";
import Header from "../../components/Header";
import { useTheme } from "@mui/material";
import { useEffect, useState, useMemo } from "react";
import api from "../../api/axios";
import { validateTeacherForm } from "../../utils/validation";
import SchoolOutlinedIcon from "@mui/icons-material/SchoolOutlined";
import BoltOutlinedIcon from "@mui/icons-material/BoltOutlined";
import PersonOutlineIcon from "@mui/icons-material/PersonOutline";
import ArchiveOutlinedIcon from "@mui/icons-material/ArchiveOutlined";
import UnarchiveOutlinedIcon from "@mui/icons-material/UnarchiveOutlined";
import EditOutlinedIcon from "@mui/icons-material/EditOutlined";
import DeleteOutlineIcon from "@mui/icons-material/DeleteOutline";
import MoreVertOutlinedIcon from "@mui/icons-material/MoreVertOutlined";
import PersonAddAlt1OutlinedIcon from "@mui/icons-material/PersonAddAlt1Outlined";

// ==========================================
// STYLE HELPERS
// ==========================================
const getStyles = (colors, isDark) => ({
    statCard: {
        backgroundColor: colors.primary[400],
        display: "flex",
        alignItems: "center",
        gap: "14px",
        p: "16px 18px",
        borderRadius: "14px",
        border: `1px solid ${colors.primary[500]}`,
        boxShadow: `0px 10px 24px rgba(0, 0, 0, 0.08)`
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
        "& .MuiCheckbox-root": { color: `${colors.greenAccent[200]} !important` },
        "& .MuiDataGrid-toolbarContainer": {
            padding: "12px 14px",
            borderBottom: `1px solid ${colors.primary[500]}`,
            gap: "8px",
            backgroundColor: isDark ? "rgba(51, 65, 85, 0.24)" : "rgba(238, 242, 247, 0.88)",
        },
        "& .MuiDataGrid-toolbarContainer .MuiButton-text": { color: `${isDark ? colors.grey[100] : "#0f172a"} !important` },
        "& .MuiDataGrid-cell:focus, & .MuiDataGrid-columnHeader:focus": { outline: "none" },
        "& .MuiDataGrid-row:last-of-type .MuiDataGrid-cell": { borderBottom: "none" },
    },
    dialogPaper: {
        backgroundColor: colors.primary[400],
        color: colors.grey[100],
        borderRadius: "12px",
        boxShadow: "0px 0px 15px rgba(0,0,0,0.5)"
    },
    formCard: {
        backgroundColor: isDark ? colors.primary[500] : "rgba(255,255,255,0.98)",
        border: `1px solid ${isDark ? colors.primary[600] : "rgba(148, 163, 184, 0.22)"}`,
        borderRadius: "16px",
        padding: "18px",
        boxShadow: isDark ? "0 12px 28px rgba(0,0,0,0.12)" : "0 14px 32px rgba(15,23,42,0.08)"
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
            marginLeft: 0,
        },
    },
    dialogTitle: {
        fontWeight: "bold",
        fontSize: "1.2rem",
        borderBottom: `1px solid ${colors.primary[500]}`
    },
    dialogActions: {
        p: 2,
        borderTop: `1px solid ${colors.primary[500]}`
    },
    compactMenuPaper: {
        backgroundColor: colors.primary[400],
        color: colors.grey[100],
        borderRadius: "14px",
        border: `1px solid ${colors.primary[500]}`,
        boxShadow: "0 16px 32px rgba(15,23,42,0.18)",
    }
});

const getTeacherStatusMeta = (teacher, colors, isDark) => {
    if (teacher.is_archived) {
        return {
            label: "Archivé",
            dotColor: isDark ? colors.grey[400] : "#94a3b8",
            textColor: colors.grey[300],
        };
    }

    if (teacher.status === "En classe") {
        return {
            label: "Actif",
            dotColor: isDark ? colors.greenAccent[400] : "#16a34a",
            textColor: isDark ? colors.greenAccent[300] : "#166534",
        };
    }

    return null;
};

const TeacherGridToolbar = ({ colors, isDark }) => (
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

// ==========================================
// SUB-COMPONENTS
// ==========================================

const StatsCards = ({ stats, colors, styles, isDark }) => (
    <Box display="grid" gridTemplateColumns={{ xs: "1fr", sm: "repeat(2, 1fr)", xl: "repeat(4, 1fr)" }} gap="14px" mb="20px">
        <Box sx={styles.statCard}>
            <Box sx={{ ...styles.statIcon, background: isDark ? "rgba(134, 239, 172, 0.14)" : "rgba(22, 163, 74, 0.12)", color: isDark ? colors.greenAccent[300] : "#166534" }}>
                <SchoolOutlinedIcon />
            </Box>
            <Box minWidth={0}>
                <Typography variant="body2" color={colors.grey[300]}>Total enseignants</Typography>
                <Typography variant="h4" fontWeight="bold" color={colors.grey[100]} mt="4px">{stats.total}</Typography>
            </Box>
        </Box>
        <Box sx={styles.statCard}>
            <Box sx={{ ...styles.statIcon, background: isDark ? "rgba(96, 165, 250, 0.14)" : "rgba(37, 99, 235, 0.12)", color: isDark ? colors.blueAccent[300] : "#1d4ed8" }}>
                <BoltOutlinedIcon />
            </Box>
            <Box minWidth={0}>
                <Typography variant="body2" color={colors.grey[300]}>Actifs aujourd&apos;hui</Typography>
                <Typography variant="h4" fontWeight="bold" color={colors.grey[100]} mt="4px">{stats.active}</Typography>
            </Box>
        </Box>
        <Box sx={styles.statCard}>
            <Box sx={{ ...styles.statIcon, background: isDark ? "rgba(148, 163, 184, 0.14)" : "rgba(100, 116, 139, 0.12)", color: isDark ? colors.grey[200] : "#475569" }}>
                <PersonOutlineIcon />
            </Box>
            <Box minWidth={0}>
                <Typography variant="body2" color={colors.grey[300]}>Disponibles</Typography>
                <Typography variant="h4" fontWeight="bold" color={colors.grey[100]} mt="4px">{stats.available}</Typography>
            </Box>
        </Box>
        <Box sx={styles.statCard}>
            <Box sx={{ ...styles.statIcon, background: isDark ? "rgba(148, 163, 184, 0.14)" : "rgba(148, 163, 184, 0.14)", color: isDark ? colors.grey[300] : "#64748b" }}>
                <ArchiveOutlinedIcon />
            </Box>
            <Box minWidth={0}>
                <Typography variant="body2" color={colors.grey[300]}>Archivés</Typography>
                <Typography variant="h4" fontWeight="bold" color={colors.grey[100]} mt="4px">{stats.archived}</Typography>
            </Box>
        </Box>
    </Box>
);

const TeacherDataGrid = ({ teachers, loading, columns, styles, colors, tab, onTabChange, onAddClick, isDark }) => {
    const activeTeachers = teachers.filter((t) => !t.is_archived);
    const archivedTeachers = teachers.filter((t) => t.is_archived);
    const visibleTeachers = tab === "active" ? activeTeachers : archivedTeachers;

    return (
        <Box>
            <Box display="flex" justifyContent="space-between" alignItems={{ xs: "flex-start", md: "center" }} flexDirection={{ xs: "column", md: "row" }} gap="12px" mb="14px">
                <Box>
                    <Typography variant="h5" fontWeight="bold" color={colors.grey[100]}>
                        Gestion des enseignants
                    </Typography>
                    <Typography variant="body2" color={colors.grey[300]} mt="4px">
                        Consultez un seul tableau et basculez entre les comptes actifs et archivés.
                    </Typography>
                </Box>
                <Box display="flex" alignItems="center" gap="10px" flexWrap="wrap">
                    <Tabs
                        value={tab}
                        onChange={onTabChange}
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
                        <Tab value="active" label={`Actifs (${activeTeachers.length})`} />
                        <Tab value="archived" label={`Archivés (${archivedTeachers.length})`} />
                    </Tabs>
                    <Button
                        variant="contained"
                        startIcon={<PersonAddAlt1OutlinedIcon />}
                        onClick={onAddClick}
                        sx={{
                            minHeight: 42,
                            borderRadius: "999px",
                            px: "16px",
                            backgroundColor: isDark ? "#475569" : "#334155",
                            color: "#ffffff",
                            fontWeight: 700,
                            textTransform: "none",
                            boxShadow: "none",
                            "&:hover": { backgroundColor: isDark ? "#64748b" : "#475569", boxShadow: "none" },
                        }}
                    >
                        Ajouter un enseignant
                    </Button>
                </Box>
            </Box>

            <Box height="62vh" sx={styles.gridContainer}>
                <DataGrid
                    loading={loading}
                    rows={visibleTeachers}
                    columns={columns}
                    rowHeight={72}
                    pageSize={10}
                    rowsPerPageOptions={[10, 50, 100]}
                    disableSelectionOnClick
                    components={{ Toolbar: TeacherGridToolbar }}
                    componentsProps={{ toolbar: { colors, isDark } }}
                />
            </Box>
        </Box>
    );
};

const AddTeacherDialog = ({ 
    open, onClose, formData, errors, formError, saving, showPassword, sendCredentials,
    onChange, onSubmit, onTogglePassword, onGeneratePassword, onToggleSendCredentials, styles, colors, isDark 
}) => (
    <Dialog open={open} onClose={onClose} fullWidth maxWidth="md" PaperProps={{ sx: styles.dialogPaper }}>
        <DialogTitle sx={styles.dialogTitle}>Ajouter un nouvel enseignant</DialogTitle>
        <form onSubmit={onSubmit}>
            <DialogContent sx={{ mt: 2, display: "flex", flexDirection: "column", gap: "18px" }}>
                <Box sx={styles.formCard}>
                    <Typography variant="body2" color={colors.grey[300]} mb="16px">
                        Renseignez les informations essentielles de l&apos;enseignant. Les libellés restent visibles pendant la saisie.
                    </Typography>
                    {formError && <Typography color={colors.redAccent[500]} textAlign="center" fontWeight="500" mb="16px">{formError}</Typography>}
                    <Box display="grid" gridTemplateColumns={{ xs: "1fr", md: "repeat(2, minmax(0, 1fr))" }} gap="16px">
                        <TextField variant="outlined" label="Prénom" name="firstName" value={formData.firstName} onChange={onChange} error={!!errors.firstName} helperText={errors.firstName} InputLabelProps={{ shrink: true }} sx={styles.floatingField} fullWidth required />
                        <TextField variant="outlined" label="Nom" name="lastName" value={formData.lastName} onChange={onChange} error={!!errors.lastName} helperText={errors.lastName} InputLabelProps={{ shrink: true }} sx={styles.floatingField} fullWidth required />
                        <TextField variant="outlined" label="CIN" name="cin" value={formData.cin} onChange={onChange} error={!!errors.cin} helperText={errors.cin} InputLabelProps={{ shrink: true }} sx={styles.floatingField} fullWidth required />
                        <TextField variant="outlined" label="Téléphone" name="phone" value={formData.phone} onChange={onChange} error={!!errors.phone} helperText={errors.phone} InputLabelProps={{ shrink: true }} sx={styles.floatingField} fullWidth required />
                        <Box gridColumn={{ xs: "span 1", md: "span 2" }}>
                            <TextField variant="outlined" label="Email" name="email" type="email" value={formData.email} onChange={onChange} error={!!errors.email} helperText={errors.email} InputLabelProps={{ shrink: true }} sx={styles.floatingField} fullWidth required />
                        </Box>
                        <TextField variant="outlined" label="Date de naissance" name="birthdate" type="date" InputLabelProps={{ shrink: true }} value={formData.birthdate} onChange={onChange} error={!!errors.birthdate} helperText={errors.birthdate} sx={styles.floatingField} fullWidth required />
                        <TextField variant="outlined" label="Adresse" name="adresse" value={formData.adresse} onChange={onChange} error={!!errors.adresse} helperText={errors.adresse} InputLabelProps={{ shrink: true }} sx={styles.floatingField} fullWidth required />
                    </Box>
                    <Box display="grid" gridTemplateColumns={{ xs: "1fr", md: "repeat(2, minmax(0, 1fr))" }} gap="16px" mt="16px">
                        <TextField variant="outlined" label="Mot de passe" name="password" type={showPassword ? "text" : "password"} value={formData.password} onChange={onChange} InputLabelProps={{ shrink: true }} sx={styles.floatingField} fullWidth required />
                        <TextField variant="outlined" label="Confirmer le mot de passe" name="password_confirmation" type={showPassword ? "text" : "password"} value={formData.password_confirmation} onChange={onChange} InputLabelProps={{ shrink: true }} sx={styles.floatingField} fullWidth required />
                    </Box>
                    <Box display="flex" gap="8px" flexWrap="wrap" mt="16px">
                        <Button type="button" variant="outlined" sx={{ height: "44px", borderColor: colors.grey[500], color: colors.grey[100] }} onClick={onTogglePassword}>
                            {showPassword ? "Masquer" : "Afficher"}
                        </Button>
                        <Button type="button" variant="contained" color="secondary" sx={{ height: "44px" }} onClick={onGeneratePassword}>Générer</Button>
                    </Box>
                    <FormControlLabel
                        control={<Switch checked={sendCredentials} onChange={onToggleSendCredentials} color="secondary" />}
                        label="Envoyer les identifiants par email"
                        sx={{ color: colors.grey[100], mt: "8px" }}
                    />
                </Box>
            </DialogContent>
            <DialogActions sx={styles.dialogActions}>
                <Button onClick={onClose} sx={{ color: colors.grey[100] }}>Annuler</Button>
                <Button type="submit" variant="contained" disabled={saving} sx={{ backgroundColor: isDark ? "#475569" : "#334155", color: "#fff", fontWeight: "bold", "&:hover": { backgroundColor: isDark ? "#64748b" : "#475569" } }}>
                    {saving ? "Enregistrement..." : "Enregistrer"}
                </Button>
            </DialogActions>
        </form>
    </Dialog>
);

const EditTeacherDialog = ({
    open, onClose, formData, errors, formError, sendCredentials,
    onChange, onSubmit, onGeneratePassword, onToggleSendCredentials, styles, colors, isDark
}) => (
    <Dialog open={open} onClose={onClose} fullWidth maxWidth="md" PaperProps={{ sx: styles.dialogPaper }}>
        <DialogTitle sx={styles.dialogTitle}>Éditer l'enseignant</DialogTitle>
        <form onSubmit={onSubmit}>
            <DialogContent sx={{ mt: 2, display: "flex", flexDirection: "column", gap: "18px" }}>
                <Box sx={styles.formCard}>
                    <Typography variant="body2" color={isDark ? colors.grey[300] : "#64748b"} mb="16px">
                        Modifiez les informations du compte. Les libellés restent visibles pendant la saisie.
                    </Typography>
                    {formError && <Typography color={colors.redAccent[500]} textAlign="center" mb="16px">{formError}</Typography>}
                    <Box display="grid" gridTemplateColumns={{ xs: "1fr", md: "repeat(2, minmax(0, 1fr))" }} gap="16px">
                        <TextField variant="outlined" label="Prénom" name="firstName" value={formData.firstName} onChange={onChange} error={!!errors.firstName} helperText={errors.firstName} InputLabelProps={{ shrink: true }} sx={styles.floatingField} fullWidth required />
                        <TextField variant="outlined" label="Nom" name="lastName" value={formData.lastName} onChange={onChange} error={!!errors.lastName} helperText={errors.lastName} InputLabelProps={{ shrink: true }} sx={styles.floatingField} fullWidth required />
                        <Box gridColumn={{ xs: "span 1", md: "span 2" }}>
                            <TextField variant="outlined" label="Email" name="email" type="email" value={formData.email} onChange={onChange} error={!!errors.email} helperText={errors.email} InputLabelProps={{ shrink: true }} sx={styles.floatingField} fullWidth required />
                        </Box>
                        <TextField variant="outlined" label="Téléphone" name="phone" value={formData.phone} onChange={onChange} error={!!errors.phone} helperText={errors.phone} InputLabelProps={{ shrink: true }} sx={styles.floatingField} fullWidth required />
                        <TextField variant="outlined" label="Date de naissance" name="birthdate" type="date" InputLabelProps={{ shrink: true }} value={formData.birthdate} onChange={onChange} error={!!errors.birthdate} helperText={errors.birthdate} sx={styles.floatingField} fullWidth required />
                        <Box gridColumn={{ xs: "span 1", md: "span 2" }}>
                            <TextField variant="outlined" label="Adresse" name="adresse" value={formData.adresse} onChange={onChange} InputLabelProps={{ shrink: true }} sx={styles.floatingField} fullWidth />
                        </Box>
                    </Box>
                    <Typography variant="caption" color={isDark ? colors.grey[300] : "#64748b"} display="block" mt="16px" mb="12px">Laissez le mot de passe vide si vous ne souhaitez pas le modifier.</Typography>
                    <Box display="grid" gridTemplateColumns={{ xs: "1fr", md: "repeat(2, minmax(0, 1fr))" }} gap="16px">
                        <TextField variant="outlined" label="Nouveau mot de passe" name="password" type="text" value={formData.password} onChange={onChange} InputLabelProps={{ shrink: true }} sx={styles.floatingField} fullWidth />
                        <TextField variant="outlined" label="Confirmer le mot de passe" name="password_confirmation" type="text" value={formData.password_confirmation} onChange={onChange} InputLabelProps={{ shrink: true }} sx={styles.floatingField} fullWidth required={!!formData.password} />
                    </Box>
                    <Box display="flex" gap="10px" alignItems="center" mt="16px" flexWrap="wrap">
                        <Button type="button" variant="contained" color="secondary" sx={{ height: "44px" }} onClick={onGeneratePassword}>Générer</Button>
                    </Box>
                    {formData.password && (
                        <FormControlLabel
                            control={<Switch checked={sendCredentials} onChange={onToggleSendCredentials} color="secondary" />}
                            label="Envoyer les identifiants par email"
                            sx={{ color: isDark ? colors.grey[100] : "#1f2937", mt: "8px" }}
                        />
                    )}
                </Box>
            </DialogContent>
            <DialogActions sx={styles.dialogActions}>
                <Button onClick={onClose} sx={{ color: colors.grey[100] }}>Annuler</Button>
                <Button type="submit" variant="contained" sx={{ backgroundColor: isDark ? "#475569" : "#334155", color: "#fff", "&:hover": { backgroundColor: isDark ? "#64748b" : "#475569" } }}>Enregistrer</Button>
            </DialogActions>
        </form>
    </Dialog>
);

const DeleteTeacherDialog = ({ open, teacher, onClose, onConfirm, styles, colors }) => (
    <Dialog open={open} onClose={onClose} PaperProps={{ sx: styles.dialogPaper }}>
        <DialogTitle sx={styles.dialogTitle}>Confirmer la suppression</DialogTitle>
        <DialogContent sx={{ mt: 2 }}>
            <DialogContentText sx={{ color: colors.grey[200] }}>
                Êtes-vous sûr de vouloir supprimer l'enseignant {teacher?.name} ? Cette action est irréversible.
            </DialogContentText>
        </DialogContent>
        <DialogActions sx={styles.dialogActions}>
            <Button onClick={onClose} sx={{ color: colors.grey[100] }}>Annuler</Button>
            <Button onClick={onConfirm} variant="contained" sx={{ backgroundColor: colors.redAccent[500], color: "#fff" }}>Supprimer</Button>
        </DialogActions>
    </Dialog>
);

// ==========================================
// MAIN COMPONENT
// ==========================================
const Teachers = () => {
    const theme = useTheme();
    const colors = tokens(theme.palette.mode);
    const isDark = theme.palette.mode === "dark";
    const styles = getStyles(colors, isDark);

    // Core State
    const [teachers, setTeachers] = useState([]);
    const [loading, setLoading] = useState(true);
    const [activeTeacherCount, setActiveTeacherCount] = useState(0);

    // Dialog States
    const [isEditDialogOpen, setIsEditDialogOpen] = useState(false);
    const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false);
    const [selectedTeacher, setSelectedTeacher] = useState(null);

    // Edit Form State
    const [editFormData, setEditFormData] = useState({ firstName: "", lastName: "", birthdate: "", phone: "", email: "", adresse: "", password: "", password_confirmation: "" });
    const [formError, setFormError] = useState("");
    const [editFormErrors, setEditFormErrors] = useState({});
    const [sendEditCredentials, setSendEditCredentials] = useState(false);

    // Add Form State
    const [addFormData, setAddFormData] = useState({ cin: "", firstName: "", lastName: "", birthdate: "", phone: "", email: "", adresse: "", password: "", password_confirmation: "" });
    const [addFormError, setAddFormError] = useState("");
    const [addFormErrors, setAddFormErrors] = useState({});
    const [addSaving, setAddSaving] = useState(false);
    const [showAddPassword, setShowAddPassword] = useState(false);
    const [sendAddCredentials, setSendAddCredentials] = useState(true);
    const [teacherTab, setTeacherTab] = useState("active");
    const [isAddDialogOpen, setIsAddDialogOpen] = useState(false);
    const [toast, setToast] = useState({ open: false, message: "", severity: "info" });
    const [actionMenuPosition, setActionMenuPosition] = useState(null);
    const [actionMenuTeacher, setActionMenuTeacher] = useState(null);

    const generateRandomPassword = () => {
        const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@#$%';
        return Array.from({ length: 10 }).map(() => chars.charAt(Math.floor(Math.random() * chars.length))).join('');
    };

    const showToast = (message, severity = "info") => {
        setToast({ open: true, message, severity });
    };

    const closeToast = (_, reason) => {
        if (reason === "clickaway") return;
        setToast((prev) => ({ ...prev, open: false }));
    };

    useEffect(() => { fetchTeachers(); }, []);

    const fetchTeachers = async () => {
        try {
            setLoading(true);
            const today = new Date();
            const todayKey = `${today.getFullYear()}-${String(today.getMonth() + 1).padStart(2, '0')}-${String(today.getDate()).padStart(2, '0')}`;

            const [teachersResult, classesResult, activitiesResult] = await Promise.allSettled([
                api.get("/admin/teachers"),
                api.get("/admin/classes"),
                api.get(`/admin/activities/by-date/${todayKey}`)
            ]);

            if (teachersResult.status === 'rejected') throw teachersResult.reason;
            const teacherData = teachersResult.value.data?.data || [];

            const teacherCinsByClassId = {};
            if (classesResult.status === 'fulfilled') {
                const classes = classesResult.value.data?.data || [];
                classes.forEach((schoolClass) => {
                    const classId = String(schoolClass?.id || '');
                    if (!classId) return;
                    teacherCinsByClassId[classId] = (schoolClass.teachers || []).map(t => String(t?.cin || '')).filter(Boolean);
                });
            }

            const teacherCinSet = new Set(
                teacherData.map((teacher) => String(teacher?.cin || '')).filter(Boolean)
            );

            const activeSet = new Set();
            if (activitiesResult.status === 'fulfilled') {
                (activitiesResult.value.data?.data || []).forEach(activity => {
                    const classId = String(activity?.class?.id || '');
                    const classTeacherCins = teacherCinsByClassId[classId] || [];

                    if (classTeacherCins.length > 0) {
                        classTeacherCins.forEach((cin) => activeSet.add(cin));
                        return;
                    }

                    const directTeacherCin = String(activity?.teacher_id || activity?.teacher?.cin || '');
                    if (teacherCinSet.has(directTeacherCin)) {
                        activeSet.add(directTeacherCin);
                    }
                });
            }

            let activeTodayCount = 0;
            const formattedData = teacherData.map((t) => {
                const cinStr = String(t.cin || '');
                const isActive = activeSet.has(cinStr);
                const isArchived = !!t.is_archived;
                if (!isArchived && isActive) activeTodayCount++;

                return {
                    id: t.cin, cin: t.cin,
                    name: `${t.firstName || ""} ${t.lastName || ""}`.trim(),
                    firstName: t.firstName || "", lastName: t.lastName || "",
                    birthdate: t.birthdate || "-", phone: t.phone || "-", email: t.email || "-", adresse: t.adresse || "",
                    is_archived: isArchived, status: isArchived ? 'Archivé' : (isActive ? 'En classe' : 'Disponible')
                };
            });

            setActiveTeacherCount(activeTodayCount);
            setTeachers(formattedData);
        } catch (error) {
            console.error("Failed to fetch teachers", error);
        } finally {
            setLoading(false);
        }
    };

    const handleToggleArchiveClick = async (teacher) => {
        const cinStr = String(teacher.cin);
        try {
            setActionMenuPosition(null);
            setActionMenuTeacher(null);
            await api.patch(`/admin/teachers/${cinStr}/toggle-archive`);
            fetchTeachers();
            if (!teacher.is_archived) {
                setTeacherTab("archived");
                showToast("Archiver un enseignant empêche immédiatement sa connexion à l'application mobile. Pour réactiver l'accès, désarchivez le compte.", "warning");
            } else {
                showToast("Le compte enseignant a été réactivé.", "success");
            }
        } catch (error) {
            alert(error.response?.data?.message || "Erreur lors de la mise à jour du statut.");
        }
    };

    const handleTeacherTabChange = (_, value) => {
        setTeacherTab(value);
        if (value === "archived") {
            showToast("Archiver un enseignant empêche immédiatement sa connexion à l'application mobile. Pour réactiver l'accès, désarchivez le compte.", "warning");
        } else {
            closeToast();
        }
    };

    const openAddDialog = () => {
        setAddFormError("");
        setAddFormErrors({});
        setIsAddDialogOpen(true);
    };

    const openActionMenu = (event, teacher) => {
        const rect = event.currentTarget.getBoundingClientRect();
        const menuWidth = 190;
        const viewportPadding = 8;
        const left = Math.max(viewportPadding, Math.min(rect.right - menuWidth, window.innerWidth - menuWidth - viewportPadding));
        const top = Math.max(viewportPadding, Math.min(rect.bottom + 4, window.innerHeight - 180));
        setActionMenuPosition({ top, left });
        setActionMenuTeacher(teacher);
    };

    const closeActionMenu = () => {
        setActionMenuPosition(null);
        setActionMenuTeacher(null);
    };

    const closeAddDialog = () => {
        setIsAddDialogOpen(false);
        setAddFormError("");
        setAddFormErrors({});
    };

    const openEditDialog = (teacher) => {
        closeActionMenu();
        setSelectedTeacher(teacher);
        setEditFormData({
            firstName: teacher.firstName,
            lastName: teacher.lastName,
            birthdate: teacher.birthdate !== "-" ? teacher.birthdate : "",
            phone: teacher.phone !== "-" ? teacher.phone : "",
            email: teacher.email !== "-" ? teacher.email : "",
            adresse: teacher.adresse || "",
            password: "",
            password_confirmation: "",
        });
        setFormError("");
        setEditFormErrors({});
        setSendEditCredentials(false);
        setIsEditDialogOpen(true);
    };

    const handleDeleteConfirm = async () => {
        if (!selectedTeacher) return;
        try {
            await api.delete(`/admin/teachers/${selectedTeacher.cin}`);
            setTeachers(teachers.filter((t) => t.cin !== selectedTeacher.cin));
            setIsDeleteDialogOpen(false);
            setSelectedTeacher(null);
        } catch (error) {
            alert(error.response?.data?.message || "Erreur lors de la suppression.");
        }
    };

    const handleDeleteClick = (teacher) => {
        closeActionMenu();
        setSelectedTeacher(teacher);
        setIsDeleteDialogOpen(true);
    };

    const applyTeacherApiErrors = (validationErrors, setFieldErrors, setGlobalError, fallbackMessage) => {
        if (validationErrors?.email?.[0]) {
            setFieldErrors((previous) => ({ ...previous, email: validationErrors.email[0] }));
            setGlobalError(validationErrors.email[0]);
            return;
        }

        if (validationErrors) {
            const firstKey = Object.keys(validationErrors)[0];
            const firstMessage = validationErrors[firstKey]?.[0];
            if (firstMessage) {
                setGlobalError(firstMessage);
                return;
            }
        }

        setGlobalError(fallbackMessage);
    };

    const handleEditSubmit = async (e) => {
        e.preventDefault();
        setFormError(""); setEditFormErrors({});
        if (!selectedTeacher) return;

        const validationErrs = validateTeacherForm(editFormData, true);
        if (Object.keys(validationErrs).length > 0) return setEditFormErrors(validationErrs);

        const payload = {
            firstName: editFormData.firstName.trim(),
            lastName: editFormData.lastName.trim(),
            birthdate: editFormData.birthdate || null,
            phone: editFormData.phone || null,
            email: editFormData.email.trim(),
            adresse: editFormData.adresse?.trim() || null,
            ...(editFormData.password ? { password: editFormData.password, password_confirmation: editFormData.password_confirmation, send_credentials: sendEditCredentials } : {})
        };

        try {
            await api.put(`/admin/teachers/${selectedTeacher.cin}`, payload);
            setIsEditDialogOpen(false); setSelectedTeacher(null); fetchTeachers();
        } catch (error) {
            const validationErrors = error.response?.data?.errors;
            applyTeacherApiErrors(validationErrors, setEditFormErrors, setFormError, error.response?.data?.message || "Erreur lors de la modification.");
        }
    };

    const handleAddSubmit = async (e) => {
        e.preventDefault();
        setAddFormError(""); setAddFormErrors({});
        const validationErrs = validateTeacherForm(addFormData, false);
        if (Object.keys(validationErrs).length > 0) return setAddFormErrors(validationErrs);

        setAddSaving(true);
        const payload = {
            cin: Number(addFormData.cin), firstName: addFormData.firstName.trim(), lastName: addFormData.lastName.trim(),
            birthdate: addFormData.birthdate || null, phone: addFormData.phone || null, email: addFormData.email.trim(),
            adresse: addFormData.adresse?.trim() || null, password: addFormData.password, password_confirmation: addFormData.password_confirmation,
            send_credentials: sendAddCredentials,
        };

        try {
            await api.post("/admin/teachers", payload);
            fetchTeachers();
            setAddFormData({ cin: "", firstName: "", lastName: "", birthdate: "", phone: "", email: "", adresse: "", password: "", password_confirmation: "" });
            setShowAddPassword(false);
            setSendAddCredentials(true);
            setIsAddDialogOpen(false);
        } catch (error) {
            const validationErrors = error.response?.data?.errors;
            applyTeacherApiErrors(validationErrors, setAddFormErrors, setAddFormError, error.response?.data?.message || "Erreur lors de l'ajout.");
        } finally {
            setAddSaving(false);
        }
    };

    const columns = [
        { field: "cin", headerName: "CIN", flex: 0.55, minWidth: 110, headerAlign: "center", align: "center" },
        {
            field: "name",
            headerName: "Nom",
            flex: 1.2,
            cellClassName: "name-column--cell",
            minWidth: 220,
            renderCell: ({ row }) => {
                const statusMeta = getTeacherStatusMeta(row, colors, theme.palette.mode === "dark");

                return (
                    <Box display="flex" flexDirection="column" justifyContent="center" minWidth={0} width="100%">
                        <Typography fontWeight="700" color={colors.grey[100]} noWrap>
                            {row.name}
                        </Typography>
                        {statusMeta && (
                            <Box display="flex" alignItems="center" gap="6px" minWidth={0}>
                                <Box width="8px" height="8px" borderRadius="999px" flexShrink={0} sx={{ backgroundColor: statusMeta.dotColor }} />
                                <Typography variant="caption" noWrap sx={{ color: statusMeta.textColor, fontWeight: 600 }}>
                                    {statusMeta.label}
                                </Typography>
                            </Box>
                        )}
                    </Box>
                );
            }
        },
        { field: "birthdate", headerName: "Date de naissance", flex: 1, minWidth: 150 },
        { field: "phone", headerName: "Téléphone", flex: 0.9, minWidth: 130, headerAlign: "center", align: "center" },
        { field: "email", headerName: "Email", flex: 1.5, minWidth: 200 },
        {
            field: "actions", headerName: "Plus", flex: 0.4, minWidth: 90, sortable: false, filterable: false, disableExport: true, headerAlign: "right", align: "right",
            renderCell: ({ row }) => (
                <Box display="flex" justifyContent="flex-end" width="100%">
                    <Tooltip title="Plus d'actions">
                        <IconButton size="small" onClick={(event) => openActionMenu(event, row)} sx={{ color: colors.grey[200], backgroundColor: "rgba(148,163,184,0.14)", "&:hover": { backgroundColor: "rgba(148,163,184,0.22)" } }}>
                            <MoreVertOutlinedIcon fontSize="small" />
                        </IconButton>
                    </Tooltip>
                </Box>
            )
        }
    ];

    const stats = useMemo(() => ({
        total: teachers.length,
        active: activeTeacherCount,
        available: teachers.filter(t => t.status === "Disponible").length,
        archived: teachers.filter(t => t.status === "Archivé").length
    }), [teachers, activeTeacherCount]);

    return (
        <Box m="20px">
            <Header title="ENSEIGNANTS" />
            <StatsCards stats={stats} colors={colors} styles={styles} isDark={isDark} />
            <TeacherDataGrid teachers={teachers} loading={loading} columns={columns} styles={styles} colors={colors} tab={teacherTab} onTabChange={handleTeacherTabChange} onAddClick={openAddDialog} isDark={isDark} />
            <AddTeacherDialog 
                open={isAddDialogOpen}
                onClose={closeAddDialog}
                formData={addFormData} errors={addFormErrors} formError={addFormError} saving={addSaving} showPassword={showAddPassword} sendCredentials={sendAddCredentials}
                onChange={e => setAddFormData({ ...addFormData, [e.target.name]: e.target.value })} onSubmit={handleAddSubmit}
                onTogglePassword={() => setShowAddPassword(!showAddPassword)} onGeneratePassword={() => { const pwd = generateRandomPassword(); setAddFormData(prev => ({ ...prev, password: pwd, password_confirmation: pwd })); }}
                onToggleSendCredentials={(e) => setSendAddCredentials(e.target.checked)} styles={styles} colors={colors} isDark={isDark}
            />
            <EditTeacherDialog 
                open={isEditDialogOpen} onClose={() => setIsEditDialogOpen(false)} formData={editFormData} errors={editFormErrors} formError={formError} sendCredentials={sendEditCredentials}
                onChange={e => setEditFormData({ ...editFormData, [e.target.name]: e.target.value })} onSubmit={handleEditSubmit}
                onGeneratePassword={() => { const pwd = generateRandomPassword(); setEditFormData(prev => ({ ...prev, password: pwd, password_confirmation: pwd })); }}
                onToggleSendCredentials={(e) => setSendEditCredentials(e.target.checked)} styles={styles} colors={colors} isDark={isDark}
            />
            <DeleteTeacherDialog open={isDeleteDialogOpen} teacher={selectedTeacher} onClose={() => setIsDeleteDialogOpen(false)} onConfirm={handleDeleteConfirm} styles={styles} colors={colors} />
            <Menu
                open={Boolean(actionMenuPosition && actionMenuTeacher)}
                onClose={closeActionMenu}
                anchorReference="none"
                transitionDuration={0}
                MenuListProps={{ autoFocusItem: false }}
                PaperProps={{
                    sx: {
                        ...styles.compactMenuPaper,
                        width: 190,
                        position: "fixed",
                        top: actionMenuPosition?.top ?? 0,
                        left: actionMenuPosition?.left ?? 0,
                    },
                }}
            >
                <MenuItem onClick={() => openEditDialog(actionMenuTeacher)}>
                    <Box display="flex" alignItems="center" gap="10px">
                        <EditOutlinedIcon fontSize="small" />
                        <span>Éditer</span>
                    </Box>
                </MenuItem>
                <MenuItem onClick={() => handleToggleArchiveClick(actionMenuTeacher)}>
                    <Box display="flex" alignItems="center" gap="10px">
                        {actionMenuTeacher?.is_archived ? <UnarchiveOutlinedIcon fontSize="small" /> : <ArchiveOutlinedIcon fontSize="small" />}
                        <span>{actionMenuTeacher?.is_archived ? "Désarchiver" : "Archiver"}</span>
                    </Box>
                </MenuItem>
                <MenuItem onClick={() => handleDeleteClick(actionMenuTeacher)} sx={{ color: colors.redAccent[400] }}>
                    <Box display="flex" alignItems="center" gap="10px">
                        <DeleteOutlineIcon fontSize="small" />
                        <span>Supprimer</span>
                    </Box>
                </MenuItem>
            </Menu>
            <Snackbar open={toast.open} autoHideDuration={5000} onClose={closeToast} anchorOrigin={{ vertical: "top", horizontal: "right" }}>
                <Alert onClose={closeToast} severity={toast.severity} variant="outlined" sx={{ width: "100%", maxWidth: "420px", alignItems: "center", borderRadius: "14px", boxShadow: "0 12px 28px rgba(15,23,42,0.12)", backgroundColor: isDark ? "rgba(17,24,39,0.96)" : "rgba(255,250,242,0.98)", color: isDark ? colors.grey[100] : "#3f2a12", borderColor: "rgba(245,158,11,0.35)" }}>
                    {toast.message}
                </Alert>
            </Snackbar>
        </Box>
    );
};

export default Teachers;
