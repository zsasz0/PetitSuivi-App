import { Alert, Box, Menu, MenuItem, Snackbar } from "@mui/material";
import { useTheme } from "@mui/material";
import ArchiveOutlinedIcon from "@mui/icons-material/ArchiveOutlined";
import DeleteOutlineIcon from "@mui/icons-material/DeleteOutline";
import EditOutlinedIcon from "@mui/icons-material/EditOutlined";
import UnarchiveOutlinedIcon from "@mui/icons-material/UnarchiveOutlined";
import { useEffect, useMemo, useState } from "react";

import Header from "../../../components/Header";
import { tokens } from "../../../theme";

import { useClassController } from "../hooks/useClassController";
import { getClassColumns } from "./classColumns";
import { getStyles } from "../utils/styles";

import ClassesDataGrid from "./ClassesDataGrid";
import ClassFormDialog from "./ClassFormDialog";
import DeleteDialog from "./DeleteDialog";
import StatsCards from "./StatsCards";
import StudentsDialog from "./StudentsDialog";

function ClassManagementPage({ headerTitle, typeName, addDialogTitle }) {
    const theme = useTheme();
    const colors = tokens(theme.palette.mode);
    const isDark = theme.palette.mode === "dark";
    const styles = getStyles(colors, isDark);

    const [classTab, setClassTab] = useState("active");
    const [isStudentsDialogOpen, setIsStudentsDialogOpen] = useState(false);
    const [studentsDialogClass, setStudentsDialogClass] = useState(null);
    const [toast, setToast] = useState({ open: false, message: "", severity: "info" });

    const showToast = (message, severity = "info") => {
        setToast({ open: true, message, severity });
    };

    const closeToast = (_, reason) => {
        if (reason === "clickaway") return;
        setToast((prev) => ({ ...prev, open: false }));
    };

    const {
    classesList,
    teachersList,
    plannings,
    loading,
    isAddDialogOpen,
    setIsAddDialogOpen,
    openAddDialog,
    isEditDialogOpen,
    setIsEditDialogOpen,
    isDeleteDialogOpen,
    setIsDeleteDialogOpen,
    actionMenuPosition,
    actionMenuClass,
    openActionMenu,
    closeActionMenu,
    selectedClass,
    addFormData,
    addFormError,
    addFormErrors,
    addSaving,
    handleAddSubmit,
    setAddFormData,
    editFormData,
    editFormError,
    editFormErrors,
    editSaving,
    handleEditSubmit,
    setEditFormData,
    handleDeleteConfirm,
    handleToggleArchiveClick,
    handleEditClick,
    handleDeleteClick,
    loadData,
    handleClassFormChange,
  } = useClassController(typeName, showToast);

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
        loadData();
    }, [loadData]);

    const handleClassTabChange = (_, value) => {
        setClassTab(value);
        if (value === "archived") {
            showToast("Archiver une classe la retire des listes actives. Pour la reutiliser, desarchivez-la.", "warning");
        } else {
            closeToast();
        }
    };

    const columns = useMemo(() => getClassColumns({
        colors,
        isDark,
        styles,
        setStudentsDialogClass,
        setIsStudentsDialogOpen,
        openActionMenu,
    }), [colors, isDark, styles, openActionMenu]);

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
