import React from "react";
import { Box, Typography, Tooltip, IconButton } from "@mui/material";
import VisibilityOutlinedIcon from "@mui/icons-material/VisibilityOutlined";
import MoreVertOutlinedIcon from "@mui/icons-material/MoreVertOutlined";
import TeachersSelectCell from "./TeachersSelectCell";

export const getClassColumns = ({
    colors,
    isDark,
    styles,
    setStudentsDialogClass,
    setIsStudentsDialogOpen,
    openActionMenu,
}) => [
    {
        field: "name",
        headerName: "Nom",
        flex: 1,
        minWidth: 220,
        cellClassName: "name-column--cell",
        renderCell: ({ row }) => (
            <Box display="flex" flexDirection="column" justifyContent="center" minWidth={0} width="100%">
                <Typography fontWeight="700" color={colors.grey[100]} noWrap>
                    {row.name}
                </Typography>
                {row.is_archived && (
                    <Box display="flex" alignItems="center" gap="6px" minWidth={0}>
                        <Box width="8px" height="8px" borderRadius="999px" flexShrink={0} sx={{ backgroundColor: isDark ? colors.grey[400] : "#94a3b8" }} />
                        <Typography variant="caption" noWrap sx={{ color: colors.grey[300], fontWeight: 600 }}>
                            Archivee
                        </Typography>
                    </Box>
                )}
            </Box>
        ),
    },
    {
        field: "year",
        headerName: "Année",
        flex: 0.7,
        minWidth: 120,
        headerAlign: "center",
        align: "center",
        renderCell: ({ row }) => {
            if (!row.year || row.year === "-") return "-";
            const parsed = parseInt(row.year, 10);
            if (isNaN(parsed)) return row.year;
            return `${parsed}/${parsed + 1}`;
        },
    },
    {
        field: "teachers",
        headerName: "Enseignants",
        flex: 1.2,
        minWidth: 220,
        sortable: false,
        valueGetter: (params) => {
            if (!params.row || !params.row.teachers || !Array.isArray(params.row.teachers)) return "";
            return params.row.teachers.map(t => `${t.firstName || ""} ${t.lastName || ""}`.trim()).join(", ");
        },
        renderCell: ({ row }) => <TeachersSelectCell teachers={row.teachers || []} colors={colors} styles={styles} isDark={isDark} />,
    },
    {
        field: "studentsCount",
        headerName: "Inscrits / Capacité",
        flex: 1,
        minWidth: 220,
        sortable: false,
        renderCell: ({ row }) => {
            const studentsCount = row.studentsCount || 0;
            const capacity = Number(row.capacity) || 0;
            const ratio = capacity > 0 ? Math.min(studentsCount / capacity, 1) : 0;
            const isFull = capacity > 0 && studentsCount >= capacity;

            return (
                <Box display="flex" alignItems="center" gap="10px" width="100%" minWidth={0}>
                    <Tooltip title="Voir les élèves">
                        <IconButton
                            size="small"
                            onClick={() => {
                                setStudentsDialogClass(row);
                                setIsStudentsDialogOpen(true);
                            }}
                            sx={{ color: isDark ? colors.grey[200] : "#475569", backgroundColor: isDark ? "rgba(148,163,184,0.14)" : "rgba(226,232,240,0.8)", "&:hover": { backgroundColor: isDark ? "rgba(148,163,184,0.22)" : "rgba(203,213,225,0.9)" } }}
                        >
                            <VisibilityOutlinedIcon fontSize="small" />
                        </IconButton>
                    </Tooltip>
                    <Box minWidth={0} flex={1}>
                        <Box display="flex" alignItems="baseline" gap="6px" mb="6px">
                            <Typography fontWeight="700" color={colors.grey[100]}>
                                {studentsCount} / {capacity}
                            </Typography>
                            <Typography variant="caption" color={isFull ? (isDark ? colors.greenAccent[300] : "#15803d") : colors.grey[300]}>
                                {isFull ? "Classe pleine" : "Places occupées"}
                            </Typography>
                        </Box>
                        <Box sx={styles.occupancyTrack}>
                            <Box sx={{ ...styles.occupancyFill(isFull), width: `${ratio * 100}%` }} />
                        </Box>
                    </Box>
                </Box>
            );
        },
    },
    {
        field: "actions",
        headerName: "Plus",
        flex: 0.4,
        minWidth: 90,
        sortable: false,
        filterable: false,
        headerAlign: "right",
        align: "right",
        renderCell: ({ row }) => (
            <Box display="flex" justifyContent="flex-end" width="100%">
                <Tooltip title="Plus d'actions">
                    <IconButton size="small" onClick={(event) => openActionMenu(event, row)} sx={{ color: colors.grey[200], backgroundColor: "rgba(148,163,184,0.14)", "&:hover": { backgroundColor: "rgba(148,163,184,0.22)" } }}>
                        <MoreVertOutlinedIcon fontSize="small" />
                    </IconButton>
                </Tooltip>
            </Box>
        ),
    },
];
