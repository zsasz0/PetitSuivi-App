import { updateParent, deleteParent, toggleParentArchive as apiToggleParentArchive, updateParentApprovalStatus as apiUpdateParentApprovalStatus } from "../api/apiService";
import { validateParentForm } from "../../../utils/validation";
import { applyApiErrors } from "../utils/calculations";

export const useParentActions = ({ fetchParentData, setParents }) => {
    
    const editParent = async ({
        cin, formData, setErrors, setError, onSuccess
    }) => {
        setError(""); setErrors({});
        const validationErrs = validateParentForm(formData, true);
        if (Object.keys(validationErrs).length > 0) {
            setErrors(validationErrs);
            return false;
        }

        const payload = { 
            ...formData, 
            firstName: formData.firstName.trim(), 
            lastName: formData.lastName.trim(), 
            email: formData.email.trim() 
        };
        
        try {
            await updateParent(cin, payload);
            await fetchParentData();
            if (onSuccess) onSuccess();
            return true;
        } catch (error) {
            applyApiErrors(error.response?.data?.errors, setErrors, setError, error.response?.data?.message || "Erreur lors de la modification.");
            return false;
        }
    };

    const removeParent = async (cin, onSuccess) => {
        try {
            await deleteParent(cin);
            setParents(prev => prev.filter((p) => p.cin !== cin));
            if (onSuccess) onSuccess();
            return true;
        } catch (error) {
            alert(error.response?.data?.message || "Erreur lors de la suppression.");
            return false;
        }
    };

    const toggleParentArchive = async (cin) => {
        await apiToggleParentArchive(cin);
        await fetchParentData();
    };

    const updateParentApprovalStatus = async (cin, status) => {
        await apiUpdateParentApprovalStatus(cin, status);
        await fetchParentData();
    };

    return {
        editParent,
        removeParent,
        toggleParentArchive,
        updateParentApprovalStatus
    };
};
