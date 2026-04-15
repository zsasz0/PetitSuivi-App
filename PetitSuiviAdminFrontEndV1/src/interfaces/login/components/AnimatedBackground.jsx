/**
 * @file AnimatedBackground.jsx
 * @description Provides the floating background elements and theme toggle for the Login page.
 */
import { useContext } from 'react';
import { Box, IconButton } from "@mui/material";
import LightModeOutlinedIcon from "@mui/icons-material/LightModeOutlined";
import DarkModeOutlinedIcon from "@mui/icons-material/DarkModeOutlined";
import { ColorModeContext } from "../../../theme";
import { float } from "../utils/loginStyles";

const AnimatedBackground = ({ theme, colors }) => {
    const colorMode = useContext(ColorModeContext);

    return (
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
};

export default AnimatedBackground;
