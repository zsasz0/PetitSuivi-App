/**
 * @file AuthContext.jsx
 * @description Provides a global authentication context for the application.
 * 
 * ROLE:
 * This file centralizes all authentication-related logic, including user state management,
 * token synchronization with local storage, and high-level login/logout actions.
 * It also monitors global API responses to handle session expiration (401 errors).
 */

import { createContext, useState, useEffect, useContext } from 'react';
import api from '../api/axios';

/**
 * The core context object used to share authentication data.
 */
const AuthContext = createContext();

/**
 * AuthProvider component that wraps the application and provides:
 * - Current user information (`user`)
 * - Authentication token (`token`)
 * - Loading state for auth operations (`loading`)
 * - Action methods (`login`, `logout`)
 * 
 * @param {Object} props - Component props.
 * @param {React.ReactNode} props.children - Child components to be wrapped.
 * @returns {JSX.Element} The provider wrapper.
 */
/*
 *
 *
 * */

export const AuthProvider = ({ children }) => {
    // CURRENT STATE
    const [user, setUser] = useState(null); // Stores full user profile after login
    const [token, setToken] = useState(localStorage.getItem('token') || null); // Auth token (synchronized with localStorage)
    const [loading, setLoading] = useState(false); // Indicates if an auth request is in progress

    /**
     * SYNCING TOKEN WITH LOCAL STORAGE
     * Whenever the token state changes:
     * - If it exists, save it to persistent storage.
     * - If it's null, remove it from storage and clear user data.
     */
    useEffect(() => {
        if (token) {
            localStorage.setItem('token', token);
        } else {
            localStorage.removeItem('token');
            setUser(null);
        }
    }, [token]);

    /**
     * GLOBAL 401 ERROR WATCHER
     * Sets up an Axios response interceptor to detect "Unauthorized" errors.
     * If a 401 is returned, it likely means the session expired, so we reset the state.
     * The interceptor is automatically cleaned up when the component unmounts.
     */
    useEffect(() => {
        const interceptorId = api.interceptors.response.use(
            (response) => response,
            (error) => {
                if (error?.response?.status === 401) {
                    setToken(null);
                    setUser(null);
                }
                return Promise.reject(error);
            }
        );

        return () => {
            api.interceptors.response.eject(interceptorId);
        };
    }, []);

    /**
     * LOGIN ACTION
     * Authenticates the user with the backend API.
     * 
     * @param {string} email - User's email address.
     * @param {string} password - User's password.
     * @returns {Promise<Object>} Result object with success status and optional message.
     */
    const login = async (email, password) => {
        setLoading(true);
        try {
            const response = await api.post('/login', { email, password });
            const { user, token } = response.data;

            // On success, update the context state
            setToken(token);
            setUser(user);

            return { success: true };
        } catch (error) {
            console.error("Échec de connexion", error);
            return {
                success: false,
                message: error.response?.data?.message || 'Échec de connexion'
            };
        } finally {
            setLoading(false);
        }
    };

    /**
     * LOGOUT ACTION
     * Destroys the session both on the server and in the local application state.
     */
    const logout = async () => {
        try {
            await api.post('/logout');
        } catch (error) {
            console.error("Échec de déconnexion", error);
        } finally {
            // Always clear state locally even if server-side logout fails
            setToken(null);
            setUser(null);
        }
    };

    return (
        <AuthContext.Provider value={{ user, token, login, logout, loading }}>
            {children}
        </AuthContext.Provider>
    );
};

/**
 * Custom hook for child components to easily consume authentication data.
 * Usage: const { user, login } = useAuth();
 * 
 * @returns {Object} Authentication context values.
 */
export const useAuth = () => useContext(AuthContext);

