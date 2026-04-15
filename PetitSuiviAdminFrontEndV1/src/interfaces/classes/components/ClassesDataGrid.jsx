import React from "react";
import { Box, Button, Tab, Tabs, Typography } from "@mui/material";
import PersonAddAlt1OutlinedIcon from "@mui/icons-material/PersonAddAlt1Outlined";
import { DataGrid, GridToolbarContainer, GridToolbarFilterButton } from "@mui/x-data-grid";

const ClassGridToolbar = ({ colors, isDark }) => (
    <GridToolbarContainer sx={{ display: "flex", justifyContent: "flex-start", p: "10px 14px" }}>
        <GridToolbarFilterButton
            sx={{
                borderRadius: "999px",
                px: "12px",
                py: "4px",
                textTransform: "none",
                fontWeight: 700,
                color: isDark ? colors.grey[100] : "#0f172a",
                border: `1px solid ${isDark ? "rgba(148,163,184,0.24)" : "rgba(148,163,184,0.28)"}`,
                backgroundColor: isDark ? "rgba(51,65,85,0.24)" : "rgba(255,255,255,0.72)",
            }}
        />
    </GridToolbarContainer>
);

const ClassesDataGrid = ({ classesList, loading, columns, styles, colors, tab, onTabChange, onAddClick, isDark }) => {
    const activeClasses = classesList.filter((item) => !item.is_archived);
    const archivedClasses = classesList.filter((item) => item.is_archived);
    const visibleClasses = tab === "active" ? activeClasses : archivedClasses;

    return (
        <Box>
            <Box display="flex" justifyContent="space-between" alignItems={{ xs: "flex-start", md: "center" }} flexDirection={{ xs: "column", md: "row" }} gap="12px" mb="14px">
                <Box>
                    <Typography variant="h5" fontWeight="bold" color={colors.grey[100]}>
                        Gestion des classes
                    </Typography>
                    <Typography variant="body2" color={colors.grey[300]} mt="4px">
                        Consultez un seul tableau et basculez entre les classes actives et archivées.
                    </Typography>
                </Box>
                <Box display="flex" alignItems="center" gap="10px" flexWrap="wrap">
                    <Tabs
                        value={tab}
                        onChange={onTabChange}
                        textColor="inherit"
                        indicatorColor="secondary"
                        sx={{
                            minHeight: 42,
                            "& .MuiTabs-flexContainer": { gap: "8px" },
                            "& .MuiTab-root": {
                                minHeight: 42,
                                borderRadius: "999px",
                                textTransform: "none",
                                fontWeight: 700,
                                color: colors.grey[300],
                                backgroundColor: colors.primary[400],
                                border: `1px solid ${colors.primary[500]}`,
                            },
                            "& .MuiTab-root.Mui-selected": {
                                color: isDark ? "#ffffff" : "#0f172a",
                                backgroundColor: isDark ? "#475569" : "#cbd5e1",
                            },
                            "& .MuiTabs-indicator": { display: "none" },
                        }}
                    >
                        <Tab value="active" label={`Actives (${activeClasses.length})`} />
                        <Tab value="archived" label={`Archivées (${archivedClasses.length})`} />
                    </Tabs>
                    <Button
                        variant="contained"
                        startIcon={<PersonAddAlt1OutlinedIcon />}
                        onClick={onAddClick}
                        sx={{
                            minHeight: 42,
                            borderRadius: "999px",
                            px: "16px",
                            backgroundColor: isDark ? "#475569" : "#334155",
                            color: "#ffffff",
                            fontWeight: 700,
                            textTransform: "none",
                            boxShadow: "none",
                            "&:hover": { backgroundColor: isDark ? "#64748b" : "#475569", boxShadow: "none" },
                        }}
                    >
                        Ajouter une classe
                    </Button>
                </Box>
            </Box>

            <Box height="62vh" sx={styles.gridContainer}>
                <DataGrid
                    loading={loading}
                    rows={visibleClasses}
                    columns={columns}
                    rowHeight={72}
                    pageSize={10}
                    rowsPerPageOptions={[10, 50, 100]}
                    disableSelectionOnClick
                    components={{ Toolbar: ClassGridToolbar }}
                    componentsProps={{ toolbar: { colors, isDark } }}
                />
            </Box>
        </Box>
    );
};

export default ClassesDataGrid;
