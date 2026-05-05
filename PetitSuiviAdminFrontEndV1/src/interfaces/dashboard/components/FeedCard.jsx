import { Box, Typography } from "@mui/material";

const FeedCard = ({
  title,
  subtitle,
  countLabel,
  emptyText,
  items,
  renderItem,
  colors,
  isDark,
}) => {
  return (
    <Box
      gridColumn={{ xs: "span 12", xl: "span 6" }}
      gridRow="span 2"
      backgroundColor={colors.primary[400]}
      borderRadius="16px"
      sx={{
        display: "flex",
        flexDirection: "column",
        minHeight: 0,
        height: { xs: "auto", xl: 300 },
        overflow: "hidden",
        boxShadow: "0 10px 24px rgba(0,0,0,0.07)",
        border: isDark
          ? "1px solid rgba(255,255,255,0.06)"
          : "1px solid rgba(148,163,184,0.16)",
      }}
    >
      {/* Header */}
      <Box
        display="flex"
        justifyContent="space-between"
        alignItems="flex-start"
        borderBottom={`1px solid ${colors.primary[500]}`}
        p="14px 16px"
      >
        <Box>
          <Typography color={colors.grey[100]} variant="h6" fontWeight="700">
            {title}
          </Typography>

          {subtitle && (
            <Typography
              color={colors.grey[300]}
              variant="body2"
              sx={{ mt: "4px", fontSize: "0.82rem" }}
            >
              {subtitle}
            </Typography>
          )}
        </Box>

        <Box
          px="9px"
          py="5px"
          borderRadius="999px"
          sx={{
            backgroundColor: colors.primary[500],
            color: colors.grey[200],
            fontSize: "11px",
            fontWeight: 700,
          }}
        >
          {countLabel}
        </Box>
      </Box>

      <Box
        sx={{
          flex: 1,
          minHeight: 0,
          overflowY: { xs: "visible", xl: "auto" },
        }}
      >
        {items.length === 0 ? (
          <Typography color={colors.grey[300]} p="20px" textAlign="center">
            {emptyText}
          </Typography>
        ) : (
          items.map((item, index) => renderItem(item, index))
        )}
      </Box>
    </Box>
  );
};

export default FeedCard;

