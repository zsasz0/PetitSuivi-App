/**
 * @file LoginForm.jsx
 * @description Presentational form component for rendering email, password fields and login button.
 */
import { Box, Button, TextField, InputAdornment, IconButton, CircularProgress } from "@mui/material";
import LockOutlinedIcon from '@mui/icons-material/LockOutlined';
import EmailOutlinedIcon from '@mui/icons-material/EmailOutlined';
import Visibility from '@mui/icons-material/Visibility';
import VisibilityOff from '@mui/icons-material/VisibilityOff';
import { getTextFieldStyles, getSubmitButtonStyles } from "../utils/loginStyles";

const LoginForm = ({ email, setEmail, password, setPassword, showPassword, setShowPassword, loading, theme, colors }) => {
    return (
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
    );
};

export default LoginForm;
