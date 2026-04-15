import React, { useMemo } from 'react';
import { Box, useTheme, Typography } from "@mui/material";
import { tokens } from "../../../theme";
import Header from "../../../components/Header";
import { useManageExceptionsController } from "../hooks/manageExceptions/useManageExceptionsController";
import { getFoodExceptionsStyles } from "../utils/styles";
import {
    AiDisabledBanner, ControlsBar, InfoBanner, LoadingState, EmptyState, ChildCard, AddExceptionDialog
} from "../components/FoodExceptionsComponents";
import Button from "@mui/material/Button";
import AddCircleOutlineIcon from "@mui/icons-material/AddCircleOutline";
import Groups2OutlinedIcon from "@mui/icons-material/Groups2Outlined";
import RestaurantOutlinedIcon from "@mui/icons-material/RestaurantOutlined";

const ManageFoodExceptions = () => {
    const theme = useTheme();
    const colors = tokens(theme.palette.mode);
    const isDark = theme.palette.mode === 'dark';
    const sxParams = useMemo(() => getFoodExceptionsStyles(colors, isDark), [colors, isDark]);

    const { state, actions } = useManageExceptionsController();

    const getSeverityColor = (count) => {
        if (count >= 3) return colors.redAccent[500];
        if (count >= 1) return "#f59e0b";
        return colors.greenAccent[500];
    };

    const totalExceptions = useMemo(() =>
        state.filteredChildren.reduce((sum, child) => sum + (child.exception_count || 0), 0),
        [state.filteredChildren]
    );

    return (
        <Box m="20px">
            <Box display="flex" justifyContent="space-between" alignItems="center">
                <Header title="EXCEPTIONS ALIMENTAIRES" />
                <Button
                    variant="contained"
                    startIcon={<AddCircleOutlineIcon />}
                    onClick={actions.handleOpenAddDialog}
                    sx={sxParams.sectionActionButton}
                >
                    Ajouter une exception
                </Button>
            </Box>

            {!state.aiEnabled && <AiDisabledBanner colors={colors} sx={sxParams} />}

            <ControlsBar
                plannings={state.plannings}
                selectedPlanningId={state.selectedPlanningId}
                onPlanningChange={(e) => actions.setSelectedPlanningId(e.target.value)}
                searchTerm={state.searchTerm}
                onSearchChange={(e) => actions.setSearchTerm(e.target.value)}
                colors={colors} sx={sxParams}
            />

            <Box sx={sxParams.summaryGrid}>
                {[
                    { label: "Enfants concernés", value: state.filteredChildren.length, accent: colors.greenAccent[500], icon: <Groups2OutlinedIcon fontSize="small" /> },
                    { label: "Repas interdits", value: totalExceptions, accent: colors.redAccent[400], icon: <RestaurantOutlinedIcon fontSize="small" /> },
                ].map((item) => (
                    <Box key={item.label} sx={sxParams.summaryCard(item.accent)}>
                        <Box>
                            <Typography sx={sxParams.summaryLabel}>{item.label}</Typography>
                            <Typography sx={sxParams.summaryValue}>{item.value}</Typography>
                        </Box>
                        <Box sx={sxParams.summaryIconWrap(item.accent)}>{item.icon}</Box>
                    </Box>
                ))}
            </Box>

            <InfoBanner count={state.filteredChildren.length} colors={colors} sx={sxParams} />

            {state.loading && <LoadingState colors={colors} />}

            {state.error && (
                <Typography color={colors.redAccent[500]} textAlign="center" mb="20px">
                    {state.error}
                </Typography>
            )}

            {!state.loading && !state.error && state.filteredChildren.length === 0 && (
                <EmptyState colors={colors} sx={sxParams} />
            )}

            {!state.loading && !state.error && state.filteredChildren.length > 0 && (
                <Box display="flex" flexDirection="column" gap="12px">
                    {state.filteredChildren.map(child => (
                        <ChildCard
                            key={child.child_id}
                            child={child}
                            isExpanded={state.expandedChild === child.child_id}
                            onToggle={() => actions.toggleExpand(child.child_id)}
                            getSeverityColor={getSeverityColor}
                            colors={colors} sx={sxParams}
                            onDeleteException={actions.handleDeleteException}
                        />
                    ))}
                </Box>
            )}

            <AddExceptionDialog
                open={state.addDialogOpen}
                onClose={() => actions.setAddDialogOpen(false)}
                onSubmit={actions.handleAddException}
                colors={colors} sx={sxParams}
                allChildren={state.allChildren}
                allMeals={state.allMeals}
                saving={state.addSaving}
                selectedPlanningId={state.selectedPlanningId}
            />
        </Box>
    );
};

export default ManageFoodExceptions;
