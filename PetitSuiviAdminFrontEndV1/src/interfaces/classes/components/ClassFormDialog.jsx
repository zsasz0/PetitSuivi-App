import React from "react";
import {
    Box,
    Button,
    Checkbox,
    Chip,
    Dialog,
    DialogActions,
    DialogContent,
    DialogTitle,
    FormControl,
    InputLabel,
    ListItemText,
    MenuItem,
    Select,
    Slider,
    TextField,
    Typography,
} from "@mui/material";

const ClassFormDialog = ({
    open,
    onClose,
    onSubmit,
    formData,
    formError,
    formErrors,
    plannings,
    teachersList,
    onChange,
    colors,
    styles,
    isDark,
    title,
    submitLabel,
    saving,
}) => (
    <Dialog open={open} onClose={onClose} fullWidth maxWidth="md" PaperProps={{ sx: styles.dialogPaper }}>
        <DialogTitle sx={styles.dialogTitle}>{title}</DialogTitle>
        <form onSubmit={onSubmit}>
            <DialogContent sx={{ mt: 2, display: "flex", flexDirection: "column", gap: "18px" }}>
                <Box sx={styles.formCard}>
                    <Typography variant="body2" color={isDark ? colors.grey[300] : "#64748b"} mb="16px">
                        Renseignez les informations de la classe. Les libelles restent visibles pendant la saisie.
                    </Typography>
                    {formError && <Typography color={colors.redAccent[500]} textAlign="center" mb="16px">{formError}</Typography>}
                    <Box display="grid" gridTemplateColumns={{ xs: "1fr", md: "repeat(2, minmax(0, 1fr))" }} gap="16px">
                        <TextField variant="outlined" label="Nom de la classe" name="name" value={formData.name} onChange={onChange} error={!!formErrors.name} helperText={formErrors.name} InputLabelProps={{ shrink: true }} sx={styles.floatingField} fullWidth required />
                        <FormControl fullWidth>
                            <InputLabel shrink sx={styles.floatingSelectLabel}>Année</InputLabel>
                            <Select name="year" value={formData.year} onChange={onChange} label="Année" sx={styles.compactSelect} MenuProps={{ PaperProps: { sx: styles.compactMenuPaper } }}>
                                {plannings.map((planning) => (
                                    <MenuItem key={planning.id} value={planning.label}>{planning.label}</MenuItem>
                                ))}
                            </Select>
                        </FormControl>
                    </Box>
                    <Box mt="16px" px="8px">
                        <Typography gutterBottom color={isDark ? colors.grey[300] : "#475569"} fontWeight="600">
                            Capacite : {formData.capacity || 0}
                        </Typography>
                        <Slider
                            value={Number(formData.capacity) || 0}
                            onChange={(_, value) => onChange({ target: { name: "capacity", value } })}
                            valueLabelDisplay="auto"
                            step={1}
                            min={0}
                            max={50}
                            sx={styles.slider}
                        />
                    </Box>
                    <Box mt="16px">
                        <FormControl fullWidth>
                            <InputLabel shrink sx={styles.floatingSelectLabel}>Enseignants</InputLabel>
                            <Select
                                multiple
                                name="teacher_ids"
                                value={formData.teacher_ids}
                                onChange={onChange}
                                label="Enseignants"
                                sx={styles.compactSelect}
                                MenuProps={{ PaperProps: { sx: styles.compactMenuPaper } }}
                                renderValue={(selected) => (
                                    <Box display="flex" flexWrap="wrap" gap="6px">
                                        {selected.map((id) => {
                                            const teacher = teachersList.find((item) => String(item.cin || item.id) === String(id));
                                            return (
                                                <Chip
                                                    key={id}
                                                    label={teacher ? `${teacher.firstName} ${teacher.lastName}` : id}
                                                    size="small"
                                                    sx={{
                                                        backgroundColor: isDark ? "rgba(148,163,184,0.18)" : "rgba(226,232,240,0.9)",
                                                        color: colors.grey[100],
                                                        fontWeight: 600,
                                                    }}
                                                />
                                            );
                                        })}
                                    </Box>
                                )}
                            >
                                {teachersList.filter((teacher) => !teacher.is_archived).map((teacher) => (
                                    <MenuItem key={String(teacher.cin || teacher.id)} value={String(teacher.cin || teacher.id)}>
                                        <Checkbox 
                                            checked={formData.teacher_ids.indexOf(String(teacher.cin || teacher.id)) > -1} 
                                            sx={{
                                                color: isDark ? "rgba(255, 255, 255, 0.4)" : "rgba(15, 23, 42, 0.3)",
                                                "&.Mui-checked": {
                                                    color: isDark ? "#64748b" : "#334155",
                                                },
                                                "& .MuiSvgIcon-root": {
                                                    opacity: 1,
                                                }
                                            }}
                                        />
                                        <ListItemText primary={`${teacher.firstName} ${teacher.lastName}`} />
                                    </MenuItem>
                                ))}
                            </Select>
                        </FormControl>
                    </Box>
                </Box>
            </DialogContent>
            <DialogActions sx={styles.dialogActions}>
                <Button onClick={onClose} sx={{ color: colors.grey[100] }}>Annuler</Button>
                <Button type="submit" variant="contained" disabled={saving} sx={{ backgroundColor: isDark ? "#475569" : "#334155", color: "#fff", "&:hover": { backgroundColor: isDark ? "#64748b" : "#475569" } }}>
                    {saving ? "Enregistrement..." : submitLabel}
                </Button>
            </DialogActions>
        </form>
    </Dialog>
);

export default ClassFormDialog;
