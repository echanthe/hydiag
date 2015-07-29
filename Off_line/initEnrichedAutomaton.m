function EA = initEnrichedAutomaton( HA )

% 1. Initialiser l'automate enrichi
EA = HA; % initialiser enriched automaton

% 2. Compter le nombre de transitions
EA.transNoInit = length(find(HA.transitionMatrix)); %OK
EA.transNo = 2*EA.transNoInit;

% 3. Actualiser le nombre de modes
EA.modesNo = HA.modesNo + EA.transNoInit;

% 4. Actualiser eventsNo avec evenements de signature dont 1 non observable
EA.eventsNo = HA.eventsNo + size(EA.uniqueSignatureArray,1) + 1;

% 5. Actualiser la matrice de transition
EA.transitionMatrix = zeros(EA.modesNo,EA.eventsNo);

end

