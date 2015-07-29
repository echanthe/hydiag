function hybridAutomaton =...
    createHybridAutomatonFromHybridSystem(hybridSystem)

%% I. PARAMETRES GENERAUX
%hybridSystem = twoTankHybridSystem

% 1. NOMBRE DE MODES, D'EVENEMENTS ET TAILLE DES SIGNATURES
% Remarque : les doublons sont utilisé pour faciliter l'utilisation des
% variables comme arguments de fonctions
modesNo = hybridSystem.main_settings.automate_size;
hybridAutomaton.modesNo = modesNo;
eventsNo= hybridSystem.main_settings.events_size;
hybridAutomaton.eventsNo  = eventsNo;
signatureSize = hybridSystem.main_settings.residuals_size;
hybridAutomaton.signatureSize = signatureSize;

% 2. MATRICE DE TRANSITION
hybridAutomaton.transitionMatrix = zeros(modesNo,eventsNo);
for iMode = 1:modesNo
    hybridAutomaton.transitionMatrix(iMode,:) =...
        hybridSystem.var_objet(iMode).next_id;
end

% 3. NOMBRE DE FAUTES
% Nombre de fautes = nombre d'évènements de faute
faultsNo = 0;
for iEvent = 1:eventsNo
    if hybridSystem.var_objet_events(iEvent).fault == 1
        faultsNo = faultsNo + 1;
    end
end
hybridAutomaton.faultsNo = faultsNo;

% 4. NOMBRE DE MODES DE CONTROLE
% Nombre de modes de controle = Nombre de modes nominaux
hybridAutomaton.controlModesNo = round ( modesNo / ( faultsNo + 1 ) );

% 5. LISTE DES SIGNATURES UNIQUES
% Enumeration des signatures
modeFullSignatureArray = zeros(modesNo,signatureSize);
for iMode = 1:modesNo
    modeFullSignatureArray(iMode,:) = hybridSystem.var_objet(iMode).sig;
end
hybridAutomaton.modeFullSignatureArray = modeFullSignatureArray;
% Liste des signatures uniques
uniqueSignatureArray = unique( modeFullSignatureArray,'rows');
hybridAutomaton.uniqueSignatureArray = uniqueSignatureArray;

% 6. TABLE DE CORRESPONDANCE SIGNATURE-MODE
% avec identifiants de signatures
modeSignatureIDArray = zeros(modesNo,1);
for iMode = 1:modesNo
    currentSignature = hybridSystem.var_objet(iMode).sig;
    [isMember,indexSignature] =...
        ismember(currentSignature,uniqueSignatureArray,'rows');
    modeSignatureIDArray(iMode,1) = indexSignature;
end
hybridAutomaton.modeSignatureIDArray = modeSignatureIDArray;

%% II. MODES
% Ecrire les id et les name
for iMode = 1:modesNo
    hybridAutomaton.modes(iMode).id = iMode;
    hybridAutomaton.modes(iMode).name = hybridSystem.var_objet(iMode).id;
end

%% III. EVENTS
% Recopier les propriétés ID, NAME, OBS ET FAULT des évènements
for iEvent = 1:eventsNo
    hybridAutomaton.events(iEvent).id =...
        hybridSystem.var_objet_events(iEvent).id;
    hybridAutomaton.events(iEvent).name =...
        hybridSystem.var_objet_events(iEvent).name;
    hybridAutomaton.events(iEvent).obs =...
        hybridSystem.var_objet_events(iEvent).obs;
    hybridAutomaton.events(iEvent).fault =...
        hybridSystem.var_objet_events(iEvent).fault;
end
%%
end

