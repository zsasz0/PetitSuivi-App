import { useState } from "react";
import { generateRandomPassword } from "../utils/calculations";

export const useParentUIStates = () => {
    // Dialogs
    const [isEditDialogOpen, setIsEditDialogOpen] = useState(false);
    const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false);
    
    // Selections
    const [selectedParent, setSelectedParent] = useState(null);
    
    // Forms
    const [editFormData, setEditFormData] = useState({ 
        cin: "", firstName: "", lastName: "", birthdate: "", phone: "", email: "", adresse: "", password: "", password_confirmation: "" 
    });
    const [formError, setFormError] = useState("");
    const [editFormErrors, setEditFormErrors] = useState({});
    
    // Table/Tabs
    const [parentTab, setParentTab] = useState("active");
    
    // Toast
    const [toast, setToast] = useState({ open: false, message: "", severity: "info" });
    const showToast = (message, severity = "info") => setToast({ open: true, message, severity });
    const closeToast = (_, reason) => { if (reason === "clickaway") return; setToast(p => ({ ...p, open: false })); };

    const handleTabChange = (_, val) => {
        setParentTab(val);
        if (val === "archived") {
            showToast(
                "Archiver un parent empêche immédiatement sa connexion à l'application mobile.\nPour réactiver l'accès, désarchivez le compte.", 
                "warning"
            );
        } else {
            closeToast();
        }
    };

    // Action Menu
    const [actionMenuPosition, setActionMenuPosition] = useState(null);
    const [actionMenuParent, setActionMenuParent] = useState(null);

    const openActionMenu = (event, parent) => {
        const rect = event.currentTarget.getBoundingClientRect();
        setActionMenuPosition({ top: rect.bottom + 4, left: rect.left - 150 });
        setActionMenuParent(parent);
    };

    const closeActionMenu = () => {
        setActionMenuPosition(null);
        setActionMenuParent(null);
    };

    // Form handlers
    const openEditDialog = (parent) => {
        closeActionMenu();
        setSelectedParent(parent);
        setEditFormData({ ...parent, password: "", password_confirmation: "" });
        setFormError("");
        setEditFormErrors({});
        setIsEditDialogOpen(true);
    };

    const handleEditFormChange = (e) => {
        setEditFormData({ ...editFormData, [e.target.name]: e.target.value });
    };

    const handleGeneratePassword = () => {
        const pwd = generateRandomPassword(); 
        setEditFormData(p => ({ ...p, password: pwd, password_confirmation: pwd }));
    };

    return {
        isEditDialogOpen, setIsEditDialogOpen,
        isDeleteDialogOpen, setIsDeleteDialogOpen,
        selectedParent, setSelectedParent,
        editFormData, setEditFormData,
        formError, setFormError,
        editFormErrors, setEditFormErrors,
        openEditDialog, handleEditFormChange, handleGeneratePassword,
        parentTab, handleTabChange,
        toast, showToast, closeToast,
        actionMenuPosition, actionMenuParent, openActionMenu, closeActionMenu
    };
};
