import {
    Alert,
    Box,
    Button,
    Dialog,
    DialogActions,
    DialogContent,
    DialogContentText,
    DialogTitle,
    FormControl,
    IconButton,
    Menu,
    MenuItem,
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
import CheckCircleOutlineOutlinedIcon from "@mui/icons-material/CheckCircleOutlineOutlined";
import DeleteOutlineIcon from "@mui/icons-material/DeleteOutline";
import EditOutlinedIcon from "@mui/icons-material/EditOutlined";
import GroupOutlinedIcon from "@mui/icons-material/GroupOutlined";
import HourglassEmptyOutlinedIcon from "@mui/icons-material/HourglassEmptyOutlined";
import HighlightOffOutlinedIcon from "@mui/icons-material/HighlightOffOutlined";
import MoreVertOutlinedIcon from "@mui/icons-material/MoreVertOutlined";
import UnarchiveOutlinedIcon from "@mui/icons-material/UnarchiveOutlined";
import { useEffect, useMemo, useState } from "react";
import api from "../../api/axios";
import Header from "../../components/Header";
import { tokens } from "../../theme";
import { validateParentForm } from "../../utils/validation";

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
        boxShadow: "0px 0px 15px rgba(0,0,0,0.5)",
    },
    dialogTitle: {
        fontWeight: "bold",
        fontSize: "1.2rem",
        borderBottom: `1px solid ${colors.primary[500]}`,
    },
    dialogActions: {
        p: 2,
        borderTop: `1px solid ${colors.primary[500]}`,
    },
    compactMenuPaper: {
        backgroundColor: colors.primary[400],
        color: colors.grey[100],
        borderRadius: "14px",
        border: `1px solid ${colors.primary[500]}`,
        boxShadow: "0 16px 32px rgba(15,23,42,0.18)",
    },
    formCard: {
        backgroundColor: isDark ? colors.primary[500] : "rgba(255,255,255,0.98)",
        border: `1px solid ${isDark ? colors.primary[600] : "rgba(148, 163, 184, 0.22)"}`,
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
    childrenPill: {
        px: "10px",
        py: "6px",
        borderRadius: "999px",
        backgroundColor: isDark ? "rgba(148,163,184,0.16)" : "rgba(226,232,240,0.72)",
        color: colors.grey[100],
        fontWeight: 700,
        fontSize: "0.75rem",
        lineHeight: 1,
    },
    childrenSelect: {
        minWidth: 160,
        borderRadius: "999px",
        backgroundColor: isDark ? "rgba(255,255,255,0.04)" : "#ffffff",
        boxShadow: isDark ? "inset 0 1px 0 rgba(255,255,255,0.03)" : "0 2px 8px rgba(15,23,42,0.05)",
        transition: "border-color 0.18s ease, box-shadow 0.18s ease, background-color 0.18s ease",
        ".MuiOutlinedInput-notchedOutline": { borderColor: isDark ? "rgba(148,163,184,0.28)" : "rgba(148,163,184,0.24)" },
        "&:hover .MuiOutlinedInput-notchedOutline": { borderColor: isDark ? "rgba(148,163,184,0.42)" : "rgba(100,116,139,0.35)" },
        "&.Mui-focused": {
            boxShadow: isDark ? "0 0 0 3px rgba(148,163,184,0.12)" : "0 0 0 3px rgba(148,163,184,0.14)",
        },
        "&.Mui-focused .MuiOutlinedInput-notchedOutline": { borderColor: isDark ? "#94a3b8" : "#64748b" },
        "& .MuiSelect-select": {
            py: "8px",
            px: "12px 14px",
            fontSize: "0.85rem",
            fontWeight: 700,
            color: isDark ? colors.grey[100] : "#0f172a",
            display: "flex",
            alignItems: "center",
            gap: "8px",
        },
        "& .MuiSelect-icon": {
            color: isDark ? colors.grey[300] : "#64748b",
            right: 10,
        },
    },
    statusSelect: (statusColor) => ({
        minWidth: 140,
        color: statusColor,
        fontSize: "0.85rem",
        borderRadius: "999px",
        backgroundColor: isDark ? "rgba(255,255,255,0.03)" : "rgba(248,250,252,0.9)",
        ".MuiOutlinedInput-notchedOutline": { borderColor: statusColor },
        "&:hover .MuiOutlinedInput-notchedOutline": { borderColor: statusColor },
        "&.Mui-focused .MuiOutlinedInput-notchedOutline": { borderColor: statusColor },
        "& .MuiSelect-select": { py: "8px", px: "12px" },
    }),
});

