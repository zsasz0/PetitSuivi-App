import { usePaymentsUIStates } from "./usePaymentsUIStates";
import { usePaymentsData } from "./usePaymentsData";
import { usePaymentsTransactions } from "./usePaymentsTransactions";

export const usePaymentsController = () => {
    const ui = usePaymentsUIStates();
    const data = usePaymentsData({ ui });
    const transactions = usePaymentsTransactions({ ui, data });

    return {
        ...ui,
        ...data,
        ...transactions,
    };
};
