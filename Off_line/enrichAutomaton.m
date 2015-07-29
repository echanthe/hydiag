function enrichedAutomaton = enrichAutomaton(hybridAutomaton)

    
%% I. INITIALISER L'AUTOMATE ENRICHI: MODES, EVENEMENTS ET TRANSMAT
HA = hybridAutomaton; %renommer hybrid automaton
EA = initEnrichedAutomaton(HA);
    
%% II. GENERER NOMS CORRESPONDANTS AUX SIGNATURES DE DESTINATION
EA = generateEnrichedEventsList(EA,HA);

%% III. REDEFINIR LES TRANSITIONS
% 1. Compter et identifier les informations (mSource, mDest, eInit) des
% transitions initiales
[transArray, transNo ] = identifyInitialTransitions(HA.transitionMatrix);

% 2. Ajouter les modes de transition dans l'automate enrichi et les nommer
EA = addTransitionModes(EA, HA,transArray, transNo);

% 3. Actualiser la liste des indices des modes de transition (mTrans)
transArray = updateTransitionModeIndices(transArray, HA, transNo);

% 4. Identifier les évènements de signature pour chaque transition initiale
transArray = identifySignatureEvents(transArray, EA, HA, transNo);

% 5. Effacer les transitions de mSource vers mDest via l'évt eInit
EA = eraseInitialTransitions(EA, transArray, transNo);

% 6. Construire les transitions entre mSource et mTrans via eInit
EA = createTransitionSourceTrans(EA, transArray, transNo);

% 7. Construire les transitions entre mTrans et mDest via eSig
EA = createTransitionTransDest(EA, transArray, transNo);

%%
enrichedAutomaton = EA;

end