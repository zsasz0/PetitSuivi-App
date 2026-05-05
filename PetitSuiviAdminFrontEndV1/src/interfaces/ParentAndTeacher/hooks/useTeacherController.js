import { useTeacherData } from "./useTeacherData";
import { useTeacherActions } from "./useTeacherActions";
import { useTeacherUIStates } from "./useTeacherUIStates";

export const useTeacherController = () => {
    const data = useTeacherData();
    const actions = useTeacherActions({ 
        fetchTeacherData: data.fetchTeacherData, 
        setTeachers: data.setTeachers 
    });
    const ui = useTeacherUIStates();

    const handleEditSubmit = async (e) => {
        e.preventDefault();
        await actions.editTeacher({
            cin: ui.selectedTeacher.cin, 
            formData: ui.editFormData, 
            sendCredentials: ui.sendEditCredentials,
            setErrors: ui.setEditFormErrors, 
            setError: ui.setFormError, 
            onSuccess: () => { 
                ui.setIsEditDialogOpen(false); 
                ui.setSelectedTeacher(null); 
            }
        });
    };

    const handleAddSubmit = async (e) => {
        e.preventDefault();
        await actions.addTeacher({
            formData: ui.addFormData, 
            sendCredentials: ui.sendAddCredentials,
            setErrors: ui.setAddFormErrors, 
            setError: ui.setAddFormError, 
            setSaving: ui.setAddSaving,
            onSuccess: () => {
                ui.setAddFormData({ 
                    cin: "", firstName: "", lastName: "", birthdate: "", phone: "", email: "", adresse: "", password: "", password_confirmation: "" 
                });
                ui.setShowAddPassword(false);
                ui.setSendAddCredentials(true); 
                ui.setIsAddDialogOpen(false);
            }
        });
    };

    const handleDeleteConfirm = async () => {
        await actions.removeTeacher(ui.selectedTeacher.cin, () => {
            ui.setIsDeleteDialogOpen(false); 
            ui.setSelectedTeacher(null);
        });
    };

    const handleToggleArchive = async (teacher) => {
        ui.closeActionMenu(); 
        await actions.toggleTeacherArchive(teacher.cin); 
    };

    const handleDeleteClick = (teacher) => {
        ui.closeActionMenu(); 
        ui.setSelectedTeacher(teacher); 
        ui.setIsDeleteDialogOpen(true);
    };

    const handleAddClick = () => {
        ui.setAddFormError(""); 
        ui.setAddFormErrors({}); 
        ui.setIsAddDialogOpen(true);
    };

    return {
        ...data,
        ...actions,
        ...ui,
        handleEditSubmit,
        handleAddSubmit,
        handleDeleteConfirm,
        handleToggleArchive,
        handleDeleteClick,
        handleAddClick
    };
};
