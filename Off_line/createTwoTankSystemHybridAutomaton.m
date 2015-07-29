function [twoTankHybridSystem] = ...
    createTwoTankSystemHybridAutomaton(hybridSystemFileName)

%% I. INITIALISATION DE L'AUTOMATE HYBRIDE
% 1. NOMBRE DE MODES, D'EVENEMENTS ET DE CAS DE FAUTES
modesNo = 73;
eventsNo = 14;
faultsNo = 5;
controlModesNo = 12;

% 2. INITIALISER L'AUTOMATE HYBRIDE
hybridModelParameters = [modesNo, eventsNo, 1, 1, 1, 1];
defaultSysHybride = SysHybride('init', 'new_auto', hybridModelParameters);
% Les attributs id sont automatiquement créés grâce à la fonction précdte
% Donner un nom aux modes : q1, q2, etc.
for i = 1:modesNo
    SysHybride('set_description',i, strcat('q', num2str(i)));
end

% 3. CONFIGURER LES MODES PAR SIGNATURE DE FAUTE (au lieu de modèle lin.)
SysHybride('set_setModesSignature',1);

SysHybride('set_signature_size',2);

for iMode = 1:modesNo
    SysHybride('set_sig',iMode,2);
end

%% II. PARAMETRER LES TRANSITIONS
% 1. PARAMETRER MODE 1 INACTIF
SysHybride('set_next_id', 1,[0  0    0   0    0   0   0 ...
    0  2  14  26  38  50  62]); 

% 2. PARAMETRER LA MATRICE DE TRANSITIONS POUR LES MODES NOMINAUX 2 à 12
% Modes => Lignes / Evènements => Colonnes
transMatNom = ...
    [0  3    0   4    6   0   0   0  0  0  0  0  0  0 ;
    2  0    0   5    7   0   0   0  0  0  0  0  0  0 ;
    0  5    2   0    8   0   0   0  0  0  0  0  0  0;
    4  0    3   0    9   0   0   0  0  0  0  0  0  0 ;
    0  7    0   8    0   2   10   0  0  0  0  0  0  0 ;
    6  0    0   9    0   3   11   0  0  0  0  0  0  0 ;
    0  9    6   0    0   4   12   0  0  0  0  0  0  0 ;
    8  0    7   0    0   5   13   0  0  0  0  0  0  0 ;
    0  11    0   12    0   0   0   6  0  0  0  0  0  0 ;
    10  0    0   13    0   0   0   7  0  0  0  0  0  0 ;
    0  13    10   0    0   0   0   8  0  0  0  0  0  0 ;
    12  0    11   0    0   0   0   9  0  0  0  0  0  0 ;];

% 3. PARAMETRER LA MATRICE DE TRANSITIONS POUR LES MODES 2 à 73
% Les matrices de transitions pour les modes de fautes sont translatées
% de multiples de 12 par rapport à la matrice des modes nominaux
transMat = zeros((faultsNo+1)*controlModesNo, eventsNo);
for iFault = 0:faultsNo
    jStart = 2 + iFault*controlModesNo;
    jStop = 2 + (iFault+1)*controlModesNo-1;
    transMat(jStart-1:jStop-1,:) = transMatNom +(transMatNom>=1)*iFault*12;
end

% 4. ECRIRE LES TRANSITIONS DANS SYSHYBRIDE
for iMode = 2:modesNo
        SysHybride('set_next_id', iMode,transMat(iMode-1,:)); 
end

%% III. PARAMETRER LES SIGNATURES
% 1. MATRICE DES CONFIGURATIONS DU SYSTEME
% colonnes : uV2, uV3, h1>h0, h1<h0, h2>h0, h2<h0, uV1
confs = ...
    [1 0 1 0 1 0 1 0 1 0 1 0;
     1 1 0 0 1 1 0 0 1 1 0 0;
     0 0 0 0 1 1 1 1 1 1 1 1;
     1 1 1 1 0 0 0 0 0 0 0 0;
     0 0 0 0 0 0 0 0 1 1 1 1;
     1 1 1 1 1 1 1 1 0 0 0 0;
     1 1 1 1 2 2 2 2 4 4 4 4 ];
confs = confs';
confs = [0 0 0 0 0 0 0 ;
         repmat(confs,6,1)]; % répéter confs pour toutes les hyp de faute

% 2. PARAMETRER LES SIGNATURES PAR HYPOTHESE DE FAUTES
% En fonction de la configuration des vannes

% MODE INACTIF
SysHybride('set_sig', 1, [-10 -10]);

% MODES NOMINAUX
for i = 2:13
    SysHybride('set_sig', i,[0 0]);
end

% MODES FUITE T1
i0= 14;
for i = i0:(i0+11)
    % [-1 -1.(h1>h0 OU V2ON)]
    SysHybride('set_sig', i,[-1 -1*(confs(i,3)||confs(i,1))]);
