import { useState } from 'react';

export const useManageMealsUIStates = () => {
    const [toast, setToast] = useState({ open: false, message: "", severity: "info" });
    const [activeTab, setActiveTab] = useState(0); 
    const [newItem, setNewItem] = useState(""); 
    const [addSaving, setAddSaving] = useState(false); 
    const [addError, setAddError] = useState(""); 
    const [isAddDialogOpen, setIsAddDialogOpen] = useState(false);
    const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false);
    const [deletingItem, setDeletingItem] = useState(null);
    const [checkingExceptions, setCheckingExceptions] = useState(false); 
    const [exceptionResults, setExceptionResults] = useState(null); 
    const [ignoredExceptions, setIgnoredExceptions] = useState([]); 
    const [pendingMeal, setPendingMeal] = useState(null); 
    const [confirmSaving, setConfirmSaving] = useState(false); 
    const [editingCommentId, setEditingCommentId] = useState(null); 
    const [overrideText, setOverrideText] = useState(""); 

    const closeToast = () => setToast(prev => ({ ...prev, open: false }));

    return {
        toast, setToast, closeToast,
        activeTab, setActiveTab,
        newItem, setNewItem,
        addSaving, setAddSaving,
        addError, setAddError,
        isAddDialogOpen, setIsAddDialogOpen,
        isDeleteDialogOpen, setIsDeleteDialogOpen,
        deletingItem, setDeletingItem,
        checkingExceptions, setCheckingExceptions,
        exceptionResults, setExceptionResults,
        ignoredExceptions, setIgnoredExceptions,
        pendingMeal, setPendingMeal,
        confirmSaving, setConfirmSaving,
        editingCommentId, setEditingCommentId,
        overrideText, setOverrideText
    };
};
