import { SharedActionMenu } from "./SharedActionMenu";

export const TeacherActionMenu = ({ 
    position, teacher, onClose, colors,
    onEdit, onToggleArchive, onDelete 
}) => (
    <SharedActionMenu
        position={position} item={teacher} onClose={onClose} colors={colors}
        onEdit={onEdit} onToggleArchive={onToggleArchive} onDelete={onDelete}
    />
);