end
% MODES FUITE T2
i0= 26;
for i = i0:(i0+11)
    % [-1.((h1>h0 ET h2>h0) OU V2ON) -1]
    SysHybride('set_sig', i,[-1*(confs(i,7)==4||confs(i,1)) -1]); 
end
% MODES ENCRASSEMENT V2
i0= 38;
for i = i0:(i0+11)
    % [+1(h1>h0) -1(h1>h0)]
    SysHybride('set_sig', i,[+1*(confs(i,3)), -1*(confs(i,3))]); 
end
i0= 50;
% MODES ENCRASSEMENT V2
for i = i0:(i0+11)
    % [+uV2 -uV2]
    SysHybride('set_sig', i,[(confs(i,1)), -(confs(i,1))]); 
end
% MODES ENCRASSEMENT V3
i0= 62;
for i = i0:(i0+11)
    % [+uV3ET(uV1==4 OU uV2) -uV3]
    SysHybride('set_sig', i, ...
        [+(confs(i,2))&&((confs(i,2)==4)||(confs(i,1))), +1*(confs(i,2))]); 
end
% for i = 15:73
%     SysHybride('set_sig', i, [0 0]);
% end
sig_modes = zeros(73,2);
for i=1:73
     sig_modes(i,:) = SysHybride('get_sig',i);
end

%% IV. PARAMETRER LES EVENEMENTS
% 1. EVENEMENT 1 V2ON
% 'id' déjà définie dans l'initialisation
SysHybride('set_event_name', 1, 'V2ON'); % SysHybride('get_event_name',1)
SysHybride('set_event_obs', 1, 1); % SysHybride('get_event_obs',1)
SysHybride('set_event_fault', 1, 0); % SysHybride('get_event_fault',1)
% Les propriétés commandable, schedule et dynamic restent inchangées
% 2. EVENEMENT 2 V2OFF
SysHybride('set_event_name', 2, 'V2OFF');
SysHybride('set_event_obs', 2, 1);
SysHybride('set_event_fault', 2, 0);
% 3. EVENEMENT 3 V3ON
SysHybride('set_event_name', 3, 'V3ON');
SysHybride('set_event_obs', 3, 1);
SysHybride('set_event_fault', 3, 0);
% 4. EVENEMENT 4 V3OFF
SysHybride('set_event_name', 4, 'V3OFF');
SysHybride('set_event_obs', 4, 1);
SysHybride('set_event_fault', 4, 0);
% 5. EVENEMENT 5 h1>h0
SysHybride('set_event_name', 5, 'h1>h0');
SysHybride('set_event_obs', 5, 1);
SysHybride('set_event_fault', 5, 0);
% 6. EVENEMENT 6 h1<h0
SysHybride('set_event_name', 6, 'h1<h0');
SysHybride('set_event_obs', 6, 1);
SysHybride('set_event_fault', 6, 0);
% 7. EVENEMENT 7 h2>h0
SysHybride('set_event_name', 7, 'h2>h0');
SysHybride('set_event_obs', 7, 1);
SysHybride('set_event_fault', 7, 0);
% 8. EVENEMENT 8 h2<h0
SysHybride('set_event_name', 8, 'h2<h0');
SysHybride('set_event_obs', 8, 1);
SysHybride('set_event_fault', 8, 0);
% 9. EVENEMENT 9 nominal
SysHybride('set_event_name', 9, 'nominal');
SysHybride('set_event_obs', 9, 0);
SysHybride('set_event_fault', 9, 0);
% 10. EVENEMENT 10 leakT1
SysHybride('set_event_name', 10, 'leakT1');
SysHybride('set_event_obs', 10, 0);
SysHybride('set_event_fault', 10, 1);
% 11. EVENEMENT 11 leakT2
SysHybride('set_event_name', 11, 'leakT2');
SysHybride('set_event_obs', 11, 0);
SysHybride('set_event_fault', 11, 1);
% 12. EVENEMENT 12 clogV1
SysHybride('set_event_name', 12, 'clogV1');
SysHybride('set_event_obs', 12, 0);
SysHybride('set_event_fault', 12, 1);
% 13. EVENEMENT 13 clogV2
SysHybride('set_event_name', 13, 'clogV2');
SysHybride('set_event_obs', 13, 0);
SysHybride('set_event_fault', 13, 1);
% 14. EVENEMENT 14 clogV3
SysHybride('set_event_name', 14, 'clogV3');
SysHybride('set_event_obs', 14, 0);
SysHybride('set_event_fault', 14, 1);

%% V. SAUVEGARDER MODELE

%load_from_filename = 'Sys2Reservoirs.mat';
%     [filename, pathname] = uiputfile(...
%         {'*.mat','Hybrid System (*.mat)';...
%          '*.*',  'All Files (*.*)'},...
%          'Save as ...',...
%          load_from_filename);
pathname = pwd;
SysHybride('save', strcat(pathname,'\', hybridSystemFileName));

%% VI. CHARGER MODELE
twoTankHybridSystem = load(strcat(pathname,'\',...
    hybridSystemFileName));
end

