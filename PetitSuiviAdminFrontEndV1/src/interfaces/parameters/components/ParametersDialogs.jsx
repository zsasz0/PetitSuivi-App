import React from "react";
import { Dialog, DialogTitle, DialogContent, DialogActions, Typography, Button } from "@mui/material";

export const ArchiveConfirmDialog = ({ open, onClose, onConfirm, colors, styles }) => (
  <Dialog open={open} onClose={onClose} PaperProps={{ sx: styles.dialogPaper }}>
    <DialogTitle sx={styles.dialogTitle}>Confirmer l'archivage</DialogTitle>
    <DialogContent sx={{ mt: 2 }}>
      <Typography>Êtes-vous sûr de vouloir archiver l'année scolaire en cours ? Cette action est irréversible et affectera toutes les inscriptions et classes actives.</Typography>
    </DialogContent>
    <DialogActions sx={styles.dialogActions}>
      <Button onClick={onClose} sx={{ color: colors.grey[300] }}>Annuler</Button>
      <Button onClick={onConfirm} variant="contained" sx={{ backgroundColor: colors.redAccent[600], color: "#fff", "&:hover": { backgroundColor: colors.redAccent[700] } }}>
        Confirmer l'archivage
      </Button>
    </DialogActions>
  </Dialog>
);

export const ToggleConfirmDialog = ({ open, onClose, onConfirm, title, description, confirmLabel, colors, styles }) => (
  <Dialog open={open} onClose={onClose} PaperProps={{ sx: styles.dialogPaper }}>
    <DialogTitle sx={styles.dialogTitle}>{title}</DialogTitle>
    <DialogContent sx={{ mt: 2 }}>
      <Typography color={colors.grey[200]}>{description}</Typography>
    </DialogContent>
    <DialogActions sx={styles.dialogActions}>
      <Button onClick={onClose} sx={{ color: colors.grey[300] }}>Annuler</Button>
      <Button onClick={onConfirm} variant="contained" sx={styles.primaryBtn}>{confirmLabel}</Button>
    </DialogActions>
  </Dialog>
);

export const DeletePlanningConfirmDialog = ({ open, onClose, onConfirm, colors, styles }) => (
  <Dialog open={open} onClose={onClose} PaperProps={{ sx: styles.dialogPaper }}>
    <DialogTitle sx={styles.dialogTitle}>Confirmer la suppression</DialogTitle>
    <DialogContent sx={{ mt: 2 }}>
      <Typography color={colors.grey[200]}>
        Êtes-vous sûr de vouloir supprimer cette année scolaire ? Cette action est irréversible.
      </Typography>
      <Typography variant="body2" color={colors.grey[300]} sx={{ mt: 1 }}>
        Seules les années vides créées par erreur peuvent être supprimées. Une année archivée ou déjà utilisée sera refusée.
      </Typography>
    </DialogContent>
    <DialogActions sx={styles.dialogActions}>
      <Button onClick={onClose} sx={{ color: colors.grey[300] }}>Annuler</Button>
      <Button onClick={onConfirm} variant="contained" sx={{ backgroundColor: colors.redAccent[600], color: "#fff", "&:hover": { backgroundColor: colors.redAccent[700] } }}>
        Supprimer
      </Button>
    </DialogActions>
  </Dialog>
);
