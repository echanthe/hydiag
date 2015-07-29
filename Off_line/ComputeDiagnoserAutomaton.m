function Diagnoser =  ComputeDiagnoserAutomaton(fpng,Behavior,Sys_hybride)
    
    fprintf('\n***** Computing diagnoser automaton with DiaDES *****\n');
    
    f = fpng(1:end-3);
    try
        delete([f '*'])
    catch
    end
    
    %cmd = [ 'rm ' f '*' ];
    %system(cmd, '-echo');
    
    fdes = [ fpng(1:end-3) 'des_comp' ];
    fhd = [ fpng(1:end-3) 'hd' ];
    
    
    N_States = length(Behavior.States);
    N_Events = length(Behavior.Events);
    N_faults = 0;
    N_unobs = 0;
    N_obs = 0;
    N_trans  = 0;
    
    fid = fopen(fdes, 'wt');
    %first line is the name
    fprintf(fid, 'Hybrid_System_Diagnoser\n');
    
    %next comes nbr of modes and name of modes
    buff =[];
    fprintf(fid, [num2str(N_States) '\n']);
    for i=1:N_States
        buff = [ buff  Behavior.States(i).name ' '];
    end
    fprintf(fid, [buff '\n']);
    
    %events unobservables that are faults (generate biger automaton)
    buff = [];
    for i=1:N_Events
        if (Behavior.Events(i).fault == 1)
           N_faults = N_faults + 1; 
           buff = [ buff  Behavior.Events(i).name ' '];
        end 
    end
    
    fprintf(fid, [num2str(N_faults) '\n']);
    fprintf(fid, [buff '\n']);
    
    %event unobservables that aren't faults
    buff = [];
    for i=1:N_Events
        if (Behavior.Events(i).obs == 0)
           if (Behavior.Events(i).fault == 0)
                 N_unobs = N_unobs + 1; 
                 buff = [ buff  Behavior.Events(i).name ' '];
           end
        end
    end
    
    fprintf(fid, [num2str(N_unobs) '\n']);
    fprintf(fid, [buff '\n']);
    
    %next shared events
    fprintf(fid, [num2str(0) '\n']);
    
    %next observable events
    buff = [];
    for i=1:N_Events
        if (Behavior.Events(i).obs == 1) 
           N_obs = N_obs + 1; 
           buff = [ buff  Behavior.Events(i).name ' '];
        end
        
    end
      fprintf(fid, '%d\n', N_obs);
      fprintf(fid, [buff '\n']);

    %next nbr of transitions and transition 
    buff = [];
    for i=1:N_States
       
        [N,M,Next_States] = find(Behavior.States(i).next_id);
        for j =1:length(Next_States)
            
            source = Behavior.States(i).name;
            dest   = Behavior.States(Next_States(j)).name;
            label  = Behavior.Events(M(j)).name;
            N_trans = N_trans + 1;
            buff = [buff    source ' -> ' dest ' ' label '\n'];
        end
    end
    fprintf(fid, '%d\n', N_trans);
    fprintf(fid, [buff '\n']);
    
    fclose(fid);
    %End of generation of .comp_des file

   %% Run DiaDES
    %eval([ 'dir ' f '*' ])
    if isunix
       cmd = [ 'Off_line/diagnoser --hd ' fhd ' ' fdes ];
       elseif ispc
        cmd = [ 'Off_line\diagnoser.exe  --hd  "' fhd '"  "' fdes  '"'  ];
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
        warning('length(dir_before) = %d, length(dir_after) = %d.', length(dir_before), length(dir_after)); %#ok
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
    Nb_States = str2double(fgetl(fid));

    %second is number of obs events
    Nb_Events = str2double(fgetl(fid));

    fprintf('%d states, %d transitions', Nb_States ,Nb_Events);
    
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
    
   
   
    incidence_matrix = zeros(Nb_Events,Nb_States);

    for i=1:Nb_Events
        line = fgetl(fid);
        incidence_matrix(i,:) = str2num( line );
    end

    %replace -1 by 0 and add 1 to each mode number (because .hd starts
    %with 0; So add 1 to the whole matrix
    incidence_matrix = incidence_matrix + 1;
    
    
    for i=1:Nb_States
        
          Diagnoser.States(i) =  struct(...
                            'id',i,...
                            'name', belief_states(i),...
                            'next_id',(incidence_matrix(:,i))') ;

    end

    for i=1:Nb_Events
          
          Diagnoser.Events(i) =  struct(...
                    'id' ,[],...
                    'name', events(i), ...
                    'fault',0, ...
                    'obs',1 ...
                    );
    end
    
    for i=1:Nb_Events
        for j=1:length(Sys_hybride.events)
                    
                   if strcmp(Diagnoser.Events(i).name,Sys_hybride.events(j).name)
                        Diagnoser.Events(i).id = j;
                   end
                  
        end
    end
    fprintf('. Ok\n');
    
end
    
