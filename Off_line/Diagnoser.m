%% Fonction-Objet stockant l'ensemble des paramètres du diagnoser
function return_value = Diagnoser(methode, param1, param2)
    persistent ARR_settings
    persistent filter_settings
    persistent enabled
    persistent Spec_input
    persistent automaton
    persistent states_in_macro_state
    
switch methode
    case 'init'

        if ~isempty(ARR_settings)
            %do nothing
        else
            ARR_settings = struct('order', {[]}...
                           );

            filter_settings = struct('dt', { 5 },...
                                     'dy', {1e-12} ...
                              );
            automaton = struct('incidence_matrix', {[]},...
                               'adjacent_matrix', {{}}, ...
                               'events_id', {[]}, ...
                               'states_id', {[]} ...
                            );

            states_in_macro_state = {};
            
            buff = [];
            for i=1:SysHybride('get_automate_size')
                buff = [buff SysHybride('get_dyn_size',i)];
            end

            ARR_settings.order = buff;
            enabled = 1;
            Spec_input = 0;
        end
        
    case 'set_ARR_order'
        ARR_settings.order = param1;
        return_value = 0;
        
    case 'set_filter_dt'
        filter_settings.dt = param1;
        return_value = 0;
        
    case 'set_filter_dy'
        filter_settings.dy = param1;
        return_value = 0;
        
    case 'set_enable'
        enabled = param1;
        return_value = 0;
    
    case 'set_spec_input'
        Spec_input = param1;
        return_value = 0;  
        
    case 'set_incidence_matrix'
        automaton.incidence_matrix = param1;
        return_value = 0;
    case 'set_adjacent_matrix'
        automaton.adjacent_matrix = param1;
        return_value = 0;
    case 'set_events_id'
        automaton.events_id = param1;
        return_value = 0;
    case 'set_states_id'
        automaton.states_id = param1;
        return_value = 0;
        
        %obselete
    case 'set_states_in_macro_state'
        states_in_macro_state{param1} = param2;
        return_value = 0;
        
    case 'get_ARR_order'
        return_value = ARR_settings.order;
        
    case 'get_filter_dt'
        return_value = filter_settings.dt;
        
    case 'get_filter_dy'
        return_value = filter_settings.dy;
        
    case 'get_enable'
        return_value = enabled;
        
    case 'get_spec_input'
        return_value = Spec_input;
        
    case 'get_ARR_order_optimal'
        %TODO: valider
        buff = [];
        
        %For each mode, compute the minimum order of redundancy
        for i=1:SysHybride('get_automate_size')
            p=0;
            C=SysHybride('get_matC', i);
            A=SysHybride('get_matA', i);
            Op=C;
            m=size(C,1);
            nbre_lignes_Op=m;
            rp=rank(Op);

            while rp >= nbre_lignes_Op
            Op=[Op;Op*A];
            p=p+1;
            rp=rank(Op);
            nbre_lignes_Op=(p+1)*m;
            end
            
            buff = [buff p];
        end
        return_value = buff;
        
    case 'get_incidence_matrix'
        return_value = automaton.incidence_matrix;

    case 'get_adjacent_matrix'
        return_value = automaton.adjacent_matrix;
       
    case 'get_automate_size'
        return_value = size(automaton.incidence_matrix, 2);
        
    case 'get_events_size'
        return_value = size(automaton.incidence_matrix, 1);
        
    %obselete
    case 'get_states_in_macro_state'
        return_value = states_in_macro_state{param1};
    
    case 'get_events_id'
        return_value = automaton.events_id;

    case 'get_states_id'
        return_value = automaton.states_id;
        
    otherwise
        error('Methode non implémentée !');
        
end
