import { useManageMealsUIStates } from './useManageMealsUIStates';
import { useManageMealsData } from './useManageMealsData';
import { useManageMealsActions } from './useManageMealsActions';

export const useManageMealsController = () => {
    const ui = useManageMealsUIStates();
    const data = useManageMealsData();
    const actions = useManageMealsActions({ ui, data });

    return {
        state: {
            toast: ui.toast,
            loading: data.loading,
            lunchOptions: data.lunchOptions,
            snackOptions: data.snackOptions,
            activeTab: ui.activeTab,
            newItem: ui.newItem,
            addSaving: ui.addSaving,
            addError: ui.addError,
            isAddDialogOpen: ui.isAddDialogOpen,
            aiEnabled: data.aiEnabled,
            scannedMealIds: data.scannedMealIds,
            isDeleteDialogOpen: ui.isDeleteDialogOpen,
            deletingItem: ui.deletingItem,
            checkingExceptions: ui.checkingExceptions,
            exceptionResults: ui.exceptionResults,
            ignoredExceptions: ui.ignoredExceptions,
            pendingMeal: ui.pendingMeal,
            confirmSaving: ui.confirmSaving,
            editingCommentId: ui.editingCommentId,
            overrideText: ui.overrideText
        },
        actions: {
            closeToast: ui.closeToast,
            setActiveTab: ui.setActiveTab,
            setNewItem: ui.setNewItem,
            setAddError: ui.setAddError,
            setIsAddDialogOpen: ui.setIsAddDialogOpen,
            setDeletingItem: ui.setDeletingItem,
            setIsDeleteDialogOpen: ui.setIsDeleteDialogOpen,
            handleAddItem: actions.handleAddItem,
            handleConfirmSave: actions.handleConfirmSave,
            handleCancelPending: actions.handleCancelPending,
            handleOverrideComment: actions.handleOverrideComment,
            handleDeleteConfirm: actions.handleDeleteConfirm,
            setIgnoredExceptions: ui.setIgnoredExceptions,
            setEditingCommentId: ui.setEditingCommentId,
            setOverrideText: ui.setOverrideText
        }
    };
};
