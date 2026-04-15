import { Box, Typography } from "@mui/material";
import FeedCard from "./FeedCard";

const RecentInscriptionsFeed = ({ inscriptions, colors, isDark }) => {
  return (
    <FeedCard
      title="8 dernières inscriptions enregistrées"
      subtitle="Vue rapide des derniers dossiers ajoutés."
      countLabel={`${inscriptions.length} affichées`}
      emptyText="Aucune inscription récente."
      items={inscriptions}
      colors={colors}
      isDark={isDark}
      renderItem={(insc, i) => {
          const childName =
            insc.child_full_name ||
            `${insc.child?.firstName || ""} ${insc.child?.lastName || ""}`.trim() ||
            "Inconnu";

          const rawDate = insc.inscription_date || insc.date || null;
          const date = rawDate
            ? new Date(rawDate).toLocaleDateString("fr-FR", {
                day: "2-digit",
                month: "short",
                year: "numeric",
              })
            : "-";

          const status = (
            insc.status?.name ||
            insc.inscription_status?.name ||
            insc.status ||
            "pending"
          ).toLowerCase();

          const statusColor =
            status === "approved"
              ? colors.greenAccent[500]
              : status === "rejected"
              ? colors.redAccent[500]
              : "#f59e0b";

          const statusLabel =
            status === "approved"
              ? "Approuvée"
              : status === "rejected"
              ? "Rejetée"
              : "En attente";

          return (
            <Box key={i} display="flex" alignItems="center" gap="12px" p="12px 16px">
              <Box
                width="36px"
                height="36px"
                borderRadius="12px"
                display="flex"
                alignItems="center"
                justifyContent="center"
                sx={{
                  background: isDark
                    ? `linear-gradient(135deg, ${colors.greenAccent[800]}, ${colors.primary[500]})`
                    : "linear-gradient(135deg, rgba(22,163,74,0.18), rgba(134,239,172,0.42))",
                  color: isDark ? colors.greenAccent[300] : "#166534",
                  fontWeight: 700,
                }}
              >
                {childName.charAt(0).toUpperCase()}
              </Box>

              <Box flex="1">
                <Typography color={colors.grey[100]} fontWeight="700" noWrap>
                  {childName}
                </Typography>
                <Typography color={colors.grey[300]} variant="body2" noWrap>
                  {insc.class?.name || "Classe non assignée"}
                </Typography>
              </Box>

              <Box textAlign="right">
                <Typography variant="body2" color={colors.grey[300]}>
                  {date}
                </Typography>
                <Typography
                  sx={{
                    fontSize: "11px",
                    fontWeight: "bold",
                    color: "#fff",
                    backgroundColor: statusColor,
                    px: 1,
                    py: 0.3,
                    borderRadius: "999px",
                    display: "inline-block",
                    mt: "4px",
                  }}
                >
                  {statusLabel}
                </Typography>
              </Box>
            </Box>
          );
      }}
    />
  );
};

export default RecentInscriptionsFeed;
