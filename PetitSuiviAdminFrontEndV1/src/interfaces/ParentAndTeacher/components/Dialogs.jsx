import { Dialog, DialogTitle, DialogContent, DialogContentText, DialogActions, Box, Button, Typography } from "@mui/material";

export const DeleteConfirmDialog = ({ title, open, itemName, onClose, onConfirm, styles, colors }) => (
    <Dialog open={open} onClose={onClose} PaperProps={{ sx: styles.dialogPaper }}>
        <DialogTitle sx={styles.dialogTitle}>{title}</DialogTitle>
        <DialogContent sx={{ mt: 2 }}>
            <DialogContentText sx={{ color: colors.grey[200] }}>
                Êtes-vous sûr de vouloir supprimer {itemName} ? Cette action est irréversible.
            </DialogContentText>
            {title === "Confirmer la suppression du parent" && (
                <Box mt="16px" p="14px" borderRadius="14px" border={`1px solid ${colors.redAccent[500]}33`} backgroundColor={colors.primary[500]}>
                    <Typography color={colors.redAccent[400]} fontWeight="700" mb="8px">
                        Cette suppression effacera aussi :
                    </Typography>
                    <Typography color={colors.grey[200]} variant="body2">Le compte parent et ses informations personnelles.</Typography>
                    <Typography color={colors.grey[200]} variant="body2">Tous les enfants liés à ce parent.</Typography>
                    <Typography color={colors.grey[200]} variant="body2">Les inscriptions, dossiers médicaux, commentaires IA et paiements liés.</Typography>
                    <Typography color={colors.grey[200]} variant="body2">Les exceptions alimentaires, présences, évaluations et affectations de classe des enfants.</Typography>
                </Box>
            )}
        </DialogContent>
        <DialogActions sx={styles.dialogActions}>
            <Button onClick={onClose} sx={{ color: colors.grey[100] }}>Annuler</Button>
            <Button onClick={onConfirm} variant="contained" sx={{ backgroundColor: colors.redAccent[500], color: "#fff" }}>Supprimer</Button>
        </DialogActions>
    </Dialog>
);

export const FormDialog = ({
    title, open, onClose, children, onSubmit, saving, saveLabel, styles, colors, isDark
}) => (
    <Dialog open={open} onClose={onClose} fullWidth maxWidth="md" PaperProps={{ sx: styles.dialogPaper }}>
        <DialogTitle sx={styles.dialogTitle}>{title}</DialogTitle>
        <form onSubmit={onSubmit}>
            <DialogContent sx={{ mt: 2, display: "flex", flexDirection: "column", gap: "18px" }}>
                <Box sx={styles.formCard}>
                    {children}
                </Box>
            </DialogContent>
            <DialogActions sx={styles.dialogActions}>
                <Button onClick={onClose} sx={{ color: colors.grey[100] }}>Annuler</Button>
                <Button type="submit" variant="contained" disabled={saving} sx={{ backgroundColor: isDark ? "#475569" : "#334155", color: "#fff", fontWeight: "bold", "&:hover": { backgroundColor: isDark ? "#64748b" : "#475569" } }}>
                    {saving ? "Enregistrement..." : (saveLabel || "Enregistrer")}
                </Button>
            </DialogActions>
        </form>
    </Dialog>
);
