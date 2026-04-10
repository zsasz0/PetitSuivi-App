/**
 * @file axios.js
 * @description Configures and exports a pre-configured Axios instance for API interactions.
 */

import axios from 'axios';

/**
 * Custom Axios instance with base configuration.
 * - `baseURL`: The fundamental URL for all API requests.
 * - `headers`: Default headers set to handle JSON responses and requests.
 * 
 * @type {import('axios').AxiosInstance}
 */
const api = axios.create({
    baseURL: process.env.REACT_APP_API_URL || 'https://api.petitsuivi.me/api',
    headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
    },
});

/**
 * Request Interceptor
 * 
 * Intercepts every outgoing request and:
 * 1. Checks for an authentication token stored in `localStorage`.
 * 2. If present, attaches the token to the `Authorization` header as a Bearer token.
 * 3. Continues with the modified request configuration.
 * 
 * If an error occurs during the request setup, it rejects the promise.
 */
api.interceptors.request.use(
    (config) => {
        const token = localStorage.getItem('token');
        if (token) {
            config.headers['Authorization'] = `Bearer ${token}`;
        }
        return config;
    },
    (error) => {
        return Promise.reject(error);
    }
);

export default api;