const getParentStatusMeta = (parent, colors, isDark) => {
    if (parent.is_archived) {
        return {
            label: "Archivé",
            dotColor: isDark ? colors.grey[400] : "#94a3b8",
            textColor: colors.grey[300],
        };
    }

    if (parent.approval_status === "approved") {
        return {
            label: "Approuvé",
            dotColor: isDark ? colors.greenAccent[400] : "#16a34a",
            textColor: isDark ? colors.greenAccent[300] : "#166534",
        };
    }

    if (parent.approval_status === "rejected") {
        return {
            label: "Rejeté",
            dotColor: isDark ? colors.redAccent[400] : "#dc2626",
            textColor: isDark ? colors.redAccent[300] : "#991b1b",
        };
    }

    return {
        label: "En attente",
        dotColor: "#f59e0b",
        textColor: isDark ? "#fbbf24" : "#92400e",
    };
};

const ParentGridToolbar = ({ colors, isDark }) => (
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
            title: "Total parents",
            value: stats.total,
            icon: <GroupOutlinedIcon />,
            iconBg: isDark ? "rgba(96,165,250,0.14)" : "rgba(37,99,235,0.12)",
            iconColor: isDark ? colors.blueAccent[300] : "#1d4ed8",
        },
        {
            title: "Approuvés",
            value: stats.approved,
            icon: <CheckCircleOutlineOutlinedIcon />,
            iconBg: isDark ? "rgba(134,239,172,0.14)" : "rgba(22,163,74,0.12)",
            iconColor: isDark ? colors.greenAccent[300] : "#166534",
        },
        {
            title: "En attente",
            value: stats.pending,
            icon: <HourglassEmptyOutlinedIcon />,
            iconBg: isDark ? "rgba(251,191,36,0.14)" : "rgba(245,158,11,0.12)",
            iconColor: isDark ? "#fbbf24" : "#b45309",
        },
        {
            title: "Rejetés",
            value: stats.rejected,
            icon: <HighlightOffOutlinedIcon />,
            iconBg: isDark ? "rgba(248,113,113,0.14)" : "rgba(220,38,38,0.12)",
            iconColor: isDark ? colors.redAccent[300] : "#991b1b",
        },
        {
            title: "Archivés",
            value: stats.archived,
            icon: <ArchiveOutlinedIcon />,
            iconBg: isDark ? "rgba(148,163,184,0.14)" : "rgba(148,163,184,0.14)",
            iconColor: isDark ? colors.grey[300] : "#64748b",
        },
    ];

    return (
        <Box display="grid" gridTemplateColumns={{ xs: "1fr", sm: "repeat(2, 1fr)", xl: "repeat(5, 1fr)" }} gap="14px" mb="20px">
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

const ParentDataGrid = ({ parents, loading, columns, styles, colors, tab, onTabChange, isDark }) => {
    const activeParents = parents.filter((parent) => !parent.is_archived);
    const archivedParents = parents.filter((parent) => parent.is_archived);
    const visibleParents = tab === "active" ? activeParents : archivedParents;

    return (
        <Box>
            <Box display="flex" justifyContent="space-between" alignItems={{ xs: "flex-start", md: "center" }} flexDirection={{ xs: "column", md: "row" }} gap="12px" mb="14px">
                <Box>
                    <Typography variant="h5" fontWeight="bold" color={colors.grey[100]}>
                        Gestion des parents
                    </Typography>
                    <Typography variant="body2" color={colors.grey[300]} mt="4px">
                        Consultez un seul tableau et basculez entre les comptes actifs et archivés.
                    </Typography>
                </Box>
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
                    <Tab value="active" label={`Actifs (${activeParents.length})`} />
                    <Tab value="archived" label={`Archivés (${archivedParents.length})`} />
                </Tabs>
            </Box>

            <Box height="62vh" sx={styles.gridContainer}>
                <DataGrid
                    loading={loading}
                    rows={visibleParents}
                    columns={columns}
                    rowHeight={72}
                    pageSize={10}
                    rowsPerPageOptions={[10, 50, 100]}
                    disableSelectionOnClick
                    components={{ Toolbar: ParentGridToolbar }}
                    componentsProps={{ toolbar: { colors, isDark } }}
                />
            </Box>
        </Box>
    );
};

const DeleteDialog = ({ isOpen, onClose, onConfirm, parent, styles, colors }) => (
    <Dialog open={isOpen} onClose={onClose} PaperProps={{ sx: styles.dialogPaper }}>
        <DialogTitle sx={styles.dialogTitle}>Confirmer la suppression</DialogTitle>
        <DialogContent sx={{ mt: 2 }}>
            <DialogContentText sx={{ color: colors.grey[200] }}>
                Êtes-vous sûr de vouloir supprimer le parent {parent?.name} ? Cette action est irréversible.
            </DialogContentText>
            <Box mt="16px" p="14px" borderRadius="14px" border={`1px solid ${colors.redAccent[500]}33`} backgroundColor={colors.primary[500]}>
                <Typography color={colors.redAccent[400]} fontWeight="700" mb="8px">
                    Cette suppression effacera aussi :
                </Typography>
                <Typography color={colors.grey[200]} variant="body2">Le compte parent et ses informations personnelles.</Typography>
                <Typography color={colors.grey[200]} variant="body2">Tous les enfants liés à ce parent.</Typography>
                <Typography color={colors.grey[200]} variant="body2">Les inscriptions, dossiers médicaux, commentaires IA et paiements liés.</Typography>
                <Typography color={colors.grey[200]} variant="body2">Les exceptions alimentaires, présences, évaluations et affectations de classe des enfants.</Typography>
            </Box>
        </DialogContent>
        <DialogActions sx={styles.dialogActions}>
            <Button onClick={onClose} sx={{ color: colors.grey[100] }}>Annuler</Button>
            <Button onClick={onConfirm} variant="contained" sx={{ backgroundColor: colors.redAccent[500], color: "#fff" }}>
                Supprimer
            </Button>
        </DialogActions>
    </Dialog>
);

const EditDialog = ({ isOpen, onClose, onSubmit, formData, onChange, formErrors, topError, generateRandomPassword, colors, styles, isDark }) => (
    <Dialog open={isOpen} onClose={onClose} fullWidth maxWidth="md" PaperProps={{ sx: styles.dialogPaper }}>
        <DialogTitle sx={styles.dialogTitle}>Éditer le parent</DialogTitle>
        <form onSubmit={onSubmit}>
            <DialogContent sx={{ mt: 2, display: "flex", flexDirection: "column", gap: "18px" }}>
                <Box sx={styles.formCard}>
                    <Typography variant="body2" color={isDark ? colors.grey[300] : "#64748b"} mb="16px">
                        Modifiez les informations du compte. Les libellés restent visibles pendant la saisie.
                    </Typography>
                    {topError && <Typography color={colors.redAccent[500]} textAlign="center" mb="16px">{topError}</Typography>}
                    <Box display="grid" gridTemplateColumns={{ xs: "1fr", md: "repeat(2, minmax(0, 1fr))" }} gap="16px">
                        <TextField variant="outlined" label="Prénom" name="firstName" value={formData.firstName} onChange={onChange} error={!!formErrors.firstName} helperText={formErrors.firstName} InputLabelProps={{ shrink: true }} sx={styles.floatingField} fullWidth required />
                        <TextField variant="outlined" label="Nom" name="lastName" value={formData.lastName} onChange={onChange} error={!!formErrors.lastName} helperText={formErrors.lastName} InputLabelProps={{ shrink: true }} sx={styles.floatingField} fullWidth required />
                        <Box gridColumn={{ xs: "span 1", md: "span 2" }}>
                            <TextField variant="outlined" label="Email" name="email" type="email" value={formData.email} onChange={onChange} error={!!formErrors.email} helperText={formErrors.email} InputLabelProps={{ shrink: true }} sx={styles.floatingField} fullWidth required />
                        </Box>
                        <TextField variant="outlined" label="Téléphone" name="phone" value={formData.phone} onChange={onChange} error={!!formErrors.phone} helperText={formErrors.phone} InputLabelProps={{ shrink: true }} sx={styles.floatingField} fullWidth required />
                        <TextField variant="outlined" label="Date de naissance" name="birthdate" type="date" value={formData.birthdate} onChange={onChange} error={!!formErrors.birthdate} helperText={formErrors.birthdate} InputLabelProps={{ shrink: true }} sx={styles.floatingField} fullWidth required />
                        <Box gridColumn={{ xs: "span 1", md: "span 2" }}>
                            <TextField variant="outlined" label="Adresse" name="adresse" value={formData.adresse} onChange={onChange} InputLabelProps={{ shrink: true }} sx={styles.floatingField} fullWidth />
                        </Box>
                    </Box>
                    <Typography variant="caption" color={isDark ? colors.grey[300] : "#64748b"} display="block" mt="16px" mb="12px">
                        Laissez le mot de passe vide si vous ne souhaitez pas le modifier.
                    </Typography>
                    <Box display="grid" gridTemplateColumns={{ xs: "1fr", md: "repeat(2, minmax(0, 1fr))" }} gap="16px">
                        <TextField variant="outlined" label="Nouveau mot de passe" name="password" type="text" value={formData.password} onChange={onChange} InputLabelProps={{ shrink: true }} sx={styles.floatingField} fullWidth />
                        <TextField variant="outlined" label="Confirmer le mot de passe" name="password_confirmation" type="text" value={formData.password_confirmation} onChange={onChange} InputLabelProps={{ shrink: true }} sx={styles.floatingField} fullWidth />
                    </Box>
                    <Box display="flex" gap="10px" alignItems="center" mt="16px" flexWrap="wrap">
                        <Button type="button" variant="contained" color="secondary" sx={{ height: "44px" }} onClick={generateRandomPassword}>
                            Générer
                        </Button>
                    </Box>
                </Box>
            </DialogContent>
            <DialogActions sx={styles.dialogActions}>
                <Button onClick={onClose} sx={{ color: colors.grey[100] }}>Annuler</Button>
                <Button type="submit" variant="contained" sx={{ backgroundColor: isDark ? "#475569" : "#334155", color: "#fff", "&:hover": { backgroundColor: isDark ? "#64748b" : "#475569" } }}>
                    Enregistrer
                </Button>
            </DialogActions>
        </form>
    </Dialog>
);

const Parents = () => {
    const theme = useTheme();
    const colors = tokens(theme.palette.mode);
    const isDark = theme.palette.mode === "dark";
    const styles = getStyles(colors, isDark);

    const [parentsList, setParentsList] = useState([]);
    const [loading, setLoading] = useState(true);
    const [isEditDialogOpen, setIsEditDialogOpen] = useState(false);
    const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false);
    const [selectedParent, setSelectedParent] = useState(null);
    const [editFormData, setEditFormData] = useState({
        firstName: "",
        lastName: "",
        birthdate: "",
        phone: "",
        email: "",
        adresse: "",
        password: "",
        password_confirmation: "",
    });
    const [formError, setFormError] = useState("");
    const [editFormErrors, setEditFormErrors] = useState({});
    const [parentTab, setParentTab] = useState("active");
    const [toast, setToast] = useState({ open: false, message: "", severity: "info" });
    const [actionMenuPosition, setActionMenuPosition] = useState(null);
    const [actionMenuParent, setActionMenuParent] = useState(null);

    const stats = useMemo(() => ({
        total: parentsList.length,
        approved: parentsList.filter((parent) => parent.approval_status === "approved").length,
        pending: parentsList.filter((parent) => parent.approval_status === "pending").length,
        rejected: parentsList.filter((parent) => parent.approval_status === "rejected").length,
        archived: parentsList.filter((parent) => parent.is_archived).length,
    }), [parentsList]);

    useEffect(() => {
        fetchParents();
    }, []);

    const generateRandomPassword = () => {
        const chars = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@#$%";
        return Array.from({ length: 10 }).map(() => chars.charAt(Math.floor(Math.random() * chars.length))).join("");
    };

    const showToast = (message, severity = "info") => {
        setToast({ open: true, message, severity });
    };

    const closeToast = (_, reason) => {
        if (reason === "clickaway") return;
        setToast((prev) => ({ ...prev, open: false }));
    };

    const fetchParents = async () => {
        try {
            setLoading(true);
            const response = await api.get("/admin/parents");
            const data = response.data?.data || [];
            const formatted = data.map((parent) => ({
                id: parent.cin,
                cin: parent.cin,
                name: `${parent.firstName || ""} ${parent.lastName || ""}`.trim(),
                firstName: parent.firstName || "",
                lastName: parent.lastName || "",
                birthdate: parent.birthdate || "-",
                phone: parent.phone || "-",
                email: parent.email || "-",
                adresse: parent.adresse || "",
                children: parent.children || [],
                childrenNames: (parent.children || []).map((child) => `${child.firstName || ""} ${child.lastName || ""}`.trim()).join(", ") || "-",
                childrenCount: (parent.children || []).length,
                is_archived: !!parent.is_archived,
                approval_status: (parent.approval_status || "approved").toLowerCase(),
            }));
            setParentsList(formatted);
        } catch (error) {
            console.error("Failed to fetch parents", error);
        } finally {
            setLoading(false);
        }
    };

    const handleEditClick = (parent) => {
        closeActionMenu();
        setSelectedParent(parent);
        setEditFormData({
            firstName: parent.firstName,
            lastName: parent.lastName,
            birthdate: parent.birthdate !== "-" ? parent.birthdate : "",
            phone: parent.phone !== "-" ? parent.phone : "",
            email: parent.email !== "-" ? parent.email : "",
            adresse: parent.adresse || "",
            password: "",
            password_confirmation: "",
        });
        setFormError("");
        setEditFormErrors({});
        setIsEditDialogOpen(true);
    };

    const handleEditChange = (event) => {
        const { name, value } = event.target;
        setEditFormData((prev) => ({ ...prev, [name]: value }));
    };

    const handleEditSubmit = async (event) => {
        event.preventDefault();
        setFormError("");
        setEditFormErrors({});

        if (!selectedParent) return;

        const validationErrs = validateParentForm(editFormData, true);
        if (Object.keys(validationErrs).length > 0) {
            setEditFormErrors(validationErrs);
            return;
        }

        const payload = {
            firstName: String(editFormData.firstName).trim(),
            lastName: String(editFormData.lastName).trim(),
            birthdate: editFormData.birthdate || null,
            phone: editFormData.phone || null,
            email: String(editFormData.email).trim(),
            adresse: editFormData.adresse?.trim() || null,
        };

        if (editFormData.password) {
            payload.password = editFormData.password;
            payload.password_confirmation = editFormData.password_confirmation;
        }

        try {
            await api.put(`/admin/parents/${selectedParent.cin}`, payload);
            setIsEditDialogOpen(false);
            setSelectedParent(null);
            fetchParents();
        } catch (error) {
            const validationErrors = error.response?.data?.errors;
            if (validationErrors) {
                const firstKey = Object.keys(validationErrors)[0];
                setFormError(validationErrors[firstKey][0]);
            } else {
                setFormError(error.response?.data?.message || "Erreur lors de la modification.");
            }
        }
    };

    const handleDeleteClick = (parent) => {
        closeActionMenu();
        setSelectedParent(parent);
        setIsDeleteDialogOpen(true);
    };

    const openActionMenu = (event, parent) => {
        const rect = event.currentTarget.getBoundingClientRect();
        const menuWidth = 190;
        const viewportPadding = 8;
        const left = Math.max(viewportPadding, Math.min(rect.right - menuWidth, window.innerWidth - menuWidth - viewportPadding));
        const top = Math.max(viewportPadding, Math.min(rect.bottom + 4, window.innerHeight - 180));
        setActionMenuPosition({ top, left });
        setActionMenuParent(parent);
    };

    const closeActionMenu = () => {
        setActionMenuPosition(null);
        setActionMenuParent(null);
    };

    const handleDeleteConfirm = async () => {
        if (!selectedParent) return;

        try {
            await api.delete(`/admin/parents/${selectedParent.cin}`);
            setParentsList((prev) => prev.filter((parent) => parent.cin !== selectedParent.cin));
            setIsDeleteDialogOpen(false);
            setSelectedParent(null);
        } catch (error) {
            alert(error.response?.data?.message || "Erreur lors de la suppression.");
        }
    };

    const handleStatusChange = async (parent, newStatus) => {
        try {
            await api.patch(`/admin/parents/${parent.cin}/approval-status`, { status: newStatus });
            fetchParents();
        } catch (error) {
            alert(error.response?.data?.message || "Erreur lors de la mise à jour du statut.");
        }
    };

    const handleToggleArchiveClick = async (parent) => {
        try {
            closeActionMenu();
            await api.patch(`/admin/parents/${parent.cin}/toggle-archive`);
            await fetchParents();
            if (!parent.is_archived) {
                setParentTab("archived");
                showToast("Archiver un parent empêche immédiatement sa connexion à l'application mobile. Pour réactiver l'accès, désarchivez le compte.", "warning");
            } else {
                showToast("Le compte parent a été réactivé.", "success");
            }
        } catch (error) {
            alert(error.response?.data?.message || "Erreur lors de l'archivage.");
        }
    };

    const handleParentTabChange = (_, value) => {
        setParentTab(value);
        if (value === "archived") {
            showToast("Archiver un parent empêche immédiatement sa connexion à l'application mobile. Pour réactiver l'accès, désarchivez le compte.", "warning");
        } else {
            closeToast();
        }
    };

    const columns = [
        { field: "cin", headerName: "CIN", flex: 0.55, minWidth: 110, headerAlign: "center", align: "center" },
        {
            field: "name",
            headerName: "Nom",
            flex: 1.15,
            minWidth: 220,
            cellClassName: "name-column--cell",
            renderCell: ({ row }) => {
                const statusMeta = getParentStatusMeta(row, colors, isDark);

                return (
                    <Box display="flex" flexDirection="column" justifyContent="center" minWidth={0} width="100%">
                        <Typography fontWeight="700" color={colors.grey[100]} noWrap>
                            {row.name}
                        </Typography>
                        <Box display="flex" alignItems="center" gap="6px" minWidth={0}>
                            <Box width="8px" height="8px" borderRadius="999px" flexShrink={0} sx={{ backgroundColor: statusMeta.dotColor }} />
                            <Typography variant="caption" noWrap sx={{ color: statusMeta.textColor, fontWeight: 600 }}>
                                {statusMeta.label}
                            </Typography>
                        </Box>
                    </Box>
                );
            },
        },
        {
            field: "childrenNames",
            headerName: "Enfants",
            flex: 1.2,
            minWidth: 220,
            sortable: false,
            renderCell: ({ row }) => {
                const children = row.children || [];
                const countLabel = row.childrenCount > 1 ? `${row.childrenCount} enfants` : row.childrenCount === 1 ? "1 enfant" : "Aucun enfant";

                if (children.length === 0) {
                    return (
                        <Box component="span" sx={styles.childrenPill}>
                            {countLabel}
                        </Box>
                    );
                }

                return (
                    <FormControl size="small" fullWidth>
                        <Select
                            value=""
                            displayEmpty
                            renderValue={() => (
                                <Box display="flex" alignItems="center" gap="8px" minWidth={0}>
                                    <Box
                                        width="22px"
                                        height="22px"
                                        borderRadius="999px"
                                        display="inline-flex"
                                        alignItems="center"
                                        justifyContent="center"
                                        sx={{
                                            backgroundColor: isDark ? "rgba(148,163,184,0.16)" : "rgba(226,232,240,0.9)",
                                            color: isDark ? colors.grey[200] : "#475569",
                                            fontSize: "0.72rem",
                                            fontWeight: 800,
                                            flexShrink: 0,
                                        }}
                                    >
                                        {row.childrenCount}
                                    </Box>
                                    <Typography variant="body2" fontWeight="700" noWrap>
                                        {countLabel}
                                    </Typography>
                                </Box>
                            )}
                            sx={styles.childrenSelect}
                            MenuProps={{
                                PaperProps: {
                                    sx: {
                                        mt: 1,
                                        borderRadius: "16px",
                                        backgroundColor: isDark ? colors.primary[400] : "#ffffff",
                                        color: isDark ? colors.grey[100] : "#0f172a",
                                        border: `1px solid ${isDark ? colors.primary[500] : "rgba(226,232,240,0.95)"}`,
                                        boxShadow: isDark ? "0 16px 32px rgba(15,23,42,0.22)" : "0 18px 40px rgba(15,23,42,0.12)",
                                        overflow: "hidden",
                                        minWidth: 220,
                                        "& .MuiList-root": {
                                            p: "8px",
                                        },
                                    },
                                },
                            }}
                        >
                            {children.map((child, index) => (
                                <MenuItem
                                    key={`${row.cin}-child-${index}`}
                                    value={`child-${index}`}
                                    disabled
                                    sx={{
                                        opacity: 1,
                                        color: isDark ? colors.grey[100] : "#0f172a",
                                        py: "10px",
                                        px: "12px",
                                        borderRadius: "12px",
                                        mb: index === children.length - 1 ? 0 : "4px",
                                        pointerEvents: "none",
                                        alignItems: "flex-start",
                                        backgroundColor: isDark ? "rgba(255,255,255,0.02)" : "#f8fafc",
                                        border: isDark ? "1px solid rgba(255,255,255,0.03)" : "1px solid #e2e8f0",
                                        "&.Mui-disabled": {
                                            opacity: 1,
                                            color: isDark ? colors.grey[100] : "#0f172a",
                                            WebkitTextFillColor: isDark ? colors.grey[100] : "#0f172a",
                                        },
                                    }}
                                >
                                    <Box display="flex" alignItems="center" gap="10px" width="100%">
                                        <Box
                                            width="28px"
                                            height="28px"
                                            borderRadius="10px"
                                            display="inline-flex"
                                            alignItems="center"
                                            justifyContent="center"
                                            sx={{
                                                backgroundColor: isDark ? "rgba(148,163,184,0.16)" : "#e2e8f0",
                                                color: isDark ? colors.grey[200] : "#1e293b",
                                                fontSize: "0.76rem",
                                                fontWeight: 800,
                                                flexShrink: 0,
                                            }}
                                        >
                                            {index + 1}
                                        </Box>
                                        <Box minWidth={0}>
                                            <Typography variant="body2" fontWeight="700" noWrap color={isDark ? colors.grey[100] : "#0f172a"}>
                                                {`${child.firstName || ""} ${child.lastName || ""}`.trim()}
                                            </Typography>
                                            <Typography variant="caption" color={isDark ? colors.grey[300] : "#64748b"}>
                                                Enfant associe
                                            </Typography>
                                        </Box>
                                    </Box>
                                </MenuItem>
                            ))}
                        </Select>
                    </FormControl>
                );
            },
        },
        { field: "birthdate", headerName: "Date de naissance", flex: 0.9, minWidth: 150 },
        { field: "phone", headerName: "Téléphone", flex: 0.85, minWidth: 130, headerAlign: "center", align: "center" },
        { field: "email", headerName: "Email", flex: 1.35, minWidth: 220 },
        {
            field: "status",
            headerName: "Statut",
            flex: 0.9,
            minWidth: 170,
            sortable: false,
            renderCell: ({ row }) => {
                const statusColor = row.approval_status === "approved"
                    ? (isDark ? colors.greenAccent[400] : "#166534")
                    : row.approval_status === "rejected"
                        ? (isDark ? colors.redAccent[400] : "#991b1b")
                        : "#b45309";

                return (
                    <FormControl size="small" fullWidth>
                        <Select
                            value={row.approval_status}
                            onChange={(event) => handleStatusChange(row, event.target.value)}
                            sx={styles.statusSelect(statusColor)}
                        >
                            <MenuItem value="pending">En attente</MenuItem>
                            <MenuItem value="approved">Approuvé</MenuItem>
                            <MenuItem value="rejected">Rejeté</MenuItem>
                        </Select>
                    </FormControl>
                );
            },
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

    return (
        <Box m="20px">
            <Header title="PARENTS" />
            <StatsCards stats={stats} colors={colors} styles={styles} isDark={isDark} />
            <ParentDataGrid parents={parentsList} loading={loading} columns={columns} styles={styles} colors={colors} tab={parentTab} onTabChange={handleParentTabChange} isDark={isDark} />
            <DeleteDialog isOpen={isDeleteDialogOpen} onClose={() => setIsDeleteDialogOpen(false)} onConfirm={handleDeleteConfirm} parent={selectedParent} styles={styles} colors={colors} />
            <EditDialog
                isOpen={isEditDialogOpen}
                onClose={() => setIsEditDialogOpen(false)}
                onSubmit={handleEditSubmit}
                formData={editFormData}
                onChange={handleEditChange}
                formErrors={editFormErrors}
                topError={formError}
                generateRandomPassword={() => {
                    const generated = generateRandomPassword();
                    setEditFormData((prev) => ({ ...prev, password: generated, password_confirmation: generated }));
                }}
                colors={colors}
                styles={styles}
                isDark={isDark}
            />
            <Menu
                open={Boolean(actionMenuPosition && actionMenuParent)}
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
                <MenuItem onClick={() => handleEditClick(actionMenuParent)}>
                    <Box display="flex" alignItems="center" gap="10px">
                        <EditOutlinedIcon fontSize="small" />
                        <span>Éditer</span>
                    </Box>
                </MenuItem>
                <MenuItem onClick={() => handleToggleArchiveClick(actionMenuParent)}>
                    <Box display="flex" alignItems="center" gap="10px">
                        {actionMenuParent?.is_archived ? <UnarchiveOutlinedIcon fontSize="small" /> : <ArchiveOutlinedIcon fontSize="small" />}
                        <span>{actionMenuParent?.is_archived ? "Désarchiver" : "Archiver"}</span>
                    </Box>
                </MenuItem>
                <MenuItem onClick={() => handleDeleteClick(actionMenuParent)} sx={{ color: colors.redAccent[400] }}>
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

export default Parents;
