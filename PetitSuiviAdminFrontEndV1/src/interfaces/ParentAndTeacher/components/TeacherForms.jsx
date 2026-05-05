import { Box, TextField, Button, FormControlLabel, Switch } from "@mui/material";

export const TeacherAddForm = ({ 
    formData, onChange, errors, styles, colors,
    showPassword, onTogglePassword, onGeneratePassword,
    sendCredentials, onToggleSendCredentials 
}) => (
    <>
        <Box display="grid" gridTemplateColumns={{ xs: "1fr", md: "repeat(2, minmax(0, 1fr))" }} gap="16px">
            <TextField label="Prénom" name="firstName" value={formData.firstName} onChange={onChange} error={!!errors.firstName} helperText={errors.firstName} sx={styles.floatingField} required />
            <TextField label="Nom" name="lastName" value={formData.lastName} onChange={onChange} error={!!errors.lastName} helperText={errors.lastName} sx={styles.floatingField} required />
            <TextField label="CIN" name="cin" value={formData.cin} onChange={onChange} error={!!errors.cin} helperText={errors.cin} sx={styles.floatingField} required />
            <TextField label="Téléphone" name="phone" value={formData.phone} onChange={onChange} error={!!errors.phone} helperText={errors.phone} sx={styles.floatingField} required />
            <TextField label="Email" name="email" type="email" value={formData.email} onChange={onChange} error={!!errors.email} helperText={errors.email} sx={{ ...styles.floatingField, gridColumn: { xs: "span 1", md: "span 2" } }} required />
            <TextField label="Date de naissance" name="birthdate" type="date" InputLabelProps={{ shrink: true }} value={formData.birthdate} onChange={onChange} error={!!errors.birthdate} helperText={errors.birthdate} sx={styles.floatingField} required />
            <TextField label="Adresse" name="adresse" value={formData.adresse} onChange={onChange} sx={styles.floatingField} required />
            <TextField label="Mot de passe" name="password" type={showPassword ? "text" : "password"} value={formData.password} onChange={onChange} sx={styles.floatingField} required />
            <TextField label="Confirmer le mot de passe" name="password_confirmation" type={showPassword ? "text" : "password"} value={formData.password_confirmation} onChange={onChange} sx={styles.floatingField} required />
        </Box>
        <Box display="flex" gap="8px" mt="16px" alignItems="center">
            <Button variant="outlined" sx={{ color: colors.grey[100] }} onClick={onTogglePassword}>{showPassword ? "Masquer" : "Afficher"}</Button>
            <Button variant="contained" color="secondary" onClick={onGeneratePassword}>Générer</Button>
        </Box>
        <FormControlLabel control={<Switch checked={sendCredentials} onChange={e => onToggleSendCredentials(e.target.checked)} color="secondary" />} label="Envoyer les identifiants par email" />
    </>
);

export const TeacherEditForm = ({
    formData, onChange, errors, styles,
    onGeneratePassword, sendCredentials, onToggleSendCredentials
}) => (
    <>
        <Box display="grid" gridTemplateColumns={{ xs: "1fr", md: "repeat(2, minmax(0, 1fr))" }} gap="16px">
            <TextField label="Prénom" name="firstName" value={formData.firstName} onChange={onChange} error={!!errors.firstName} helperText={errors.firstName} sx={styles.floatingField} required />
            <TextField label="Nom" name="lastName" value={formData.lastName} onChange={onChange} error={!!errors.lastName} helperText={errors.lastName} sx={styles.floatingField} required />
            <TextField label="Email" name="email" type="email" value={formData.email} onChange={onChange} error={!!errors.email} helperText={errors.email} sx={{ ...styles.floatingField, gridColumn: { xs: "span 1", md: "span 2" } }} required />
            <TextField label="Téléphone" name="phone" value={formData.phone} onChange={onChange} error={!!errors.phone} helperText={errors.phone} sx={styles.floatingField} required />
            <TextField label="Date de naissance" name="birthdate" type="date" InputLabelProps={{ shrink: true }} value={formData.birthdate} onChange={onChange} error={!!errors.birthdate} helperText={errors.birthdate} sx={styles.floatingField} required />
            <TextField label="Adresse" name="adresse" value={formData.adresse} onChange={onChange} sx={{ ...styles.floatingField, gridColumn: { xs: "span 1", md: "span 2" } }} />
            <TextField label="Nouveau mot de passe" name="password" type="text" value={formData.password} onChange={onChange} sx={styles.floatingField} />
            <TextField label="Confirmer le mot de passe" name="password_confirmation" type="text" value={formData.password_confirmation} onChange={onChange} sx={styles.floatingField} required={!!formData.password} />
        </Box>
        <Button variant="contained" color="secondary" sx={{ mt: "16px", width: "120px" }} onClick={onGeneratePassword}>Générer</Button>
        {formData.password && <FormControlLabel control={<Switch checked={sendCredentials} onChange={e => onToggleSendCredentials(e.target.checked)} color="secondary" />} label="Envoyer les identifiants par email" />}
    </>
);
