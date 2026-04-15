/**
 * @file PaymentReceiptDialog.jsx
 * @description Renders a print-ready receipt for a specific payment transaction.
 */
import React from 'react';
import { Dialog, Box, IconButton, Button, Typography, useTheme } from '@mui/material';
import CloseIcon from '@mui/icons-material/Close';
import PrintIcon from '@mui/icons-material/Print';
import { tokens } from '../../../theme';

const formatCurrency = (amount) =>
    new Intl.NumberFormat('fr-FR', { minimumFractionDigits: 0 }).format(Number(amount || 0)) + ' TND';

const PaymentReceiptDialog = ({ open, onClose, receiptData, companyParams = {} }) => {
    const theme = useTheme();
    const colors = tokens(theme.palette.mode);

    if (!receiptData || !receiptData.transaction) return null;

    const { companyName = 'PETIT SUIVI', address = '123 Avenue des Écoles, Tunis, Tunisie', phone = '+216 71 123 456', email = 'contact@petitsuivi.tn' } = companyParams;

    const {
        parentName,
        parentCin,
        name: childName,
        className,
        paymentMethodLabel,
        planningStartYear,
        planningEndYear,
        transaction,
        targetMonthLabel
    } = receiptData;

    const maskCin = (cin) => {
        if (!cin) return "";
        const str = String(cin);
        if (str.length <= 3) return str;
        return str.substring(0, 3) + "*".repeat(str.length - 3);
    };

    // Calculate dynamic receipt number
    const receiptNumber = transaction.isFrais
        ? `REC-${planningStartYear}-${planningEndYear}-FRAIS-${String(receiptData.inscriptionId).padStart(4, '0')}`
        : `REC-${planningStartYear}-${planningEndYear}-${String(transaction.id).padStart(5, '0')}`;

    // Payment Date
    const paymentDateObj = new Date(transaction.payment_date || Date.now());
    const paymentDateStr = new Intl.DateTimeFormat('fr-FR', {
        day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit'
    }).format(paymentDateObj);

    const disclaimerText = transaction.isFrais
        ? "Ce montant représente le règlement des frais annuels d'inscription (dossier et assurance)."
        : targetMonthLabel
            ? `Ce reçu atteste du paiement du mois de : ${targetMonthLabel}.`
            : "Ce montant représente un versement partiel ou total associé aux frais de scolarité / cantine. Les frais d'inscription annuels ne sont pas compris dans ce reçu de paiement.";


    /**
     * handlePrint – Isolates the .print-container into a hidden iframe and prints
     * only that content with professional receipt styling.
     */
    const handlePrint = () => {
        const cinHtml = parentCin ? `<p style="color:#4b5563;margin-top:4px;font-size:14px;">CIN: ${maskCin(parentCin)}</p>` : '';
        const amountPaid = transaction.amount_paid || transaction.value || transaction.amount;

        const html = `<html><head>
            <meta charset="utf-8"/>
            <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
            <style>
                * { box-sizing: border-box; margin: 0; padding: 0; }
                body { font-family: 'Inter', sans-serif; background: white; color: #1f2937; font-size: 14px; line-height: 1.6; padding: 40px; }
                table { border-collapse: collapse; width: 100%; }
                @page { margin: 0; size: A4; }
            </style>
        </head><body>
            <!-- Header -->
            <table style="margin-bottom:32px;border:none;">
                <tr>
                    <td style="border:none;vertical-align:top;width:50%;padding:0;">
                        <div style="font-size:24px;font-weight:bold;color:#111827;">${companyName}</div>
                        <div style="color:#6b7280;font-size:14px;margin-top:4px;">École Maternelle &amp; Primaire</div>
                        <div style="margin-top:16px;font-size:14px;color:#4b5563;line-height:1.8;">
                            <span style="color:#6b7280;font-weight:bold;">Adresse :</span> ${address}<br/>
                            <span style="color:#6b7280;font-weight:bold;">Tél :</span> ${phone}<br/>
                            <span style="color:#6b7280;font-weight:bold;">Email :</span> ${email}
                        </div>
                    </td>
                    <td style="border:none;vertical-align:top;text-align:right;width:50%;padding:0;">
                        <div style="font-size:20px;font-weight:bold;color:#1f2937;text-transform:uppercase;">Reçu de Paiement</div>
                        <div style="color:#6b7280;margin-top:4px;">N° ${receiptNumber}</div>
                        <div style="margin-top:16px;font-size:14px;">
                            <p style="color:#4b5563;">Date: <span style="font-weight:normal;">${paymentDateStr}</span></p>
                            <p style="color:#4b5563;margin-top:4px;">Modalité: <span style="font-weight:normal;color:#1f2937;">${paymentMethodLabel || ''}</span></p>
                        </div>
                    </td>
                </tr>
            </table>

            <hr style="border:none;border-top:1px solid #e5e7eb;margin-bottom:24px;"/>

            <!-- Parent & Student Info -->
            <table style="border:1px solid #9ca3af;margin-bottom:40px;">
                <tr>
                    <td style="padding:20px;border-right:1px solid #9ca3af;background-color:#f9fafb;width:50%;vertical-align:top;border-bottom:none;">
                        <div style="color:#4b5563;text-transform:uppercase;font-size:12px;font-weight:bold;margin-bottom:12px;">Reçu de (Parent)</div>
                        <div style="font-size:16px;font-weight:bold;color:#111827;">${parentName || 'Parent Inconnu'}</div>
                        ${cinHtml}
                    </td>
                    <td style="padding:20px;width:50%;vertical-align:top;border-bottom:none;">
                        <div style="color:#374151;text-transform:uppercase;font-size:12px;font-weight:bold;margin-bottom:12px;">Pour l'élève</div>
                        <div style="font-size:16px;font-weight:bold;color:#111827;">${childName || ''}</div>
                        <p style="color:#4b5563;margin-top:4px;font-size:14px;">Classe: ${className || ''}</p>
                    </td>
                </tr>
            </table>

            <!-- Payment Details -->
            <table style="border:1px solid #9ca3af;margin-bottom:48px;">
                <thead>
                    <tr>
                        <th colspan="2" style="padding:16px 20px;background-color:#f9fafb;color:#1f2937;text-transform:uppercase;font-size:14px;font-weight:bold;border:1px solid #9ca3af;text-align:left;">Détails de la transaction ${targetMonthLabel ? `- Mois: ${targetMonthLabel}` : ''}</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td style="padding:24px 20px;color:#1f2937;border:1px solid #9ca3af;">
                            <div style="color:#6b7280;font-size:12px;margin-bottom:4px;">Montant Versé</div>
                            <div style="font-size:22px;font-weight:bold;color:#111827;">${formatCurrency(amountPaid)}</div>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2" style="padding:16px 20px;background-color:#f9fafb;color:#4b5563;font-style:italic;font-size:12px;border:1px solid #9ca3af;">
                            ${disclaimerText}
                        </td>
                    </tr>
                </tbody>
            </table>

            <!-- Signature -->
            <table style="border:none;margin-top:48px;padding-top:32px;border-top:2px dashed #e5e7eb;">
                <tr>
                    <td style="border:none;text-align:center;padding:0;width:50%;position:relative;">
                        <p style="color:#4b5563;margin-bottom:48px;position:relative;z-index:1;">Signature de la Direction / Cachet</p>
                        <img src="/assets/sig.png" style="position:absolute; top:10px; left:50%; transform:translateX(-50%); width:180px; mix-blend-mode:multiply; z-index:0; pointer-events:none;" alt="Signature" />
                        <div style="border-bottom:1px solid #d1d5db;width:200px;margin:0 auto;position:relative;z-index:1;"></div>
                    </td>
                    <td style="border:none;width:50%;"></td>
                </tr>
            </table>

            <!-- Footer -->
            <div style="margin-top:48px;text-align:center;font-size:12px;color:#9ca3af;">
                <p>${companyName}</p>
                <p>Merci de votre confiance.</p>
            </div>
        </body></html>`;

        const iframe = document.createElement('iframe');
        iframe.style.position = 'fixed';
        iframe.style.right = '0';
        iframe.style.bottom = '0';
        iframe.style.width = '0';
        iframe.style.height = '0';
        iframe.style.border = 'none';
        document.body.appendChild(iframe);
        const doc = iframe.contentWindow.document;
        doc.open();
        doc.write(html);
        doc.close();
        iframe.contentWindow.focus();
        setTimeout(() => {
            iframe.contentWindow.print();
            setTimeout(() => document.body.removeChild(iframe), 1000);
        }, 500);
    };

    return (
        <Dialog fullScreen open={open} onClose={onClose}
             sx={{
                 '& .MuiDialog-paper': {
                     backgroundColor: '#f3f4f6', 
                 }
             }}
        >
            {/* Header Toolbar */}
            <Box className="print-hidden" display="flex" justifyContent="space-between" alignItems="center" p={2} backgroundColor={colors.primary[400]}>
                <Typography variant="h4" fontWeight="bold">Prévisualisation Reçu</Typography>
                <Box display="flex" gap={2}>
                    <Button variant="contained" color="info" startIcon={<PrintIcon />} onClick={handlePrint}
                            sx={{ backgroundColor: '#2563eb', color: 'white', '&:hover': { backgroundColor: '#1d4ed8' } }}>
                        Imprimer le Reçu
                    </Button>
                    <IconButton onClick={onClose}><CloseIcon /></IconButton>
                </Box>
            </Box>

            {/* Print Styles */}
            <style>
                {`
                    @media print {
                        body { background: white; margin: 0; padding: 0; }
                        .print-hidden { display: none !important; }
                        .print-container { margin: 0 !important; box-shadow: none !important; max-width: 100% !important; border: none !important; padding: 20px !important;}
                        .MuiDialog-root { position: static !important; }
                        .MuiDialog-paper { overflow: visible !important; width: 100% !important; max-width: 100% !important; margin: 0 !important; padding: 0 !important;}
                    }
                    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap');
                `}
            </style>

            <Box p={4} overflow="auto" sx={{ fontFamily: "'Inter', sans-serif" }}>
                <Box className="print-container" maxWidth="800px" mx="auto" bgcolor="white" p={"40px"} borderRadius="8px" boxShadow="0 4px 6px -1px rgba(0, 0, 0, 0.1)">
                    
                    {/* Header */}
                    <Box display="flex" justifyContent="space-between" alignItems="flex-start" borderBottom="1px solid #e5e7eb" pb={"32px"}>
                        <Box>
                            <Typography variant="h3" fontWeight="bold" sx={{ color: '#111827' }}>{companyName}</Typography>
                            <Typography sx={{ color: '#6b7280', fontSize: '14px', mt: '4px' }}>École Maternelle & Primaire</Typography>
                            <Box mt="16px" sx={{ fontSize: '14px', color: '#4b5563', lineHeight: 1.6 }}>
                                <Typography variant="body2"><strong style={{ color: '#6b7280' }}>Adresse :</strong> {address}</Typography>
                                <Typography variant="body2"><strong style={{ color: '#6b7280' }}>Tél :</strong> {phone}</Typography> 
                                <Typography variant="body2"><strong style={{ color: '#6b7280' }}>Email :</strong> {email}</Typography>
                            </Box>
                        </Box>
                        <Box textAlign="right">
                            <Typography variant="h4" fontWeight="bold" sx={{ color: '#1f2937', textTransform: 'uppercase' }}>Reçu de Paiement</Typography>
                            <Typography sx={{ color: '#6b7280', mt: '4px' }}>N° {receiptNumber}</Typography>
                            <Box mt="16px" sx={{ fontSize: '14px', fontWeight: 600 }}>
                                <Typography variant="body2" color="#4b5563">Date: <span style={{ fontWeight: 'normal' }}>{paymentDateStr}</span></Typography>
                                <Typography variant="body2" mt="4px" sx={{ color: '#4b5563' }}>Modalité: <span style={{ fontWeight: 'normal', color: '#1f2937' }}>{paymentMethodLabel}</span></Typography>
                            </Box>
                        </Box>
                    </Box>

                    {/* Information Parent & Elève */}
                    <Box display="grid" gridTemplateColumns="1fr 1fr" mb="40px" sx={{ border: '1px solid #9ca3af', borderRadius: '4px', overflow: 'hidden' }}>
                        <Box p="20px" sx={{ borderRight: '1px solid #9ca3af', backgroundColor: '#f9fafb' }}>
                            <Typography sx={{ color: '#4b5563', textTransform: 'uppercase', fontSize: '12px', fontWeight: 'bold', mb: '12px' }}>
                                Reçu de (Parent)
                            </Typography>
                            <Typography variant="h6" fontWeight="bold" sx={{ color: '#111827' }}>{parentName || 'Parent Inconnu'}</Typography>
                            {parentCin && <Typography variant="body2" sx={{ color: '#4b5563', mt: '4px' }}>CIN: {maskCin(parentCin)}</Typography>}
                        </Box>
                        <Box p="20px">
                            <Typography sx={{ color: '#374151', textTransform: 'uppercase', fontSize: '12px', fontWeight: 'bold', mb: '12px' }}>
                                Pour l'élève
                            </Typography>
                            <Typography variant="h6" fontWeight="bold" sx={{ color: '#111827' }}>{childName}</Typography>
                            <Typography variant="body2" sx={{ color: '#4b5563', mt: '4px' }}>Classe: {className}</Typography>
                        </Box>
                    </Box>

                    {/* Détails du Paiement */}
                    <Box component="table" width="100%" textAlign="left" mb="48px" sx={{ borderCollapse: 'collapse', border: '1px solid #9ca3af' }}>
                        <thead>
                            <tr>
                                <th colSpan="2" style={{ padding: '16px 20px', backgroundColor: '#f9fafb', color: '#1f2937', textTransform: 'uppercase', fontSize: '14px', fontWeight: 'bold', border: '1px solid #9ca3af' }}>Détails de la transaction {targetMonthLabel ? `- Mois: ${targetMonthLabel}` : ''}</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td style={{ padding: '24px 20px', color: '#1f2937', border: '1px solid #9ca3af' }}>
                                    <Typography variant="caption" sx={{ color: '#6b7280', display: 'block', mb: '4px' }}>Montant Versé</Typography>
                                    <Typography variant="h4" fontWeight="bold" sx={{ color: '#111827' }}>{formatCurrency(transaction.amount_paid || transaction.value || transaction.amount)}</Typography>
                                </td>
                            </tr>
                            <tr>
                                <td colSpan="2" style={{ padding: '16px 20px', backgroundColor: '#f9fafb', color: '#4b5563', fontStyle: 'italic', fontSize: '12px', border: '1px solid #9ca3af' }}>
                                    {disclaimerText}
                                </td>
                            </tr>
                        </tbody>
                    </Box>

                    {/* Signatures */}
                    <Box display="grid" gridTemplateColumns="1fr 1fr" gap={4} mt={"48px"} pt={"32px"} sx={{ borderTop: '2px dashed #e5e7eb' }}>
                        <Box textAlign="center" position="relative">
                            <Typography variant="body2" sx={{ color: '#4b5563', mb: '48px', position: 'relative', zIndex: 1 }}>Signature de la Direction / Cachet</Typography>
                            <Box
                                component="img"
                                src="/assets/sig.png"
                                alt="Signature"
                                sx={{
                                    position: 'absolute',
                                    top: '10px',
                                    left: '50%',
                                    transform: 'translateX(-50%)',
                                    width: '180px',
                                    mixBlendMode: 'multiply',
                                    pointerEvents: 'none',
                                    zIndex: 0
                                }}
                            />
                            <Box sx={{ borderBottom: '1px solid #d1d5db', width: '200px', mx: 'auto', position: 'relative', zIndex: 1 }}></Box>
                        </Box>
                    </Box>

                    {/* Footer */}
                    <Box mt={"48px"} textAlign="center" sx={{ fontSize: '12px', color: '#9ca3af' }}>
                        <Typography variant="caption" display="block">{companyName}</Typography>
                        <Typography variant="caption" display="block">Merci de votre confiance.</Typography>
                    </Box>
                </Box>
            </Box>
        </Dialog>
    );
};

export default PaymentReceiptDialog;
