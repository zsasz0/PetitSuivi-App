import { Box, Chip, IconButton, Tooltip, Typography } from "@mui/material";
import MoreVertOutlinedIcon from "@mui/icons-material/MoreVertOutlined";
import StatusBadge from "./StatusBadge";

export const getInscriptionsColumns = ({ colors, isDark, styles, openDetailDialog }) => [
    {
        field: "name",
        headerName: "Nom",
        flex: 1.1,
        minWidth: 190,
        cellClassName: "name-column--cell",
        renderCell: ({ row }) => (
            <Box display="flex" flexDirection="column" justifyContent="center" minWidth={0} width="100%">
                <Typography fontWeight="700" color={colors.grey[100]} noWrap>
                    {row.name}
                </Typography>
                <Typography variant="caption" color={colors.grey[300]} noWrap>
                    {row.parent}
                </Typography>
            </Box>
        ),
    },
    { field: "age", headerName: "Âge", flex: 0.45, minWidth: 70, headerAlign: "center", align: "center" },
    {
        field: "previousInscriptions",
        headerName: "Hist.",
        flex: 0.55,
        minWidth: 90,
        headerAlign: "center",
        align: "center",
        renderCell: ({ row }) => row.previousInscriptions > 0
            ? <Typography fontWeight="700" color={colors.redAccent[400]}>{row.previousInscriptions}</Typography>
            : <Typography color={colors.grey[300]}>{row.previousInscriptions}</Typography>,
    },
    { field: "inscriptionType", headerName: "Type", flex: 0.75, minWidth: 120 },
    {
        field: "inscriptionClass",
        headerName: "Classe",
        flex: 1,
        minWidth: 160,
        sortable: false,
        renderCell: ({ row }) => {
            if (row.approval === "approved") {
                return (
                    row.inscriptionClass ? (
                        <Chip
                            label={row.inscriptionClass}
                            size="small"
                            sx={{
                                backgroundColor: isDark ? "rgba(34,197,94,0.18)" : "rgba(22,163,74,0.12)",
                                color: isDark ? colors.greenAccent[300] : "#166534",
                                border: `1px solid ${isDark ? "rgba(34,197,94,0.22)" : "rgba(22,163,74,0.18)"}`,
                                fontWeight: 700,
                            }}
                        />
                    ) : (
                        <Box component="span" sx={styles.infoBadge}>Non assignée</Box>
                    )
                );
            }

            return (
                <Box component="span" sx={styles.assignBadge}>
                    Assigner
                </Box>
            );
        },
    },
    { field: "paymentMethod", headerName: "Paiement", flex: 0.9, minWidth: 150 },
    { field: "totalAmount", headerName: "Montant", flex: 0.8, minWidth: 130 },
    {
        field: "approval",
        headerName: "Statut",
        flex: 0.8,
        minWidth: 130,
        renderCell: ({ row }) => <StatusBadge status={row.approval} styles={styles} />,
    },
    { field: "inscriptionDate", headerName: "Date d'inscription", flex: 0.9, minWidth: 140 },
    {
        field: "more",
        headerName: "Plus",
        flex: 0.35,
        minWidth: 90,
        sortable: false,
        filterable: false,
        disableExport: true,
        headerAlign: "right",
        align: "right",
        renderCell: ({ row }) => (
            <Box display="flex" justifyContent="flex-end" width="100%">
                <Tooltip title="Plus">
                    <IconButton size="small" onClick={() => openDetailDialog(row)} sx={{ color: isDark ? colors.grey[200] : "#475569", backgroundColor: isDark ? "rgba(148,163,184,0.14)" : "rgba(226,232,240,0.8)", "&:hover": { backgroundColor: isDark ? "rgba(148,163,184,0.22)" : "rgba(203,213,225,0.9)" } }}>
                        <MoreVertOutlinedIcon fontSize="small" />
                    </IconButton>
                </Tooltip>
            </Box>
        ),
    },
];
