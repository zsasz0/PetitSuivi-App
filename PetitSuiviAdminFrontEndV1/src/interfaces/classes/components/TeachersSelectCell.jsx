import React from "react";
import { Box, FormControl, MenuItem, Select, Typography } from "@mui/material";

const TeachersSelectCell = ({ teachers, colors, styles, isDark }) => {
    if (!teachers.length) {
        return <Typography variant="body2" color={colors.grey[300]}>Aucun enseignant</Typography>;
    }

    const label = teachers.length === 1 ? "1 enseignant" : `${teachers.length} enseignants`;

    return (
        <FormControl size="small" fullWidth>
            <Select
                value=""
                displayEmpty
                renderValue={() => (
                    <Box display="flex" alignItems="center" gap="8px" minWidth={0}>
                        <Box component="span" sx={styles.countPill}>{teachers.length}</Box>
                        <Typography variant="body2" fontWeight="700" noWrap>
                            {label}
                        </Typography>
                    </Box>
                )}
                sx={styles.listSelectCell}
                MenuProps={{
                    PaperProps: {
                        sx: {
                            ...styles.compactMenuPaper,
                            backgroundColor: isDark ? colors.primary[400] : "#ffffff",
                            color: isDark ? colors.grey[100] : "#0f172a",
                            minWidth: 220,
                            "& .MuiList-root": { p: "8px" },
                        },
                    },
                }}
            >
                {teachers.map((teacher, index) => (
                    <MenuItem
                        key={`${teacher.cin || teacher.id}-${index}`}
                        value={`teacher-${index}`}
                        disabled
                        sx={{
                            opacity: 1,
                            color: isDark ? colors.grey[100] : "#0f172a",
                            py: "10px",
                            px: "12px",
                            borderRadius: "12px",
                            mb: index === teachers.length - 1 ? 0 : "4px",
                            pointerEvents: "none",
                            alignItems: "flex-start",
                            backgroundColor: isDark ? "rgba(255,255,255,0.02)" : "#f8fafc",
                            border: isDark ? "1px solid rgba(255,255,255,0.03)" : "1px solid #e2e8f0",
                            "&.Mui-disabled": {
                                opacity: 1,
                                color: isDark ? colors.grey[100] : "#0f172a",
                                WebkitTextFillColor: isDark ? colors.grey[100] : "#0f172a",
                            },
                        }}
                    >
                        <Box display="flex" alignItems="center" gap="10px" width="100%">
                            <Box component="span" sx={{ ...styles.countPill, width: 28, height: 28, borderRadius: "10px", fontSize: "0.76rem" }}>
                                {index + 1}
                            </Box>
                            <Box minWidth={0}>
                                <Typography variant="body2" fontWeight="700" noWrap color={isDark ? colors.grey[100] : "#0f172a"}>
                                    {`${teacher.firstName || ""} ${teacher.lastName || ""}`.trim()}
                                </Typography>
                                <Typography variant="caption" color={isDark ? colors.grey[300] : "#64748b"}>
                                    Enseignant associe
                                </Typography>
                            </Box>
                        </Box>
                    </MenuItem>
                ))}
            </Select>
        </FormControl>
    );
};

export default TeachersSelectCell;
