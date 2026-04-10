import {
    Alert,
    Box,
    Button,
    Checkbox,
    Chip,
    Dialog,
    DialogActions,
    DialogContent,
    DialogContentText,
    DialogTitle,
    FormControl,
    IconButton,
    InputLabel,
    ListItemText,
    Menu,
    MenuItem,
    Paper,
    Select,
    Slider,
    Snackbar,
    Tab,
    Table,
    TableBody,
    TableCell,
    TableContainer,
    TableHead,
    TableRow,
    Tabs,
    TextField,
    Tooltip,
    Typography,
} from "@mui/material";
import { useTheme } from "@mui/material";
import {
    DataGrid,
    GridToolbarContainer,
    GridToolbarFilterButton,
} from "@mui/x-data-grid";
import ArchiveOutlinedIcon from "@mui/icons-material/ArchiveOutlined";
import CloseIcon from "@mui/icons-material/Close";
import DeleteOutlineIcon from "@mui/icons-material/DeleteOutline";
import EditOutlinedIcon from "@mui/icons-material/EditOutlined";
import GroupOutlinedIcon from "@mui/icons-material/GroupOutlined";
import MoreVertOutlinedIcon from "@mui/icons-material/MoreVertOutlined";
import PeopleOutlineIcon from "@mui/icons-material/PeopleOutline";
import PersonAddAlt1OutlinedIcon from "@mui/icons-material/PersonAddAlt1Outlined";
import SchoolOutlinedIcon from "@mui/icons-material/SchoolOutlined";
import UnarchiveOutlinedIcon from "@mui/icons-material/UnarchiveOutlined";
import VisibilityOutlinedIcon from "@mui/icons-material/VisibilityOutlined";
import { useEffect, useMemo, useState } from "react";
import api from "../../api/axios";
import Header from "../../components/Header";
import { tokens } from "../../theme";
import { validateClassForm } from "../../utils/validation";

function getPlanningLabel(startYear, endYear) {
    return startYear === endYear ? `${startYear}` : `${startYear}/${endYear}`;
}

function mapPlanningFromApi(planning) {
    const startYear = Number(planning.Startyear ?? planning.startYear ?? planning.start_year);
    const endYear = Number(planning.Endyear ?? planning.endYear ?? planning.end_year);
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
        isActive: !!planning.is_active,
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
    floatingSelectLabel: {
        color: colors.grey[300],
        fontWeight: 600,
        px: "6px",
        backgroundColor: isDark ? colors.primary[400] : "#f8fafc",
        borderRadius: "999px",
        "&.Mui-focused": {
            color: isDark ? "#94a3b8" : "#475569",
        },
    },
    compactSelect: {
        borderRadius: "12px",
        backgroundColor: isDark ? colors.primary[400] : "#f8fafc",
        ".MuiOutlinedInput-notchedOutline": { borderColor: colors.primary[600] },
        "&:hover .MuiOutlinedInput-notchedOutline": { borderColor: colors.grey[400] },
        "&.Mui-focused .MuiOutlinedInput-notchedOutline": { borderColor: isDark ? "#94a3b8" : "#475569" },
    },
    compactMenuPaper: {
        backgroundColor: colors.primary[400],
        color: colors.grey[100],
        borderRadius: "14px",
        border: `1px solid ${colors.primary[500]}`,
        boxShadow: "0 16px 32px rgba(15,23,42,0.18)",
    },
    listSelectCell: {
        minWidth: 160,
        borderRadius: "999px",
        backgroundColor: isDark ? "rgba(255,255,255,0.04)" : "#ffffff",
        boxShadow: isDark ? "inset 0 1px 0 rgba(255,255,255,0.03)" : "0 2px 8px rgba(15,23,42,0.05)",
        ".MuiOutlinedInput-notchedOutline": { borderColor: isDark ? "rgba(148,163,184,0.28)" : "rgba(148,163,184,0.24)" },
        "&:hover .MuiOutlinedInput-notchedOutline": { borderColor: isDark ? "rgba(148,163,184,0.42)" : "rgba(100,116,139,0.35)" },
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
    countPill: {
        width: 22,
        height: 22,
        borderRadius: "999px",
        display: "inline-flex",
        alignItems: "center",
        justifyContent: "center",
        backgroundColor: isDark ? "rgba(148,163,184,0.16)" : "#e2e8f0",
        color: isDark ? colors.grey[200] : "#1e293b",
        fontSize: "0.72rem",
        fontWeight: 800,
        flexShrink: 0,
    },
    occupancyTrack: {
        width: "100%",
        height: 6,
        borderRadius: "999px",
        overflow: "hidden",
        backgroundColor: isDark ? "rgba(148,163,184,0.18)" : "rgba(203,213,225,0.75)",
    },
    occupancyFill: (isFull) => ({
        height: "100%",
        borderRadius: "999px",
        backgroundColor: isFull ? (isDark ? colors.greenAccent[400] : "#16a34a") : (isDark ? "#94a3b8" : "#64748b"),
        transition: "width 0.2s ease",
    }),
    slider: {
        color: isDark ? colors.grey[300] : "#475569",
        "& .MuiSlider-thumb": { backgroundColor: isDark ? colors.grey[100] : "#fff" },
        "& .MuiSlider-track": { backgroundColor: isDark ? colors.grey[300] : "#475569" },
        "& .MuiSlider-rail": { backgroundColor: isDark ? colors.primary[200] : "#cbd5e1" },
    },
    studentsDialogPaper: {
        backgroundColor: colors.primary[400],
        color: colors.grey[100],
        borderRadius: "16px",
        boxShadow: "0px 8px 30px rgba(0,0,0,0.5)",
        overflow: "hidden",
    },
    tableHeader: {
        backgroundColor: isDark ? "#334155" : "#eef2f7",
        color: isDark ? "#fff" : "#0f172a",
        fontWeight: 700,
        fontSize: "0.9rem",
        borderBottom: `1px solid ${colors.primary[500]}`,
    },
    tableRow: {
        "&:nth-of-type(odd)": { backgroundColor: isDark ? "rgba(255,255,255,0.02)" : "rgba(248,250,252,0.75)" },
        "&:hover": { backgroundColor: isDark ? "rgba(148,163,184,0.08)" : "rgba(226,232,240,0.8)" },
        transition: "background-color 0.2s",
    },
    tableCellIndex: {
        color: isDark ? "#a3a3a3" : "#64748b",
        borderBottom: `1px solid ${colors.primary[500]}`,
    },
    tableCellFirstName: {
        color: isDark ? colors.greenAccent[300] : "#0f172a",
        fontWeight: 700,
        borderBottom: `1px solid ${colors.primary[500]}`,
    },
    tableCellDefault: {
        color: colors.grey[100],
        borderBottom: `1px solid ${colors.primary[500]}`,
    },
});

