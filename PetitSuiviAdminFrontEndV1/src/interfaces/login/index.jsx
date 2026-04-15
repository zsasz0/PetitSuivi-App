/**
 * @file index.jsx
 * @description Main Entry / View Component for Login.
 */
import { Box, Typography, useTheme, Fade } from "@mui/material";
import { tokens } from "../../theme";
import AnimatedBackground from "./components/AnimatedBackground";
import LoginForm from "./components/LoginForm";
import LoginHeader from "./components/LoginHeader";
import { getGlassContainerStyles, getContainerBackgroundStyles } from "./utils/loginStyles";
import { useController } from "./hooks/useController";

const Login = () => {
    const theme = useTheme();
    const colors = tokens(theme.palette.mode);
    
    // Auth & Form Facade
    const { state, actions } = useController();
    const { email, password, showPassword, error, loading } = state;
    const { setEmail, setPassword, setShowPassword, handleSubmit } = actions;

    return (
        <Box sx={getContainerBackgroundStyles(theme)}>
            <AnimatedBackground theme={theme} colors={colors} />

            <Box sx={getGlassContainerStyles(theme, colors)}>
                <form onSubmit={handleSubmit}>
                    
                    <LoginHeader colors={colors} />

                    {/* Error Handling */}
                    {error && (
                        <Fade in={!!error}>
                            <Typography color="#ff6b6b" textAlign="center" mb="20px" sx={{ background: "rgba(255, 107, 107, 0.08)", padding: "10px", borderRadius: "8px", border: "1px solid rgba(255, 107, 107, 0.2)", fontSize: "13px" }}>
                                {error}
                            </Typography>
                        </Fade>
                    )}

                    <LoginForm 
                        email={email}
                        setEmail={setEmail}
                        password={password}
                        setPassword={setPassword}
                        showPassword={showPassword}
                        setShowPassword={setShowPassword}
                        loading={loading}
                        theme={theme}
                        colors={colors}
                    />

                </form>
            </Box>
        </Box>
    );
};

export default Login;
