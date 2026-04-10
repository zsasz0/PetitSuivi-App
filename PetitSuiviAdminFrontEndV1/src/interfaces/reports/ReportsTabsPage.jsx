import { Box, Tab, Tabs, useTheme } from "@mui/material";
import { useSearchParams } from "react-router-dom";
import Header from "../../components/Header";
import { tokens } from "../../theme";
import Reports from "./index";
import BehavioralHistory from "../behavioral-history";

const TAB_MAP = {
  behavioral: 0,
  history: 1,
};

const TAB_KEYS = ["behavioral", "history"];

function ReportsTabsPage() {
  const theme = useTheme();
  const colors = tokens(theme.palette.mode);
  const [searchParams, setSearchParams] = useSearchParams();
  const tabParam = searchParams.get("tab") || "behavioral";
  const activeTab = TAB_MAP[tabParam] ?? 0;

  const handleTabChange = (_event, nextTab) => {
    setSearchParams({ tab: TAB_KEYS[nextTab] });
  };

  return (
    <Box m="20px">
      <Header title="RAPPORTS" />

      <Box
        sx={{
          borderBottom: `1px solid ${colors.primary[400]}`,
          mb: "24px",
          px: { xs: 0, md: 1 },
        }}
      >
        <Tabs
          value={activeTab}
          onChange={handleTabChange}
          sx={{
            minHeight: 46,
            "& .MuiTab-root": {
              color: colors.grey[300],
              fontSize: "0.95rem",
              textTransform: "none",
              fontWeight: 600,
              opacity: 1,
              minHeight: 46,
              px: 0,
              mr: 3,
            },
            "& .Mui-selected": {
              color: `${colors.greenAccent[400]} !important`,
              fontWeight: 800,
            },
            "& .MuiTabs-indicator": {
              backgroundColor: colors.greenAccent[500],
              height: "4px",
              borderRadius: "999px",
            },
          }}
        >
          <Tab label="Signalements Comportementaux" />
          <Tab label="Historique Comportemental" />
        </Tabs>
      </Box>

      {activeTab === 0 ? <Reports showHeader={false} /> : <BehavioralHistory showHeader={false} />}
    </Box>
  );
}

export default ReportsTabsPage;
