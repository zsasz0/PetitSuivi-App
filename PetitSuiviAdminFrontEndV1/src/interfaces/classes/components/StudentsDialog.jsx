import React from "react";
import { Box, Button, Dialog, DialogActions, DialogContent, DialogTitle, IconButton, Paper, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Typography } from "@mui/material";
import CloseIcon from "@mui/icons-material/Close";
import GroupOutlinedIcon from "@mui/icons-material/GroupOutlined";

const StudentsDialog = ({ open, onClose, studentsDialogClass, colors, styles, isDark }) => (
    <Dialog open={open} onClose={onClose} fullWidth maxWidth="md" PaperProps={{ sx: styles.studentsDialogPaper }}>
        <DialogTitle sx={{ ...styles.dialogTitle, display: "flex", alignItems: "center", justifyContent: "space-between" }}>
            <Box display="flex" alignItems="center" gap="10px">
                <GroupOutlinedIcon sx={{ color: isDark ? colors.blueAccent[400] : "#475569" }} />
                <span>Élèves inscrits — {studentsDialogClass?.name || ""}</span>
            </Box>
            <IconButton onClick={onClose} sx={{ color: colors.grey[300] }}>
                <CloseIcon />
            </IconButton>
        </DialogTitle>
        <DialogContent sx={{ p: 0 }}>
            {(studentsDialogClass?.students || []).length === 0 ? (
                <Box p="40px" textAlign="center">
                    <Typography variant="h6" color={colors.grey[300]}>Aucun élève inscrit dans cette classe.</Typography>
                </Box>
            ) : (
                <TableContainer component={Paper} sx={{ backgroundColor: "transparent", boxShadow: "none", maxHeight: "60vh" }}>
                    <Table stickyHeader>
                        <TableHead>
                            <TableRow>
                                {["#", "Prénom", "Nom", "Date de naissance", "CIN Parent"].map((header) => (
                                    <TableCell key={header} sx={styles.tableHeader}>{header}</TableCell>
                                ))}
                            </TableRow>
                        </TableHead>
                        <TableBody>
                            {(studentsDialogClass?.students || []).map((student, index) => (
                                <TableRow key={student.id} sx={styles.tableRow}>
                                    <TableCell sx={styles.tableCellIndex}>{index + 1}</TableCell>
                                    <TableCell sx={styles.tableCellFirstName}>{student.firstName}</TableCell>
                                    <TableCell sx={styles.tableCellDefault}>{student.lastName}</TableCell>
                                    <TableCell sx={styles.tableCellDefault}>{student.birthdate || "-"}</TableCell>
                                    <TableCell sx={styles.tableCellIndex}>{student.parent_id || "-"}</TableCell>
                                </TableRow>
                            ))}
                        </TableBody>
                    </Table>
                </TableContainer>
            )}
        </DialogContent>
        <DialogActions sx={{ ...styles.dialogActions, justifyContent: "space-between" }}>
            <Typography variant="body2" color={colors.grey[300]}>
                Total : {(studentsDialogClass?.students || []).length} élève(s)
            </Typography>
            <Button onClick={onClose} variant="contained" sx={{ backgroundColor: isDark ? "#475569" : "#334155", color: "#fff", "&:hover": { backgroundColor: isDark ? "#64748b" : "#475569" } }}>
                Fermer
            </Button>
        </DialogActions>
    </Dialog>
);

export default StudentsDialog;
