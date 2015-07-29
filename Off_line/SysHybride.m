%% Fonction-Objet stockant l'ensemble des paramÃštres du systÃšme hybride

% GÃ©nÃ©ralement param1=Id de l'Ã©tat auquel s'applique la mÃ©thode 
% et param2 la valeur Ã  passer Ã  la methode
function return_value = SysHybride(methode, param1, param2)
    persistent var_objet;       % structure contenant le systÃšme hybride (les modes)
    persistent var_objet_events;% (les Ã©venements)
    persistent main_settings;
    global Prognoser;% automate_size, events_size, time_step ...

switch methode
    case 'init'
        % param1 
        %        'new', create a new system with param2 (array) as basic
        %               settings
        %        'new_default', as 'new' but initialise all structures.
        %        'load_file', load system file specified in param2
        %        'clean', simply empty the structure

%         clear var_objet_events var_objet main_settings

%         automate_size = 0;
%         events_size = 0;
%         time_step = 0;
%         description = '';
        
        switch param1
            case 'new'
                % param2 = [Â automaton_size, events_size, time_step ]
                % Initialisation de la structure
                var_objet = struct(...
                    'id',{}, ... % Id de l'Ã©tat discret
                    'next_id', {}, ... % tableau: indice = id_evenement, valeur = id de l'Ã©tat suivant
                    'matA', {}, 'matB', {}, 'matC', {}, 'matD', {}, ... % SystÃšme continu
                    'x0', {}, ... % Etat initial
                    'desc',{}, ... % Description de l'Ã©tat discret
                    'sig',{} ... % Signature du mode
                );
                var_objet_events = struct(...
                    'id',{},...
                    'name',{}, ... % nom de l'Ã©venement
                    'obs', {}, ...  % est-ce que l'Ã©venement est observable ?
                    'fault', {}, ... % is the event a fault ?
                    'commandable', {}, ... % is this event commandable ? (usefull for active diag.)
                    'schedule', {}, ... % tableau des temps auxquels se produisent les Ã©venements
                    'cost', {0}, ... %cout
                    'dynamic',{} ...
                );
                main_settings = struct(...
                    'automate_size', {0}, ... % Number of discrete states
                    'events_size', {0}, ... % Number of events
                    'time_step', {0}, ... % Sample time
                    'total_time', {5}, ... % final time for the simulation
                    'description', {''}, ... % description of the system
                    'residuals_size',{0},... % size of the bank of residuals
                    'optionSignatures', {0} ... % configure signature events 1 selon signatures et 0 selon matrices A,B,C,D
                );
                Prognoser = struct(...
                    'fault', {}, ...
                    'state', {}, ...
                    'Dmin', {}, ...
                    'DminPr', {}, ...
                    'Enable', {} ...
                    );
                %TODO: (add) Input signal, Simulation time                     
                
                if exist('param2', 'var') && param2(1) > 0 && param2(2) > 0 && param2(3)
                    main_settings.automate_size = param2(1);
                    main_settings.events_size = param2(2);
                    main_settings.time_step = param2(3);

                    % Initialisations Ã  voir ...
                    for i=1:main_settings.automate_size
                        var_objet(i).next_id = zeros(main_settings.events_size,1);
