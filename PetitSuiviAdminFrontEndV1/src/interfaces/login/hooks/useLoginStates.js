/**
 * @file useLoginStates.js
 * @description Domain hook handling state variables for the Login interface.
 */
import { useState } from 'react';

export const useLoginStates = () => {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [showPassword, setShowPassword] = useState(false);
    const [error, setError] = useState('');
    const [loading, setLoading] = useState(false);

    return {
        email, setEmail,
        password, setPassword,
        showPassword, setShowPassword,
        error, setError,
        loading, setLoading,
    };
};
