import { Box, Button, Checkbox, CircularProgress, Typography } from "@mui/material";
import CheckBoxOutlineBlankRoundedIcon from "@mui/icons-material/CheckBoxOutlineBlankRounded";
import CheckBoxRoundedIcon from "@mui/icons-material/CheckBoxRounded";

const MealExceptionReviewBox = ({
    title,
    description,
    exceptions,
    loading,
    onScan,
    onToggle,
    colors,
    styles,
    isDark,
}) => (
    <Box sx={styles.aiBlock}>
        <Box display="flex" justifyContent="space-between" alignItems={{ xs: "flex-start", md: "center" }} gap="12px" flexDirection={{ xs: "column", md: "row" }} mb="12px">
            <Box>
                <Typography variant="caption" color={isDark ? colors.greenAccent[300] : "#166534"} fontWeight="700" mb="6px" display="block">
                    Détection des repas à risque
                </Typography>
                <Typography variant="body2" color={colors.grey[300]}>
                    {description}
                </Typography>
            </Box>
            <Button variant="outlined" onClick={onScan} disabled={loading} sx={styles.mutedButton}>
                {loading ? <CircularProgress size={18} sx={{ color: colors.grey[100] }} /> : title}
            </Button>
        </Box>

        {exceptions !== null && (
            <Box mt="10px" p="14px" borderRadius="12px" backgroundColor={isDark ? "rgba(255,255,255,0.02)" : "rgba(255,255,255,0.7)"} border={`1px solid ${colors.primary[500]}`}>
                {exceptions.length === 0 ? (
                    <Typography color={colors.greenAccent[400]} fontWeight="700">
                        Aucun repas problématique détecté.
                    </Typography>
                ) : (
                    <Box display="flex" flexDirection="column" gap="10px">
                        <Typography color={colors.redAccent[400]} fontWeight="700">
                            {exceptions.length} repas potentiellement problématique(s). Décochez les faux positifs.
                        </Typography>
                        {exceptions.map((exception, index) => (
                            <Box
                                key={`${exception.meal_id}-${index}`}
                                display="flex"
                                alignItems="flex-start"
                                gap="10px"
                                p="10px 12px"
                                borderRadius="12px"
                                backgroundColor={isDark ? "rgba(15,23,42,0.42)" : "rgba(248,250,252,0.92)"}
                                border={`1px solid ${isDark ? "rgba(148,163,184,0.16)" : "rgba(148,163,184,0.24)"}`}
                            >
                                <Checkbox
                                    checked={exception.checked !== false}
                                    onChange={(event) => onToggle(index, event.target.checked)}
                                    size="small"
                                    icon={<CheckBoxOutlineBlankRoundedIcon sx={{ color: isDark ? "rgba(148,163,184,0.78)" : "#94a3b8", fontSize: 22 }} />}
                                    checkedIcon={<CheckBoxRoundedIcon sx={{ color: isDark ? colors.greenAccent[300] : "#16a34a", fontSize: 22 }} />}
                                    sx={{
                                        p: 0.25,
                                        alignSelf: "flex-start",
                                        "&:hover": { backgroundColor: "transparent" },
                                    }}
                                />
                                <Box>
                                    <Typography color={colors.grey[100]} fontWeight="700" fontSize="0.92rem">
                                        Repas ID {exception.meal_id}
                                    </Typography>
                                    <Typography color={colors.grey[300]} fontSize="0.84rem" mt="4px">
                                        {exception.reason}
                                    </Typography>
                                </Box>
                            </Box>
                        ))}
                    </Box>
                )}
            </Box>
        )}
    </Box>
);

export default MealExceptionReviewBox;
