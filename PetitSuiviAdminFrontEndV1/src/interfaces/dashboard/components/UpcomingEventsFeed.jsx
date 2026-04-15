import { Box, Typography } from "@mui/material";
import FeedCard from "./FeedCard";

const UpcomingEventsFeed = ({ events, colors, isDark }) => {
  return (
    <FeedCard
      title="Événements à venir"
      subtitle="Affichage des événements prévus pour le reste de cette semaine"
      countLabel={`${events.length} affichés`}
      emptyText="Aucun événement prévu pour le reste de la semaine."
      items={events}
      colors={colors}
      isDark={isDark}
      renderItem={(evt, i) => {
          const d = evt.date ? new Date(evt.date) : null;

          const day = d ? d.toLocaleDateString("fr-FR", { day: "2-digit" }) : "-";
          const month = d
            ? d
                .toLocaleDateString("fr-FR", { month: "short" })
                .replace(".", "")
                .toUpperCase()
            : "-";

          const fullDate = d
            ? d.toLocaleDateString("fr-FR", {
                weekday: "short",
                day: "2-digit",
                month: "2-digit",
              })
            : "-";

          const statusColor =
            evt.status === "executed"
              ? colors.greenAccent[500]
              : "#f59e0b";

          const statusLabel =
            evt.status === "executed" ? "Exécuté" : "Prévu";

          return (
            <Box key={i} display="flex" alignItems="center" gap="12px" p="12px 16px">
              <Box textAlign="center">
                <Typography sx={{ fontSize: "12px", fontWeight: 800 }}>
                  {day}
                </Typography>
                <Typography sx={{ fontSize: "8px", fontWeight: 700 }}>
                  {month}
                </Typography>
              </Box>

              <Box flex="1">
                <Typography fontWeight="700" noWrap>
                  {evt.name}
                </Typography>
                <Typography variant="body2" color={colors.grey[300]} noWrap>
                  {fullDate} • {(evt.start_time || "").slice(0, 5)} -{" "}
                  {(evt.end_time || "").slice(0, 5)}
                </Typography>
              </Box>

              <Box
                px="9px"
                py="4px"
                borderRadius="999px"
                backgroundColor={statusColor}
                color="#fff"
                fontWeight="bold"
                fontSize="11px"
              >
                {statusLabel}
              </Box>
            </Box>
          );
      }}
    />
  );
};

export default UpcomingEventsFeed;
