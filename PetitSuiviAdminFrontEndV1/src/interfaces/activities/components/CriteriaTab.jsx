import React from "react";
import { Box, Typography, Button } from "@mui/material";
import AddRoundedIcon from "@mui/icons-material/AddRounded";
import { DataGrid } from "@mui/x-data-grid";
import { ActivitiesFilterToolbar } from "./ActivitiesFilterToolbar";

export const CriteriaTab = (props) => {
  const {
    colors,
    isDark,
    styles,
    criteriaCols,
    criteriaList,
    openModal,
    setAddCriteriaError,
    setNewCriteriaName,
  } = props;

  return (
    <Box sx={styles.sectionCard}>
      <Box sx={styles.sectionHeader}>
        <Box>
          <Typography sx={styles.sectionTitle}>Critères d'évaluation</Typography>
          <Typography sx={styles.sectionSubtitle}>
            Gérez une bibliothèque plus lisible de critères avec une liste compacte et des actions discrètes.
          </Typography>
        </Box>
        <Button
          variant="contained"
          startIcon={<AddRoundedIcon fontSize="small" />}
          onClick={() => {
            setAddCriteriaError("");
            setNewCriteriaName("");
            openModal("criteria");
          }}
          sx={styles.sectionActionButton}
        >
          Ajouter un critère
        </Button>
      </Box>
      <Box height="60vh" sx={styles.datagridSx}>
        <DataGrid
          rows={criteriaList}
          columns={criteriaCols}
          components={{ Toolbar: ActivitiesFilterToolbar }}
          componentsProps={{ toolbar: { colors, isDark } }}
          pageSize={10}
          rowsPerPageOptions={[10, 50, 100]}
          disableSelectionOnClick
          rowHeight={74}
        />
      </Box>
    </Box>
  );
};
