import { Box, Typography } from "@mui/material";

const AiDisabledBanner = ({ colors, isDark }) => (
    <Box mb="16px" p="12px 14px" borderRadius="12px" backgroundColor={isDark ? "rgba(239,68,68,0.12)" : "rgba(254,226,226,0.9)"} border="1px solid rgba(239,68,68,0.22)" display="flex" alignItems="center" gap="10px">
        <Typography fontSize="18px">⚠️</Typography>
        <Typography color={colors.redAccent[400]} fontSize="0.85rem">
            <strong>IA désactivée</strong> — l&apos;analyse médicale automatique sera ignorée pendant l&apos;approbation.
        </Typography>
    </Box>
);

export default AiDisabledBanner;
