import { useState } from 'react';
import { Box, Typography, TextField, Collapse, Select, MenuItem, FormControl, CircularProgress, Button, IconButton, Dialog, DialogTitle, DialogContent, DialogActions, Autocomplete, Chip, InputAdornment } from "@mui/material";
import DeleteOutlineIcon from "@mui/icons-material/DeleteOutline";
import SearchIcon from "@mui/icons-material/Search";

export const AiDisabledBanner = ({ colors, sx }) => (
    <Box sx={sx.aiBanner}>
        <Typography fontSize="18px">⚠️</Typography>
        <Typography color={colors.redAccent[400]} fontSize="0.85rem">
            <strong>IA désactivée</strong> — La détection automatique des exceptions alimentaires est désactivée. Les exceptions affichées sont celles déjà enregistrées.
        </Typography>
    </Box>
);

export const ControlsBar = ({ plannings, selectedPlanningId, onPlanningChange, searchTerm, onSearchChange, colors, sx }) => (
    <Box sx={sx.controlsBar}>
        <Box display="flex" alignItems={{ xs: "stretch", sm: "center" }} gap="12px" flexDirection={{ xs: "column", sm: "row" }}>
            <Typography sx={sx.toolbarLabel}>Année scolaire</Typography>
            <FormControl variant="outlined" size="small" sx={sx.selectControl}>
                <Select value={selectedPlanningId} onChange={onPlanningChange}>
                    {plannings.map((p) => (
                        <MenuItem key={p.id} value={String(p.id)}>
                            {p.label || `${p.startDate || p.start_date} — ${p.endDate || p.end_date}`}
                        </MenuItem>
                    ))}
                </Select>
            </FormControl>
        </Box>
        <TextField
            variant="outlined" placeholder="Rechercher un enfant ou une classe"
            value={searchTerm} onChange={onSearchChange} sx={sx.searchField}
            InputProps={{ startAdornment: (<InputAdornment position="start"><SearchIcon sx={{ color: colors.grey[400] }} fontSize="small" /></InputAdornment>) }}
        />
    </Box>
);

export const InfoBanner = ({ count, colors, sx }) => (
    <Box sx={sx.infoBanner}>
        <Typography color={colors.grey[200]} variant="body2">
            Seuls les enfants ayant des problèmes de santé alimentaires sont affichés. <strong>{count}</strong> enfant(s) concerné(s).
        </Typography>
    </Box>
);

export const LoadingState = ({ colors }) => (
    <Box textAlign="center" py="40px">
        <CircularProgress sx={{ color: colors.greenAccent[500] }} />
        <Typography color={colors.grey[300]} mt="10px">
            Chargement...
        </Typography>
    </Box>
);

export const EmptyState = ({ colors, sx }) => (
    <Box sx={sx.emptyState}>
        <Typography variant="h4" mb="10px">✅</Typography>
        <Typography variant="h5" color={colors.greenAccent[500]}>Aucune exception alimentaire</Typography>
        <Typography color={colors.grey[300]}>Tous les enfants peuvent manger tous les repas.</Typography>
    </Box>
);

const ExceptionItem = ({ exc, colors, sx, onDelete }) => (
    <Box key={exc.meal_id} sx={sx.exceptionItem}>
        <Box sx={sx.exceptionDot} />
        <Box flex="1">
            <Typography fontWeight="bold" color={colors.redAccent[400]} fontSize="0.9rem">{exc.meal_name || "Repas inconnu"}</Typography>
            <Typography variant="caption" color={colors.grey[400]}>{exc.reason || "Raison non spécifiée"}</Typography>
        </Box>
        {onDelete && (
            <IconButton size="small" onClick={() => onDelete(exc.exception_id)} sx={{ color: colors.redAccent[400] }}>
                <DeleteOutlineIcon fontSize="small" />
            </IconButton>
        )}
    </Box>
);

const ExpandedDetail = ({ child, isOpen, colors, sx, onDeleteException }) => (
    <Collapse in={isOpen}>
        <Box sx={sx.expandedBody}>
            <Typography variant="body2" color={colors.grey[200]} mb="16px">
                <strong>Commentaire diététique :</strong> {child.dietary_comment || "Aucun"}
            </Typography>
            <Typography variant="body2" fontWeight="bold" color={colors.grey[100]} mb="12px">
                Repas interdits ({child.exception_count || 0})
            </Typography>
            {(child.exception_count || 0) === 0 ? (
                <Typography variant="body2" color={colors.greenAccent[500]}>Aucun repas spécifique interdit.</Typography>
            ) : (
                <Box display="flex" flexDirection="column" gap="8px">
                    {(child.exceptions || []).map((exc) => (
                        <ExceptionItem key={exc.meal_id} exc={exc} colors={colors} sx={sx} onDelete={onDeleteException} />
                    ))}
                </Box>
            )}
        </Box>
    </Collapse>
);

