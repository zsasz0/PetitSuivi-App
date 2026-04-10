/**
 * @file PaymentInvoiceDialog.jsx
 * @description Renders a print-ready invoice for a given registration.
 */
import React from 'react';
import { Dialog, Box, IconButton, Button, Typography, useTheme } from '@mui/material';
import CloseIcon from '@mui/icons-material/Close';
import PrintIcon from '@mui/icons-material/Print';
import { tokens } from '../../theme';

const formatCurrency = (amount) =>
    new Intl.NumberFormat('fr-FR', { minimumFractionDigits: 0 }).format(Number(amount || 0)) + ' TND';

const maskCin = (cin) => {
    if (!cin) return "";
    const str = String(cin);
    if (str.length <= 3) return str;
    return str.substring(0, 3) + "*".repeat(str.length - 3);
};

const PaymentInvoiceDialog = ({ open, onClose, invoiceData, companyParams = {} }) => {
    const theme = useTheme();
    const colors = tokens(theme.palette.mode);

    if (!invoiceData) return null;

    const { companyName = 'PETIT SUIVI', address = '123 Avenue des Écoles, Tunis, Tunisie', phone = '+216 71 123 456', email = 'contact@petitsuivi.tn' } = companyParams;

    /**
     * handlePrint – Isolates the .print-container into a hidden iframe and prints
     * only that content with professional table/invoice styling.
     */
    const handlePrint = () => {
        // Build line items HTML
        let rowsHtml = '';
        if (lineItems.length === 0) {
            rowsHtml = `<tr><td colspan="2" style="padding:16px 20px;text-align:center;color:#6b7280;border:1px solid #9ca3af;">Aucun montant associé</td></tr>`;
        } else {
            lineItems.forEach((item) => {
                const amountCell = item.isIncluded
                    ? `<span style="color:#1f2937;font-weight:600;">Inclus</span>`
                    : formatCurrency(item.amount);
                rowsHtml += `<tr>
                    <td style="padding:16px 20px;color:#1f2937;border:1px solid #9ca3af;">
                        <strong>${item.desc}</strong><br/>
                        <span style="color:#6b7280;font-style:italic;font-size:12px;">${item.sub}</span>
                    </td>
                    <td style="padding:16px 20px;text-align:right;color:#1f2937;vertical-align:top;border:1px solid #9ca3af;">${amountCell}</td>
                </tr>`;
            });
        }
        rowsHtml += `<tr>
            <td style="padding:16px 20px;text-align:right;font-weight:bold;background-color:#f9fafb;border:1px solid #9ca3af;text-transform:uppercase;font-size:14px;">TOTAL À PAYER</td>
            <td style="padding:16px 20px;text-align:right;font-weight:bold;color:#111827;background-color:#f9fafb;border:1px solid #9ca3af;font-size:16px;">${formatCurrency(subTotal)}</td>
        </tr>`;

        const cinHtml = parentCin ? `<p style="color:#4b5563;margin-top:4px;font-size:14px;">CIN: ${maskCin(parentCin)}</p>` : '';

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
                        <div style="font-size:20px;font-weight:bold;color:#1f2937;text-transform:uppercase;">Facture</div>
                        <div style="color:#6b7280;margin-top:4px;">N° ${invoiceNumber}</div>
                        <div style="margin-top:16px;font-size:14px;">
                            <p style="color:#4b5563;">Date d'émission: <span style="font-weight:normal;">${issueDate}</span></p>
                            <p style="color:#4b5563;">Date d'échéance: <span style="font-weight:normal;color:#1f2937;">${dueDate}</span></p>
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
                        <div style="color:#4b5563;text-transform:uppercase;font-size:12px;font-weight:bold;margin-bottom:12px;">Destinataire (Parent)</div>
                        <div style="font-size:16px;font-weight:bold;color:#111827;">${parentName || 'Parent Inconnu'}</div>
                        ${cinHtml}
                    </td>
                    <td style="padding:20px;width:50%;vertical-align:top;border-bottom:none;">
                        <div style="color:#374151;text-transform:uppercase;font-size:12px;font-weight:bold;margin-bottom:12px;">Détails de l'élève</div>
                        <div style="font-size:16px;font-weight:bold;color:#111827;">${childName || ''}</div>
                        <p style="color:#4b5563;margin-top:4px;font-size:14px;">Classe: ${className || ''}</p>
                    </td>
                </tr>
            </table>

            <!-- Fees Table -->
            <table style="border:1px solid #9ca3af;margin-bottom:32px;">
                <thead>
                    <tr>
                        <th style="padding:14px 20px;background-color:#f9fafb;color:#374151;text-transform:uppercase;font-size:12px;font-weight:bold;border:1px solid #9ca3af;text-align:left;">Description des services</th>
                        <th style="padding:14px 20px;background-color:#f9fafb;text-align:right;color:#374151;text-transform:uppercase;font-size:12px;font-weight:bold;width:150px;border:1px solid #9ca3af;">Montant</th>
                    </tr>
                </thead>
                <tbody>
                    ${rowsHtml}
                </tbody>
            </table>

            <!-- Signature -->
            <table style="border:none;margin-top:48px;padding-top:32px;border-top:2px dashed #e5e7eb;">
                <tr>
                    <td style="border:none;width:50%;"></td>
                    <td style="border:none;text-align:center;padding:0;width:50%;position:relative;">
                        <p style="color:#4b5563;margin-bottom:48px;position:relative;z-index:1;">Signature de la Direction / Cachet</p>
                        <img src="/assets/sig.png" style="position:absolute; top:10px; left:50%; transform:translateX(-50%); width:180px; mix-blend-mode:multiply; z-index:0; pointer-events:none;" alt="Signature" />
                        <div style="border-bottom:1px solid #d1d5db;width:200px;margin:0 auto;position:relative;z-index:1;"></div>
                    </td>
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

    const {
        parentName,
        parentCin,
        name: childName, // mapped from row.name
        className,
        inscriptionDate,
        totalAmount,    // base tuition
        fraisAmount,    // registration fee
        fraisSnapshot,  // registration fee snapshot
        mealPlan,       // e.g. "Oui", "Non", or meal plan name
        inscriptionId,
        paymentMethodLabel,
        planningStartYear,
        planningEndYear,
        planningEndDate
    } = invoiceData;

    // Calculate dynamic invoice number based on the academic year bounds and inscription ID
    // e.g., INV-2024-2025-0012
    const invoiceNumber = `INV-${planningStartYear}-${planningEndYear}-${String(inscriptionId).padStart(4, '0')}`;

    const issueDateObj = new Date(inscriptionDate || Date.now());
    const issueDate = new Intl.DateTimeFormat('fr-FR', {
        day: '2-digit', month: '2-digit', year: 'numeric'
    }).format(issueDateObj);

    // Due Date is tightly coupled to the end of the academic year planning
    const dueDateObj = new Date(planningEndDate || new Date(issueDateObj.getTime() + 10 * 24 * 60 * 60 * 1000));
    const dueDate = new Intl.DateTimeFormat('fr-FR', {
        day: '2-digit', month: '2-digit', year: 'numeric'
    }).format(dueDateObj);

    const mealCost = Number(invoiceData.mealPlanCost || 0);
    const baseTuition = invoiceData.baseFee !== undefined && invoiceData.baseFee > 0 
        ? Number(invoiceData.baseFee) 
        : Math.max(0, totalAmount - mealCost);

    // Compute lines
    const lineItems = [];
    if (baseTuition > 0) {
        lineItems.push({
            desc: "Frais de Scolarité",
            sub: "Prix de base",
            amount: baseTuition
        });
    }

    // Meal Plan logic 
    if (mealPlan && ["non", "false", "none", null, undefined].indexOf(String(mealPlan).toLowerCase().trim()) === -1) {
        lineItems.push({
            desc: "Service de Cantine",
            sub: mealPlan,
            amount: mealCost, 
            isIncluded: false
        });
    }

    const actualFraisAmount = fraisAmount > 0 ? fraisAmount : (fraisSnapshot > 0 ? fraisSnapshot : 0);
    if (actualFraisAmount > 0) {
        lineItems.push({
            desc: "Frais d'Inscription",
            sub: "Frais de dossier et d'assurance" + (fraisAmount > 0 ? "" : " (Non payé)"),
            amount: actualFraisAmount
        });
    }

    const subTotal = lineItems.reduce((acc, item) => acc + item.amount, 0);

    return (
        <Dialog fullScreen open={open} onClose={onClose}
             sx={{
                 '& .MuiDialog-paper': {
                     backgroundColor: '#f3f4f6', // Grey outer background like the template
                 }
             }}
        >
            {/* Header Toolbar (Hidden purely in print via CSS below) */}
            <Box className="print-hidden" display="flex" justifyContent="space-between" alignItems="center" p={2} backgroundColor={colors.primary[400]}>
                <Typography variant="h4" fontWeight="bold">Prévisualisation Facture</Typography>
                <Box display="flex" gap={2}>
                    <Button variant="contained" color="info" startIcon={<PrintIcon />} onClick={handlePrint}
                            sx={{ backgroundColor: '#2563eb', color: 'white', '&:hover': { backgroundColor: '#1d4ed8' } }}>
                        Imprimer
                    </Button>
                    <IconButton onClick={onClose}><CloseIcon /></IconButton>
                </Box>
            </Box>

            {/* Print Styles injection */}
            <style>
                {`
                    @media print {
                        body { background: white; margin: 0; padding: 0; }
                        .print-hidden { display: none !important; }
                        .print-container { margin: 0 !important; box-shadow: none !important; max-width: 100% !important; border: none !important; padding: 20px !important;}
                        /* Reset MUI Dialog overscrolls */
                        .MuiDialog-root { position: static !important; }
                        .MuiDialog-paper { overflow: visible !important; width: 100% !important; max-width: 100% !important; margin: 0 !important; padding: 0 !important;}
                    }
                    /* Inter Font load */
                    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap');
                `}
            </style>

            <Box p={4} overflow="auto" sx={{ fontFamily: "'Inter', sans-serif" }}>
                {/* Invoice Container */}
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
                            <Typography variant="h4" fontWeight="bold" sx={{ color: '#1f2937', textTransform: 'uppercase' }}>Facture</Typography>
                            <Typography sx={{ color: '#6b7280', mt: '4px' }}>N° {invoiceNumber}</Typography>
                            <Box mt="16px" sx={{ fontSize: '14px', fontWeight: 600 }}>
                                <Typography variant="body2" color="#4b5563">Date d'émission: <span style={{ fontWeight: 'normal' }}>{issueDate}</span></Typography>
                            <Typography variant="body2" sx={{ color: '#4b5563' }}>Date d'échéance: <span style={{ fontWeight: 'normal', color: '#1f2937' }}>{dueDate}</span></Typography>
                                <Typography variant="body2" mt="4px" sx={{ color: '#4b5563' }}>Modalité: <span style={{ fontWeight: 'normal', color: '#1f2937' }}>{paymentMethodLabel}</span></Typography>
                            </Box>
                        </Box>
                    </Box>

                    {/* Information Parent & Elève - Boxed Layout */}
                    <Box display="grid" gridTemplateColumns="1fr 1fr" mb="40px" sx={{ border: '1px solid #9ca3af', borderRadius: '4px', overflow: 'hidden' }}>
                        <Box p="20px" sx={{ borderRight: '1px solid #9ca3af', backgroundColor: '#f9fafb' }}>
                            <Typography sx={{ color: '#4b5563', textTransform: 'uppercase', fontSize: '12px', fontWeight: 'bold', mb: '12px' }}>
                                Destinataire (Parent)
                            </Typography>
                            <Typography variant="h6" fontWeight="bold" sx={{ color: '#111827' }}>{parentName || 'Parent Inconnu'}</Typography>
                            {parentCin && <Typography variant="body2" sx={{ color: '#4b5563', mt: '4px' }}>CIN: {maskCin(parentCin)}</Typography>}
                        </Box>
                        <Box p="20px">
                            <Typography sx={{ color: '#374151', textTransform: 'uppercase', fontSize: '12px', fontWeight: 'bold', mb: '12px' }}>
                                Détails de l'élève
                            </Typography>
                            <Typography variant="h6" fontWeight="bold" sx={{ color: '#111827' }}>{childName}</Typography>
                            <Typography variant="body2" sx={{ color: '#4b5563', mt: '4px' }}>Classe: {className}</Typography>
                        </Box>
                    </Box>

                    {/* Table des Frais */}
                    <Box component="table" width="100%" textAlign="left" mb="32px" sx={{ borderCollapse: 'collapse', border: '1px solid #9ca3af' }}>
                        <thead>
                            <tr>
                                <th style={{ padding: '14px 20px', backgroundColor: '#f9fafb', color: '#374151', textTransform: 'uppercase', fontSize: '12px', fontWeight: 'bold', border: '1px solid #9ca3af' }}>Description des services</th>
                                <th style={{ padding: '14px 20px', backgroundColor: '#f9fafb', textAlign: 'right', color: '#374151', textTransform: 'uppercase', fontSize: '12px', fontWeight: 'bold', width: '150px', border: '1px solid #9ca3af' }}>Montant</th>
                            </tr>
                        </thead>
                        <tbody>
                            {lineItems.map((item, idx) => (
                                <tr key={idx}>
                                    <td style={{ padding: '16px 20px', color: '#1f2937', border: '1px solid #9ca3af' }}>
                                        <Typography variant="body2" fontWeight="600">{item.desc}</Typography>
                                        <Typography variant="caption" sx={{ color: '#6b7280', fontStyle: 'italic' }}>{item.sub}</Typography>
                                    </td>
                                    <td style={{ padding: '16px 20px', textAlign: 'right', color: '#1f2937', verticalAlign: 'top', border: '1px solid #9ca3af' }}>
                                        {item.isIncluded ? (
                                            <Typography variant="body2" sx={{ color: '#1f2937', fontWeight: 600 }}>Inclus</Typography>
                                        ) : (
                                            formatCurrency(item.amount)
                                        )}
                                    </td>
                                </tr>
                            ))}
                            {lineItems.length === 0 && (
                                <tr>
                                    <td colSpan="2" style={{ padding: '16px 20px', textAlign: 'center', color: '#6b7280', border: '1px solid #9ca3af' }}>Aucun montant associé</td>
                                </tr>
                            )}
                            <tr>
                                <td style={{ padding: '16px 20px', textAlign: 'right', fontWeight: 'bold', backgroundColor: '#f9fafb', border: '1px solid #9ca3af', textTransform: 'uppercase', fontSize: '14px' }}>TOTAL À PAYER</td>
                                <td style={{ padding: '16px 20px', textAlign: 'right', fontWeight: 'bold', color: '#111827', backgroundColor: '#f9fafb', border: '1px solid #9ca3af', fontSize: '16px' }}>{formatCurrency(subTotal)}</td>
                            </tr>
                        </tbody>
                    </Box>

                    {/* Signatures */}
                    <Box display="grid" gridTemplateColumns="1fr 1fr" gap={4} mt={"48px"} pt={"32px"} sx={{ borderTop: '2px dashed #e5e7eb' }}>
                        <Box></Box>
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

export default PaymentInvoiceDialog;
