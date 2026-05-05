import React from "react";
import { Box, Switch, Typography, CircularProgress } from "@mui/material";

export const ToggleFeatureList = ({ title, description, features, enabled, colors, styles }) => (
  <Box sx={{ ...styles.featureCard(enabled), width: "100%", maxWidth: 440 }}>
    <Typography variant="subtitle2" fontWeight="700" color={colors.grey[100]} mb="6px">{title}</Typography>
    <Typography variant="body2" color={colors.grey[300]} mb="12px">{description}</Typography>
    <Box display="flex" flexDirection="column" gap="8px">
      {features.map((feature) => (
        <Box key={feature.label} display="grid" gridTemplateColumns="14px 1fr" gap="10px" alignItems="start">
          <Box mt="7px" width="6px" height="6px" borderRadius="999px" bgcolor={enabled ? colors.greenAccent[400] : colors.grey[500]} />
          <Box>
            <Typography variant="body2" color={colors.grey[100]} fontWeight="600">{feature.label}</Typography>
            <Typography variant="caption" color={colors.grey[400]}>{feature.desc}</Typography>
          </Box>
        </Box>
      ))}
    </Box>
  </Box>
);

export const ToggleCard = ({ title, subtitle, enabled, saving, onToggleRequest, features, colors, styles }) => (
  <Box sx={styles.card}>
    <Box display="flex" justifyContent="space-between" alignItems="flex-start" gap="16px">
      <Box>
        <Typography variant="h5" fontWeight="700" color={colors.grey[100]}>{title}</Typography>
        <Typography variant="body2" color={colors.grey[300]} mt="4px">{subtitle}</Typography>
      </Box>
      <Box display="flex" alignItems="center" gap="12px">
        {saving && <CircularProgress size={18} sx={{ color: colors.grey[300] }} />}
        <Switch checked={enabled} onChange={onToggleRequest} disabled={saving} sx={styles.switch(enabled)} />
      </Box>
    </Box>

    <Box mt="18px" sx={styles.subtlePanel(enabled)}>
      <Typography variant="caption" color={colors.grey[400]} fontWeight="700" textTransform="uppercase" letterSpacing="0.5px" mb="12px" display="block">
        Fonctionnalités affectées
      </Typography>
      <Box
        display="grid"
        gridTemplateColumns={features.length > 1 ? { xs: "1fr", md: "repeat(2, minmax(0, 1fr))" } : "1fr"}
        gap="12px"
        sx={{
          flex: 1,
          alignItems: "center",
          justifyItems: "center",
          alignContent: "center",
          maxWidth: features.length > 1 ? "100%" : 460,
          mx: "auto",
          width: "100%",
        }}
      >
        {features.map((group) => (
          <ToggleFeatureList key={group.title} title={group.title} description={group.description} features={group.items} enabled={enabled} colors={colors} styles={styles} />
        ))}
      </Box>
    </Box>
  </Box>
);
