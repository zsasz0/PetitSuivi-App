import { Box, Button, CircularProgress, Dialog, DialogActions, DialogContent, DialogTitle, FormControl, MenuItem, Select, Typography } from "@mui/material";

const ClassAssignDialog = ({
    open,
    child,
    selectedClassId,
    onClassChange,
    classOptions,
    error,
    loading,
    onConfirm,
    onClose,
    colors,
    styles,
}) => (
    <Dialog open={open} onClose={loading ? undefined : onClose} fullWidth maxWidth="sm" PaperProps={{ sx: styles.dialogPaper }}>
        <DialogTitle sx={styles.dialogTitle}>Assigner une classe</DialogTitle>
        <DialogContent sx={{ mt: 2, display: "flex", flexDirection: "column", gap: "16px" }}>
            <Box sx={styles.detailCard}>
                <Typography variant="body2" color={colors.grey[300]} mb="12px">
                    Sélectionnez une classe pour <strong>{child?.name}</strong>.
                </Typography>
                <Typography variant="body2" color={colors.grey[300]} mb="16px">
                    Type souhaité : <strong>{child?.inscriptionType || "-"}</strong>
                </Typography>
                <FormControl fullWidth>
                    <Select
                        value={selectedClassId}
                        onChange={(event) => onClassChange(event.target.value)}
                        displayEmpty
                        sx={{ borderRadius: "12px", backgroundColor: colors.primary[500] }}
                        MenuProps={{ PaperProps: { sx: styles.compactMenuPaper } }}
                    >
                        <MenuItem value="" disabled>Sélectionner une classe</MenuItem>
                        {classOptions.map((schoolClass) => (
                            <MenuItem key={schoolClass.id} value={String(schoolClass.id)} disabled={schoolClass.isFull}>
                                {schoolClass.name} — {schoolClass.enrolled}/{schoolClass.capacity ?? "∞"}{schoolClass.isFull ? " — Classe complète" : ""}
                            </MenuItem>
                        ))}
                    </Select>
                </FormControl>
                {classOptions.length > 0 && classOptions.every((schoolClass) => schoolClass.isFull) && (
                    <Typography color={colors.redAccent[500]} mt={1}>Aucune classe disponible : toutes les classes correspondantes sont complètes.</Typography>
                )}
                {error && <Typography color={colors.redAccent[500]} mt={1}>{error}</Typography>}
            </Box>
        </DialogContent>
        <DialogActions sx={styles.dialogActions}>
            <Button onClick={onClose} sx={{ color: colors.grey[100] }} disabled={loading}>Annuler</Button>
            <Button onClick={onConfirm} variant="contained" disabled={!selectedClassId || loading} sx={styles.approveButton}>
                {loading ? <CircularProgress size={18} sx={{ color: "#fff" }} /> : "Confirmer"}
            </Button>
        </DialogActions>
    </Dialog>
);

export default ClassAssignDialog;
