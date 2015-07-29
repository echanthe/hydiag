function displayBehaviorAutomaton(automaton,figureTitle)

%% I. Initialisation
A = automaton;
% Noms de fichiers image
if isunix
   fpngAutomaton  = [pwd '/Off_line/behaviorAutomaton.png']; 
elseif ispc
    fpngAutomaton  = [pwd '\Off_line\behaviorAutomaton.png'];
end


fdot = [ fpngAutomaton(1:end-3) 'dot' ];
fid = fopen(fdot, 'wt');

% Forme des �tats et des �tiquettes de l'automate
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

if isunix
   system([ 'dot ' fdot ' -Tpng -o ' fpngAutomaton ' -K dot']);
elseif ispc
   system(['dot.exe ' fdot ' -Tpng -o ' fpngAutomaton ' -K dot']);
end

% END BuildAutomatonGraph(fpngAutomaton, Behavior,'B');
%% III. Afficher la figure

handle = ...
    figure('Color', 'white','Name', 'View automatons','Toolbar','none');
image(imread(fpngAutomaton));

title(figureTitle,...
    'FontSize', 12, 'FontWeight', 'bold');
axis off
axis image

end