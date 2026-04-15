import { Box, Typography, Snackbar, Alert } from "@mui/material";
import ArchiveOutlinedIcon from "@mui/icons-material/ArchiveOutlined";
import CheckCircleOutlineOutlinedIcon from "@mui/icons-material/CheckCircleOutlineOutlined";
import GroupOutlinedIcon from "@mui/icons-material/GroupOutlined";
import HourglassEmptyOutlinedIcon from "@mui/icons-material/HourglassEmptyOutlined";
import HighlightOffOutlinedIcon from "@mui/icons-material/HighlightOffOutlined";

import { useTheme } from "@mui/material";
import Header from "../../../components/Header";
import { tokens } from "../../../theme";

import SharedStatsCards from "./SharedStatsCards";
import SharedDataGrid from "./SharedDataGrid";
import { FormDialog, DeleteConfirmDialog } from "./Dialogs";
import { ParentEditForm } from "./ParentForms";
import { ParentActionMenu } from "./ParentActionMenu";
import { getParentColumns } from "../utils/parentColumns";

import { useParentController } from "../hooks/useParentController";
import { calculateParentStats } from "../utils/calculations";
import { getSharedStyles } from "../utils/styles";

const Parent = () => {
    const theme = useTheme();
    const colors = tokens(theme.palette.mode);
    const isDark = theme.palette.mode === "dark";
    const styles = getSharedStyles(colors, isDark);

    const controller = useParentController();
    
    // Destructuring UI states, Data, and handlers
    const {
        parents, loading,
        isEditDialogOpen, setIsEditDialogOpen,
        isDeleteDialogOpen, setIsDeleteDialogOpen,
        selectedParent,
        editFormData, editFormErrors, formError,
        handleEditFormChange, handleGeneratePassword,
        parentTab, handleTabChange,
        toast, closeToast,
        actionMenuPosition, actionMenuParent, closeActionMenu, openActionMenu,
        
        openEditDialog, handleDeleteClick,
        handleEditSubmit, handleDeleteConfirm, handleToggleArchive,
        updateParentApprovalStatus
    } = controller;

    const columns = getParentColumns(colors, isDark, styles, {
        onOpenMenu: openActionMenu,
        onUpdateStatus: updateParentApprovalStatus
    });

    const statsObj = calculateParentStats(parents);
    const statsItems = [
        { title: "Total parents", value: statsObj.total, icon: <GroupOutlinedIcon />, iconBg: isDark ? "rgba(96,165,250,0.14)" : "rgba(37,99,235,0.12)", iconColor: isDark ? colors.blueAccent[300] : "#1d4ed8" },
        { title: "Approuvés", value: statsObj.approved, icon: <CheckCircleOutlineOutlinedIcon />, iconBg: isDark ? "rgba(134,239,172,0.14)" : "rgba(22,163,74,0.12)", iconColor: isDark ? colors.greenAccent[300] : "#166534" },
        { title: "En attente", value: statsObj.pending, icon: <HourglassEmptyOutlinedIcon />, iconBg: isDark ? "rgba(251,191,36,0.14)" : "rgba(245,158,11,0.12)", iconColor: isDark ? "#fbbf24" : "#b45309" },
        { title: "Rejetés", value: statsObj.rejected, icon: <HighlightOffOutlinedIcon />, iconBg: isDark ? "rgba(248,113,113,0.14)" : "rgba(220,38,38,0.12)", iconColor: isDark ? colors.redAccent[300] : "#991b1b" },
        { title: "Archivés", value: statsObj.archived, icon: <ArchiveOutlinedIcon />, iconBg: isDark ? "rgba(148,163,184,0.14)" : "rgba(148,163,184,0.14)", iconColor: isDark ? colors.grey[300] : "#64748b" }
    ];

    return (
        <Box m="20px">
            <Header title="PARENTS" />
            <SharedStatsCards items={statsItems} styles={styles} colors={colors} isDark={isDark} />
            <SharedDataGrid 
                title="Gestion des parents" subtitle="Consultez un seul tableau et basculez entre les comptes."
                rows={parents.filter(p => (parentTab === "active" ? !p.is_archived : p.is_archived))} loading={loading} columns={columns} styles={styles} colors={colors} tab={parentTab} onTabChange={handleTabChange}
                activeCount={parents.filter(p => !p.is_archived).length} archivedCount={parents.filter(p => p.is_archived).length} isDark={isDark}
            />

            <FormDialog title="Éditer le parent" open={isEditDialogOpen} onClose={() => setIsEditDialogOpen(false)} onSubmit={handleEditSubmit} styles={styles} colors={colors} isDark={isDark}>
                <Typography variant="body2" color={colors.grey[300]} mb="16px">Modifiez les informations du compte.</Typography>
                {formError && <Typography color={colors.redAccent[500]} textAlign="center" mb="16px">{formError}</Typography>}
                <ParentEditForm formData={editFormData} onChange={handleEditFormChange} errors={editFormErrors} styles={styles} onGeneratePassword={handleGeneratePassword} />
            </FormDialog>

            <DeleteConfirmDialog title="Confirmer la suppression du parent" open={isDeleteDialogOpen} itemName={selectedParent?.name} onClose={() => setIsDeleteDialogOpen(false)} onConfirm={handleDeleteConfirm} styles={styles} colors={colors} />
            
            <ParentActionMenu 
                position={actionMenuPosition} parent={actionMenuParent} colors={colors} onClose={closeActionMenu}
                onEdit={openEditDialog}
                onToggleArchive={handleToggleArchive}
                onDelete={handleDeleteClick}
            />

            <Snackbar open={toast.open} autoHideDuration={6000} onClose={closeToast} anchorOrigin={{ vertical: "top", horizontal: "right" }}>
                <Alert onClose={closeToast} severity={toast.severity} sx={{ width: "100%", borderRadius: "8px", whiteSpace: "pre-line" }}>
                    {toast.message}
                </Alert>
            </Snackbar>
        </Box>
    );
};

export default Parent;
