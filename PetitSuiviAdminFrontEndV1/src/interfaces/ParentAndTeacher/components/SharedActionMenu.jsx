import { Box, Menu, MenuItem, Fade } from "@mui/material";
import EditOutlinedIcon from "@mui/icons-material/EditOutlined";
import ArchiveOutlinedIcon from "@mui/icons-material/ArchiveOutlined";
import UnarchiveOutlinedIcon from "@mui/icons-material/UnarchiveOutlined";
import DeleteOutlineIcon from "@mui/icons-material/DeleteOutline";

export const SharedActionMenu = ({ 
    position, item, onClose, colors,
    onEdit, onToggleArchive, onDelete,
    customActionItems
}) => (
    <Menu
        open={Boolean(position && item)}
        onClose={onClose}
        TransitionComponent={Fade}
        transitionDuration={0}
        anchorReference="none"
        PaperProps={{
            sx: {
                position: "fixed",
                top: position?.top ?? 0,
                left: position?.left ?? 0,
                backgroundColor: colors.primary[400], color: colors.grey[100], borderRadius: "14px",
                border: `1px solid ${colors.primary[500]}`, boxShadow: "0 16px 32px rgba(15,23,42,0.18)",
                width: 190
            }
        }}
    >
        {onEdit && (
            <MenuItem onClick={() => onEdit(item)}>
                <Box display="flex" alignItems="center" gap="10px">
                    <EditOutlinedIcon fontSize="small" /><span>Éditer</span>
                </Box>
            </MenuItem>
        )}
        
        {onToggleArchive && (
            <MenuItem onClick={() => onToggleArchive(item)}>
                <Box display="flex" alignItems="center" gap="10px">
                    {item?.is_archived ? <UnarchiveOutlinedIcon fontSize="small" /> : <ArchiveOutlinedIcon fontSize="small" />}
                    <span>{item?.is_archived ? "Désarchiver" : "Archiver"}</span>
                </Box>
            </MenuItem>
        )}

        {customActionItems}

        {onDelete && (
            <MenuItem onClick={() => onDelete(item)} sx={{ color: colors.redAccent[400] }}>
                <Box display="flex" alignItems="center" gap="10px">
                    <DeleteOutlineIcon fontSize="small" /><span>Supprimer</span>
                </Box>
            </MenuItem>
        )}
    </Menu>
);
