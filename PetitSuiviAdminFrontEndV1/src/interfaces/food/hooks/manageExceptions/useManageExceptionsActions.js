import { getChildren, getMeals, addFoodException, deleteFoodException, getFoodExceptions } from '../../api/foodExceptionsService';

export const useManageExceptionsActions = ({ ui, data }) => {
    const handleOpenAddDialog = async () => {
        try {
            const [childRes, mealRes] = await Promise.all([getChildren(data.selectedPlanningId), getMeals()]);
            const childList = (childRes.data?.data || []).map(c => ({
                child_id: c.id || c.child_id || c.ChildID,
                class_name: c.class_name || c.className || '',
                child_name: `${c.firstName || c.Firstname || ''} ${c.lastName || c.Lastname || ''}`.trim(),
            }));
            data.setAllChildren(childList);
            data.setAllMeals(mealRes.data?.data || mealRes.data || []);
        } catch { /* ignore */ }
        ui.setAddDialogOpen(true);
    };

    const handleAddException = async (payload) => {
        ui.setAddSaving(true);
        try {
            await addFoodException(payload);
            ui.setAddDialogOpen(false);
            if (data.selectedPlanningId) {
                const res = await getFoodExceptions(data.selectedPlanningId);
                data.setChildren(res.data?.data || []);
            }
        } catch (err) {
            alert('Erreur: ' + (err?.response?.data?.message || err.message));
        } finally {
            ui.setAddSaving(false);
        }
    };

    const handleDeleteException = async (exceptionId) => {
        if (!window.confirm('Supprimer cette exception alimentaire ?')) return;
        try {
            await deleteFoodException(exceptionId);
            if (data.selectedPlanningId) {
                const res = await getFoodExceptions(data.selectedPlanningId);
                data.setChildren(res.data?.data || []);
            }
        } catch (err) {
            alert('Erreur: ' + (err?.response?.data?.message || err.message));
        }
    };

    return { handleOpenAddDialog, handleAddException, handleDeleteException };
};
