import {
  Autocomplete,
  Box,
  Button,
  Checkbox,
  Chip,
  CircularProgress,
  Dialog,
  DialogActions,
  DialogContent,
  DialogTitle,
  FormControlLabel,
  Radio,
  RadioGroup,
  TextField,
  Typography,
} from "@mui/material";
import { getStyles } from "../utils/styles";

const EventFormDialog = ({
  open,
  onClose,
  editingEvent,
  form,
  setForm,
  onSubmit,
  formError,
  conflictInfo,
  saving,
  colors,
  isDark,
  classes,
  teachers,
  children,
  selectedClasses,
  setSelectedClasses,
  selectedTeachers,
  setSelectedTeachers,
  selectedChildren,
  setSelectedChildren,
  notifTargetMode,
  setNotifTargetMode,
}) => {
  const styles = getStyles(colors, isDark);
  const isNotifEnabled = !!form.send_notifications;

  return (
    <Dialog open={open} onClose={saving ? undefined : onClose} fullWidth maxWidth="lg" PaperProps={{ sx: styles.dialogPaper }}>
      <DialogTitle sx={styles.dialogTitle}>{editingEvent ? "Modifier l'événement" : "Créer un événement"}</DialogTitle>
      <DialogContent sx={{ mt: 2 }}>
        <form id="event-form" onSubmit={onSubmit}>
          <Box display="grid" gridTemplateColumns={{ xs: "1fr", xl: "1.05fr 0.95fr" }} gap="18px">
            <Box sx={styles.formCard}>
              <Typography variant="h6" fontWeight="700" mb="6px">Détails de l'événement</Typography>
              <Typography variant="body2" color={colors.grey[300]} mb="16px">
                Définissez le titre, le contenu et les horaires de l'événement dans une seule fiche.
              </Typography>
              <Box display="flex" flexDirection="column" gap="16px">
                <TextField
                  variant="outlined"
                  label="Nom de l'événement"
                  value={form.name}
                  onChange={(e) => setForm((prev) => ({ ...prev, name: e.target.value }))}
                  InputLabelProps={{ shrink: true }}
                  sx={styles.floatingField}
                  fullWidth
                  required
                />
                <TextField
                  variant="outlined"
                  label="Description"
                  multiline
                  minRows={4}
                  value={form.description}
                  onChange={(e) => setForm((prev) => ({ ...prev, description: e.target.value }))}
                  InputLabelProps={{ shrink: true }}
                  sx={styles.floatingField}
                  fullWidth
                  required
                />
                <Box display="grid" gridTemplateColumns={{ xs: "1fr", md: "repeat(3, minmax(0, 1fr))" }} gap="16px">
                  <TextField
                    variant="outlined"
                    label="Date"
                    type="date"
                    value={form.date}
                    onChange={(e) => setForm((prev) => ({ ...prev, date: e.target.value }))}
                    InputLabelProps={{ shrink: true }}
                    sx={styles.floatingField}
                    inputProps={{ min: new Date().toISOString().split("T")[0] }}
                    fullWidth
                    required
                  />
                  <TextField
                    variant="outlined"
                    label="Heure de début"
                    type="time"
                    value={form.start_time}
                    onChange={(e) => setForm((prev) => ({ ...prev, start_time: e.target.value }))}
                    InputLabelProps={{ shrink: true }}
                    sx={styles.floatingField}
                    fullWidth
                    required
                  />
                  <TextField
                    variant="outlined"
                    label="Heure de fin"
                    type="time"
                    value={form.end_time}
                    onChange={(e) => setForm((prev) => ({ ...prev, end_time: e.target.value }))}
                    InputLabelProps={{ shrink: true }}
                    sx={styles.floatingField}
                    fullWidth
                    required
                  />
                </Box>

                {conflictInfo && (
                  <Box sx={styles.conflictBox}>
                    <Typography color={colors.redAccent[400]} fontWeight="700" mb="8px">Conflit détecté</Typography>
                    <Typography color={colors.redAccent[300]} whiteSpace="pre-line" fontSize="0.85rem">{conflictInfo}</Typography>
                    <Typography color={colors.grey[300]} mt="8px" fontSize="0.8rem">Veuillez changer la date ou l'horaire pour éviter ce conflit.</Typography>
                  </Box>
                )}

                {formError && <Typography sx={styles.errorBox}>{formError}</Typography>}
              </Box>
            </Box>

            <Box sx={styles.formCard}>
              <Typography variant="h6" fontWeight="700" mb="6px">Notification</Typography>
              <Typography variant="body2" color={colors.grey[300]} mb="16px">
                Gérez immédiatement les destinataires dans la même fenêtre, sans deuxième popup.
              </Typography>

              <FormControlLabel
                control={
                  <Checkbox
                    checked={isNotifEnabled}
                    onChange={(e) => setForm((prev) => ({ ...prev, send_notifications: e.target.checked }))}
                    sx={{ color: colors.greenAccent[400], "&.Mui-checked": { color: colors.greenAccent[500] } }}
                  />
                }
                label="Envoyer une notification après l'enregistrement"
                sx={{ color: colors.grey[100], mb: "12px" }}
              />

              {isNotifEnabled ? (
                <Box display="flex" flexDirection="column" gap="16px">
                  <Box p="14px" borderRadius="12px" backgroundColor={colors.primary[500]} border={`1px solid ${colors.primary[600]}`}>
                    <Typography variant="subtitle2" color={colors.grey[300]} fontWeight="700" mb="8px">
                      Cible des notifications (Parents)
                    </Typography>
                    <RadioGroup row value={notifTargetMode} onChange={(e) => setNotifTargetMode(e.target.value)}>
                      <FormControlLabel value="classes" control={<Radio sx={{ color: colors.greenAccent[500], "&.Mui-checked": { color: colors.greenAccent[500] } }} />} label="Par classes" />
                      <FormControlLabel value="children" control={<Radio sx={{ color: colors.blueAccent[500], "&.Mui-checked": { color: colors.blueAccent[500] } }} />} label="Par enfants" />
                    </RadioGroup>
                  </Box>

                  {notifTargetMode === "classes" ? (
                    <Autocomplete
                      multiple
                      disableCloseOnSelect
                      options={classes}
                      getOptionLabel={(option) => option.name || ""}
                      value={selectedClasses}
                      onChange={(_, value) => setSelectedClasses(value)}
                      isOptionEqualToValue={(option, value) => option.id === value.id}
                      slotProps={{ paper: { sx: styles.menuPaper } }}
                      renderOption={(props, option, { selected }) => {
                        const { key, ...rest } = props;
                        return (
                          <li key={key || option.id} {...rest}>
                            <Checkbox checked={selected} sx={{ color: colors.grey[300], "&.Mui-checked": { color: colors.greenAccent[500] }, p: 0.5, mr: 1 }} />
                            <Typography>{option.name}</Typography>
                          </li>
                        );
                      }}
                      renderInput={(params) => (
                        <TextField
                          {...params}
                          variant="outlined"
                          label="Classes destinataires"
                          InputLabelProps={{ shrink: true }}
                          sx={styles.floatingField}
                        />
                      )}
                      renderTags={(value, getTagProps) =>
                        value.map((option, index) => (
                          <Chip {...getTagProps({ index })} key={option.id} label={option.name} sx={{ backgroundColor: colors.greenAccent[600], color: "#fff", fontWeight: 700 }} />
                        ))
                      }
                    />
                  ) : (
                    <Autocomplete
                      multiple
                      disableCloseOnSelect
                      options={children}
                      getOptionLabel={(option) => option.id === "ALL" ? option.name : `${option.name} (Parent: ${option.parentName})`}
                      value={selectedChildren}
                      onChange={(_, value) => {
                        if (value.some((opt) => opt.id === "ALL")) {
                          // Expand the synthetic "ALL" option into every real child ID so the backend only receives valid ChildIDs.
                          setSelectedChildren(children.filter((child) => child.id !== "ALL"));
                        } else {
                          setSelectedChildren(value);
                        }
                      }}
                      isOptionEqualToValue={(option, value) => option.id === value.id}
                      slotProps={{ paper: { sx: styles.menuPaper } }}
                      renderOption={(props, option, { selected }) => {
                        const { key, ...rest } = props;
                        const isAll = option.id === "ALL";
                        return (
                          <li key={key || option.id} {...rest} style={{ backgroundColor: isAll ? "rgba(139, 92, 246, 0.15)" : "transparent" }}>
                            <Checkbox checked={selected || isAll} sx={{ color: colors.grey[300], "&.Mui-checked": { color: "#8b5cf6" }, p: 0.5, mr: 1 }} />
                            <Box>
                              <Typography fontWeight={isAll ? 700 : 400} color={isAll ? "#a78bfa" : "inherit"}>{option.name}</Typography>
                              {!isAll && <Typography fontSize="0.75rem" color={colors.grey[400]}>Parent: {option.parentName}</Typography>}
                            </Box>
                          </li>
                        );
                      }}
                      renderInput={(params) => (
                        <TextField
                          {...params}
                          variant="outlined"
                          label="Enfants"
                          InputLabelProps={{ shrink: true }}
                          sx={styles.floatingField}
                        />
                      )}
                      renderTags={(value, getTagProps) =>
                        value.map((option, index) => (
                          <Chip {...getTagProps({ index })} key={option.id} label={option.name} sx={{ backgroundColor: "#8b5cf6", color: "#fff", fontWeight: 700 }} />
                        ))
                      }
                    />
                  )}

                  <Autocomplete
                    multiple
                    disableCloseOnSelect
                    options={teachers}
                    getOptionLabel={(option) => `${option.name} (${option.email})`}
                    value={selectedTeachers}
                    onChange={(_, value) => setSelectedTeachers(value)}
                    isOptionEqualToValue={(option, value) => option.cin === value.cin}
                    slotProps={{ paper: { sx: styles.menuPaper } }}
                    renderOption={(props, option, { selected }) => {
                      const { key, ...rest } = props;
                      return (
                        <li key={key || option.cin} {...rest}>
                          <Checkbox checked={selected} sx={{ color: colors.grey[300], "&.Mui-checked": { color: colors.greenAccent[500] }, p: 0.5, mr: 1 }} />
                          <Typography>{option.name} <Typography component="span" fontSize="0.8rem" color={colors.grey[400]}>({option.email})</Typography></Typography>
                        </li>
                      );
                    }}
                    renderInput={(params) => (
                      <TextField
                        {...params}
                        variant="outlined"
                        label="Enseignants"
                        InputLabelProps={{ shrink: true }}
                        sx={styles.floatingField}
                      />
                    )}
                    renderTags={(value, getTagProps) =>
                      value.map((option, index) => (
                        <Chip {...getTagProps({ index })} key={option.cin} label={option.name} sx={{ backgroundColor: colors.greenAccent[600], color: "#fff", fontWeight: 700 }} />
                      ))
                    }
                  />

                  {((notifTargetMode === "classes" ? selectedClasses.length === 0 : selectedChildren.length === 0) && selectedTeachers.length === 0) && (
                    <Typography color={colors.grey[500]} fontSize="0.85rem" textAlign="center">
                      Sélectionnez au moins un destinataire, ou désactivez les notifications.
                    </Typography>
                  )}
                </Box>
              ) : (
                <Box p="16px" borderRadius="12px" backgroundColor={colors.primary[500]} border={`1px solid ${colors.primary[600]}`}>
                  <Typography color={colors.grey[300]} fontSize="0.9rem">
                    Les détails de l'événement seront enregistrés sans envoi de notification.
                  </Typography>
                </Box>
              )}
            </Box>
          </Box>
        </form>
      </DialogContent>
      <DialogActions sx={styles.dialogActions}>
        <Button onClick={onClose} sx={{ color: colors.grey[300] }} disabled={saving}>Annuler</Button>
        <Button type="submit" form="event-form" variant="contained" disabled={saving} sx={styles.submitBtn}>
          {saving ? <CircularProgress size={20} sx={{ color: "#fff" }} /> : (editingEvent ? "Mettre à jour" : "Créer")}
        </Button>
      </DialogActions>
    </Dialog>
  );
};

export default EventFormDialog;
