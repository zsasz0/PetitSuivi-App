/**
 * @file LoginHeader.jsx
 * @description Renders the logo, title, and subtitle for the Login page.
 */
import { Box, Typography } from "@mui/material";
import appLogo from '../../../assets/appImage.png';

const LoginHeader = ({ colors }) => (
    <>
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
    </>
);

export default LoginHeader;
