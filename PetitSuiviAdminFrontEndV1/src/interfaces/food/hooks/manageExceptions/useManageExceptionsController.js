import { useManageExceptionsUIStates } from './useManageExceptionsUIStates';
import { useManageExceptionsData } from './useManageExceptionsData';
import { useManageExceptionsActions } from './useManageExceptionsActions';

export const useManageExceptionsController = () => {
    const ui = useManageExceptionsUIStates();
    const data = useManageExceptionsData({ ui });
    const actions = useManageExceptionsActions({ ui, data });

    return {
        state: {
            children: data.children,
            loading: data.loading,
            error: data.error,
            expandedChild: ui.expandedChild,
            searchTerm: ui.searchTerm,
            aiEnabled: data.aiEnabled,
            plannings: data.plannings,
            selectedPlanningId: data.selectedPlanningId,
            addDialogOpen: ui.addDialogOpen,
            addSaving: ui.addSaving,
            allChildren: data.allChildren,
            allMeals: data.allMeals,
            filteredChildren: data.filteredChildren
        },
        actions: {
            setSearchTerm: ui.setSearchTerm,
            setSelectedPlanningId: data.setSelectedPlanningId,
            toggleExpand: ui.toggleExpand,
            handleOpenAddDialog: actions.handleOpenAddDialog,
            setAddDialogOpen: ui.setAddDialogOpen,
            handleAddException: actions.handleAddException,
            handleDeleteException: actions.handleDeleteException
        }
    };
};
