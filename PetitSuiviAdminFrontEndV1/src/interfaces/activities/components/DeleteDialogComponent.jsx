import React from "react";
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Typography,
  Button,
} from "@mui/material";

export const DeleteDialogComponent = (props) => {
  const {
    colors,
    modals,
    closeModal,
    deletingItem,
    handleDeleteConfirm,
  } = props;

  return (
    <Dialog
      open={modals.delete}
      onClose={() => closeModal("delete")}
      PaperProps={{
        sx: {
          backgroundColor: colors.primary[400],
          color: colors.grey[100],
          borderRadius: "12px",
        },
      }}
    >
      <DialogTitle sx={{ fontWeight: "bold", borderBottom: `1px solid ${colors.primary[500]}` }}>
        Confirmer la suppression
      </DialogTitle>
      <DialogContent sx={{ mt: 2 }}>
        <Typography color={colors.grey[200]}>
          Supprimer "{deletingItem?.name || deletingItem?.title}" ?
        </Typography>
      </DialogContent>
      <DialogActions sx={{ p: 2, borderTop: `1px solid ${colors.primary[500]}` }}>
        <Button onClick={() => closeModal("delete")} sx={{ color: colors.grey[100] }}>
          Annuler
        </Button>
        <Button onClick={handleDeleteConfirm} variant="contained" sx={{ backgroundColor: colors.redAccent[500], color: "#fff" }}>
          Supprimer
        </Button>
      </DialogActions>
    </Dialog>
  );
};
