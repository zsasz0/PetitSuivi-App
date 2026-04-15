/**
 * @file useController.js
 * @description Facade hook composing states and actions for the Login interface.
 */
import { useLoginStates } from './useLoginStates';
import { useLoginActions } from './useLoginActions';

export const useController = () => {
    const states = useLoginStates();
    const actions = useLoginActions(states);

    return {
        state: {
            email: states.email,
            password: states.password,
            showPassword: states.showPassword,
            error: states.error,
            loading: states.loading,
        },
        actions: {
            setEmail: states.setEmail,
            setPassword: states.setPassword,
            setShowPassword: states.setShowPassword,
            handleSubmit: actions.handleSubmit,
        }
    };
};
