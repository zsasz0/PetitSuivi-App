import { Box } from "@mui/material";
import { DataGrid, GridToolbarContainer, GridToolbarFilterButton } from "@mui/x-data-grid";
import { getStyles } from "../utils/styles";

/**
 * @file components/PaymentsDataGrid.jsx
 * Wraps the MUI DataGrid with column definitions, toolbar, and styling.
 */

const PaymentsGridToolbar = ({ colors, isDark }) => (
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

const gridComponents = { Toolbar: PaymentsGridToolbar };

const PaymentsDataGrid = ({ loading, rows, columns, colors, isDark }) => {
  const styles = getStyles(colors, isDark);

  return (
    <Box m="20px 0 0 0" height="65vh" sx={styles.dataGrid}>
      <DataGrid
        loading={loading}
        rows={rows}
        columns={columns}
        components={gridComponents}
        componentsProps={{ toolbar: { colors, isDark } }}
        getRowHeight={() => "auto"}
        pageSize={10}
        rowsPerPageOptions={[10, 50, 100]}
        disableSelectionOnClick
      />
    </Box>
  );
};

export default PaymentsDataGrid;
