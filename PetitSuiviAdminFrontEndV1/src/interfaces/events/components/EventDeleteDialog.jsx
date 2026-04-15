import {
  Button,
  Dialog,
  DialogActions,
  DialogContent,
  DialogTitle,
  Typography,
} from "@mui/material";
import { getStyles } from "../utils/styles";

const EventDeleteDialog = ({ open, onClose, deletingEvent, onConfirm, colors, isDark }) => {
  const styles = getStyles(colors, isDark);
  return (
    <Dialog open={open} onClose={onClose} maxWidth="xs" PaperProps={{ sx: styles.dialogPaper }}>
      <DialogTitle sx={styles.dialogTitle}>Confirmer la suppression</DialogTitle>
      <DialogContent sx={{ mt: 2 }}>
        <Typography color={colors.grey[300]}>
          Êtes-vous sûr de vouloir supprimer l'événement <strong>"{deletingEvent?.name}"</strong> ?
        </Typography>
      </DialogContent>
      <DialogActions sx={styles.dialogActions}>
        <Button onClick={onClose} sx={{ color: colors.grey[300] }}>Annuler</Button>
        <Button variant="contained" onClick={onConfirm} sx={styles.deleteBtn}>Supprimer</Button>
      </DialogActions>
    </Dialog>
  );
};

export default EventDeleteDialog;
