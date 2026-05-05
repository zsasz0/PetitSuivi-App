import { Box } from "@mui/material";

const StatusBadge = ({ status, styles }) => {
    const labels = {
        approved: "Approuvée",
        pending: "En attente",
        rejected: "Rejetée",
    };
    return <Box component="span" sx={styles.statusPill(status)}>{labels[status] || status}</Box>;
};

export default StatusBadge;
