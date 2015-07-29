function displayEnrichedAutomaton( enrichedAutomaton, figureTitle )


%% I. Initialisation
A = enrichedAutomaton;
% Noms de fichiers image
fpngAutomaton  = [pwd '\enrichedAutomaton.png'];
fdot = [ fpngAutomaton(1:end-3) 'dot' ];
fid = fopen(fdot, 'wt');

% Forme des états et des étiquettes de l'automate
shape = 'circle';
labelcolor = 'blue';

% Ecriture dans le fichier
fprintf(fid, 'digraph output {\n');
fprintf(fid, '    rankdir=TB;\n');
fprintf(fid, '    node [shape = %s];\n',shape);

%% II. Ecrire les modes et leurs transitions
for iMode=1:A.modesNo

    % 1. Modes
    [mSourceArray,eventArray,mDestArray] =...
        find(A.transitionMatrix(iMode,:));
    mSourceName = A.modes(iMode).name;
    mSourceID = A.modes(iMode).id;

    fprintf(fid, '    %d  [label="%s" ]\n',...
        mSourceID, mSourceName);
    
    % 2. Transitions
    for jTrans =1:length(mDestArray)
        mDestID = mDestArray(jTrans);
        eventID = eventArray(jTrans);
        eventName = A.events(eventID).name;

        fprintf(fid, '    %d->%d [label="%s" fontcolor="%s" ]\n',...
            mSourceID,mDestID,eventName, labelcolor);
    end
end
fprintf(fid, '}\n');
%%
system(['dot.exe ' fdot ' -Tpng -o ' fpngAutomaton ' -K dot']);

% END BuildAutomatonGraph(fpngAutomaton, Behavior,'B');
%% III. Afficher la figure

figureEA = ...
    figure('Color', 'white','Name', 'View automatons','Toolbar','none');
image(imread(fpngAutomaton));

title(figureTitle,...
    'FontSize', 12, 'FontWeight', 'bold');
axis off
axis image


end

