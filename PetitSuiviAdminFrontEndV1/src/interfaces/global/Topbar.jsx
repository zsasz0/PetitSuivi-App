import { Box, IconButton, useTheme, Button, CircularProgress } from "@mui/material";
import { useState, useContext } from "react";
import { tokens, ColorModeContext } from "../../theme";
import MenuOutlinedIcon from "@mui/icons-material/MenuOutlined";
import LightModeOutlinedIcon from "@mui/icons-material/LightModeOutlined";
import DarkModeOutlinedIcon from "@mui/icons-material/DarkModeOutlined";
import SettingsOutlinedIcon from "@mui/icons-material/SettingsOutlined";
import { useAuth } from "../../context/AuthContext";
import { useNavigate } from "react-router-dom";

/**
 * @file global/Topbar.jsx
 * @description Global Topbar / Header component.
 *
 * ROLE:
 * Renders the fixed top bar across all admin pages. Currently contains:
 *   1. A hamburger-menu icon to toggle the sidebar collapsed/expanded state.
 *   2. A logout button that calls AuthContext.logout() to properly clear
 *      both client-side state and server-side session, then redirects to /login.
 *
 * PROPS:
 * @param {Function} setIsSidebar – State setter from the parent layout; toggles
 *                                  the sidebar visibility.
 *
 * DEPENDENCIES:
 * - MUI components – Box, IconButton, Button, `useTheme`.
 * - `ColorModeContext` / `tokens` – Theme colours.
 * - React Router `useNavigate` – Programmatic redirect on logout.
 * - `useAuth` from AuthContext – Handles logout API call and state cleanup.
 */
/**
 * Global Topbar / Header component.
 * Renders the fixed top bar with sidebar toggle and logout functionality.
 * 
 * @param {Object} props - Component props.
 * @param {Function} props.setIsSidebar - Function to toggle the parent sidebar visibility state.
 * @returns {JSX.Element} The rendered Topbar.
 */
const Topbar = ({ setIsSidebar }) => {
  const theme = useTheme();
  const colors = tokens(theme.palette.mode);
  const colorMode = useContext(ColorModeContext);
  const { logout } = useAuth();
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  /**
   * Logs the user out via AuthContext (clears state + calls backend /logout),
   * then redirects to the login page.
   */
  const handleLogout = async () => {
    setLoading(true);
    await logout();
    setLoading(false);
  };

  return (
    <Box display="flex" justifyContent="space-between" p={2}>
      <Box display="flex" alignItems="center">
        <IconButton onClick={() => setIsSidebar((prev) => !prev)} sx={{ mr: 2 }}>
          <MenuOutlinedIcon />
        </IconButton>
      </Box>

      <Box display="flex" alignItems="center" gap={2}>
        <IconButton onClick={colorMode.toggleColorMode}>
          {theme.palette.mode === "dark" ? (
            <DarkModeOutlinedIcon />
          ) : (
            <LightModeOutlinedIcon />
          )}
        </IconButton>
        <IconButton onClick={() => navigate("/management/parameters")}>
          <SettingsOutlinedIcon />
        </IconButton>
        <Button
          variant="contained"
          onClick={handleLogout}
          disabled={loading}
          sx={{
            backgroundColor: colors.greenAccent[600],
            color: 'white',
            fontWeight: 'bold',
            '&.Mui-disabled': {
              backgroundColor: colors.greenAccent[800],
              color: 'rgba(255, 255, 255, 0.7)',
            },
            '&:hover': {
              backgroundColor: colors.greenAccent[700],
            }
          }}
        >
          {loading ? <CircularProgress size={24} color="inherit" /> : "Déconnecter"}
        </Button>
      </Box>
    </Box>
  );
};

export default Topbar;
