import React from "react";
import { Box, Typography, Button } from "@mui/material";
import AddRoundedIcon from "@mui/icons-material/AddRounded";
import { DataGrid, frFR } from "@mui/x-data-grid";
import { ActivitiesFilterToolbar } from "./ActivitiesFilterToolbar";

const FR_LOCALE = frFR.components.MuiDataGrid.defaultProps.localeText;

export const AllActivitiesTab = (props) => {
  const {
    colors,
    isDark,
    styles,
    allActivCols,
    allActivities,
    openModal,
    setAddAllActivityError,
    setAddAllActivityForm,
  } = props;

  return (
    <Box sx={styles.sectionCard}>
      <Box sx={styles.sectionHeader}>
        <Box>
          <Typography sx={styles.sectionTitle}>Bibliothèque d'activités</Typography>
          <Typography sx={styles.sectionSubtitle}>
            Des descriptions plus respirantes, des critères sous forme de tags et des actions compactes pour libérer la table.
          </Typography>
        </Box>
        <Button
          variant="contained"
          startIcon={<AddRoundedIcon fontSize="small" />}
          onClick={() => {
            setAddAllActivityError("");
            setAddAllActivityForm({ title: "", description: "", criteriaIds: [] });
            openModal("allActivity");
          }}
          sx={styles.sectionActionButton}
        >
          Ajouter une activité
        </Button>
      </Box>
      <Box height="60vh" sx={styles.datagridSx}>
        <DataGrid
          rows={allActivities}
          columns={allActivCols}
          components={{ Toolbar: ActivitiesFilterToolbar }}
          componentsProps={{ toolbar: { colors, isDark } }}
          pageSize={10}
          rowsPerPageOptions={[10, 50, 100]}
          disableSelectionOnClick
          rowHeight={92}
          localeText={FR_LOCALE}
        />
      </Box>
    </Box>
  );
};
