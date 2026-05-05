import { SharedActionMenu } from "./SharedActionMenu";

export const ParentActionMenu = ({ 
    position, parent, onClose, colors,
    onEdit, onToggleArchive, onDelete
}) => {
    return (
        <SharedActionMenu
            position={position} item={parent} onClose={onClose} colors={colors}
            onEdit={onEdit} onToggleArchive={onToggleArchive} onDelete={onDelete}
        />
    );
};
