function displayDiagnoserAutomaton(diagnoserAutomaton, figureTitle)

%% I. INITIALISATION
DA = diagnoserAutomaton;
% Noms des fichiers
fpngDiagnoser = [pwd '\Off_line\diagnoserAutomaton.png'];
fdot = [ fpngDiagnoser(1:end-3) 'dot' ];
fid = fopen(fdot, 'wt');

% Forme des états et des étiquettes de l'automate
shape = 'rectangle';
labelcolor = 'blue';

% Ecriture dans le fichier
fprintf(fid, 'digraph output {\n');
fprintf(fid, '    rankdir=TB;\n');
fprintf(fid, '    node [shape = %s];\n',shape);

modesNo = length(DA.modes);
%N_Events = length(Diagnoser.Events);


for iMode=1:modesNo

    [mSourceArray,eventArray,mDestArray] =...
        find(DA.transitionMatrix(iMode,:));
    mSourceName = DA.modes(iMode).name;
    mSourceID = DA.modes(iMode).id;
    
    fprintf(fid, '    %d  [label="%s" ]\n',...
        mSourceID, mSourceName);

     for jTrans =1:length(mDestArray)
        mDestID = mDestArray(jTrans);
        eventID = eventArray(jTrans);
        eventName = DA.events(eventID).name;

        fprintf(fid, '    %d->%d [label="%s" fontcolor="%s" ]\n',...
            mSourceID,mDestID,eventName, labelcolor);
    end
    
end
fprintf(fid, '}\n');

system(['dot.exe ' fdot ' -Tpng -o ' fpngDiagnoser ' -K dot']);

%% III. Afficher la figure

figure2 = ...
    figure('Color', 'white','Name', 'View automatons','Toolbar','none');
image(imread(fpngDiagnoser));

title(figureTitle,...
    'FontSize', 12, 'FontWeight', 'bold');
axis off
axis image

end

