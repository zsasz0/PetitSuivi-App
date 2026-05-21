import { Box, TextField, Button } from "@mui/material";

export const ParentEditForm = ({
    formData, onChange, errors, styles, onGeneratePassword
}) => (
    <>
        <Box display="grid" gridTemplateColumns={{ xs: "1fr", md: "repeat(2, minmax(0, 1fr))" }} gap="16px">
            <TextField label="Prénom" name="firstName" value={formData.firstName} onChange={onChange} error={!!errors.firstName} helperText={errors.firstName} sx={styles.floatingField} required />
            <TextField label="Nom" name="lastName" value={formData.lastName} onChange={onChange} error={!!errors.lastName} helperText={errors.lastName} sx={styles.floatingField} required />
            <TextField label="Email" name="email" type="email" value={formData.email} onChange={onChange} error={!!errors.email} helperText={errors.email} sx={styles.floatingField} required />
            <TextField label="CIN" name="cin" value={formData.cin} onChange={onChange} error={!!errors.cin} helperText={errors.cin} sx={styles.floatingField} required />
            <TextField label="Téléphone" name="phone" value={formData.phone} onChange={onChange} error={!!errors.phone} helperText={errors.phone} sx={styles.floatingField} required />
            <TextField label="Date de naissance" name="birthdate" type="date" InputLabelProps={{ shrink: true }} value={formData.birthdate} onChange={onChange} error={!!errors.birthdate} helperText={errors.birthdate} sx={styles.floatingField} required />
            <TextField label="Adresse" name="adresse" value={formData.adresse} onChange={onChange} sx={{ ...styles.floatingField, gridColumn: { xs: "span 1", md: "span 2" } }} />
            <TextField label="Nouveau mot de passe" name="password" type="text" value={formData.password} onChange={onChange} sx={styles.floatingField} />
            <TextField label="Confirmer le mot de passe" name="password_confirmation" type="text" value={formData.password_confirmation} onChange={onChange} sx={styles.floatingField} required={!!formData.password} />
        </Box>
        <Button variant="contained" color="secondary" sx={{ mt: "16px", width: "120px" }} onClick={onGeneratePassword}>Générer</Button>
    </>
);
