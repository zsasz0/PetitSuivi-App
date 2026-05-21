import { useState } from "react";
import { generateRandomPassword } from "../utils/calculations";

export const useTeacherUIStates = () => {
    // Dialogs
    const [isEditDialogOpen, setIsEditDialogOpen] = useState(false);
    const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false);
    const [isAddDialogOpen, setIsAddDialogOpen] = useState(false);
    
    // Selections
    const [selectedTeacher, setSelectedTeacher] = useState(null);
    
    // Edit Form
    const [editFormData, setEditFormData] = useState({ 
        cin: "", firstName: "", lastName: "", birthdate: "", phone: "", email: "", adresse: "", password: "", password_confirmation: "" 
    });
    const [formError, setFormError] = useState("");
    const [editFormErrors, setEditFormErrors] = useState({});
    const [sendEditCredentials, setSendEditCredentials] = useState(false);

    // Add Form
    const [addFormData, setAddFormData] = useState({ 
        cin: "", firstName: "", lastName: "", birthdate: "", phone: "", email: "", adresse: "", password: "", password_confirmation: "" 
    });
    const [addFormError, setAddFormError] = useState("");
    const [addFormErrors, setAddFormErrors] = useState({});
    const [addSaving, setAddSaving] = useState(false);
    const [showAddPassword, setShowAddPassword] = useState(false);
    const [sendAddCredentials, setSendAddCredentials] = useState(true);

    // Table/Tabs
    const [teacherTab, setTeacherTab] = useState("active");
    
    // Toast
    const [toast, setToast] = useState({ open: false, message: "", severity: "info" });
    const showToast = (message, severity = "info") => setToast({ open: true, message, severity });
    const closeToast = (_, reason) => { if (reason === "clickaway") return; setToast(p => ({ ...p, open: false })); };

    const handleTabChange = (_, val) => {
        setTeacherTab(val);
        if (val === "archived") {
            showToast(
                "Archiver un enseignant empêche immédiatement sa connexion à l'application mobile.\nPour réactiver l'accès, désarchivez le compte.", 
                "warning"
            );
        } else {
            closeToast();
        }
    };

    // Action Menu
    const [actionMenuPosition, setActionMenuPosition] = useState(null);
    const [actionMenuTeacher, setActionMenuTeacher] = useState(null);

    const openActionMenu = (event, teacher) => {
        const rect = event.currentTarget.getBoundingClientRect();
        setActionMenuPosition({ top: rect.bottom + 4, left: rect.left - 150 });
        setActionMenuTeacher(teacher);
    };

    const closeActionMenu = () => {
        setActionMenuPosition(null);
        setActionMenuTeacher(null);
    };

    const openEditDialog = (teacher) => {
        closeActionMenu();
        setSelectedTeacher(teacher);
        setEditFormData({ ...teacher, password: "", password_confirmation: "" });
        setFormError(""); 
        setEditFormErrors({}); 
        setSendEditCredentials(false);
        setIsEditDialogOpen(true);
    };

    const handleAddFormChange = (e) => setAddFormData({ ...addFormData, [e.target.name]: e.target.value });
    const handleEditFormChange = (e) => setEditFormData({ ...editFormData, [e.target.name]: e.target.value });

    const handleGenerateAddPassword = () => {
        const pwd = generateRandomPassword(); 
        setAddFormData(p => ({ ...p, password: pwd, password_confirmation: pwd }));
    };

    const handleGenerateEditPassword = () => {
        const pwd = generateRandomPassword(); 
        setEditFormData(p => ({ ...p, password: pwd, password_confirmation: pwd }));
    };

    return {
        isEditDialogOpen, setIsEditDialogOpen,
        isDeleteDialogOpen, setIsDeleteDialogOpen,
        isAddDialogOpen, setIsAddDialogOpen,
        selectedTeacher, setSelectedTeacher,
        editFormData, setEditFormData,
        formError, setFormError,
        editFormErrors, setEditFormErrors,
        sendEditCredentials, setSendEditCredentials,
        addFormData, setAddFormData,
        addFormError, setAddFormError,
        addFormErrors, setAddFormErrors,
        addSaving, setAddSaving,
        showAddPassword, setShowAddPassword,
        sendAddCredentials, setSendAddCredentials,
        teacherTab, handleTabChange,
        toast, showToast, closeToast,
        actionMenuPosition, actionMenuTeacher,
        openActionMenu, closeActionMenu,
        openEditDialog, handleAddFormChange, handleEditFormChange,
        handleGenerateAddPassword, handleGenerateEditPassword
    };
};
