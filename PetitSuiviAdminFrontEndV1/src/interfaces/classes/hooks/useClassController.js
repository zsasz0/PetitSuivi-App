import { useClassUIStates } from "./useClassUIStates";
import { useClassData } from "./useClassData";
import { useClassForms } from "./useClassForms";
import { useCallback } from "react";

export const useClassController = (typeName, showToast) => {
    const ui = useClassUIStates();
    const data = useClassData({ ui, typeName, showToast });
    const forms = useClassForms({ ui, data, typeName });

    const { loadData: dataLoadData, loadClasses } = data;
    const { setAddFormData } = forms;

    // Compose loadData to hydrate forms natively
    const loadData = useCallback(() => dataLoadData(setAddFormData), [dataLoadData, setAddFormData]);

    return {
        ...ui,
        ...data,
        ...forms,
        loadData,
        fetchClasses: loadClasses,
    };
};
