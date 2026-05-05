/**
 * @file useLoginActions.js
 * @description Domain hook handling form submissions and authentication logic.
 */
import { useAuth } from '../../../context/AuthContext';
import { useNavigate } from 'react-router-dom';

export const useLoginActions = (states) => {
    const { login } = useAuth();
    const navigate = useNavigate();
    
    const { email, password, setError, setLoading } = states;

    const handleSubmit = async (e) => {
        if (e) e.preventDefault();
        setError('');
        setLoading(true);
        const result = await login(email, password);
        setLoading(false);
        if (result.success) {
            navigate('/');
        } else {
            setError(result.message);
        }
    };

    return {
        handleSubmit,
    };
};
