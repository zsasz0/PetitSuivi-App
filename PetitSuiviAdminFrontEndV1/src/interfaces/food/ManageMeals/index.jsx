import React, { useMemo } from 'react';
import { Box, useTheme, Tab, Tabs, Snackbar, Alert, Tooltip } from "@mui/material";
import { tokens } from "../../../theme";
import Header from "../../../components/Header";
import { useManageMealsController } from "../hooks/manageMeals/useManageMealsController";
import { getFoodItemsStyles } from "../utils/styles";
import {
    AiDisabledBannerMeals,
    StatsCardsMeals,
    DataGridSection,
    AddSection,
    AddItemDialog,
    DeleteDialog,
    ExceptionDialog
} from "../components/FoodItemsComponents";
import IconButton from "@mui/material/IconButton";
import DeleteOutlineIcon from "@mui/icons-material/DeleteOutline";
import Typography from "@mui/material/Typography";

const ManageMeals = () => {
    const theme = useTheme();
    const colors = tokens(theme.palette.mode);
    const isDark = theme.palette.mode === 'dark';
    const sxParams = useMemo(() => getFoodItemsStyles(colors, isDark), [colors, isDark]);

    const { state, actions } = useManageMealsController();

    const getDeleteTooltip = (meal) => {
        if (meal?.isUsedInMenu && meal?.isUsedInException) return "Utilisé dans des menus et des exceptions alimentaires";
        if (meal?.isUsedInMenu) return "Utilisé dans un ou plusieurs menus";
        if (meal?.isUsedInException) return "Utilisé dans une ou plusieurs exceptions alimentaires";
        return "Supprimer";
    };

    const columns = [
        { field: "id", headerName: "ID", flex: 0.25, minWidth: 64, align: "center", headerAlign: "center" },
        {
            field: "name",
            headerName: "Nom",
            flex: 1,
            cellClassName: "name-column--cell",
            renderCell: ({ value }) => (
                <Box display="flex" alignItems="center" height="100%" py="8px">
                    <Typography fontWeight={700} color={colors.grey[100]}>{value}</Typography>
                </Box>
            ),
        },
        {
            field: "actions", headerName: "Actions", flex: 0.28, minWidth: 96, align: "center", headerAlign: "center", sortable: false, filterable: false,
            renderCell: ({ row }) => (
                <Tooltip title={getDeleteTooltip(row)}>
                    <span>
                    <IconButton sx={sxParams.dangerIconButton} size="small" disabled={!row.isDeletable} onClick={() => actions.handleDeleteClick(row)}>
                        <DeleteOutlineIcon fontSize="small" />
                    </IconButton>
                    </span>
                </Tooltip>
            ),
        },
    ];

    const currentList = state.activeTab === 0 ? state.lunchOptions : state.snackOptions;

    return (
        <Box m="20px">
            <Header title="GÉRER LES ALIMENTS" />

            {!state.aiEnabled && <AiDisabledBannerMeals colors={colors} />}

            <StatsCardsMeals
                lunchCount={state.lunchOptions.length}
                snackCount={state.snackOptions.length}
                colors={colors} styles={sxParams}
            />

            <Box sx={sxParams.tabsWrap}>
                <Tabs value={state.activeTab} onChange={(_, v) => actions.setActiveTab(v)} sx={sxParams.tabs}>
                    <Tab label=" Déjeuner" />
                    <Tab label=" Goûter" />
                </Tabs>
            </Box>

            <AddSection
                activeTab={state.activeTab} styles={sxParams}
                setAddError={actions.setAddError} setNewItem={actions.setNewItem}
                setIsAddDialogOpen={actions.setIsAddDialogOpen}
            />

            <DataGridSection
                loading={state.loading} currentList={currentList}
                columns={columns} styles={sxParams} colors={colors} isDark={isDark}
            />

            <AddItemDialog
                open={state.isAddDialogOpen}
                onClose={() => { actions.setIsAddDialogOpen(false); actions.setAddError(""); actions.setNewItem(""); }}
                activeTab={state.activeTab} aiEnabled={state.aiEnabled}
                newItem={state.newItem} setNewItem={actions.setNewItem}
                handleAddItem={actions.handleAddItem} addError={state.addError}
                addSaving={state.addSaving} checkingExceptions={state.checkingExceptions}
                colors={colors} styles={sxParams}
            />

            <DeleteDialog
                isDeleteDialogOpen={state.isDeleteDialogOpen}
                setIsDeleteDialogOpen={actions.setIsDeleteDialogOpen}
                handleDeleteConfirm={actions.handleDeleteConfirm}
                deletingItem={state.deletingItem} colors={colors} styles={sxParams}
            />

            <ExceptionDialog
                exceptionResults={state.exceptionResults}
                handleCancelPending={actions.handleCancelPending}
                pendingMeal={state.pendingMeal}
                ignoredExceptions={state.ignoredExceptions}
                setIgnoredExceptions={actions.setIgnoredExceptions}
                editingCommentId={state.editingCommentId}
                setEditingCommentId={actions.setEditingCommentId}
                overrideText={state.overrideText}
                setOverrideText={actions.setOverrideText}
                handleOverrideComment={actions.handleOverrideComment}
                handleConfirmSave={actions.handleConfirmSave}
                confirmSaving={state.confirmSaving}
                colors={colors} styles={sxParams}
            />

            <Snackbar
                open={state.toast.open}
                autoHideDuration={6000}
                onClose={actions.closeToast}
                anchorOrigin={{ vertical: "top", horizontal: "right" }}
                sx={{ zIndex: 3000 }}
            >
                <Alert onClose={actions.closeToast} severity={state.toast.severity} sx={{ width: "100%" }} variant="filled">
                    {state.toast.message}
                </Alert>
            </Snackbar>
        </Box>
    );
};

export default ManageMeals;