const ClassGridToolbar = ({ colors, isDark }) => (
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
            title: "Classes actives",
            value: stats.totalClasses,
            icon: <SchoolOutlinedIcon />,
            iconBg: isDark ? "rgba(96,165,250,0.14)" : "rgba(37,99,235,0.12)",
            iconColor: isDark ? colors.blueAccent[300] : "#1d4ed8",
        },
        {
            title: "Capacité totale",
            value: stats.totalCapacity,
            icon: <GroupOutlinedIcon />,
            iconBg: isDark ? "rgba(134,239,172,0.14)" : "rgba(22,163,74,0.12)",
            iconColor: isDark ? colors.greenAccent[300] : "#166534",
        },
        {
            title: "Élèves inscrits",
            value: stats.totalStudents,
            icon: <PeopleOutlineIcon />,
            iconBg: isDark ? "rgba(148,163,184,0.14)" : "rgba(100,116,139,0.12)",
            iconColor: isDark ? colors.grey[200] : "#475569",
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
        <Box display="grid" gridTemplateColumns={{ xs: "1fr", sm: "repeat(2, 1fr)", xl: "repeat(4, 1fr)" }} gap="14px" mb="20px">
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

const TeachersSelectCell = ({ teachers, colors, styles, isDark }) => {
    if (!teachers.length) {
        return <Typography variant="body2" color={colors.grey[300]}>Aucun enseignant</Typography>;
    }

    const label = teachers.length === 1 ? "1 enseignant" : `${teachers.length} enseignants`;

    return (
        <FormControl size="small" fullWidth>
            <Select
                value=""
                displayEmpty
                renderValue={() => (
                    <Box display="flex" alignItems="center" gap="8px" minWidth={0}>
                        <Box component="span" sx={styles.countPill}>{teachers.length}</Box>
                        <Typography variant="body2" fontWeight="700" noWrap>
                            {label}
                        </Typography>
                    </Box>
                )}
                sx={styles.listSelectCell}
                MenuProps={{
                    PaperProps: {
                        sx: {
                            ...styles.compactMenuPaper,
                            backgroundColor: isDark ? colors.primary[400] : "#ffffff",
                            color: isDark ? colors.grey[100] : "#0f172a",
                            minWidth: 220,
                            "& .MuiList-root": { p: "8px" },
                        },
                    },
                }}
            >
                {teachers.map((teacher, index) => (
                    <MenuItem
                        key={`${teacher.cin || teacher.id}-${index}`}
                        value={`teacher-${index}`}
                        disabled
                        sx={{
                            opacity: 1,
                            color: isDark ? colors.grey[100] : "#0f172a",
                            py: "10px",
                            px: "12px",
                            borderRadius: "12px",
                            mb: index === teachers.length - 1 ? 0 : "4px",
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
                            <Box component="span" sx={{ ...styles.countPill, width: 28, height: 28, borderRadius: "10px", fontSize: "0.76rem" }}>
                                {index + 1}
                            </Box>
                            <Box minWidth={0}>
                                <Typography variant="body2" fontWeight="700" noWrap color={isDark ? colors.grey[100] : "#0f172a"}>
                                    {`${teacher.firstName || ""} ${teacher.lastName || ""}`.trim()}
                                </Typography>
                                <Typography variant="caption" color={isDark ? colors.grey[300] : "#64748b"}>
                                    Enseignant associe
                                </Typography>
                            </Box>
                        </Box>
                    </MenuItem>
                ))}
            </Select>
        </FormControl>
    );
};

const ClassFormDialog = ({
    open,
    onClose,
    onSubmit,
    formData,
    formError,
    formErrors,
    plannings,
    teachersList,
    onChange,
    colors,
    styles,
    isDark,
    title,
    submitLabel,
    saving,
}) => (
    <Dialog open={open} onClose={onClose} fullWidth maxWidth="md" PaperProps={{ sx: styles.dialogPaper }}>
        <DialogTitle sx={styles.dialogTitle}>{title}</DialogTitle>
        <form onSubmit={onSubmit}>
            <DialogContent sx={{ mt: 2, display: "flex", flexDirection: "column", gap: "18px" }}>
                <Box sx={styles.formCard}>
                    <Typography variant="body2" color={isDark ? colors.grey[300] : "#64748b"} mb="16px">
                        Renseignez les informations de la classe. Les libelles restent visibles pendant la saisie.
                    </Typography>
                    {formError && <Typography color={colors.redAccent[500]} textAlign="center" mb="16px">{formError}</Typography>}
                    <Box display="grid" gridTemplateColumns={{ xs: "1fr", md: "repeat(2, minmax(0, 1fr))" }} gap="16px">
                        <TextField variant="outlined" label="Nom de la classe" name="name" value={formData.name} onChange={onChange} error={!!formErrors.name} helperText={formErrors.name} InputLabelProps={{ shrink: true }} sx={styles.floatingField} fullWidth required />
                        <FormControl fullWidth>
                            <InputLabel shrink sx={styles.floatingSelectLabel}>Année</InputLabel>
                            <Select name="year" value={formData.year} onChange={onChange} label="Année" sx={styles.compactSelect} MenuProps={{ PaperProps: { sx: styles.compactMenuPaper } }}>
                                {plannings.map((planning) => (
                                    <MenuItem key={planning.id} value={planning.label}>{planning.label}</MenuItem>
                                ))}
                            </Select>
                        </FormControl>
                    </Box>
                    <Box mt="16px" px="8px">
                        <Typography gutterBottom color={isDark ? colors.grey[300] : "#475569"} fontWeight="600">
                            Capacite : {formData.capacity || 0}
                        </Typography>
                        <Slider
                            value={Number(formData.capacity) || 0}
                            onChange={(_, value) => onChange({ target: { name: "capacity", value } })}
                            valueLabelDisplay="auto"
                            step={1}
                            min={0}
                            max={50}
                            sx={styles.slider}
                        />
                    </Box>
                    <Box mt="16px">
                        <FormControl fullWidth>
                            <InputLabel shrink sx={styles.floatingSelectLabel}>Enseignants</InputLabel>
                            <Select
                                multiple
                                name="teacher_ids"
                                value={formData.teacher_ids}
                                onChange={onChange}
                                label="Enseignants"
                                sx={styles.compactSelect}
                                MenuProps={{ PaperProps: { sx: styles.compactMenuPaper } }}
                                renderValue={(selected) => (
                                    <Box display="flex" flexWrap="wrap" gap="6px">
                                        {selected.map((id) => {
                                            const teacher = teachersList.find((item) => String(item.cin || item.id) === String(id));
                                            return (
                                                <Chip
                                                    key={id}
                                                    label={teacher ? `${teacher.firstName} ${teacher.lastName}` : id}
                                                    size="small"
                                                    sx={{
                                                        backgroundColor: isDark ? "rgba(148,163,184,0.18)" : "rgba(226,232,240,0.9)",
                                                        color: colors.grey[100],
                                                        fontWeight: 600,
                                                    }}
                                                />
                                            );
                                        })}
                                    </Box>
                                )}
                            >
                                {teachersList.filter((teacher) => !teacher.is_archived).map((teacher) => (
                                    <MenuItem key={String(teacher.cin || teacher.id)} value={String(teacher.cin || teacher.id)}>
                                        <Checkbox checked={formData.teacher_ids.indexOf(String(teacher.cin || teacher.id)) > -1} />
                                        <ListItemText primary={`${teacher.firstName} ${teacher.lastName}`} />
                                    </MenuItem>
                                ))}
                            </Select>
                        </FormControl>
                    </Box>
                </Box>
            </DialogContent>
            <DialogActions sx={styles.dialogActions}>
                <Button onClick={onClose} sx={{ color: colors.grey[100] }}>Annuler</Button>
                <Button type="submit" variant="contained" disabled={saving} sx={{ backgroundColor: isDark ? "#475569" : "#334155", color: "#fff", "&:hover": { backgroundColor: isDark ? "#64748b" : "#475569" } }}>
                    {saving ? "Enregistrement..." : submitLabel}
                </Button>
            </DialogActions>
        </form>
    </Dialog>
);

const DeleteDialog = ({ open, onClose, onConfirm, selectedClass, colors, styles }) => (
    <Dialog open={open} onClose={onClose} PaperProps={{ sx: styles.dialogPaper }}>
        <DialogTitle sx={styles.dialogTitle}>Confirmer la suppression</DialogTitle>
        <DialogContent sx={{ mt: 2 }}>
            <DialogContentText sx={{ color: colors.grey[200] }}>
                Êtes-vous sûr de vouloir supprimer la classe "{selectedClass?.name}" ? Cette action est irréversible.
            </DialogContentText>
        </DialogContent>
        <DialogActions sx={styles.dialogActions}>
            <Button onClick={onClose} sx={{ color: colors.grey[100] }}>Annuler</Button>
            <Button onClick={onConfirm} variant="contained" sx={{ backgroundColor: colors.redAccent[500], color: "#fff" }}>
                Supprimer
            </Button>
        </DialogActions>
    </Dialog>
);

const StudentsDialog = ({ open, onClose, studentsDialogClass, colors, styles, isDark }) => (
    <Dialog open={open} onClose={onClose} fullWidth maxWidth="md" PaperProps={{ sx: styles.studentsDialogPaper }}>
        <DialogTitle sx={{ ...styles.dialogTitle, display: "flex", alignItems: "center", justifyContent: "space-between" }}>
            <Box display="flex" alignItems="center" gap="10px">
                <GroupOutlinedIcon sx={{ color: isDark ? colors.blueAccent[400] : "#475569" }} />
                <span>Élèves inscrits — {studentsDialogClass?.name || ""}</span>
            </Box>
            <IconButton onClick={onClose} sx={{ color: colors.grey[300] }}>
                <CloseIcon />
            </IconButton>
        </DialogTitle>
        <DialogContent sx={{ p: 0 }}>
            {(studentsDialogClass?.students || []).length === 0 ? (
                <Box p="40px" textAlign="center">
                    <Typography variant="h6" color={colors.grey[300]}>Aucun élève inscrit dans cette classe.</Typography>
                </Box>
            ) : (
                <TableContainer component={Paper} sx={{ backgroundColor: "transparent", boxShadow: "none", maxHeight: "60vh" }}>
                    <Table stickyHeader>
                        <TableHead>
                            <TableRow>
                                {["#", "Prénom", "Nom", "Date de naissance", "CIN Parent"].map((header) => (
                                    <TableCell key={header} sx={styles.tableHeader}>{header}</TableCell>
                                ))}
                            </TableRow>
                        </TableHead>
                        <TableBody>
                            {(studentsDialogClass?.students || []).map((student, index) => (
                                <TableRow key={student.id} sx={styles.tableRow}>
                                    <TableCell sx={styles.tableCellIndex}>{index + 1}</TableCell>
                                    <TableCell sx={styles.tableCellFirstName}>{student.firstName}</TableCell>
                                    <TableCell sx={styles.tableCellDefault}>{student.lastName}</TableCell>
                                    <TableCell sx={styles.tableCellDefault}>{student.birthdate || "-"}</TableCell>
                                    <TableCell sx={styles.tableCellIndex}>{student.parent_id || "-"}</TableCell>
                                </TableRow>
                            ))}
                        </TableBody>
                    </Table>
                </TableContainer>
            )}
        </DialogContent>
        <DialogActions sx={{ ...styles.dialogActions, justifyContent: "space-between" }}>
            <Typography variant="body2" color={colors.grey[300]}>
                Total : {(studentsDialogClass?.students || []).length} élève(s)
            </Typography>
            <Button onClick={onClose} variant="contained" sx={{ backgroundColor: isDark ? "#475569" : "#334155", color: "#fff", "&:hover": { backgroundColor: isDark ? "#64748b" : "#475569" } }}>
                Fermer
            </Button>
        </DialogActions>
    </Dialog>
);

const ClassesDataGrid = ({ classesList, loading, columns, styles, colors, tab, onTabChange, onAddClick, isDark }) => {
    const activeClasses = classesList.filter((item) => !item.is_archived);
    const archivedClasses = classesList.filter((item) => item.is_archived);
    const visibleClasses = tab === "active" ? activeClasses : archivedClasses;

    return (
        <Box>
            <Box display="flex" justifyContent="space-between" alignItems={{ xs: "flex-start", md: "center" }} flexDirection={{ xs: "column", md: "row" }} gap="12px" mb="14px">
                <Box>
                    <Typography variant="h5" fontWeight="bold" color={colors.grey[100]}>
                        Gestion des classes
                    </Typography>
                    <Typography variant="body2" color={colors.grey[300]} mt="4px">
                        Consultez un seul tableau et basculez entre les classes actives et archivées.
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
                        <Tab value="active" label={`Actives (${activeClasses.length})`} />
                        <Tab value="archived" label={`Archivées (${archivedClasses.length})`} />
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
                        Ajouter une classe
                    </Button>
                </Box>
            </Box>

            <Box height="62vh" sx={styles.gridContainer}>
                <DataGrid
                    loading={loading}
                    rows={visibleClasses}
                    columns={columns}
                    rowHeight={72}
                    pageSize={10}
                    rowsPerPageOptions={[10, 50, 100]}
                    disableSelectionOnClick
                    components={{ Toolbar: ClassGridToolbar }}
                    componentsProps={{ toolbar: { colors, isDark } }}
                />
            </Box>
        </Box>
    );
};

function ClassManagementPage({ headerTitle, typeName, addDialogTitle }) {
    const theme = useTheme();
    const colors = tokens(theme.palette.mode);
    const isDark = theme.palette.mode === "dark";
    const styles = getStyles(colors, isDark);

    const [classesList, setClassesList] = useState([]);
    const [teachersList, setTeachersList] = useState([]);
    const [plannings, setPlannings] = useState([]);
    const [loading, setLoading] = useState(true);
    const [typeId, setTypeId] = useState(null);
    const [classTab, setClassTab] = useState("active");
    const [isAddDialogOpen, setIsAddDialogOpen] = useState(false);
    const [isEditDialogOpen, setIsEditDialogOpen] = useState(false);
    const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false);
    const [isStudentsDialogOpen, setIsStudentsDialogOpen] = useState(false);
    const [actionMenuPosition, setActionMenuPosition] = useState(null);
    const [actionMenuClass, setActionMenuClass] = useState(null);
    const [selectedClass, setSelectedClass] = useState(null);
    const [studentsDialogClass, setStudentsDialogClass] = useState(null);
    const [addFormData, setAddFormData] = useState({ name: "", year: "", capacity: "", teacher_ids: [] });
    const [addFormError, setAddFormError] = useState("");
    const [addFormErrors, setAddFormErrors] = useState({});
    const [addSaving, setAddSaving] = useState(false);
    const [editFormData, setEditFormData] = useState({ name: "", year: "", capacity: "", teacher_ids: [] });
    const [editFormError, setEditFormError] = useState("");
    const [editFormErrors, setEditFormErrors] = useState({});
    const [editSaving, setEditSaving] = useState(false);
    const [toast, setToast] = useState({ open: false, message: "", severity: "info" });

    const stats = useMemo(() => {
        const activeClasses = classesList.filter((classItem) => !classItem.is_archived);
        return {
            totalClasses: activeClasses.length,
            totalCapacity: activeClasses.reduce((sum, classItem) => sum + (classItem.capacity || 0), 0),
            totalStudents: activeClasses.reduce((sum, classItem) => sum + classItem.studentsCount, 0),
            archived: classesList.filter((classItem) => classItem.is_archived).length,
        };
    }, [classesList]);

    useEffect(() => {
        fetchClasses();
        fetchTeachers();
        fetchPlannings();
        fetchClassTypes();
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, []);

    const showToast = (message, severity = "info") => {
        setToast({ open: true, message, severity });
    };

    const closeToast = (_, reason) => {
        if (reason === "clickaway") return;
        setToast((prev) => ({ ...prev, open: false }));
    };

    const fetchClassTypes = async () => {
        try {
            const response = await api.get("/admin/class-types");
            const types = response.data?.data || [];
            const targetType = types.find((type) => (type.name || "").toLowerCase() === typeName.toLowerCase());
            if (targetType) setTypeId(targetType.id);
        } catch (error) {
            console.error("Failed to fetch class types", error);
        }
    };

    const fetchPlannings = async () => {
        try {
            const response = await api.get("/admin/plannings");
            const data = response.data?.data || [];
            const rows = (Array.isArray(data) ? data : []).map(mapPlanningFromApi).sort((a, b) => b.startYear - a.startYear);
            setPlannings(rows);
            const defaultPlanning = getDefaultPlanning(rows, new Date());
            if (defaultPlanning) {
                setAddFormData((prev) => ({ ...prev, year: defaultPlanning.label }));
            }
        } catch (error) {
            console.error("Failed to fetch plannings", error);
        }
    };

    const fetchTeachers = async () => {
        try {
            const response = await api.get("/admin/teachers");
            setTeachersList(response.data?.data || []);
        } catch (error) {
            console.error("Failed to fetch teachers", error);
        }
    };

    const fetchClasses = async () => {
        try {
            setLoading(true);
            const response = await api.get("/admin/classes");
            const data = response.data?.data || [];
            const filteredClasses = data.filter((classItem) => (classItem.type?.name || "").toLowerCase() === typeName.toLowerCase());
            const formatted = filteredClasses.map((classItem) => ({
                id: classItem.id,
                name: classItem.name || "",
                year: classItem.year || "-",
                capacity: classItem.capacity || 0,
                teachers: classItem.teachers || [],
                teacher_ids: (classItem.teachers || []).map((teacher) => String(teacher.cin || teacher.id)),
                students: classItem.students || [],
                studentsCount: (classItem.students || []).length,
                is_archived: !!classItem.is_archived,
            }));
            setClassesList(formatted);
        } catch (error) {
            console.error("Failed to fetch classes", error);
        } finally {
            setLoading(false);
        }
    };

    const handleClassFormChange = (setter) => (event) => {
        const { name, value } = event.target;
        setter((prev) => ({ ...prev, [name]: value }));
    };

    const openAddDialog = () => {
        const defaultPlanning = getDefaultPlanning(plannings, new Date());
        setAddFormData({ name: "", year: defaultPlanning ? defaultPlanning.label : "", capacity: "", teacher_ids: [] });
        setAddFormError("");
        setAddFormErrors({});
        setIsAddDialogOpen(true);
    };

    const handleAddSubmit = async (event) => {
        event.preventDefault();
        setAddFormError("");
        setAddFormErrors({});

        const validationErrs = validateClassForm(addFormData);
        if (Object.keys(validationErrs).length > 0) {
            setAddFormErrors(validationErrs);
            return;
        }

        if (!typeId) {
            setAddFormError(`Type '${typeName}' introuvable. Veuillez d'abord creer une classe de ce type.`);
            return;
        }

        setAddSaving(true);
        try {
            const selectedPlanning = plannings.find((planning) => planning.label === addFormData.year);
            const resolvedYear = selectedPlanning ? selectedPlanning.startYear : new Date().getFullYear();
            await api.post("/admin/classes", {
                name: addFormData.name.trim(),
                year: resolvedYear,
                capacity: Number(addFormData.capacity) || null,
                type_id: typeId,
                teacher_ids: addFormData.teacher_ids,
            });
            setIsAddDialogOpen(false);
            fetchClasses();
        } catch (error) {
            const validationErrors = error.response?.data?.errors;
            if (validationErrors) {
                const firstKey = Object.keys(validationErrors)[0];
                setAddFormError(validationErrors[firstKey][0]);
            } else {
                setAddFormError(error.response?.data?.message || "Erreur lors de l'ajout.");
            }
        } finally {
            setAddSaving(false);
        }
    };

    const handleEditClick = (classItem) => {
        setSelectedClass(classItem);
        const classYear = classItem.year !== "-" ? Number(classItem.year) : null;
        const matchedPlanning = classYear ? plannings.find((planning) => planning.startYear === classYear) : null;
        setEditFormData({
            name: classItem.name,
            year: matchedPlanning ? matchedPlanning.label : (classItem.year !== "-" ? String(classItem.year) : ""),
            capacity: classItem.capacity || "",
            teacher_ids: classItem.teacher_ids || [],
        });
        setEditFormError("");
        setEditFormErrors({});
        setIsEditDialogOpen(true);
    };

    const handleEditSubmit = async (event) => {
        event.preventDefault();
        setEditFormError("");
        setEditFormErrors({});

        if (!selectedClass) return;

        const validationErrs = validateClassForm(editFormData);
        if (Object.keys(validationErrs).length > 0) {
            setEditFormErrors(validationErrs);
            return;
        }

        setEditSaving(true);
        try {
            const selectedPlanning = plannings.find((planning) => planning.label === editFormData.year);
            const resolvedYear = selectedPlanning
                ? selectedPlanning.startYear
                : (editFormData.year ? parseInt(String(editFormData.year).split("/")[0], 10) : new Date().getFullYear());
            await api.put(`/admin/classes/${selectedClass.id}`, {
                name: editFormData.name.trim(),
                year: resolvedYear,
                capacity: Number(editFormData.capacity) || null,
                teacher_ids: editFormData.teacher_ids,
            });
            setIsEditDialogOpen(false);
            setSelectedClass(null);
            fetchClasses();
        } catch (error) {
            const validationErrors = error.response?.data?.errors;
            if (validationErrors) {
                const firstKey = Object.keys(validationErrors)[0];
                setEditFormError(validationErrors[firstKey][0]);
            } else {
                setEditFormError(error.response?.data?.message || "Erreur lors de la modification.");
            }
        } finally {
            setEditSaving(false);
        }
    };

    const handleDeleteClick = (classItem) => {
        setActionMenuPosition(null);
        setActionMenuClass(null);
        setSelectedClass(classItem);
        setIsDeleteDialogOpen(true);
    };

    const openActionMenu = (event, classItem) => {
        const rect = event.currentTarget.getBoundingClientRect();
        const menuWidth = 190;
        const viewportPadding = 8;
        const left = Math.max(viewportPadding, Math.min(rect.right - menuWidth, window.innerWidth - menuWidth - viewportPadding));
        const top = Math.max(viewportPadding, Math.min(rect.bottom + 4, window.innerHeight - 180));
        setActionMenuPosition({ top, left });
        setActionMenuClass(classItem);
    };

    const closeActionMenu = () => {
        setActionMenuPosition(null);
        setActionMenuClass(null);
    };

    const handleDeleteConfirm = async () => {
        if (!selectedClass) return;

        try {
            await api.delete(`/admin/classes/${selectedClass.id}`);
            setClassesList((prev) => prev.filter((classItem) => classItem.id !== selectedClass.id));
            setIsDeleteDialogOpen(false);
            setSelectedClass(null);
        } catch (error) {
            alert(error.response?.data?.message || "Erreur lors de la suppression.");
        }
    };

    const handleToggleArchiveClick = async (classItem) => {
        try {
            closeActionMenu();
            await api.patch(`/admin/classes/${classItem.id}/toggle-archive`);
            await fetchClasses();
            if (!classItem.is_archived) {
                showToast("Archiver une classe la retire des listes actives. Pour la reutiliser, desarchivez-la.", "warning");
            } else {
                showToast("La classe a ete reactivee.", "success");
            }
        } catch (error) {
            alert(error.response?.data?.message || "Erreur lors de l'archivage.");
        }
    };

    const handleClassTabChange = (_, value) => {
        setClassTab(value);
        if (value === "archived") {
            showToast("Archiver une classe la retire des listes actives. Pour la reutiliser, desarchivez-la.", "warning");
        } else {
            closeToast();
        }
    };

    const columns = [
        {
            field: "name",
            headerName: "Nom",
            flex: 1,
            minWidth: 220,
            cellClassName: "name-column--cell",
            renderCell: ({ row }) => (
                <Box display="flex" flexDirection="column" justifyContent="center" minWidth={0} width="100%">
                    <Typography fontWeight="700" color={colors.grey[100]} noWrap>
                        {row.name}
                    </Typography>
                    {row.is_archived && (
                        <Box display="flex" alignItems="center" gap="6px" minWidth={0}>
                            <Box width="8px" height="8px" borderRadius="999px" flexShrink={0} sx={{ backgroundColor: isDark ? colors.grey[400] : "#94a3b8" }} />
                            <Typography variant="caption" noWrap sx={{ color: colors.grey[300], fontWeight: 600 }}>
                                Archivee
                            </Typography>
                        </Box>
                    )}
                </Box>
            ),
        },
        {
            field: "year",
            headerName: "Année",
            flex: 0.7,
            minWidth: 120,
            headerAlign: "center",
            align: "center",
            renderCell: ({ row }) => {
                if (!row.year || row.year === "-") return "-";
                const parsed = parseInt(row.year, 10);
                if (isNaN(parsed)) return row.year;
                return `${parsed}/${parsed + 1}`;
            },
        },
        {
            field: "teachers",
            headerName: "Enseignants",
            flex: 1.2,
            minWidth: 220,
            sortable: false,
            renderCell: ({ row }) => <TeachersSelectCell teachers={row.teachers || []} colors={colors} styles={styles} isDark={isDark} />,
        },
        {
            field: "studentsCount",
            headerName: "Inscrits / Capacité",
            flex: 1,
            minWidth: 220,
            sortable: false,
            renderCell: ({ row }) => {
                const studentsCount = row.studentsCount || 0;
                const capacity = Number(row.capacity) || 0;
                const ratio = capacity > 0 ? Math.min(studentsCount / capacity, 1) : 0;
                const isFull = capacity > 0 && studentsCount >= capacity;

                return (
                    <Box display="flex" alignItems="center" gap="10px" width="100%" minWidth={0}>
                        <Tooltip title="Voir les élèves">
                            <IconButton
                                size="small"
                                onClick={() => {
                                    setStudentsDialogClass(row);
                                    setIsStudentsDialogOpen(true);
                                }}
                                sx={{ color: isDark ? colors.grey[200] : "#475569", backgroundColor: isDark ? "rgba(148,163,184,0.14)" : "rgba(226,232,240,0.8)", "&:hover": { backgroundColor: isDark ? "rgba(148,163,184,0.22)" : "rgba(203,213,225,0.9)" } }}
                            >
                                <VisibilityOutlinedIcon fontSize="small" />
                            </IconButton>
                        </Tooltip>
                        <Box minWidth={0} flex={1}>
                            <Box display="flex" alignItems="baseline" gap="6px" mb="6px">
                                <Typography fontWeight="700" color={colors.grey[100]}>
                                    {studentsCount} / {capacity}
                                </Typography>
                                <Typography variant="caption" color={isFull ? (isDark ? colors.greenAccent[300] : "#15803d") : colors.grey[300]}>
                                    {isFull ? "Classe pleine" : "Places occupées"}
                                </Typography>
                            </Box>
                            <Box sx={styles.occupancyTrack}>
                                <Box sx={{ ...styles.occupancyFill(isFull), width: `${ratio * 100}%` }} />
                            </Box>
                        </Box>
                    </Box>
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
            <Header title={headerTitle} />
            <StatsCards stats={stats} colors={colors} styles={styles} isDark={isDark} />
            <ClassesDataGrid classesList={classesList} loading={loading} columns={columns} styles={styles} colors={colors} tab={classTab} onTabChange={handleClassTabChange} onAddClick={openAddDialog} isDark={isDark} />
            <ClassFormDialog
                open={isAddDialogOpen}
                onClose={() => setIsAddDialogOpen(false)}
                onSubmit={handleAddSubmit}
                formData={addFormData}
                formError={addFormError}
                formErrors={addFormErrors}
                plannings={plannings}
                teachersList={teachersList}
                onChange={handleClassFormChange(setAddFormData)}
                colors={colors}
                styles={styles}
                isDark={isDark}
                title={addDialogTitle}
                submitLabel="Enregistrer"
                saving={addSaving}
            />
            <ClassFormDialog
                open={isEditDialogOpen}
                onClose={() => setIsEditDialogOpen(false)}
                onSubmit={handleEditSubmit}
                formData={editFormData}
                formError={editFormError}
                formErrors={editFormErrors}
                plannings={plannings}
                teachersList={teachersList}
                onChange={handleClassFormChange(setEditFormData)}
                colors={colors}
                styles={styles}
                isDark={isDark}
                title="Éditer la classe"
                submitLabel="Enregistrer"
                saving={editSaving}
            />
            <DeleteDialog open={isDeleteDialogOpen} onClose={() => setIsDeleteDialogOpen(false)} onConfirm={handleDeleteConfirm} selectedClass={selectedClass} colors={colors} styles={styles} />
            <StudentsDialog open={isStudentsDialogOpen} onClose={() => setIsStudentsDialogOpen(false)} studentsDialogClass={studentsDialogClass} colors={colors} styles={styles} isDark={isDark} />
            <Menu
                open={Boolean(actionMenuPosition && actionMenuClass)}
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
                <MenuItem onClick={() => { handleEditClick(actionMenuClass); closeActionMenu(); }}>
                    <Box display="flex" alignItems="center" gap="10px">
                        <EditOutlinedIcon fontSize="small" />
                        <span>Éditer</span>
                    </Box>
                </MenuItem>
                <MenuItem onClick={() => handleToggleArchiveClick(actionMenuClass)}>
                    <Box display="flex" alignItems="center" gap="10px">
                        {actionMenuClass?.is_archived ? <UnarchiveOutlinedIcon fontSize="small" /> : <ArchiveOutlinedIcon fontSize="small" />}
                        <span>{actionMenuClass?.is_archived ? "Désarchiver" : "Archiver"}</span>
                    </Box>
                </MenuItem>
                <MenuItem onClick={() => handleDeleteClick(actionMenuClass)} sx={{ color: colors.redAccent[400] }}>
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
}

export default ClassManagementPage;
