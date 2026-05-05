import React, { useMemo, useCallback } from 'react';
import { Box, useTheme, CircularProgress } from "@mui/material";
import { tokens } from "../../../theme";
import Header from "../../../components/Header";
import { useScheduleController } from "../hooks/schedule/useScheduleController";
import { formatDate } from "../utils/scheduleHelpers";
import { getScheduleStyles } from "../utils/styles";
import {
    StatsCards, AiDisabledBanner, YearSelector, WeekNavigator, BlankSlate,
    ActionButtons, WeekGrid, MealPickerDialog, SavedMenusDialog, SavePresetDialog,
    WeekConflictsTable
} from "../components/ScheduleComponents";
import api from "../../../api/axios";

const ScheduleMeals = () => {
    const theme = useTheme();
    const colors = tokens(theme.palette.mode);
    const styles = useMemo(() => getScheduleStyles(colors), [colors]);

    const { state, actions } = useScheduleController();

    const weekEndDate = useMemo(() => new Date(state.weekStart.getTime() + 4 * 86400000), [state.weekStart]);

    const isCurrentWeek = state.getMonday(new Date()).getTime() === state.weekStart.getTime();

    const openMealPicker = (dayIndex, category) => {
        actions.setPickDayIndex(dayIndex);
        actions.setPickCategory(category);
        actions.setPickDialogOpen(true);
    };

    const saveOverrideToApi = useCallback(async (row, selectedNames) => {
        try {
            const norm = (str) => (str || '').toString().trim().toLowerCase();
            const originalMealName = norm(row.currentMeal);
            const originalMeal = state.allMeals.find(m => norm(m.name) === originalMealName);
            const replacementMealIds = selectedNames.map(name => {
                if (name === "Aucun (Retirer ce plat)") return null;
                const matchedMeal = state.allMeals.find(m => norm(m.name) === norm(name));
                return matchedMeal ? matchedMeal.id : undefined;
            }).filter(id => id !== undefined);

            if (originalMeal) {
                await api.post('/admin/child-food-exception-overrides', {
                    child_id: row.childId,
                    original_meal_id: originalMeal.id,
                    replacement_meal_ids: replacementMealIds,
                    day_index: row.dayIdx,
                    week_start: formatDate(state.weekStart)
                });
            }
        } catch (err) { console.error("Failed to save override", err); }
    }, [state.allMeals, state.weekStart]);

    return (
        <Box m="20px">
            <Header title="PLANNING DES REPAS" />

            {!state.aiEnabled && <AiDisabledBanner colors={colors} styles={styles} />}

            <StatsCards
                lunchCount={state.lunchOptions.length}
                snackCount={state.snackOptions.length}
                colors={colors} styles={styles}
            />

            <YearSelector
                plannings={state.plannings}
                selectedPlanningId={state.selectedPlanningId}
                setSelectedPlanningId={actions.setSelectedPlanningId}
                colors={colors} styles={styles}
            />

            <WeekNavigator
                weekStart={state.weekStart}
                weekEndDate={weekEndDate}
                isCurrentWeek={isCurrentWeek}
                navigationBounds={state.navigationBounds}
                goToPreviousWeek={() => actions.setWeekStart(new Date(state.weekStart.getTime() - 7 * 86400000))}
                goToNextWeek={() => actions.setWeekStart(new Date(state.weekStart.getTime() + 7 * 86400000))}
                goToThisWeek={() => actions.setWeekStart(state.getMonday(new Date()))}
                colors={colors} styles={styles}
            />

            {state.loading ? (
                <Box display="flex" justifyContent="center" p="40px">
                    <CircularProgress sx={{ color: colors.greenAccent[500] }} />
                </Box>
            ) : state.showBlankSlate ? (
                <BlankSlate
                    handleCreateFromScratch={actions.handleCreateFromScratch}
                    openSavedMenus={() => actions.setSavedMenusDialogOpen(true)}
                    colors={colors} styles={styles}
                />
            ) : state.weeklyMeals ? (
                <>
                    <WeekGrid
                        aiEnabled={state.aiEnabled}
                        weeklyMeals={state.weeklyMeals}
                        weekStart={state.weekStart}
                        dbExceptionsDejeuner={state.dbExceptionsDejeuner}
                        dbExceptionsGouter={state.dbExceptionsGouter}
                        openDropdown={state.openDropdown}
                        setOpenDropdown={actions.setOpenDropdown}
                        expandedChild={state.expandedChild}
                        setExpandedChild={actions.setExpandedChild}
                        childMealOverrides={state.childMealOverrides}
                        checkChildConflict={actions.checkChildConflict}
                        isExceptionResolved={actions.isExceptionResolved}
                        toggleDropdown={(d, t) => actions.setOpenDropdown(prev => prev === `${d}-${t}` ? null : `${d}-${t}`)}
                        toggleChildExpansion={(k) => actions.setExpandedChild(prev => prev === k ? null : k)}
                        openMealPicker={openMealPicker}
                        colors={colors} styles={styles}
                    />
                    <ActionButtons
                        openSavedMenus={() => actions.setSavedMenusDialogOpen(true)}
                        openPresetPrompt={() => { actions.setPresetName(""); actions.setPresetError(""); actions.setPresetNamePromptOpen(true); }}
                        handleSaveWeek={actions.handleSaveWeek}
                        saving={state.saving}
                        colors={colors} styles={styles}
                    />
                    {state.aiEnabled && (
                        <WeekConflictsTable
                            weeklyMeals={state.weeklyMeals}
                            dbExceptionsDejeuner={state.dbExceptionsDejeuner}
                            dbExceptionsGouter={state.dbExceptionsGouter}
                            checkChildConflict={actions.checkChildConflict}
                            lunchOptions={state.lunchOptions}
                            snackOptions={state.snackOptions}
                            childMealOverrides={state.childMealOverrides}
                            setChildMealOverrides={actions.setChildMealOverrides}
                            weekStart={state.weekStart}
                            allMeals={state.allMeals}
                            colors={colors} styles={styles}
                            saveOverrideToApi={saveOverrideToApi}
                        />
                    )}
                </>
            ) : null}

            <MealPickerDialog
                open={state.pickDialogOpen}
                onClose={() => actions.setPickDialogOpen(false)}
                pickCategory={state.pickCategory}
                pickDayIndex={state.pickDayIndex}
                weeklyMeals={state.weeklyMeals}
                lunchOptions={state.lunchOptions}
                snackOptions={state.snackOptions}
                toggleMealSelection={actions.toggleMealSelection}
                colors={colors} styles={styles}
            />
            <SavedMenusDialog
                open={state.savedMenusDialogOpen}
                onClose={() => actions.setSavedMenusDialogOpen(false)}
                presets={state.presets}
                onLoadPreset={actions.handleLoadPresetLocal}
                onDeletePreset={actions.handleDeletePresetLocal}
                colors={colors} styles={styles}
            />
            <SavePresetDialog
                open={state.presetNamePromptOpen}
                onClose={() => { actions.setPresetNamePromptOpen(false); actions.setPresetError(""); }}
                presetName={state.presetName}
                setPresetName={actions.setPresetName}
                presetError={state.presetError}
                onSave={actions.handleSavePresetLocal}
                colors={colors} styles={styles}
            />
        </Box>
    );
};

export default ScheduleMeals;
