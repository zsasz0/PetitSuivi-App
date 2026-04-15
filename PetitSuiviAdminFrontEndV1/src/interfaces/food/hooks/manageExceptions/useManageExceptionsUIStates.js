import { useState } from 'react';

export const useManageExceptionsUIStates = () => {
    const [expandedChild, setExpandedChild] = useState(null);
    const [searchTerm, setSearchTerm] = useState("");
    const [addDialogOpen, setAddDialogOpen] = useState(false);
    const [addSaving, setAddSaving] = useState(false);

    const toggleExpand = (childId) => setExpandedChild(prev => prev === childId ? null : childId);

    return {
        expandedChild, setExpandedChild, toggleExpand,
        searchTerm, setSearchTerm,
        addDialogOpen, setAddDialogOpen,
        addSaving, setAddSaving
    };
};
