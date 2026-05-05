import React from "react";
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Typography,
  Box,
  Button,
  IconButton,
  TextField,
} from "@mui/material";
import CloseIcon from "@mui/icons-material/Close";

export const AddCriteriaDialogComponent = (props) => {
  const {
    colors,
    styles,
    modals,
    closeModal,
    newCriteriaName,
    setNewCriteriaName,
    addCriteriaError,
    setAddCriteriaError,
    addCriteriaSaving,
    handleAddCriteria,
  } = props;

  const handleClose = () => {
    closeModal("criteria");
    setAddCriteriaError("");
    setNewCriteriaName("");
  };

  return (
    <Dialog open={modals.criteria} onClose={handleClose} fullWidth maxWidth="sm" PaperProps={{ sx: styles.dialogPaper }}>
      <DialogTitle sx={{ ...styles.dialogTitle, display: "flex", alignItems: "center", justifyContent: "space-between" }}>
        <Box>
          <Typography fontWeight="bold" fontSize="1.1rem">Ajouter un critère</Typography>
          <Typography variant="body2" color={colors.grey[300]} mt="4px">
            Ajoutez un nouveau critère dans une fiche plus propre, comme sur la gestion des classes.
          </Typography>
        </Box>
        <IconButton onClick={handleClose} sx={{ color: colors.grey[100] }}>
          <CloseIcon />
        </IconButton>
      </DialogTitle>
      <form onSubmit={handleAddCriteria}>
        <DialogContent sx={{ mt: 2 }}>
          <Box sx={styles.formCard}>
            {addCriteriaError && (
              <Typography color={colors.redAccent[500]} textAlign="center" mb="16px">
                {addCriteriaError}
              </Typography>
            )}
            <TextField
              variant="outlined"
              label="Nom du critère"
              value={newCriteriaName}
              onChange={(e) => setNewCriteriaName(e.target.value)}
              fullWidth
              required
              InputLabelProps={{ shrink: true }}
              sx={styles.filledInputSx}
            />
          </Box>
        </DialogContent>
        <DialogActions sx={styles.dialogActions}>
          <Button onClick={handleClose} sx={{ color: colors.grey[100] }}>Annuler</Button>
          <Button type="submit" variant="contained" disabled={addCriteriaSaving} sx={styles.primaryButton}>
            {addCriteriaSaving ? "Ajout..." : "Ajouter le critère"}
          </Button>
        </DialogActions>
      </form>
    </Dialog>
  );
};
