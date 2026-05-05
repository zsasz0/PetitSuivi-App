import { useState } from 'react';
import { getMonday } from '../../utils/scheduleHelpers';

export const useScheduleUIStates = () => {
    const [weekStart, setWeekStart] = useState(() => getMonday(new Date()));
    const [openDropdown, setOpenDropdown] = useState(null);
    const [expandedChild, setExpandedChild] = useState(null);
    const [pickDialogOpen, setPickDialogOpen] = useState(false);
    const [pickDayIndex, setPickDayIndex] = useState(null);
    const [pickCategory, setPickCategory] = useState("lunch");
    const [showBlankSlate, setShowBlankSlate] = useState(false);
    const [savedMenusDialogOpen, setSavedMenusDialogOpen] = useState(false);
    const [presetNamePromptOpen, setPresetNamePromptOpen] = useState(false);
    const [presetName, setPresetName] = useState("");
    const [presetError, setPresetError] = useState("");
    const [childMealOverrides, setChildMealOverrides] = useState({});
    const [saving, setSaving] = useState(false);
    const [weeklyMeals, setWeeklyMeals] = useState(null);

    return {
        weekStart, setWeekStart,
        openDropdown, setOpenDropdown,
        expandedChild, setExpandedChild,
        pickDialogOpen, setPickDialogOpen,
        pickDayIndex, setPickDayIndex,
        pickCategory, setPickCategory,
        showBlankSlate, setShowBlankSlate,
        savedMenusDialogOpen, setSavedMenusDialogOpen,
        presetNamePromptOpen, setPresetNamePromptOpen,
        presetName, setPresetName,
        presetError, setPresetError,
        childMealOverrides, setChildMealOverrides,
        saving, setSaving,
        weeklyMeals, setWeeklyMeals
    };
};
