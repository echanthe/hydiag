function EA = addTransitionModes(EA, HA, transArray, transNo)

% 1. Ajouter les modes de transition dans l'automate (nom et id)
for iTrans = 1:transNo
    jTrans = HA.modesNo + iTrans;
    EA.modes(jTrans).name = strcat('q',...
        num2str(transArray(iTrans).mSource),...
        '_',...
        num2str(transArray(iTrans).mDest));
     EA.modes(jTrans).id = jTrans;
end


end

