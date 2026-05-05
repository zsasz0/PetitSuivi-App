import React from "react";
import { Button, Dialog, DialogActions, DialogContent, DialogContentText, DialogTitle } from "@mui/material";

const DeleteDialog = ({ open, onClose, onConfirm, selectedClass, colors, styles }) => (
    <Dialog open={open} onClose={onClose} PaperProps={{ sx: styles.dialogPaper }}>
        <DialogTitle sx={styles.dialogTitle}>Confirmer la suppression</DialogTitle>
        <DialogContent sx={{ mt: 2 }}>
            <DialogContentText sx={{ color: colors.grey[200] }}>
                Êtes-vous sûr de vouloir supprimer la classe "{selectedClass?.name}" ? Cette action est irréversible.
            </DialogContentText>
        </DialogContent>
        <DialogActions sx={styles.dialogActions}>
            <Button onClick={onClose} sx={{ color: colors.grey[100] }}>Annuler</Button>
            <Button onClick={onConfirm} variant="contained" sx={{ backgroundColor: colors.redAccent[500], color: "#fff" }}>
                Supprimer
            </Button>
        </DialogActions>
    </Dialog>
);

export default DeleteDialog;