%                             var_objet(i).matA = []
%                             var_objet(i).matB = []
%                             var_objet(i).matC = []
%                             var_objet(i).matD = []
                    end
                    
                    %clear others structures
                    clear Diagnoser Diagnoser_automaton
                    
                    return_value = 0;

                else
                    return_value = -1;
                end
            case 'new_auto'
                % param2 = [Â automaton_size, events_size, time_step,
                % input_size, output_size, default_order ]
                if length(param2) == 6 && SysHybride('init', 'new', param2) == 0
                    input_size = param2(4);
                    output_size = param2(5);
                    default_order = param2(6);
                    residuals_size = SysHybride('get_residuals_size');
                    
                    %For each mode we fill default matrix with right sizes
                    for i=1:main_settings.automate_size
                        SysHybride('set_id', i, ['q' num2str(i)]);
                        SysHybride('set_matA', i, -1*eye(default_order));
                        SysHybride('set_matB', i, zeros(default_order, input_size));
                        SysHybride('set_matC', i, zeros(output_size, default_order));
                        SysHybride('set_matD', i, zeros(output_size, input_size));
                        SysHybride('set_x0', i, zeros(default_order, 1));
                        SysHybride('set_description', i, strcat('This is the mode nÂ°', num2str(i)));
                        SysHybride('set_next_id', i, zeros(1, main_settings.events_size));  
                        SysHybride('set_sig', i,residuals_size);
                    end
                    
                    %TODO: initialize events
                    for i=1:main_settings.events_size
                        SysHybride('set_event_id', i, i);
                        SysHybride('set_event_name', i, ['Event_nÂ°' num2str(i)]);
                        SysHybride('set_event_obs', i, 1);
                        SysHybride('set_event_fault', i, 0);
                        SysHybride('set_event_commandable', i, 1);
                        SysHybride('set_event_schedule', i, []);
                        SysHybride('set_event_cost', i, 0);
                        SysHybride('set_dynamic', i, [-Inf*ones(output_size,1) Inf*ones(output_size,1)]);
                    end
                    
                    %clear others structures
                    clear Diagnoser Diagnoser_automaton
                    
                    return_value = 0;
                else
                    return_value = -1;
                end
                
            case 'load_file'
                %clear others structures
                clear Diagnoser Diagnoser_automaton             
                load(param2)
                 %Retrocompatibilité anciens modeles
            %    main_settings
            %    var_objet
            %    var_objet_events
            %    var_objet.sig %%pour chaque mode (main_settings.automate_size)
            %    main_settings.residuals_size
                if (isfield(main_settings,'optionSignatures') == 0); %%par défaut il n'y avait pas les signatures
                    main_settings.optionSignatures=0;%%par défaut il n'y avait pas les signatures
                    main_settings.residuals_size=main_settings.automate_size;
                    A=zeros(1,main_settings.automate_size);
                    for i=1:main_settings.automate_size                  
                    var_objet(1,i).sig=A;
                    end
                end
                if (isfield(var_objet_events(1,1),'cost')== 0); %par défaut pas de coûts aux événements
                    for i=1:main_settings.events_size    
                    var_objet_events(1,i).cost=0;
    
                    end
                end
                
                % give 'validity' as return value
                return_value = SysHybride('is_valid');

            case 'clean'
                %clear others structures
                clear Diagnoser Diagnoser_automaton Prognoser
                    
                % everything has already been cleared above.
                var_objet = '';
                var_objet_events = '';
                main_settings = '';
                return_value = 0;
                
            otherwise
                return_value = -1;
        end

    %% Bank of residuals size        
    case 'set_residuals_size'
        main_settings.residuals_size = param1;
        return_value = 0;
    case 'get_residuals_size'
        return_value = main_settings.residuals_size;    
          
    %% Option configure sig events by linear models or sig matrices
    case 'set_optionSignatures'
        main_settings.optionSignatures = param1;
        return_value = 0;
    case 'get_optionSignatures'
        return_value = main_settings.optionSignatures;
    
    %% Vitals accessors (states)
    case 'set_id'
        var_objet(param1).id = param2;
        return_value = 0;
    case 'set_next_id'
        var_objet(param1).next_id = param2;
        return_value = 0;
    case 'set_matA'
        var_objet(param1).matA = param2;
        return_value = 0;
    case 'set_matB'
        var_objet(param1).matB = param2;
        return_value = 0;
    case 'set_matC'
        var_objet(param1).matC = param2;
        return_value = 0;
    case 'set_matD'
        var_objet(param1).matD = param2;
        return_value = 0;
    case 'set_x0'
        var_objet(param1).x0 = param2;
        return_value = 0;
    case 'set_description'
        if exist('param2','var')
            var_objet(param1).desc = param2;
        else
            main_settings.description = param1;
        end
        return_value = 0;
    case 'set_sig'
        var_objet(param1).sig = param2;
        return_value = 0;
    case 'set_total_time'
        main_settings.total_time = param1;
        return_value = 0;
    case 'get_id'
        return_value = var_objet(param1).id;     
    case 'get_next_id'
        return_value = var_objet(param1).next_id;
    case 'get_matA'
        return_value = var_objet(param1).matA;
    case 'get_matB'
        return_value = var_objet(param1).matB;
    case 'get_matC'
        return_value = var_objet(param1).matC;
    case 'get_matD'
        return_value = var_objet(param1).matD;
    case 'get_x0'
        return_value = var_objet(1).x0;
     case 'get_sig'
        return_value = var_objet(param1).sig;
    case 'get_description'
        if exist('param1', 'var')
            return_value = var_objet(param1).desc;
        else
            return_value = main_settings.description;
        end
    case 'get_total_time'
        return_value = main_settings.total_time;    
        
    %% Special actions for modes
    case 'mode_delete'
        % allow to do this only if system is safe enough
        if SysHybride('is_valid') <= 11 && ~isempty('param1') && param1 <= SysHybride('get_automate_size') && SysHybride('get_automate_size') > 0

            %delete mode
            var_objet(param1) = [];

            %update automate size
            main_settings.automate_size = main_settings.automate_size - 1;
            
            %check for links pointing on deleted mode
            % WE CHOOSE TO REMOVE THIS LINK(S)
            has_deleted_link = 0;
            
            for i=1:SysHybride('get_automate_size')
                buff = SysHybride('get_next_id',i);
                buff_index = find(buff==param1);
                buff(buff_index) = 0; % replace dead link by no link (0)
                SysHybride('set_next_id', i, buff);
                if ~isempty(buff_index)
                    has_deleted_link = has_deleted_link + 1;
                end
                
            end
            
            return_value = has_deleted_link;
        else
            return_value = -1;
        end
    
    case 'mode_add'
        %TODO
        return_value = 0;
        

    %% Additionnal accessors (states)
    case 'get_dyn_size'
        return_value = length(var_objet(param1).matA);
    
    case 'get_output_size'
        % we rely on the first D matrix
        return_value = size(var_objet(1).matD,1);
    case 'get_input_size'
        % we rely on the first B matrix
        return_value = size(var_objet(1).matB,2);

    % Compute meta-matrix (used in the S-function)
    % (we use recursion but it would be better to get data from var_objet)
    % TODO
    case 'get_metaA'
        return_value = [SysHybride('get_matA', 1) ...
    zeros(SysHybride('get_dyn_size',1),SysHybride('get_dyn_size',2))...
    zeros(SysHybride('get_dyn_size',1),SysHybride('get_dyn_size',3))...
    zeros(SysHybride('get_dyn_size',1),SysHybride('get_dyn_size',4))...
    ;...
    zeros(SysHybride('get_dyn_size',2),SysHybride('get_dyn_size',1))...
    SysHybride('get_matA', 2) ...
    zeros(SysHybride('get_dyn_size',2),SysHybride('get_dyn_size',3))...
    zeros(SysHybride('get_dyn_size',2),SysHybride('get_dyn_size',4))...
    ;...
    zeros(SysHybride('get_dyn_size',3),SysHybride('get_dyn_size',1))...
    zeros(SysHybride('get_dyn_size',3),SysHybride('get_dyn_size',2))...
    SysHybride('get_matA', 3) ...
    zeros(SysHybride('get_dyn_size',3),SysHybride('get_dyn_size',4))...
    ;...
    zeros(SysHybride('get_dyn_size',4),SysHybride('get_dyn_size',1))...
    zeros(SysHybride('get_dyn_size',4),SysHybride('get_dyn_size',2))...
    zeros(SysHybride('get_dyn_size',4),SysHybride('get_dyn_size',3))...
    SysHybride('get_matA', 4) ...
    ];

    case 'get_metaB'
        return_value = [SysHybride('get_matB', 1);SysHybride('get_matB', 2);SysHybride('get_matB', 3);SysHybride('get_matB', 4)];

    case 'get_metaC'
        OUTPUT_SIZE=SysHybride('get_output_size');
        return_value = [SysHybride('get_matC', 1) ...
    zeros(OUTPUT_SIZE,SysHybride('get_dyn_size',2))...
    zeros(OUTPUT_SIZE,SysHybride('get_dyn_size',3))...
    zeros(OUTPUT_SIZE,SysHybride('get_dyn_size',4))...
    ;...
    zeros(OUTPUT_SIZE,SysHybride('get_dyn_size',1))...
    SysHybride('get_matC', 2) ...
    zeros(OUTPUT_SIZE,SysHybride('get_dyn_size',3))...
    zeros(OUTPUT_SIZE,SysHybride('get_dyn_size',4))...
    ;...
    zeros(OUTPUT_SIZE,SysHybride('get_dyn_size',1))...
    zeros(OUTPUT_SIZE,SysHybride('get_dyn_size',2))...
    SysHybride('get_matC', 3) ...
    zeros(OUTPUT_SIZE,SysHybride('get_dyn_size',4))...
    ;...
    zeros(OUTPUT_SIZE,SysHybride('get_dyn_size',1))...
    zeros(OUTPUT_SIZE,SysHybride('get_dyn_size',2))...
    zeros(OUTPUT_SIZE,SysHybride('get_dyn_size',3))...
    SysHybride('get_matC', 4) ...
    ];
    
    case 'get_metaD'
        return_value = [SysHybride('get_matD', 1);SysHybride('get_matD', 2);SysHybride('get_matD', 3); SysHybride('get_matD', 4)];
    % end of meta-matrix
    
    case 'get_incidence_matrix'
        buff = [];
        for i=1:SysHybride('get_automate_size')
            buff=[buff ; var_objet(i).next_id]; % Peut-Ãªtre amÃ©liorable
        end
        return_value = buff';
        
    case 'get_adjacence_matrix'
        buff = zeros(SysHybride('get_automate_size'));

        %for each starting node i, test if node j is in next_id of i
        for i=1:SysHybride('get_automate_size')
            for j=1:SysHybride('get_automate_size')
                if sum(SysHybride('get_next_id', i)==j) > 0
                    buff(i,j)=1;
                else
                    buff(i,j)=0;
                end
            end
        end
        return_value = buff;
        
    case 'get_automate_size'
        return_value = main_settings.automate_size;
        
    case 'get_events_size'
        return_value = main_settings.events_size;
    case 'get_events_observables_size'
        buff = 0;
        for i=1:main_settings.events_size
            if var_objet_events(i).obs
                buff = buff + 1;
            end
        end
        return_value = buff;
        
    case 'get_events_observables_names'
        buff = cell(1,SysHybride('get_events_observables_size'));
        j=1;
        
        for i=1:SysHybride('get_events_size')
            if SysHybride('get_event_obs',i) == 1
                buff{j} = SysHybride('get_event_name', i);
                j = j+1;
            end
        end
        
        return_value = buff;
        
     case 'get_events_names'
        buff = cell(1,SysHybride('get_events_size'));
        
        for i=1:SysHybride('get_events_size')
                buff{i} = SysHybride('get_event_name', i);
        end
        
        return_value = buff;
        
    case 'get_time_step'
        return_value = main_settings.time_step;

    

        
 %% Accessors (events)
    case 'set_event_id'
        var_objet_events(param1).id = param2;
    case 'set_event_name'
        var_objet_events(param1).name = param2;
        return_value = 0;
    case 'set_event_obs'
        var_objet_events(param1).obs = param2;
        return_value = 0;
    case 'set_event_commandable'
        var_objet_events(param1).commandable = param2;
        return_value = 0;
    case 'set_event_schedule'
        var_objet_events(param1).schedule = param2;
        return_value = 0;
   case 'set_event_cost'
        var_objet_events(param1).cost = param2;
        return_value =0;
    case 'set_event_fault'
        var_objet_events(param1).fault = param2;
        return_value = 0;
    case 'set_dynamic'
        var_objet_events(param1).dynamic = param2;
        return_value = 0;
    case 'get_event_id'
        return_value = var_objet_events(param1).id;
    case 'get_event_name'
        return_value = var_objet_events(param1).name;
    case 'get_event_cost' 
        return_value = var_objet_events(param1).cost;
    case 'get_event_obs'
        return_value = var_objet_events(param1).obs;
    case 'get_event_commandable'
        return_value = var_objet_events(param1).commandable;
    case 'get_event_schedule'
        return_value = var_objet_events(param1).schedule;
    case 'get_event_fault'
        return_value = var_objet_events(param1).fault;
    case 'get_dynamic'
        return_value = var_objet_events(param1).dynamic;
    case 'get_born_inf'
        return_value = var_objet_events(param1).dynamic(param2,1);
    case 'get_born_sup'
        return_value = var_objet_events(param1).dynamic(param2,2);   
    case 'get_NFaults'
        N_Faults = 0;
        for j=1:length(var_objet_events)
            
            if var_objet_events(j).fault
                N_Faults = N_Faults + 1;    
            end
    
        end
        return_value = N_Faults;
        
    %% Special actions for events:
    case 'event_delete'
        % allow to do this only if system is safe enough
        if SysHybride('is_valid') <= 11 && ~isempty('param1') && param1 <= SysHybride('get_events_size') && SysHybride('get_events_size') > 0
            %delete i-th value in each next_id
            for i=1:SysHybride('get_automate_size');
                buff=SysHybride('get_next_id', i);
                buff(param1) = [];
                SysHybride('set_next_id', i, buff);
            end
            %delete i-th value in the event struct
            var_objet_events(param1)=[];
            
            %decrease event_size
            main_settings.events_size = main_settings.events_size - 1;
            
            return_value = 0;
        else
            return_value = -1;
        end
        
    case 'event_add'
        % allow to do this only if system is safe enough
        if SysHybride('is_valid') <= 11
            %extend size of each next_id
            for i=1:SysHybride('get_automate_size')
                SysHybride('set_next_id', i, [SysHybride('get_next_id', i) 0]);
            end

            %increase event_size
            new_i = main_settings.events_size + 1;
            main_settings.events_size = new_i;
            
            %defaults settings
            if exist('param1', 'var') && ~isempty('param1')
                SysHybride('set_event_name', new_i, param1);
            else
                SysHybride('set_event_name', new_i, 'New event');
            end
            SysHybride('set_event_obs', new_i, 1);
            SysHybride('set_event_fault', new_i, 0);
            SysHybride('set_event_commandable', new_i, 1);
            SysHybride('set_event_schedule', new_i, []);
           
            return_value = 0;
            
        else
            return_value = -1;
        end

 %% Other actions        
    case 'save'
        %TODO vÃ©rifier que le fichier est w        
        save(param1, 'var_objet', 'var_objet_events', 'main_settings', 'Prognoser')
        
        return_value = 0;
     case ('get_states')
        return_value = var_objet;
        
    case ('get_events')
        return_value = var_objet_events;
        
    case ('get_setting')
        return_value = main_settings;   
    case 'is_valid'
        %VÃ©rifie qu'on a bien chargÃ© un systeme, que les matrices ont Ã©tÃ© spÃ©cifiÃ©es (non nulles) ...
        % 0  : everything is ok
        % 9  : error in incidence matrix
        % 10 : some matrix size doesn't match declared size
        % 11 : no events nor modes have been set
        % 100: base parameters haven't been set
        % 1000: base parameters aren't defined
        
        %TODO to finish

        % existence of parameters can't be check because we declare them at
        % the begining of SysHybride ; TODO: implanter une clef de
        % vÃ©rification.
        
        if isempty(main_settings)
            %base parameters aren't set !
            return_value = 100;
        elseif isempty(var_objet) || isempty(var_objet_events)
            %no events nor modes have been set yet
            return_value = 11;
        else
            % VÃ©rifier l'automate (TODO)
            % VÃ©rifier les modes (TODO)
            return_value = 0;
        end

        
    otherwise
        error(strcat('Erreur: \"', methode, '\" n''est pas une mÃ©thode implÃ©mantÃ©e'))
        return_value = -1;
end
