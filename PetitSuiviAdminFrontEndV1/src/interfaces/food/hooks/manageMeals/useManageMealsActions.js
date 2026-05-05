import { checkMealExceptions, addMeal, updateDietaryComment, deleteMeal } from '../../api/foodItemsService';

export const useManageMealsActions = ({ ui, data }) => {
    const getDeleteBlockedMessage = (meal) => {
        if (meal?.isUsedInMenu && meal?.isUsedInException) {
            return "Impossible de supprimer cet aliment car il est utilisé dans des menus et des exceptions alimentaires.";
        }
        if (meal?.isUsedInMenu) {
            return "Impossible de supprimer cet aliment car il est utilisé dans un ou plusieurs menus.";
        }
        if (meal?.isUsedInException) {
            return "Impossible de supprimer cet aliment car il est utilisé dans une ou plusieurs exceptions alimentaires.";
        }

        return "";
    };

    const handleDeleteClick = (meal) => {
        const blockedMessage = getDeleteBlockedMessage(meal);
        if (blockedMessage) {
            ui.setToast({ open: true, message: blockedMessage, severity: "warning" });
            return;
        }

        ui.setDeletingItem(meal);
        ui.setIsDeleteDialogOpen(true);
    };

    const handleAddItem = async (e) => {
        e.preventDefault();
        const mealName = ui.newItem.trim();
        if (!mealName) return;

        const existingMeal = [...data.lunchOptions, ...data.snackOptions].find(m => m.name.toLowerCase() === mealName.toLowerCase());
        if (existingMeal) { ui.setAddError(`L'aliment "${mealName}" existe déjà !`); return; }

        const category = ui.activeTab === 0 ? 'lunch' : 'snack';
        ui.setAddError(""); ui.setAddSaving(true);
        try {
            const latestAiEnabled = await data.checkAiStatus();
            if (latestAiEnabled) {
                ui.setCheckingExceptions(true);
                try {
                    const checkRes = await checkMealExceptions({ meal_name: mealName, ingredients: [], category });
                    if (checkRes.data?.success !== true) {
                        ui.setAddError((checkRes.data?.message || "La vérification IA a échoué.") + " Désactivez l'IA dans Paramètres pour continuer sans vérification.");
                        return;
                    }
                    ui.setPendingMeal({ name: mealName, category });
                    ui.setExceptionResults({ mealName, exceptions: checkRes.data?.exceptions || [], aiChecked: true });
                    ui.setNewItem(""); ui.setIsAddDialogOpen(false);
                } catch (checkErr) {
                    ui.setAddError((checkErr?.response?.data?.message || "Échec IA.") + " Désactivez l'IA pour forcer l'ajout.");
                } finally { ui.setCheckingExceptions(false); }
            } else {
                await addMeal({ name: mealName, category });
                ui.setNewItem(""); ui.setIsAddDialogOpen(false); data.loadData();
            }
        } catch (err) { ui.setAddError(err?.response?.data?.message || "Erreur."); } finally { ui.setAddSaving(false); }
    };

    const handleConfirmSave = async () => {
        if (!ui.pendingMeal || !ui.exceptionResults) return;
        ui.setConfirmSaving(true);
        try {
            const validExceptions = (ui.exceptionResults.exceptions || []).filter(exc => !ui.ignoredExceptions.includes(exc.child_id)).map(exc => ({ child_id: exc.child_id, reason: exc.reason }));
            await addMeal({ name: ui.pendingMeal.name, category: ui.pendingMeal.category, exceptions: validExceptions });
            ui.setToast({ open: true, message: "Ajouté avec succès.", severity: "success" });
            data.loadData();
        } catch (err) { ui.setToast({ open: true, message: err?.response?.data?.message || "Erreur.", severity: "error" }); }
        finally { ui.setConfirmSaving(false); ui.setPendingMeal(null); ui.setExceptionResults(null); ui.setIgnoredExceptions([]); }
    };

    const handleCancelPending = () => { ui.setPendingMeal(null); ui.setExceptionResults(null); ui.setIgnoredExceptions([]); ui.setEditingCommentId(null); ui.setOverrideText(""); };

    const handleOverrideComment = async (childId, newComment) => {
        try {
            await updateDietaryComment(childId, { dietary_comment: newComment });
            ui.setToast({ open: true, message: "Profil de l'enfant mis à jour avec succès.", severity: "success" });
            ui.setEditingCommentId(null); ui.setOverrideText("");
        } catch (err) { ui.setToast({ open: true, message: 'Erreur: ' + (err?.response?.data?.message || err.message), severity: 'error' }); }
    };

    const handleDeleteConfirm = async () => {
        if (!ui.deletingItem) return;

        const blockedMessage = getDeleteBlockedMessage(ui.deletingItem);
        if (blockedMessage) {
            ui.setToast({ open: true, message: blockedMessage, severity: "warning" });
            ui.setIsDeleteDialogOpen(false);
            ui.setDeletingItem(null);
            return;
        }

        try {
            await deleteMeal(ui.deletingItem.id);
            ui.setToast({ open: true, message: "Supprimé avec succès.", severity: "success" });
            data.loadData(); ui.setIsDeleteDialogOpen(false); ui.setDeletingItem(null);
        } catch (err) { ui.setToast({ open: true, message: err?.response?.data?.message || "Erreur.", severity: "error" }); }
    };

    return {
        handleAddItem, handleConfirmSave, handleCancelPending, handleOverrideComment, handleDeleteClick, handleDeleteConfirm
    };
};
