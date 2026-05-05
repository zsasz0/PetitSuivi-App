import { useInscriptionsUIStates } from "./useInscriptionsUIStates";
import { useInscriptionsData } from "./useInscriptionsData";
import { useInscriptionsActions } from "./useInscriptionsActions";

export const useInscriptionsController = () => {
    const ui = useInscriptionsUIStates();
    const data = useInscriptionsData({ ui });
    const actions = useInscriptionsActions({ ui, data });

    return {
        ...ui,
        ...data,
        ...actions,

        mealReviewDirty: actions.detailMealExceptions !== null,

        toggleDetailMealExceptionChecked: (index, checked) => actions.toggleMealExceptionChecked(actions.setDetailMealExceptions, index, checked),
        toggleAiReviewMealExceptionChecked: (index, checked) => actions.toggleMealExceptionChecked(actions.setAiReviewMealExceptions, index, checked),
    };
};
