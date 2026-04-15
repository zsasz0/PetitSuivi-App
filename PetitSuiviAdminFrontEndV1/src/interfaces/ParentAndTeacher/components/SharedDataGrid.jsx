import { Box, Typography, Tabs, Tab, Button } from "@mui/material";
import { DataGrid, GridToolbarContainer, GridToolbarFilterButton } from "@mui/x-data-grid";
import PersonAddAlt1OutlinedIcon from "@mui/icons-material/PersonAddAlt1Outlined";

const CustomGridToolbar = ({ colors, isDark }) => (
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

/**
 * Shared DataGrid accommodating tabs and optional Add button
 */
const SharedDataGrid = ({ 
    title, 
    subtitle, 
    rows, 
    loading, 
    columns, 
    styles, 
    colors, 
    tab, 
    onTabChange, 
    onAddClick, 
    addLabel,
    activeCount,
    archivedCount,
    isDark 
}) => {
    return (
        <Box>
            <Box display="flex" justifyContent="space-between" alignItems={{ xs: "flex-start", md: "center" }} flexDirection={{ xs: "column", md: "row" }} gap="12px" mb="14px">
                <Box>
                    <Typography variant="h5" fontWeight="bold" color={colors.grey[100]}>
                        {title}
                    </Typography>
                    <Typography variant="body2" color={colors.grey[300]} mt="4px">
                        {subtitle}
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
                        <Tab value="active" label={`Actifs (${activeCount})`} />
                        <Tab value="archived" label={`Archivés (${archivedCount})`} />
                    </Tabs>
                    {onAddClick && (
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
                            {addLabel || "Ajouter"}
                        </Button>
                    )}
                </Box>
            </Box>

            <Box height="62vh" sx={styles.gridContainer}>
                <DataGrid
                    loading={loading}
                    rows={rows}
                    columns={columns}
                    rowHeight={72}
                    pageSize={10}
                    rowsPerPageOptions={[10, 50, 100]}
                    disableSelectionOnClick
                    components={{ Toolbar: CustomGridToolbar }}
                    componentsProps={{ toolbar: { colors, isDark } }}
                />
            </Box>
        </Box>
    );
};

export default SharedDataGrid;
