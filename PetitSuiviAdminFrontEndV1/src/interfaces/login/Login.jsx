/**
 * @file login/Login.jsx
 * @description Authentication / Login Screen component.
 * Renders the full-page login form with glassmorphism design and animated background.
 * Submits credentials to the AuthContext login function.
 */
import { useState, useContext } from 'react';
import { useAuth } from '../../context/AuthContext';
import { useNavigate } from 'react-router-dom';
import { Box, Button, TextField, Typography, useTheme, InputAdornment, IconButton, Fade, CircularProgress } from "@mui/material";
import { tokens, ColorModeContext } from "../../theme";
import { keyframes } from '@mui/system';
import LockOutlinedIcon from '@mui/icons-material/LockOutlined';
import EmailOutlinedIcon from '@mui/icons-material/EmailOutlined';
import Visibility from '@mui/icons-material/Visibility';
import VisibilityOff from '@mui/icons-material/VisibilityOff';
import LightModeOutlinedIcon from "@mui/icons-material/LightModeOutlined";
import DarkModeOutlinedIcon from "@mui/icons-material/DarkModeOutlined";
import appLogo from '../../assets/appImage.png';

// --- Animations ---
const gradientAnimation = keyframes`
  0% { background-position: 0% 50%; }
  50% { background-position: 100% 50%; }
  100% { background-position: 0% 50%; }
`;

const float = keyframes`
  0% { transform: translateY(0px); }
  50% { transform: translateY(-10px); }
  100% { transform: translateY(0px); }
`;

// --- Extracted Styled Components & Helpers ---

const AnimatedBackground = ({ theme, colors, colorMode }) => (
    <>
        <Box position="absolute" top="20px" right="20px" zIndex={10}>
            <IconButton onClick={colorMode.toggleColorMode} sx={{ color: theme.palette.mode === 'dark' ? 'white' : '#111827' }}>
                {theme.palette.mode === "dark" ? <DarkModeOutlinedIcon /> : <LightModeOutlinedIcon />}
            </IconButton>
        </Box>
        <Box sx={{
            position: 'absolute', top: '15%', left: '20%', width: '350px', height: '350px',
            background: `radial-gradient(circle, ${colors.blueAccent[700]}33 0%, rgba(0,0,0,0) 70%)`,
            animation: `${float} 10s ease-in-out infinite`, filter: 'blur(60px)', zIndex: 0
        }} />
        <Box sx={{
            position: 'absolute', bottom: '15%', right: '25%', width: '450px', height: '450px',
            background: `radial-gradient(circle, ${colors.greenAccent[700]}26 0%, rgba(0,0,0,0) 70%)`,
            animation: `${float} 12s ease-in-out infinite reverse`, filter: 'blur(80px)', zIndex: 0
        }} />
    </>
);

