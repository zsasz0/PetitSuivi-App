import { Box, Typography, Tooltip, IconButton, FormControl, Select, MenuItem } from "@mui/material";
import { getParentStatusMeta } from "./statusFormatting";

import MoreVertOutlinedIcon from "@mui/icons-material/MoreVertOutlined";

/**
 * Returns the column configuration for the Parent DataGrid.
 */
export const getParentColumns = (colors, isDark, styles, { onOpenMenu, onUpdateStatus }) => [
    { field: "cin", headerName: "CIN", flex: 0.55, minWidth: 110, headerAlign: "center", align: "center" },
    {
        field: "name", headerName: "Nom", flex: 1.15, minWidth: 220, cellClassName: "name-column--cell",
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
        field: "childrenNames", headerName: "Enfants", flex: 1.2, minWidth: 220, sortable: false,
        renderCell: ({ row }) => {
            const children = row.children || [];
            const countLabel = row.childrenCount > 1 ? `${row.childrenCount} enfants` : row.childrenCount === 1 ? "1 enfant" : "Aucun enfant";
            if (children.length === 0) return <Box component="span" sx={styles.childrenPill}>{countLabel}</Box>;

            return (
                <FormControl size="small" fullWidth>
                    <Select value="" displayEmpty sx={styles.childrenSelect} 
                        renderValue={() => (
                            <Box display="flex" alignItems="center" gap="8px" minWidth={0}>
                                <Box width="22px" height="22px" borderRadius="999px" display="inline-flex" alignItems="center" justifyContent="center"
                                    sx={{ backgroundColor: isDark ? "rgba(148,163,184,0.16)" : "rgba(226,232,240,0.9)", color: isDark ? colors.grey[200] : "#475569", fontSize: "0.72rem", fontWeight: 800 }}>
                                    {row.childrenCount}
                                </Box>
                                <Typography variant="body2" fontWeight="700" noWrap>{countLabel}</Typography>
                            </Box>
                        )}
                    >
                        {children.map((child, index) => (
                            <MenuItem key={`child-${index}`} value={`child-${index}`} 
                                sx={{ py: "10px", px: "12px", pointerEvents: "none" }}>
                                <Box display="flex" alignItems="center" gap="10px">
                                    <Box width="28px" height="28px" borderRadius="10px" display="inline-flex" alignItems="center" justifyContent="center"
                                        sx={{ backgroundColor: isDark ? "rgba(148,163,184,0.16)" : "#e2e8f0", color: isDark ? colors.grey[100] : "#1e293b", fontSize: "0.76rem", fontWeight: 700 }}>
                                        {index + 1}
                                    </Box>
                                    <Box minWidth={0}>
                                        <Typography variant="body2" fontWeight="700" color={isDark ? colors.grey[100] : "#1e293b"}>{`${child.firstName} ${child.lastName}`}</Typography>
                                        <Typography variant="caption" color={isDark ? colors.grey[300] : "#64748b"}>Enfant associé</Typography>
                                    </Box>
                                </Box>
                            </MenuItem>
                        ))}
                    </Select>
                </FormControl>
            );
        }
    },
    {
        field: "approval_status", headerName: "Statut", flex: 0.8, minWidth: 120,
        valueGetter: (params) => {
            if (!params.row) return params.value;
            return getParentStatusMeta(params.row, colors, isDark)?.label || params.value;
        },
        renderCell: ({ row }) => {
            const statusMeta = getParentStatusMeta(row, colors, isDark);
            
            if (row.is_archived) {
                return (
                    <Box display="flex" alignItems="center" gap="6px" height="100%">
                        <Box width="8px" height="8px" borderRadius="999px" flexShrink={0} sx={{ backgroundColor: statusMeta.dotColor }} />
                        <Typography variant="body2" sx={{ color: statusMeta.textColor, fontWeight: 600 }}>{statusMeta.label}</Typography>
                    </Box>
                );
            }

            const statusColor = row.approval_status === "approved"
                ? (isDark ? colors.greenAccent[400] : "#166534")
                : row.approval_status === "rejected"
                    ? (isDark ? colors.redAccent[400] : "#991b1b")
                    : "#b45309";

            return (
                <FormControl size="small" fullWidth>
                    <Select
                        value={row.approval_status || "approved"}
                        onChange={(e) => onUpdateStatus(row.cin, e.target.value)}
                        sx={styles.statusSelect(statusColor)}
                    >
                        <MenuItem value="pending">En attente</MenuItem>
                        <MenuItem value="approved">Approuvé</MenuItem>
                        <MenuItem value="rejected">Rejeté</MenuItem>
                    </Select>
                </FormControl>
            );
        }
    },
    {
        field: "actions", headerName: "Plus", flex: 0.5, minWidth: 90, sortable: false, filterable: false, disableExport: true, headerAlign: "right", align: "right",
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
