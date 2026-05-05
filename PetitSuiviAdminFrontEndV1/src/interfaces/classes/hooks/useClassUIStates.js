import { useState, useCallback } from "react";

export const useClassUIStates = () => {
    const [loading, setLoading] = useState(true);
    const [isAddDialogOpen, setIsAddDialogOpen] = useState(false);
    const [isEditDialogOpen, setIsEditDialogOpen] = useState(false);
    const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false);
    
    const [actionMenuPosition, setActionMenuPosition] = useState(null);
    const [actionMenuClass, setActionMenuClass] = useState(null);

    const openActionMenu = useCallback((event, classItem) => {
        const rect = event.currentTarget.getBoundingClientRect();
        const menuWidth = 190;
        const viewportPadding = 8;
        const left = Math.max(viewportPadding, Math.min(rect.right - menuWidth, window.innerWidth - menuWidth - viewportPadding));
        const top = Math.max(viewportPadding, Math.min(rect.bottom + 4, window.innerHeight - 180));
        setActionMenuPosition({ top, left });
        setActionMenuClass(classItem);
    }, []);

    const closeActionMenu = useCallback(() => {
        setActionMenuPosition(null);
        setActionMenuClass(null);
    }, []);

    return {
        loading, setLoading,
        isAddDialogOpen, setIsAddDialogOpen,
        isEditDialogOpen, setIsEditDialogOpen,
        isDeleteDialogOpen, setIsDeleteDialogOpen,
        actionMenuPosition, setActionMenuPosition,
        actionMenuClass, setActionMenuClass,
        openActionMenu, closeActionMenu,
    };
};
