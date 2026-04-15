import { Box, Typography, Tooltip, IconButton } from "@mui/material";

import MoreVertOutlinedIcon from "@mui/icons-material/MoreVertOutlined";

/**
 * Returns the column configuration for the Teacher DataGrid.
 */
export const getTeacherColumns = (colors, isDark, { onOpenMenu }) => [
    { field: "cin", headerName: "CIN", flex: 0.55, minWidth: 110, headerAlign: "center", align: "center" },
    {
        field: "name", headerName: "Nom", flex: 1.2, cellClassName: "name-column--cell", minWidth: 220,
        renderCell: ({ row }) => (
            <Box display="flex" flexDirection="column" justifyContent="center" minWidth={0} width="100%">
                <Typography fontWeight="700" color={colors.grey[100]} noWrap>{row.name}</Typography>
            </Box>
        )
    },
    { field: "birthdate", headerName: "Date de naissance", flex: 1, minWidth: 150 },
    { field: "phone", headerName: "Téléphone", flex: 0.9, minWidth: 130, headerAlign: "center", align: "center" },
    { field: "email", headerName: "Email", flex: 1.5, minWidth: 200 },
    {
        field: "actions", headerName: "Plus", flex: 0.4, minWidth: 90, sortable: false, filterable: false, disableExport: true, headerAlign: "right", align: "right",
        renderCell: ({ row }) => (
            <Box display="flex" justifyContent="flex-end" width="100%">
                <Tooltip title="Plus d'actions">
                    <IconButton size="small" onClick={(e) => onOpenMenu(e, row)} sx={{ color: colors.grey[200], backgroundColor: isDark ? "rgba(148,163,184,0.14)" : "rgba(148,163,184,0.14)", "&:hover": { backgroundColor: isDark ? "rgba(148,163,184,0.22)" : "rgba(148,163,184,0.22)" } }}>
                        <MoreVertOutlinedIcon fontSize="small" />
                    </IconButton>
                </Tooltip>
            </Box>
        )
    }
];
