import { createTeacher, updateTeacher, deleteTeacher, toggleTeacherArchive as apiToggleTeacherArchive } from "../api/apiService";
import { validateTeacherForm } from "../../../utils/validation";
import { applyApiErrors } from "../utils/calculations";

export const useTeacherActions = ({ fetchTeacherData, setTeachers }) => {
    
    const addTeacher = async ({
        formData, sendCredentials, setErrors, setError, setSaving, onSuccess
    }) => {
        setError(""); setErrors({});
        const validationErrs = validateTeacherForm(formData, false);
        if (Object.keys(validationErrs).length > 0) {
            setErrors(validationErrs);
            return false;
        }

        setSaving(true);
        const payload = { 
            ...formData, 
            cin: Number(formData.cin), 
            send_credentials: sendCredentials, 
            firstName: formData.firstName.trim(), 
            lastName: formData.lastName.trim(), 
            email: formData.email.trim() 
        };

        try {
            await createTeacher(payload);
            await fetchTeacherData();
            if (onSuccess) onSuccess();
            return true;
        } catch (error) {
            applyApiErrors(error.response?.data?.errors, setErrors, setError, error.response?.data?.message || "Erreur lors de l'ajout.");
            return false;
        } finally {
            setSaving(false);
        }
    };

    const editTeacher = async ({
        cin, formData, sendCredentials, setErrors, setError, onSuccess
    }) => {
        setError(""); setErrors({});
        const validationErrs = validateTeacherForm(formData, true);
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
        if (formData.password) payload.send_credentials = sendCredentials;

        try {
            await updateTeacher(cin, payload);
            await fetchTeacherData();
            if (onSuccess) onSuccess();
            return true;
        } catch (error) {
            applyApiErrors(error.response?.data?.errors, setErrors, setError, error.response?.data?.message || "Erreur lors de la modification.");
            return false;
        }
    };

    const removeTeacher = async (cin, onSuccess) => {
        try {
            await deleteTeacher(cin);
            setTeachers(prev => prev.filter((t) => t.cin !== cin));
            if (onSuccess) onSuccess();
            return true;
        } catch (error) {
            alert(error.response?.data?.message || "Erreur lors de la suppression.");
            return false;
        }
    };

    const toggleTeacherArchive = async (cin) => {
        await apiToggleTeacherArchive(cin);
        await fetchTeacherData();
    };

    return { addTeacher, editTeacher, removeTeacher, toggleTeacherArchive };
};
