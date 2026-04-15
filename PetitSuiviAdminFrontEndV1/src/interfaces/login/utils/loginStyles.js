/**
 * @file loginStyles.js
 * @description Utility functions for generating styling objects and animations for the Login interface.
 */
import { keyframes } from '@mui/system';

export const gradientAnimation = keyframes`
  0% { background-position: 0% 50%; }
  50% { background-position: 100% 50%; }
  100% { background-position: 0% 50%; }
`;

export const float = keyframes`
  0% { transform: translateY(0px); }
  50% { transform: translateY(-10px); }
  100% { transform: translateY(0px); }
`;

/**
 * Returns container background styles for the login page
 * @param {object} theme - MUI theme object 
 * @returns {object} MUI sx styles
 */
export const getContainerBackgroundStyles = (theme) => ({
    display: "flex", 
    justifyContent: "center", 
    alignItems: "center", 
    minHeight: "100vh", 
    position: "relative", 
    overflow: "hidden",
    background: theme.palette.mode === 'dark' 
        ? "linear-gradient(-45deg, #0a0f1a, #111827, #061014, #0b1a13)"
        : "linear-gradient(-45deg, #f0f4f8, #e5e7eb, #f9fafb, #eef2f6)",
    backgroundSize: "400% 400%", 
    animation: `${gradientAnimation} 15s ease infinite`
});

/**
 * Returns styles for the glassmorphism container
 * @param {object} theme - MUI theme object
 * @param {object} colors - App color tokens
 * @returns {object} MUI sx styles
 */
export const getGlassContainerStyles = (theme, colors) => ({
    position: "relative", 
    zIndex: 1, 
    width: "100%", 
    maxWidth: "420px", 
    p: "45px 35px", 
    borderRadius: "16px",
    background: theme.palette.mode === 'dark' ? "rgba(10, 15, 26, 0.7)" : "rgba(255, 255, 255, 0.7)",
    backdropFilter: "blur(12px)", 
    WebkitBackdropFilter: "blur(12px)",
    border: `1px solid ${colors.greenAccent[500]}33`,
    boxShadow: theme.palette.mode === 'dark' ? "0 20px 50px rgba(0, 0, 0, 0.6)" : "0 20px 50px rgba(0, 0, 0, 0.1)",
});

/**
 * Returns styles for text fields in login
 * @param {object} theme - MUI theme object
 * @param {object} colors - App color tokens
 * @returns {object} MUI sx styles
 */
export const getTextFieldStyles = (theme, colors) => ({
    color: theme.palette.mode === 'dark' ? "#fff" : "#141414",
    borderRadius: "8px",
    background: theme.palette.mode === 'dark' ? "rgba(255, 255, 255, 0.03)" : "rgba(0, 0, 0, 0.03)",
    "& fieldset": { borderColor: theme.palette.mode === 'dark' ? "rgba(255, 255, 255, 0.1)" : "rgba(0, 0, 0, 0.1)" },
    "&:hover fieldset": { borderColor: colors.greenAccent[400] },
    "&.Mui-focused fieldset": {
        borderColor: colors.greenAccent[500],
        borderWidth: "1px",
    }
});

/**
 * Returns styles for the submit button
 * @param {object} colors - App color tokens
 * @returns {object} MUI sx styles
 */
export const getSubmitButtonStyles = (colors) => ({
    mt: 1, padding: "12px", fontWeight: "600", fontSize: "15px",
    color: "#fff", borderRadius: "8px", backgroundColor: colors.greenAccent[600],
    transition: "all 0.2s ease", textTransform: "none", letterSpacing: "0.3px",
    "&.Mui-disabled": { backgroundColor: colors.greenAccent[800], color: "rgba(255, 255, 255, 0.7)" },
    "&:hover": { backgroundColor: colors.greenAccent[500], transform: "translateY(-1px)", boxShadow: `0 8px 20px rgba(76, 206, 172, 0.2)` },
    "&:active": { transform: "translateY(0px)" }
});
