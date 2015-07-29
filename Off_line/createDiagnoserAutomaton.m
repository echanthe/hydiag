function diagnoserAutomaton = ...
    createDiagnoserAutomaton( enrichedAutomaton )

    %% I. Préparation des fichiers et 
    
    % Renommer l'automate enrichi
    EA = enrichedAutomaton;
  
    % Initialiser des variables
    modesNo = length(EA.modes);
    eventsNo = length(EA.events);
    faultsNo = 0;
    unobsNo = 0;
    obsNo = 0;
    transNo  = 0;

    % Préparation de fichiers 
    fprintf('\n***** Computing diagnoser automaton with DiaDES dans create diagnoser *****\n');
    fpng = [pwd '\Off_line\diagnoserAutomaton.png'];
    f = fpng(1:end-3);
    try
        delete([f '*'])
    catch
    end
  
    fdes = [ fpng(1:end-3) 'des_comp' ];
    fhd = [ fpng(1:end-3) 'had' ];
  
    fid = fopen(fdes, 'wt');
    %first line is the name
    fprintf(fid, 'Hybrid_System_Diagnoser\n');
    
    %% ECRIRE LE NOMBRE ET LES NOMS DES MODES
    %next comes nbr of modes and name of modes
    buff =[];
    fprintf(fid, [num2str(modesNo) '\n']);
    for iMode=1:modesNo
        buff = [ buff  EA.modes(iMode).name ' '];
    end
    fprintf(fid, [buff '\n']);
    
    %% ECRIRE LES EVENEMENTS DE FAUTE NON OBSERVABLES
    %events unobservables that are faults (generate biger automaton)
    buff = [];
    for i=1:eventsNo
        if (EA.events(i).fault == 1)
           faultsNo = faultsNo + 1; 
           buff = [ buff  EA.events(i).name ' '];
        end 
    end
    
    fprintf(fid, [num2str(faultsNo) '\n']);
    fprintf(fid, [buff '\n']);
    
    %% ECRIRE LES EVENEMENTS DE CONTROLE NON OBSERVABLES
    %event unobservables that aren't faults
    buff = [];
    for iEvent=1:eventsNo
        if (EA.events(iEvent).obs == 0)
           if (EA.events(iEvent).fault == 0)
                 unobsNo = unobsNo + 1; 
                 buff = [ buff  EA.events(iEvent).name ' '];
           end
        end
    end
    
    fprintf(fid, [num2str(unobsNo) '\n']);
    fprintf(fid, [buff '\n']);
    
    %% WRITE SHARED EVENTS
    %next shared events
    fprintf(fid, [num2str(0) '\n']);
    
    %% WRITE OBSERVABLE EVENTS
    %next observable events
    buff = [];
    for iMode=1:eventsNo
        if (EA.events(iMode).obs == 1)
           obsNo = obsNo + 1; 
           buff = [ buff  EA.events(iMode).name ' '];
        end
        
    end
      fprintf(fid, '%d\n', obsNo);
      fprintf(fid, [buff '\n']);

    %% WRITE NUMBER OF TRANSITIONS AND TRANSITIONS
    %next nbr of transitions and transition 
    buff = [];
    for iMode=1:modesNo
       
        [mSourceArray,eventArray,mDestArray] =...
            find(EA.transitionMatrix(iMode,:));
        for jTrans =1:length(mDestArray)
            
            mSourceName = EA.modes(iMode).name;
            mDestInd = mDestArray(jTrans);
            mDestName  = EA.modes(mDestInd).name;
            eventInd = eventArray(jTrans);
            eventName = EA.events(eventInd).name;
            transNo = transNo + 1;
            buff = [buff  mSourceName ' -> ' mDestName ' ' eventName '\n'];
        end
    end
    fprintf(fid, '%d\n', transNo);
    fprintf(fid, [buff '\n']);
    
    fclose(fid);

   %% Run DiaDES
    %eval([ 'dir ' f '*' ])
    if isunix
       cmd = [ 'Off_line/active_diagnoser --had ' fhd ' ' fdes ];
       elseif ispc
           pathname = strcat(pwd, '\Off_line\active_diagnoser.exe  --had  "');
        cmd = [ pathname fhd '"  "' fdes  '"'  ];
       else
    end
    disp(['Running ' cmd]);
    dir_before = dir([f '*']);
    [s,w] = system(cmd, '-echo');
    fprintf('System command return %d.\n', s);
    dir_after = dir([f '*']);
    if (s ~= 0)
        % error(w);
        error('System command return bad value with message "%s"', w);
    else
        disp('System command ok.');
    end
    % double check !
    if (length(dir_after) ~= (length(dir_before) + 1));
        warning('length(dir_before) = %d, length(dir_after) = %d.',...
            length(dir_before), length(dir_after)); %#ok
    end
    %eval([ 'dir ' f '*' ])
    fprintf('   -> DiaDES computation ok\n');
  
   
    %% Parse '.hd' output and store in Diagnoser()
    fprintf('   -> Parsing output: ');
    
    fid = fopen(fhd, 'rt');
    if (fid == -1)
        error('Unable to open %s.', fhd);
    end
    
    %first line is number of states
    modesNo = str2double(fgetl(fid));

    %second is number of obs events
    eventsNo = str2double(fgetl(fid));

    fprintf('%d states, %d transitions', modesNo ,eventsNo);
    
    %skip initial macro state
    fgetl(fid);

    %now, get states in belief states
    line = fgetl(fid);
    line = line(2:end-2);

    %separate belief states
    belief_states = regexp(line, '} {', 'split');
    
    %line of events name
    %we need it to re-order incidence matrix
    line = fgetl(fid);
    
    events = regexp(line, ' ', 'split');
    
   incidence_matrix = zeros(eventsNo,modesNo);

    for i=1:eventsNo
        line = fgetl(fid);
        incidence_matrix(i,:) = str2num( line );
    end

    %replace -1 by 0 and add 1 to each mode number (because .hd starts
    %with 0; So add 1 to the whole matrix
    incidence_matrix = incidence_matrix + 1;
    
    
    for i=1:modesNo
          diagnoserAutomaton.modes(i) =  struct(...
                            'id',i,...
                            'name', belief_states(i),...
                            'next_id',(incidence_matrix(:,i))') ;
    end
    

    for i=1:eventsNo
          diagnoserAutomaton.events(i) =  struct(...
                    'id' ,[],...
                    'name', events(i), ...
                    'fault',0, ...
                    'obs',1 ...
                    );
    end
    
    diagnoserAutomaton.transitionMatrix = incidence_matrix';

end

