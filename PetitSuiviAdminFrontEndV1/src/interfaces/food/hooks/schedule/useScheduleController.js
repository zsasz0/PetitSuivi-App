import { useScheduleUIStates } from './useScheduleUIStates';
import { useScheduleData } from './useScheduleData';
import { useScheduleActions } from './useScheduleActions';
import { getMonday } from '../../utils/scheduleHelpers';

export const useScheduleController = () => {
    const ui = useScheduleUIStates();
    const data = useScheduleData({ ui });
    const actions = useScheduleActions({ ui, data });

    return {
        state: {
            loading: data.loading,
            aiEnabled: data.aiEnabled,
            lunchOptions: data.lunchOptions,
            snackOptions: data.snackOptions,
            plannings: data.plannings,
            selectedPlanningId: data.selectedPlanningId,
            weekStart: ui.weekStart,
            navigationBounds: data.navigationBounds,
            showBlankSlate: ui.showBlankSlate,
            weeklyMeals: ui.weeklyMeals,
            dbExceptionsDejeuner: data.dbExceptionsDejeuner,
            dbExceptionsGouter: data.dbExceptionsGouter,
            openDropdown: ui.openDropdown,
            expandedChild: ui.expandedChild,
            childMealOverrides: ui.childMealOverrides,
            saving: ui.saving,
            presets: data.presets,
            pickDialogOpen: ui.pickDialogOpen,
            pickCategory: ui.pickCategory,
            pickDayIndex: ui.pickDayIndex,
            savedMenusDialogOpen: ui.savedMenusDialogOpen,
            presetNamePromptOpen: ui.presetNamePromptOpen,
            presetName: ui.presetName,
            presetError: ui.presetError,
            allMeals: data.allMeals,
            getMonday
        },
        actions: {
            setSelectedPlanningId: data.setSelectedPlanningId,
            setWeekStart: ui.setWeekStart,
            handleCreateFromScratch: actions.handleCreateFromScratch,
            setSavedMenusDialogOpen: ui.setSavedMenusDialogOpen,
            setOpenDropdown: ui.setOpenDropdown,
            setExpandedChild: ui.setExpandedChild,
            setChildMealOverrides: ui.setChildMealOverrides,
            setPickDayIndex: ui.setPickDayIndex,
            setPickCategory: ui.setPickCategory,
            setPickDialogOpen: ui.setPickDialogOpen,
            toggleMealSelection: actions.toggleMealSelection,
            handleSaveWeek: actions.handleSaveWeek,
            handleLoadPresetLocal: actions.handleLoadPresetLocal,
            handleDeletePresetLocal: actions.handleDeletePresetLocal,
            setPresetName: ui.setPresetName,
            setPresetError: ui.setPresetError,
            setPresetNamePromptOpen: ui.setPresetNamePromptOpen,
            handleSavePresetLocal: actions.handleSavePresetLocal,
            checkChildConflict: actions.checkChildConflict,
            isExceptionResolved: actions.isExceptionResolved,
            setWeeklyMeals: ui.setWeeklyMeals,
            setShowBlankSlate: ui.setShowBlankSlate
        }
    };
};
