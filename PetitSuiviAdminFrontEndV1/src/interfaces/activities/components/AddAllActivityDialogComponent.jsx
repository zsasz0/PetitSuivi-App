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
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  TextField,
  Chip,
  CircularProgress,
} from "@mui/material";
import CloseIcon from "@mui/icons-material/Close";

export const AddAllActivityDialogComponent = (props) => {
  const {
    theme,
    colors,
    styles,
    criteriaList,
    criteriaNameMap,
    addAllActivityForm,
    setAddAllActivityForm,
    addAllActivityError,
    setAddAllActivityError,
    addAllActivitySaving,
    handleAddAllActivity,
    suggestingCriteria,
    maxSuggestedCriteria,
    setMaxSuggestedCriteria,
    handleSuggestCriteria,
    aiEnabled,
    modals,
    closeModal,
  } = props;

  const handleClose = () => {
    closeModal("allActivity");
    setAddAllActivityError("");
    setAddAllActivityForm({ title: "", description: "", criteriaIds: [] });
  };

  return (
    <Dialog open={modals.allActivity} onClose={handleClose} fullWidth maxWidth="md" PaperProps={{ sx: styles.dialogPaper }}>
      <DialogTitle sx={{ ...styles.dialogTitle, display: "flex", alignItems: "center", justifyContent: "space-between" }}>
        <Box>
          <Typography fontWeight="bold" fontSize="1.1rem">Ajouter une activité</Typography>
          <Typography variant="body2" color={colors.grey[300]} mt="4px">
            Créez une activité dans la bibliothèque avec une mise en page plus douce et plus lisible.
          </Typography>
        </Box>
        <IconButton onClick={handleClose} sx={{ color: colors.grey[100] }}>
          <CloseIcon />
        </IconButton>
      </DialogTitle>
      <form onSubmit={handleAddAllActivity}>
        <DialogContent sx={{ mt: 2 }}>
          <Box sx={styles.formCard}>
            {addAllActivityError && (
              <Typography color={colors.redAccent[500]} textAlign="center" mb="16px">
                {addAllActivityError}
              </Typography>
            )}
            <Box display="flex" flexDirection="column" gap="16px">
              <TextField
                variant="outlined"
                label="Titre de l'activité"
                value={addAllActivityForm.title}
                onChange={(e) => setAddAllActivityForm((f) => ({ ...f, title: e.target.value }))}
                fullWidth
                required
                InputLabelProps={{ shrink: true }}
                sx={styles.filledInputSx}
              />
              <TextField
                variant="outlined"
                label="Description"
                multiline
                rows={3}
                value={addAllActivityForm.description}
                onChange={(e) => setAddAllActivityForm((f) => ({ ...f, description: e.target.value }))}
                fullWidth
                InputLabelProps={{ shrink: true }}
                sx={styles.filledInputSx}
              />
              <FormControl variant="outlined" fullWidth sx={styles.filledInputSx}>
                <InputLabel shrink>Sélectionner les critères</InputLabel>
                <Select
                  multiple
                  value={addAllActivityForm.criteriaIds}
                  onChange={(e) => setAddAllActivityForm((f) => ({ ...f, criteriaIds: e.target.value }))}
                  label="Sélectionner les critères"
                  renderValue={(sel) => (
                    <Box display="flex" flexWrap="wrap" gap="4px">
                      {sel.map((id) => (
                        <Chip
                          key={id}
                          label={criteriaNameMap[id] || id}
                          size="small"
                          sx={{
                            backgroundColor: theme.palette.mode === "dark" ? "rgba(20, 184, 166, 0.14)" : "rgba(13, 148, 136, 0.10)",
                            color: colors.greenAccent[400],
                            border: `1px solid ${theme.palette.mode === "dark" ? "rgba(45, 212, 191, 0.16)" : "rgba(13, 148, 136, 0.16)"}`,
                            fontWeight: 700,
                          }}
                        />
                      ))}
                    </Box>
                  )}
                  MenuProps={{
                    PaperProps: {
                      sx: { backgroundColor: colors.primary[400], backgroundImage: "none", borderRadius: "12px", boxShadow: "0 8px 32px rgba(0,0,0,0.3)", p: 1 },
                    },
                  }}
                >
                  {criteriaList.map((c) => {
                    const isSelected = addAllActivityForm.criteriaIds.includes(c.id);
                    return (
                      <MenuItem
                        key={c.id}
                        value={c.id}
                        sx={{
                          display: "flex", alignItems: "center", gap: "12px", borderRadius: "8px", my: "4px", transition: "all 0.2s",
                          backgroundColor: isSelected ? `${colors.greenAccent[500]}15` : "transparent",
                          "&:hover": { backgroundColor: isSelected ? `${colors.greenAccent[500]}25` : "rgba(255,255,255,0.08)" },
                        }}
                      >
                        <Box sx={{
                          width: "20px", height: "20px", borderRadius: "5px", flexShrink: 0,
                          border: `2px solid ${isSelected ? colors.greenAccent[500] : colors.grey[500]}`,
                          backgroundColor: isSelected ? colors.greenAccent[500] : "transparent",
                          display: "flex", alignItems: "center", justifyContent: "center", transition: "all 0.2s ease-in-out",
                        }}>
                          {isSelected && <Typography color="#fff" fontSize="12px" fontWeight="bold">✓</Typography>}
                        </Box>
                        <Typography color={isSelected ? colors.greenAccent[400] : colors.grey[100]} fontWeight={isSelected ? "bold" : "normal"}>{c.name}</Typography>
                      </MenuItem>
                    );
                  })}
                </Select>
              </FormControl>
              <Box sx={styles.helperPanel}>
                <Typography sx={styles.helperLabel}>Max critères :</Typography>
                <TextField
                  variant="outlined"
                  type="number"
                  size="small"
                  value={maxSuggestedCriteria}
                  onChange={(e) => {
                    const v = parseInt(e.target.value);
                    if (!v || v < 1) setMaxSuggestedCriteria(1);
                    else setMaxSuggestedCriteria(Math.min(v, criteriaList.length || 5));
                  }}
                  sx={{ width: 78, ...styles.filledInputSx }}
                  inputProps={{ min: 1, max: criteriaList.length || 5 }}
                />
                <Button variant="contained" onClick={handleSuggestCriteria} disabled={suggestingCriteria || !aiEnabled} sx={styles.secondaryButton}>
                  {suggestingCriteria ? (
                    <>
                      <CircularProgress size={16} sx={{ color: "#fff", mr: 1 }} /> Suggestion...
                    </>
                  ) : !aiEnabled ? (
                    "IA désactivée"
                  ) : (
                    "Suggérer des critères (AI)"
                  )}
                </Button>
              </Box>
            </Box>
          </Box>
        </DialogContent>
        <DialogActions sx={styles.dialogActions}>
          <Button onClick={handleClose} sx={{ color: colors.grey[100] }}>Annuler</Button>
          <Button type="submit" variant="contained" disabled={addAllActivitySaving} sx={styles.primaryButton}>
            {addAllActivitySaving ? "Ajout..." : "Ajouter l'activité"}
          </Button>
        </DialogActions>
      </form>
    </Dialog>
  );
};
