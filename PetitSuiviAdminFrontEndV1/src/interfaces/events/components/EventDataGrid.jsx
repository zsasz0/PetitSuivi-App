import { Box, Tooltip, Typography, IconButton } from "@mui/material";
import { DataGrid, GridToolbarContainer, GridToolbarFilterButton, frFR } from "@mui/x-data-grid";
import MoreVertOutlinedIcon from "@mui/icons-material/MoreVertOutlined";
import { getStyles } from "../utils/styles";
import { formatDate, formatShortTime, getTimeProgressMeta, getStatusMeta } from "../utils/formatters";

const FR_LOCALE = frFR.components.MuiDataGrid.defaultProps.localeText;

const EventsGridToolbar = ({ colors, isDark }) => (
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

const EventDataGrid = ({ events, colors, isDark, openActionMenu }) => {
  const styles = getStyles(colors, isDark);

  const columns = [
    { field: "id", headerName: "ID", flex: 0.35, minWidth: 70, headerAlign: "center", align: "center" },
    {
      field: "name",
      headerName: "Nom",
      flex: 1.2,
      minWidth: 220,
      cellClassName: "name-column--cell",
      renderCell: ({ row }) => (
        <Box display="flex" flexDirection="column" justifyContent="center" minWidth={0} width="100%" py="8px">
          <Typography fontWeight="700" color={colors.grey[100]} noWrap>{row.name}</Typography>
          <Typography variant="caption" color={colors.grey[300]} noWrap>{row.description || "Sans description"}</Typography>
        </Box>
      ),
    },
    {
      field: "date",
      headerName: "Date",
      flex: 0.7,
      minWidth: 120,
      renderCell: ({ row }) => <Typography>{formatDate(row.date)}</Typography>,
    },
    {
      field: "time",
      headerName: "Horaire",
      flex: 1.1,
      minWidth: 220,
      sortable: false,
      renderCell: ({ row }) => {
        const progress = getTimeProgressMeta(row, new Date());
        const timeLabel = `${formatShortTime(row.start_time)} - ${formatShortTime(row.end_time)}`;
        return (
          <Tooltip title={progress?.tooltip || timeLabel}>
            <Box width="100%" display="flex" flexDirection="column" justifyContent="center" py="8px">
              <Typography fontWeight="700" color={colors.grey[100]}>{timeLabel}</Typography>
              {progress ? (
                <>
                  <Typography variant="caption" color={progress.isMuted ? colors.grey[400] : colors.grey[300]} mt="2px">{progress.label}</Typography>
                  <Box mt="6px" height="4px" borderRadius="999px" overflow="hidden" sx={{ backgroundColor: progress.trackColor }}>
                    <Box height="100%" width={`${progress.percent}%`} borderRadius="999px" sx={{ backgroundColor: progress.barColor }} />
                  </Box>
                </>
              ) : (
                <Typography variant="caption" color={colors.grey[300]} mt="2px">Planifié</Typography>
              )}
            </Box>
          </Tooltip>
        );
      },
    },
    {
      field: "status",
      headerName: "Statut",
      flex: 0.8,
      minWidth: 140,
      renderCell: ({ row }) => {
        const meta = getStatusMeta(row.status, colors, isDark);
        return (
          <Box component="span" sx={{ px: "10px", py: "6px", borderRadius: "999px", border: "1px solid", fontWeight: 700, fontSize: "0.75rem", lineHeight: 1, display: "inline-flex", alignItems: "center", backgroundColor: meta.backgroundColor, color: meta.color, borderColor: meta.borderColor }}>
            {meta.label}
          </Box>
        );
      },
    },
    {
      field: "notifications_sent",
      headerName: "Notifié",
      flex: 0.65,
      minWidth: 120,
      renderCell: ({ row }) => (
        <Box component="span" sx={{ px: "10px", py: "6px", borderRadius: "999px", border: "1px solid", fontWeight: 700, fontSize: "0.75rem", lineHeight: 1, display: "inline-flex", alignItems: "center", backgroundColor: row.notifications_sent ? (isDark ? "rgba(34,197,94,0.18)" : "rgba(22,163,74,0.12)") : (isDark ? "rgba(148,163,184,0.14)" : "rgba(148,163,184,0.14)"), color: row.notifications_sent ? (isDark ? colors.greenAccent[300] : "#166534") : (isDark ? colors.grey[300] : "#64748b"), borderColor: row.notifications_sent ? (isDark ? "rgba(34,197,94,0.22)" : "rgba(22,163,74,0.18)") : (isDark ? "rgba(148,163,184,0.22)" : "rgba(148,163,184,0.18)") }}>
          {row.notifications_sent ? "Envoyé" : "Non envoyé"}
        </Box>
      ),
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

  return (
    <Box height="65vh" sx={styles.dataGrid}>
      <DataGrid
        rows={events}
        columns={columns}
        components={{ Toolbar: EventsGridToolbar }}
        componentsProps={{ toolbar: { colors, isDark } }}
        pageSize={10}
        rowsPerPageOptions={[10, 50, 100]}
        disableSelectionOnClick
        getRowHeight={() => "auto"}
        localeText={FR_LOCALE}
      />
    </Box>
  );
};

export default EventDataGrid;
