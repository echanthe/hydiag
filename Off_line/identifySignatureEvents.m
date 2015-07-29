function transArray = identifySignatureEvents(transArray, EA, HA, transNo)

for iTrans = 1:transNo

    mSource = transArray(iTrans).mSource;
    mDest = transArray(iTrans).mDest;
    eInit = transArray(iTrans).eInit;
    signatureArray = EA.modeSignatureIDArray;
    % Same signatures between mSource and mDest ?
    sameSig =(signatureArray(mSource)==signatureArray(mDest));
    % Is eInit a fault event ?
    isFaultEvent = HA.events(eInit).fault;
    % Cas après évènement de faute
    if isFaultEvent
        % Si les signatures source et dest sont différentes => obs.
       % if ~sameSig
            eSig = HA.eventsNo + signatureArray(mDest);
        % Sinon => non observable
      % else
      %      eSig = EA.eventsNo;
      %  end
    % Cas après évènement de contrôle
    else
        eSig = HA.eventsNo + signatureArray(mDest);
    end
    
    transArray(iTrans).eSig = eSig;

end

end

