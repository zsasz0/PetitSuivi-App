import React, { useRef } from "react";
import {
  Alert,
  Box,
  Button,
  CircularProgress,
  Portal,
  Snackbar,
  Typography,
} from "@mui/material";
import { useTheme } from "@mui/material/styles";
import Header from "../../components/Header";
import { tokens } from "../../theme";

import { useParametersController } from "./hooks/useParametersController";
import { getStyles } from "./components/ParametersStyles";
import { ToggleCard } from "./components/ToggleCard";
import { SettingsGroupCard } from "./components/SettingsGroupCard";
import { PlanningSection } from "./components/PlanningSection";
import { ArchiveConfirmDialog, ToggleConfirmDialog, DeletePlanningConfirmDialog } from "./components/ParametersDialogs";
import { getInputType, sanitizeNumericInput } from "./utils/parametersUtils";

const Parameters = () => {
  const theme = useTheme();
  const colors = tokens(theme.palette.mode);
  const isDark = theme.palette.mode === "dark";
  const styles = getStyles(colors, isDark);

  const { state, actions } = useParametersController();
  const signatureInputRef = useRef(null);

  const handleSignatureSelect = async (event) => {
    const file = event.target.files?.[0];
    if (!file) return;
    await actions.handleUploadSignature(file);
    event.target.value = "";
  };

  if (state.loading) {
    return (
      <Box m="20px" display="flex" justifyContent="center" alignItems="center" height="60vh">
        <CircularProgress sx={{ color: colors.greenAccent[500] }} />
      </Box>
    );
  }

  const toggleDialogContent = state.toggleConfirm.type === "inscriptions"
    ? {
        title: state.inscriptionsOpen ? "Fermer les inscriptions" : "Ouvrir les inscriptions",
        description: state.inscriptionsOpen
          ? "Cela désactivera la création de compte parent, l'ajout d'enfant et les réinscriptions depuis l'application parent."
          : "Cela réactivera toutes les fonctionnalités d'inscription pour les parents.",
        confirmLabel: state.inscriptionsOpen ? "Fermer" : "Ouvrir",
        onConfirm: actions.handleToggleInscriptions,
      }
    : {
        title: state.aiEnabled ? "Désactiver l'IA" : "Activer l'IA",
        description: state.aiEnabled
          ? "Les analyses médicales, suggestions et détections automatiques seront mises hors service jusqu'à réactivation."
          : "Les modules d'assistance intelligente seront remis en service sur les écrans compatibles.",
        confirmLabel: state.aiEnabled ? "Désactiver" : "Activer",
        onConfirm: actions.handleToggleAi,
      };

  return (
    <Box m="20px">
      <Header title="PARAMÈTRES" />

      <Box display="grid" gridTemplateColumns={{ xs: "1fr", xl: "repeat(2, minmax(0, 1fr))" }} gap="18px" mb="20px" alignItems="stretch">
        <ToggleCard
          title="Inscriptions"
          subtitle={state.inscriptionsOpen ? "Les inscriptions et ré-inscriptions sont ouvertes." : "Toutes les inscriptions sont fermées."}
          enabled={state.inscriptionsOpen}
          saving={state.savingInscriptions}
          onToggleRequest={() => actions.confirmToggle("inscriptions")}
          features={[
            {
              title: "Parcours parent",
              description: "Fonctionnalités impactées quand les inscriptions changent d'état.",
              items: [
                { label: "Création de compte parent", desc: "Accès au parcours d'inscription." },
                { label: "Ajout d'enfant et inscription", desc: "Saisie du dossier enfant." },
                { label: "Ré-inscription", desc: "Passage à la nouvelle année scolaire." },
              ],
            },
          ]}
          colors={colors}
          styles={styles}
        />

        <ToggleCard
          title="Intelligence artificielle"
          subtitle={state.aiEnabled ? "Toutes les fonctionnalités IA sont actives." : "Toutes les fonctionnalités IA sont désactivées."}
          enabled={state.aiEnabled}
          saving={state.savingAi}
          onToggleRequest={() => actions.confirmToggle("ai")}
          features={[
            {
              title: "Modules alimentés par l'IA",
              description: "Cette liste est informative : elle n'ouvre pas de configuration supplémentaire.",
              items: [
                { label: "Analyse médicale", desc: "Résumé IA des dossiers d'inscription." },
                { label: "Détection des exceptions", desc: "Repas et restrictions automatiques." },
                { label: "Suggestions de critères", desc: "Aide à la préparation des activités." },
                { label: "Analyse des signalements", desc: "Aide à la lecture des rapports." },
              ],
            },
          ]}
          colors={colors}
          styles={styles}
        />
      </Box>

      <Box sx={styles.card} mb="20px">
        <Typography variant="h5" fontWeight="700" color={colors.grey[100]} mb="6px">Signature des documents</Typography>
        <Typography variant="body2" color={colors.grey[300]} mb="18px">Cette image est stockée sur le serveur et utilisée dans les factures et reçus de paiement.</Typography>
        <Box display="grid" gridTemplateColumns={{ xs: "1fr", md: "220px 1fr" }} gap="18px" alignItems="center">
          <Box
            sx={{
              border: `1px dashed ${colors.primary[500]}`,
              borderRadius: "16px",
              minHeight: "160px",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              backgroundColor: colors.primary[400],
              overflow: "hidden",
              p: 2,
            }}
          >
            {state.signature.url ? (
              <Box component="img" src={state.signature.url} alt="Signature" sx={{ maxWidth: "100%", maxHeight: "120px", objectFit: "contain", mixBlendMode: "multiply" }} />
            ) : (
              <Typography variant="body2" color={colors.grey[300]}>Aucune signature</Typography>
            )}
          </Box>

          <Box>
            <Typography variant="body2" color={colors.grey[100]} mb="4px">
              Source actuelle : {state.signature.isDefault ? "signature par défaut" : "signature personnalisée"}
            </Typography>
            <Typography variant="body2" color={colors.grey[300]} mb="16px">
              Formats acceptés : JPG, PNG, WEBP. Taille max : 5 Mo.
            </Typography>
            <input ref={signatureInputRef} type="file" accept="image/png,image/jpeg,image/webp" style={{ display: "none" }} onChange={handleSignatureSelect} />
            <Box display="flex" gap="12px" flexWrap="wrap">
              <Button variant="contained" onClick={() => signatureInputRef.current?.click()} disabled={state.uploadingSignature || state.deletingSignature} sx={styles.primaryBtn}>
                {state.uploadingSignature ? "Téléversement..." : state.signature.isDefault ? "Téléverser une signature" : "Remplacer la signature"}
              </Button>
              <Button
                variant="outlined"
                onClick={actions.handleDeleteSignature}
                disabled={state.deletingSignature || state.uploadingSignature || state.signature.isDefault}
                sx={{
                  ...styles.secondaryBtn,
                  borderRadius: "12px",
                  px: 2.5,
                  py: 1.1,
                  color: isDark ? colors.grey[100] : "#334155",
                  borderColor: isDark ? colors.grey[500] : "#94a3b8",
                  backgroundColor: isDark ? "rgba(51,65,85,0.16)" : "rgba(241,245,249,0.9)",
                  "&:hover": {
                    borderColor: isDark ? colors.grey[300] : "#64748b",
                    backgroundColor: isDark ? "rgba(71,85,105,0.24)" : "rgba(226,232,240,0.96)",
                  },
                  "&.Mui-disabled": {
                    borderColor: isDark ? "rgba(148,163,184,0.2)" : "rgba(148,163,184,0.35)",
                    color: isDark ? "rgba(226,232,240,0.38)" : "rgba(51,65,85,0.38)",
                  },
                }}
              >
                {state.deletingSignature ? "Restauration..." : "Restaurer la signature par défaut"}
              </Button>
            </Box>
          </Box>
        </Box>
      </Box>

      <Box sx={styles.card} mt="20px">
        <Typography variant="h5" fontWeight="700" color={colors.grey[100]} mb="6px">Réglages détaillés</Typography>
        <Typography variant="body2" color={colors.grey[300]} mb="18px">Tous les champs ci-dessous appartiennent à la même section. Modifiez-les librement, puis enregistrez l'ensemble en une seule fois.</Typography>

        <Box display="grid" gridTemplateColumns={{ xs: "1fr", xl: "repeat(2, minmax(0, 1fr))" }} gap="18px" alignItems="stretch">
          <SettingsGroupCard title="Identité de l'établissement" description="Nom, adresse et repères généraux de l'école." params={state.groupedParams.identity} columns={2} colors={colors} styles={styles} handleChange={actions.handleChange} getInputType={getInputType} sanitizeNumericInput={sanitizeNumericInput} />
          <SettingsGroupCard title="Tarification des repas & frais" description="Centralisez les montants de restauration et les frais administratifs." params={[...state.groupedParams.fees, ...state.groupedParams.meals]} columns={2} colors={colors} styles={styles} handleChange={actions.handleChange} getInputType={getInputType} sanitizeNumericInput={sanitizeNumericInput} />
          <SettingsGroupCard title="Coordonnées & réseaux" description="Regroupez les coordonnées et liens utiles dans une grille compacte." params={state.groupedParams.contact} columns={3} colors={colors} styles={styles} handleChange={actions.handleChange} getInputType={getInputType} sanitizeNumericInput={sanitizeNumericInput} />
          <SettingsGroupCard title="Autres réglages" description="Réglages supplémentaires non couverts par les groupes principaux." params={state.groupedParams.other} columns={2} colors={colors} styles={styles} handleChange={actions.handleChange} getInputType={getInputType} sanitizeNumericInput={sanitizeNumericInput} />
        </Box>

        <Box mt="20px" pt="18px" borderTop={`1px solid ${colors.primary[500]}`}>
          <Typography variant="h6" fontWeight="700" color={colors.grey[100]} mb="6px">Enregistrement</Typography>
          <Typography variant="body2" color={colors.grey[300]} mb="16px">Ce bouton enregistre tous les champs de cette section.</Typography>
        {state.error && <Alert severity="error" sx={{ mb: "12px" }}>{state.error}</Alert>}
        {state.success && <Alert severity="success" sx={{ mb: "12px" }}>{state.success}</Alert>}
        <Box display="flex" justifyContent="flex-end">
          <Button variant="contained" onClick={actions.handleSaveParams} disabled={state.saving || state.visibleParams.length === 0 || state.hasParamValidationError} sx={styles.primaryBtn}>
            {state.saving ? "Enregistrement..." : "Enregistrer les paramètres"}
          </Button>
        </Box>
        </Box>
      </Box>

      <Box mt="20px">
        <PlanningSection
          plannings={state.plannings}
          selectedPlanningId={state.selectedPlanningId}
          setSelectedPlanningId={actions.setSelectedPlanningId}
          planningForm={state.planningForm}
          setPlanningForm={actions.setPlanningForm}
          planningMessage={state.planningMessage}
          savingPlanning={state.savingPlanning}
          handleSavePlanning={actions.handleSavePlanning}
          handleCreatePlanning={actions.handleCreatePlanning}
          handleRemovePlanning={actions.requestRemovePlanning}
          selectedPlanning={state.selectedPlanning}
          archiveError={state.archiveError}
          archiveResult={state.archiveResult}
          archiveLoading={state.archiveLoading}
          onArchiveRequest={() => actions.setArchiveConfirmOpen(true)}
          colors={colors}
          styles={styles}
        />
      </Box>

      <ArchiveConfirmDialog open={state.archiveConfirmOpen} onClose={() => actions.setArchiveConfirmOpen(false)} onConfirm={actions.handleArchiveYear} colors={colors} styles={styles} />

      <DeletePlanningConfirmDialog open={state.deletePlanningConfirmOpen} onClose={actions.cancelRemovePlanning} onConfirm={actions.confirmRemovePlanning} colors={colors} styles={styles} />

      <ToggleConfirmDialog open={state.toggleConfirm.open} onClose={actions.closeToggleConfirm} onConfirm={toggleDialogContent.onConfirm} title={toggleDialogContent.title} description={toggleDialogContent.description} confirmLabel={toggleDialogContent.confirmLabel} colors={colors} styles={styles} />

      <Portal>
        <Snackbar open={state.toast.open} autoHideDuration={4000} onClose={actions.closeToast} anchorOrigin={{ vertical: "top", horizontal: "right" }} sx={{ zIndex: 2001 }}>
          <Alert onClose={actions.closeToast} severity={state.toast.severity} variant="outlined" sx={{ width: "100%", maxWidth: "420px", alignItems: "center", borderRadius: "14px", boxShadow: "0 12px 28px rgba(15,23,42,0.12)", backgroundColor: isDark ? "rgba(17,24,39,0.96)" : "rgba(255,250,242,0.98)", color: isDark ? colors.grey[100] : "#3f2a12", borderColor: state.toast.severity === "error" ? "rgba(239,68,68,0.35)" : "rgba(245,158,11,0.35)" }}>
            {state.toast.message}
          </Alert>
        </Snackbar>
      </Portal>
    </Box>
  );
};

export default Parameters;
