import { Box, Typography, Snackbar, Alert } from "@mui/material";
import SchoolOutlinedIcon from "@mui/icons-material/SchoolOutlined";
import BoltOutlinedIcon from "@mui/icons-material/BoltOutlined";
import PersonOutlineIcon from "@mui/icons-material/PersonOutline";
import ArchiveOutlinedIcon from "@mui/icons-material/ArchiveOutlined";

import { useTheme } from "@mui/material";
import Header from "../../../components/Header";
import { tokens } from "../../../theme";

import SharedStatsCards from "./SharedStatsCards";
import SharedDataGrid from "./SharedDataGrid";
import { FormDialog } from "./Dialogs";
import { TeacherAddForm, TeacherEditForm } from "./TeacherForms";
import { TeacherActionMenu } from "./TeacherActionMenu";
import { getTeacherColumns } from "../utils/teacherColumns";

import { useTeacherController } from "../hooks/useTeacherController";
import { getSharedStyles } from "../utils/styles";

const Teacher = () => {
    const theme = useTheme();
    const colors = tokens(theme.palette.mode);
    const isDark = theme.palette.mode === "dark";
    const styles = getSharedStyles(colors, isDark);

    const controller = useTeacherController();

    const {
        teachers, loading, activeTeacherCount,

        isEditDialogOpen, setIsEditDialogOpen,
        isAddDialogOpen, setIsAddDialogOpen,

        editFormData, editFormErrors, formError, sendEditCredentials, setSendEditCredentials,
        addFormData, addFormErrors, addFormError, addSaving, showAddPassword, setShowAddPassword, sendAddCredentials, setSendAddCredentials,

        teacherTab, handleTabChange,
        toast, closeToast,
        actionMenuPosition, actionMenuTeacher, openActionMenu, closeActionMenu,

        openEditDialog, handleAddFormChange, handleEditFormChange, handleGenerateAddPassword, handleGenerateEditPassword,
        handleEditSubmit, handleAddSubmit, handleToggleArchive, handleAddClick
    } = controller;

    const columns = getTeacherColumns(colors, isDark, {
        onOpenMenu: openActionMenu
    });

    const statsItems = [
        { title: "Total enseignants", value: teachers.length, icon: <SchoolOutlinedIcon />, iconBg: isDark ? "rgba(134, 239, 172, 0.14)" : "rgba(22, 163, 74, 0.12)", iconColor: isDark ? colors.greenAccent[300] : "#166534" },
        { title: "Actifs", value: activeTeacherCount, icon: <BoltOutlinedIcon />, iconBg: isDark ? "rgba(96, 165, 250, 0.14)" : "rgba(37, 99, 235, 0.12)", iconColor: isDark ? colors.blueAccent[300] : "#1d4ed8" },
        { title: "Disponibles", value: teachers.filter(t => t.status === "Disponible").length, icon: <PersonOutlineIcon />, iconBg: isDark ? "rgba(148, 163, 184, 0.14)" : "rgba(100, 116, 139, 0.12)", iconColor: isDark ? colors.grey[200] : "#475569" },
        { title: "Archivés", value: teachers.filter(t => t.status === "Archivé").length, icon: <ArchiveOutlinedIcon />, iconBg: isDark ? "rgba(148, 163, 184, 0.14)" : "rgba(148, 163, 184, 0.14)", iconColor: isDark ? colors.grey[300] : "#64748b" }
    ];

    return (
        <Box m="20px">
            <Header title="ENSEIGNANTS" />
            <SharedStatsCards items={statsItems} styles={styles} colors={colors} isDark={isDark} />
            <SharedDataGrid 
                title="Gestion des enseignants" subtitle="Consultez et basculez entre comptes actifs et archivés."
                rows={teachers.filter(t => (teacherTab === "active" ? !t.is_archived : t.is_archived))} loading={loading} columns={columns} styles={styles} colors={colors} tab={teacherTab} onTabChange={handleTabChange}
                onAddClick={handleAddClick} addLabel="Ajouter enseignant"
                activeCount={teachers.filter(t => !t.is_archived).length} archivedCount={teachers.filter(t => t.is_archived).length} isDark={isDark}
            />

            <FormDialog title="Ajouter enseignant" open={isAddDialogOpen} onClose={() => setIsAddDialogOpen(false)} onSubmit={handleAddSubmit} saving={addSaving} styles={styles} colors={colors} isDark={isDark}>
                <Typography variant="body2" color={colors.grey[300]} mb="16px">Renseignez les infos de l'enseignant.</Typography>
                {addFormError && <Typography color={colors.redAccent[500]} textAlign="center" mb="16px">{addFormError}</Typography>}
                <TeacherAddForm formData={addFormData} onChange={handleAddFormChange} errors={addFormErrors} styles={styles} colors={colors} showPassword={showAddPassword} onTogglePassword={() => setShowAddPassword(!showAddPassword)} onGeneratePassword={handleGenerateAddPassword} sendCredentials={sendAddCredentials} onToggleSendCredentials={setSendAddCredentials} />
            </FormDialog>

            <FormDialog title="Éditer l'enseignant" open={isEditDialogOpen} onClose={() => setIsEditDialogOpen(false)} onSubmit={handleEditSubmit} styles={styles} colors={colors} isDark={isDark}>
                <Typography variant="body2" color={colors.grey[300]} mb="16px">Modifiez les informations du compte.</Typography>
                {formError && <Typography color={colors.redAccent[500]} textAlign="center" mb="16px">{formError}</Typography>}
                <TeacherEditForm formData={editFormData} onChange={handleEditFormChange} errors={editFormErrors} styles={styles} onGeneratePassword={handleGenerateEditPassword} sendCredentials={sendEditCredentials} onToggleSendCredentials={setSendEditCredentials} />
            </FormDialog>

            <TeacherActionMenu 
                position={actionMenuPosition} teacher={actionMenuTeacher} colors={colors} onClose={closeActionMenu}
                onEdit={openEditDialog}
                onToggleArchive={handleToggleArchive}
            />

            <Snackbar open={toast.open} autoHideDuration={6000} onClose={closeToast} anchorOrigin={{ vertical: "top", horizontal: "right" }}>
                <Alert onClose={closeToast} severity={toast.severity} sx={{ width: "100%", borderRadius: "8px", whiteSpace: "pre-line" }}>
                    {toast.message}
                </Alert>
            </Snackbar>
        </Box>
    );
};

export default Teacher;
