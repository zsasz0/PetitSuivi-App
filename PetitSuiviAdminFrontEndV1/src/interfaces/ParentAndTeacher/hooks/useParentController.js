import { useParentData } from "./useParentData";
import { useParentActions } from "./useParentActions";
import { useParentUIStates } from "./useParentUIStates";

export const useParentController = () => {
    const data = useParentData();
    const actions = useParentActions({ 
        fetchParentData: data.fetchParentData, 
        setParents: data.setParents 
    });
    const ui = useParentUIStates();

    const handleEditSubmit = async (e) => {
        e.preventDefault();
        await actions.editParent({
            cin: ui.selectedParent.cin, 
            formData: ui.editFormData,
            setErrors: ui.setEditFormErrors, 
            setError: ui.setFormError,
            onSuccess: () => { 
                ui.setIsEditDialogOpen(false); 
                ui.setSelectedParent(null); 
            }
        });
    };

    const handleDeleteConfirm = async () => {
        await actions.removeParent(ui.selectedParent.cin, () => {
            ui.setIsDeleteDialogOpen(false); 
            ui.setSelectedParent(null);
        });
    };

    const handleToggleArchive = async (parent) => {
        ui.closeActionMenu(); 
        await actions.toggleParentArchive(parent.cin); 
    };

    const handleDeleteClick = (parent) => {
        ui.closeActionMenu(); 
        ui.setSelectedParent(parent); 
        ui.setIsDeleteDialogOpen(true);
    };

    return {
        ...data,
        ...actions,
        ...ui,
        handleEditSubmit,
        handleDeleteConfirm,
        handleToggleArchive,
        handleDeleteClick
    };
};
