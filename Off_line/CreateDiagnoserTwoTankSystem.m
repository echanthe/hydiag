%% INITIALISATION INTERFACE ET LIENS
initializationCreateDiagnoser
hybridSystemFileName = 'TwoTankSystemTest.mat';

%% I. CREER ET SAUVEGARDER LE MODELE AU FORMAT SYSTEM HYBRIDE
% avec le programme SysHybride.m
twoTankHybridSystem = ...
    createTwoTankSystemHybridAutomaton(hybridSystemFileName);


%% II. TRANSFERER LE MODELE DANS UN 2e FORMAT : AUTOMATE HYBRIDE
hybridAutomaton =...
    createHybridAutomatonFromHybridSystem(twoTankHybridSystem);

figureTitle = 'Underlying discrete event system';
displayBehaviorAutomaton(hybridAutomaton,figureTitle);


%% III. ENRICHIR L'AUTOMATE AVEC LES EVENEMENTS DE SIGNATURE

enrichedAutomaton = enrichAutomaton(hybridAutomaton);

figureTitle = 'Enriched Automaton with Signature Events';
displayBehaviorAutomaton(enrichedAutomaton,figureTitle);

%% V. CONSTRUIRE LE DIAGNOSTIQUEUR
diagnoserAutomaton = createDiagnoserAutomaton( enrichedAutomaton );

figureTitle = ...
    'The diagnoser of the hybrid system built from the behavior automaton';
displayDiagnoserAutomaton(diagnoserAutomaton, figureTitle);

