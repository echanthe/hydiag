function [ EA ] = generateEnrichedEventsList( EA,HA )

EA.sigEventNameArray = cell(size(EA.uniqueSignatureArray,1),1);

% 1. Construire une matrice de caractère pour chaque évènement de signature
symptom = cell(size(EA.uniqueSignatureArray));
for iEvent = 1:size(EA.uniqueSignatureArray,1)
    for jSymptom =1:EA.signatureSize
        if EA.uniqueSignatureArray(iEvent,jSymptom) == 1
            symptom(iEvent,jSymptom) = {'+'};
        elseif EA.uniqueSignatureArray(iEvent,jSymptom) == 0
            symptom(iEvent,jSymptom) = {'.'};
        elseif EA.uniqueSignatureArray(iEvent,jSymptom) == -1
             symptom(iEvent,jSymptom) = {'-'};
        else
            symptom(iEvent,jSymptom) = {'*'};
        end
    end
end

% 2. Construire la notation en concaténant les séries de caractères
for iEvent = 1:size(EA.uniqueSignatureArray,1)
    name = 'R';
    for jSymptom =1:EA.signatureSize
        name = strcat(name,symptom(iEvent,jSymptom));
    end
    EA.sigEventNameArray(iEvent,1) = {name};
end

% 3. Evenements de signature observables
for iEvent = (HA.eventsNo+1):(EA.eventsNo-1)
    iSig = iEvent - HA.eventsNo;
    EA.events(iEvent).id = iEvent;
    EA.events(iEvent).name = char(EA.sigEventNameArray{iSig,1});
    EA.events(iEvent).obs = 1;
    EA.events(iEvent).fault = 0;
end

% 4. Evenement de signature non observable
EA.events(EA.eventsNo).id = EA.eventsNo;
EA.events(EA.eventsNo).name = 'Runobs';
EA.events(EA.eventsNo).obs = 0;
EA.events(EA.eventsNo).fault = 0;

end