export const ChildCard = ({ child, isExpanded, onToggle, getSeverityColor, colors, sx, onDeleteException }) => {
    const severityColor = getSeverityColor(child.exception_count);
    return (
        <Box sx={sx.card}>
            <Box sx={sx.cardRow} onClick={onToggle}>
                <Box sx={sx.avatar}>{(child.child_name || "?").charAt(0).toUpperCase()}</Box>
                <Box flex="1" minWidth="150px">
                    <Typography fontWeight="bold" color={colors.grey[100]} fontSize="0.95rem">{child.child_name || "Inconnu"}</Typography>
                    <Typography color={colors.grey[300]} fontSize="0.8rem">🏫 {child.class_name || "Non assigné"}</Typography>
                </Box>
                <Box px="12px" py="5px" borderRadius="20px" fontSize="12px" fontWeight="bold" flexShrink={0} sx={{ backgroundColor: severityColor + "22", color: severityColor }}>
                    🚫 {child.exception_count || 0} repas interdit{(child.exception_count || 0) > 1 ? "s" : ""}
                </Box>
                <Box flex="1.5" minWidth="200px" display={{ xs: "none", md: "block" }}>
                    <Typography variant="body2" color={colors.grey[300]} fontStyle="italic" noWrap title={child.dietary_comment || ""}>
                        💬 {child.dietary_comment || "Aucun commentaire"}
                    </Typography>
                </Box>
                <Typography color={colors.grey[300]} fontSize="1rem" flexShrink={0}>{isExpanded ? "▲" : "▼"}</Typography>
            </Box>
            <ExpandedDetail child={child} isOpen={isExpanded} colors={colors} sx={sx} onDeleteException={onDeleteException} />
        </Box>
    );
};

export const AddExceptionDialog = ({ open, onClose, onSubmit, colors, sx, allChildren, allMeals, saving, selectedPlanningId }) => {
    const [selectedChild, setSelectedChild] = useState(null);
    const [selectedMeals, setSelectedMeals] = useState([]);
    const [reason, setReason] = useState("");

    const handleSubmit = () => {
        if (!selectedChild || selectedMeals.length === 0 || !reason.trim()) return;
        onSubmit({
            child_id: selectedChild.child_id,
            meal_ids: selectedMeals.map(m => m.id || m.MealsID),
            reason: reason.trim(),
            planning_id: selectedPlanningId ? Number(selectedPlanningId) : undefined,
        });
        setSelectedChild(null); setSelectedMeals([]); setReason("");
    };

    return (
        <Dialog open={open} onClose={onClose} fullWidth maxWidth="sm" PaperProps={{ sx: sx.dialogPaper }}>
            <DialogTitle sx={sx.dialogTitle}>Ajouter une exception alimentaire</DialogTitle>
            <DialogContent sx={{ display: 'flex', flexDirection: 'column', gap: '16px', mt: 1 }}>
                <Box sx={sx.formCard}>
                <Autocomplete options={allChildren} getOptionLabel={(opt) => [opt.child_name, opt.class_name].filter(Boolean).join(" • ")} value={selectedChild} onChange={(_, val) => setSelectedChild(val)} renderInput={(params) => <TextField {...params} label="Enfant" variant="outlined" InputLabelProps={{ shrink: true }} sx={sx.filledInputSx} />} isOptionEqualToValue={(o, v) => o.child_id === v.child_id} />
                <Autocomplete multiple options={allMeals} getOptionLabel={(opt) => opt.name || opt.Name || ""} value={selectedMeals} onChange={(_, val) => setSelectedMeals(val)} renderInput={(params) => <TextField {...params} label="Repas à interdire" variant="outlined" InputLabelProps={{ shrink: true }} sx={sx.filledInputSx} />} renderTags={(value, getTagProps) => value.map((opt, index) => <Chip label={opt.name || opt.Name || ""} {...getTagProps({ index })} key={opt.id || opt.MealsID} sx={sx.mealChip} /> )} isOptionEqualToValue={(o, v) => (o.id || o.MealsID) === (v.id || v.MealsID)} />
                <TextField label="Raison de la restriction" variant="outlined" multiline minRows={2} value={reason} onChange={(e) => setReason(e.target.value)} InputLabelProps={{ shrink: true }} sx={sx.filledInputSx} />
                </Box>
            </DialogContent>
            <DialogActions sx={sx.dialogActions}>
                <Button onClick={onClose} sx={{ color: colors.grey[100] }}>Annuler</Button>
                <Button variant="contained" disabled={!selectedChild || selectedMeals.length === 0 || !reason.trim() || saving} onClick={handleSubmit} sx={sx.primaryButton}>
                    {saving ? <CircularProgress size={18} sx={{ color: '#fff' }} /> : 'Ajouter'}
                </Button>
            </DialogActions>
        </Dialog>
    );
};