const getTextFieldStyles = (theme, colors) => ({
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

const getSubmitButtonStyles = (colors) => ({
    mt: 1, padding: "12px", fontWeight: "600", fontSize: "15px",
    color: "#fff", borderRadius: "8px", backgroundColor: colors.greenAccent[600],
    transition: "all 0.2s ease", textTransform: "none", letterSpacing: "0.3px",
    "&.Mui-disabled": { backgroundColor: colors.greenAccent[800], color: "rgba(255, 255, 255, 0.7)" },
    "&:hover": { backgroundColor: colors.greenAccent[500], transform: "translateY(-1px)", boxShadow: `0 8px 20px rgba(76, 206, 172, 0.2)` },
    "&:active": { transform: "translateY(0px)" }
});

const getGlassContainerStyles = (theme, colors) => ({
    position: "relative", zIndex: 1, width: "100%", maxWidth: "420px", p: "45px 35px", borderRadius: "16px",
    background: theme.palette.mode === 'dark' ? "rgba(10, 15, 26, 0.7)" : "rgba(255, 255, 255, 0.7)",
    backdropFilter: "blur(12px)", WebkitBackdropFilter: "blur(12px)",
    border: `1px solid ${colors.greenAccent[500]}33`,
    boxShadow: theme.palette.mode === 'dark' ? "0 20px 50px rgba(0, 0, 0, 0.6)" : "0 20px 50px rgba(0, 0, 0, 0.1)",
});

/**
 * Login Component
 */
const Login = () => {
    const theme = useTheme();
    const colors = tokens(theme.palette.mode);
    const colorMode = useContext(ColorModeContext);
    
    // Auth & Route State
    const { login } = useAuth();
    const navigate = useNavigate();

    // Form State
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [showPassword, setShowPassword] = useState(false);
    const [error, setError] = useState('');
    const [loading, setLoading] = useState(false);

    /**
     * Processes the login form submission.
     */
    const handleSubmit = async (e) => {
        e.preventDefault();
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

    return (
        <Box
            sx={{
                display: "flex", justifyContent: "center", alignItems: "center", minHeight: "100vh", position: "relative", overflow: "hidden",
                background: theme.palette.mode === 'dark' 
                    ? "linear-gradient(-45deg, #0a0f1a, #111827, #061014, #0b1a13)"
                    : "linear-gradient(-45deg, #f0f4f8, #e5e7eb, #f9fafb, #eef2f6)",
                backgroundSize: "400% 400%", animation: `${gradientAnimation} 15s ease infinite`
            }}
        >
            <AnimatedBackground theme={theme} colors={colors} colorMode={colorMode} />

            <Box sx={getGlassContainerStyles(theme, colors)}>
                <form onSubmit={handleSubmit}>
                    
                    {/* Header Region */}
                    <Box display="flex" justifyContent="center" mb="25px">
                        <Box sx={{ width: "65px", height: "65px", display: "flex", justifyContent: "center", alignItems: "center", mb: "10px" }}>
                            <img src={appLogo} alt="App Logo" style={{ width: '65px', height: '65px', objectFit: 'contain', display: 'block' }} />
                        </Box>
                    </Box>

                    <Typography variant="h3" fontWeight="700" textAlign="center" mb="8px" color={colors.grey[100]} sx={{ letterSpacing: "0.5px" }}>
                        Administration
                    </Typography>

                    <Typography variant="body1" textAlign="center" mb="35px" color={colors.grey[400]} sx={{ fontSize: "14px" }}>
                        Veuillez vous connecter pour continuer
                    </Typography>

                    {/* Error Handling */}
                    {error && (
                        <Fade in={!!error}>
                            <Typography color="#ff6b6b" textAlign="center" mb="20px" sx={{ background: "rgba(255, 107, 107, 0.08)", padding: "10px", borderRadius: "8px", border: "1px solid rgba(255, 107, 107, 0.2)", fontSize: "13px" }}>
                                {error}
                            </Typography>
                        </Fade>
                    )}

                    {/* Form Fields */}
                    <Box display="flex" flexDirection="column" gap="20px">
                        <TextField
                            fullWidth variant="outlined" type="email" placeholder="Email" required
                            value={email} onChange={(e) => setEmail(e.target.value)}
                            InputProps={{
                                startAdornment: (
                                    <InputAdornment position="start">
                                        <EmailOutlinedIcon sx={{ color: colors.grey[500], fontSize: "20px" }} />
                                    </InputAdornment>
                                ),
                                sx: getTextFieldStyles(theme, colors)
                            }}
                        />

                        <TextField
                            fullWidth variant="outlined" type={showPassword ? 'text' : 'password'} placeholder="Mot de passe" required
                            value={password} onChange={(e) => setPassword(e.target.value)}
                            InputProps={{
                                startAdornment: (
                                    <InputAdornment position="start">
                                        <LockOutlinedIcon sx={{ color: colors.grey[500], fontSize: "20px" }} />
                                    </InputAdornment>
                                ),
                                endAdornment: (
                                    <InputAdornment position="end">
                                        <IconButton onClick={() => setShowPassword(!showPassword)} edge="end" sx={{ color: colors.grey[500] }} size="small">
                                            {showPassword ? <VisibilityOff sx={{ fontSize: "20px" }} /> : <Visibility sx={{ fontSize: "20px" }} />}
                                        </IconButton>
                                    </InputAdornment>
                                ),
                                sx: getTextFieldStyles(theme, colors)
                            }}
                        />

                        <Button type="submit" fullWidth disabled={loading} sx={getSubmitButtonStyles(colors)}>
                            {loading ? <CircularProgress size={24} color="inherit" /> : "Se Connecter"}
                        </Button>
                    </Box>
                </form>
            </Box>
        </Box>
    );
};

export default Login;
