import React from "react";
import { Box, Typography, Alert, FormControl, InputLabel, Select, MenuItem, TextField, Button, Divider } from "@mui/material";
import AddCircleOutlineIcon from "@mui/icons-material/AddCircleOutline";
import { getPlanningLabel, getPlanningDeleteBlockedMessage, validatePlanningDates } from "../utils/parametersUtils";

export const PlanningSection = ({
  plannings,
  selectedPlanningId,
  setSelectedPlanningId,
  planningForm,
  setPlanningForm,
  planningMessage,
  savingPlanning,
  handleSavePlanning,
  handleCreatePlanning,
  handleRemovePlanning,
  selectedPlanning,
  archiveError,
  archiveResult,
  archiveLoading,
  onArchiveRequest,
  colors,
  styles,
}) => {
  const isNewMode = selectedPlanningId === "__new__";
  const deleteBlockedMessage = !isNewMode && selectedPlanning && !selectedPlanning.isDeletable
    ? getPlanningDeleteBlockedMessage(selectedPlanning)
    : "";

  return (
  <Box sx={styles.card}>
    <Typography variant="h5" fontWeight="700" color={colors.grey[100]} mb="6px">Cycle scolaire</Typography>
    <Typography variant="body2" color={colors.grey[300]} mb="18px">Gérez l'année active, créez la suivante et clôturez l'année en cours depuis un seul panneau.</Typography>

    {planningMessage.text && (
      <Alert severity={planningMessage.type === "success" ? "success" : "error"} sx={{ mb: "16px" }}>
        {planningMessage.text}
      </Alert>
    )}

    <Box display="grid" gridTemplateColumns={{ xs: "1fr", xl: "1.1fr 0.9fr" }} gap="18px">
      <Box sx={styles.featureCard(true)}>
        <Typography variant="subtitle2" fontWeight="700" color={colors.grey[100]} mb="14px">{isNewMode ? "Nouvelle année scolaire" : "Année scolaire sélectionnée"}</Typography>
        <Box component="form" onSubmit={handleSavePlanning} display="flex" flexDirection="column" gap="16px">
          <FormControl fullWidth>
            <InputLabel shrink>Choisir l'année scolaire</InputLabel>
            <Select
              value={selectedPlanningId || ""}
              onChange={(e) => setSelectedPlanningId(e.target.value)}
              label="Choisir l'année scolaire"
              sx={styles.field}
            >
              <MenuItem value="" disabled>Sélectionner une année</MenuItem>
              {plannings.map((planning) => (
                <MenuItem key={planning.id} value={planning.id}>
                  {planning.label || getPlanningLabel(planning.startYear, planning.endYear)} {planning.isArchived ? "(Archivée)" : ""}
                </MenuItem>
              ))}
              <Divider sx={{ my: "4px" }} />
              <MenuItem value="__new__" sx={{ color: colors.greenAccent[400], fontWeight: 700 }}>
                <AddCircleOutlineIcon sx={{ mr: 1, fontSize: "1.2rem" }} /> Créer une nouvelle année
              </MenuItem>
            </Select>
          </FormControl>

          <Box display="grid" gridTemplateColumns={{ xs: "1fr", md: "repeat(3, minmax(0, 1fr))" }} gap="16px">
            <TextField fullWidth variant="outlined" type="date" label="Date de début" value={planningForm.startDate} onChange={(e) => setPlanningForm((prev) => ({ ...prev, startDate: e.target.value }))} InputLabelProps={{ shrink: true }} sx={styles.field} />
            <TextField fullWidth variant="outlined" type="date" label="Date de fin" value={planningForm.endDate} onChange={(e) => setPlanningForm((prev) => ({ ...prev, endDate: e.target.value }))} InputLabelProps={{ shrink: true }} sx={styles.field} />
            <TextField fullWidth variant="outlined" type="text" label="Label" value={(() => {
              const valid = validatePlanningDates(planningForm.startDate, planningForm.endDate);
              return valid ? getPlanningLabel(valid.startYear, valid.endYear) : "";
            })()} disabled InputLabelProps={{ shrink: true }} sx={styles.field} />
          </Box>

          <Box display="flex" justifyContent="flex-end" gap="10px" flexWrap="wrap">
            {isNewMode ? (
              <Button variant="contained" onClick={handleCreatePlanning} disabled={savingPlanning || !planningForm.startDate || !planningForm.endDate} sx={{ ...styles.primaryBtn, backgroundColor: colors.greenAccent[600], "&:hover": { backgroundColor: colors.greenAccent[700] } }}>
                {savingPlanning ? "Création..." : "Créer la nouvelle année"}
              </Button>
            ) : (
              <>
                <Button variant="outlined" color="error" onClick={handleRemovePlanning} disabled={savingPlanning || !selectedPlanningId || !selectedPlanning?.isDeletable} sx={styles.secondaryBtn}>Supprimer</Button>
                <Button type="submit" variant="contained" disabled={savingPlanning || !selectedPlanningId} sx={styles.primaryBtn}>
                  {savingPlanning ? "Enregistrement..." : "Enregistrer"}
                </Button>
              </>
            )}
          </Box>
          {deleteBlockedMessage && (
            <Alert severity="info" sx={{ mt: "4px" }}>
              {deleteBlockedMessage}
            </Alert>
          )}
        </Box>
      </Box>

      <Box sx={styles.featureCard(!(selectedPlanning?.isArchived))}>
        <Typography variant="subtitle2" fontWeight="700" color={colors.grey[100]} mb="8px">Clôture de l'année</Typography>
        <Typography variant="body2" color={colors.grey[300]} mb="12px">
          Archive toutes les inscriptions et classes de l'année en cours. Utilisez cette action seulement lorsque le cycle est terminé.
        </Typography>

        {selectedPlanning?.isArchived ? (
          <Alert severity="success" sx={{ mb: "16px" }}>
            Cette année scolaire est déjà archivée. Créez une nouvelle année pour relancer les inscriptions.
          </Alert>
        ) : (
          <>
            {archiveError && <Alert severity="error" sx={{ mb: "12px" }}>{archiveError}</Alert>}
            {archiveResult && (
              <Alert severity="success" sx={{ mb: "12px" }}>
                {archiveResult.message}<br />
                Inscriptions archivées : {archiveResult.stats?.inscriptions_archived || 0}<br />
                Classes archivées : {archiveResult.stats?.classes_archived || 0}
              </Alert>
            )}
            <Button variant="contained" onClick={onArchiveRequest} disabled={archiveLoading || !!archiveResult || selectedPlanning?.isArchived} sx={{ ...styles.primaryBtn, backgroundColor: colors.redAccent[600], "&:hover": { backgroundColor: colors.redAccent[700] } }}>
              {archiveLoading ? "Archivage en cours..." : "Archiver l'année scolaire"}
            </Button>
          </>
        )}
      </Box>
    </Box>
  </Box>
  );
};
