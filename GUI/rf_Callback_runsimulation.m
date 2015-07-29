function rf_Callback_runsimulation(source, event, obj_frame)
    global results
    global sim_sample_time

    set(source, 'String', 'Running ...');
    %flush display
    results.self = {
                {'__separator__' '-- Simulator : --'} ...
                {'t' 'Simulation time'} ...
                {'U' 'Continuous input(s)'} ...
                {'Y' 'Continuous output(s)'} ...
                {'events' 'Observables and unobservables discretes events'} ...
                {'events_obs' 'Observables discretes events'} ...
                {'real_state' 'Real state of the automaton'} ...
                {'__separator__' '-- Diagnoser : --'} ...
                {'belief_state' 'Belief state in output of the diagnoser' } ...
                {'residual_norm' 'Norm 1 of residuals'} ...
                {'residual_event' 'Events generated from residuals changes' } ...
                {'__separator__' '-- Prognoser : --'} ...
                {'Ages' 'Faults ages' } ...
                {'FaultsMaxDates' 'Predicted dates of fault occurrence' } ...
                {'TimeElapsed' 'Prognosis process computation time' } ...
                {'RUL' 'RUL (or date of the last fault if failure is not accesible)' }...
                };
    drawnow

    %store final time
    SysHybride('set_total_time', str2num(get(obj_frame{3}, 'String')));


    %validate and store ARR settings
    orders = str2num(get(obj_frame{14}, 'String'));

    if isempty(orders) || size(orders,2) ~= SysHybride('get_automate_size')
        errordlg('Wrong size for ARR Order array.');
        % arbitrary criteria ... we should check with the max
        % dyn
        % size
%                 elseif orders >= SysHybride('get_dyn_size',1)
%                     errordlg('ARR Order mustn''t be greater than dynamic size of the mode');
    else
         %global U event_new event_new_obs Y Mode_estim_new Mode t % TODO : a nettoyer
         %warn if simulation step time < dynamics step time
         if str2num(get(obj_frame{23}, 'String')) > SysHybride('get_time_step')
             %todo: suspend execution with uiwait
             warndlg('Simulation sample time sould be lower than step time set.')

         end
         sim_sample_time = str2num(get(obj_frame{23}, 'String'));
         
         % clean S-function (to clean persistent variables)
         clear simom Diagnoser_automaton U_Y_buffer progressbar_display ...
               Input_signal_Commande ComputeResidaulEvent PrognoserOnline
         
         Diagnoser('set_ARR_order', orders);
         Diagnoser('set_filter_dy', str2num(get(obj_frame{16}, 'String')));
         Diagnoser('set_filter_dt', str2num(get(obj_frame{18}, 'String')));
         Diagnoser('set_enable', get(obj_frame{20}, 'Value'));
         PrognoserSet('set_enable', get(obj_frame{10}, 'Value'));
         Diagnoser('set_spec_input', get(obj_frame{30}, 'Value'));

        
        
        rf_Callback_showautomatons(source, event, obj_frame)
        
        options = '';
        get(obj_frame{3}, 'String');
        
      events_size = SysHybride('get_events_size'); 
      output_size = SysHybride('get_output_size');
      buff ={};
      for event=1:events_size
         if~(SysHybride('get_event_commandable', event));  
             
             Dynamic_constraints = SysHybride('get_dynamic', event);
             check = sum(sum(Dynamic_constraints == [-Inf*ones(output_size,1) Inf*ones(output_size,1)])) == 2*output_size;
             if check
                     
                 buff = [buff strcat('Event n°', num2str(event) ,' is always true')];
             end
             
         end
      end
      
      if ~isempty (buff)
          
          buff = [buff 'Would you like to continue'];
             selection = questdlg(buff,...
             'Warning Event',...
              'Yes','No','Yes'); 
               switch selection, 
                case 'Yes',
                'Continue';
                case 'No'
                return 
               end
               
      end
      if Diagnoser('get_spec_input') 
         if ~exist('Input.mat','file')
          selection = questdlg('File "Input.mat" not found. Do you want to run simulation anyway?' ,...
             'Warning Event',...
              'Yes','No','Yes'); 
               switch selection, 
                case 'Yes',
                'Continue'
                case 'No'
                return 
               end
         else
            
            load ('Input.mat')
            L=(str2num(get(obj_frame{3},'String')) / sim_sample_time) +1;
            if  L~=length(Input)
                buff = ['Input must have a length of: ' num2str(L)];
                errordlg(buff);
            return
            
            end
            clear Input;
         end
      end
     
     try
     delete Results/behavior*
     delete Results/diagnoser* 
     delete Results/Real_hybrid_system.txt
     delete Results/Diagnoser_tracker.txt
     catch 
         
     end
     
     if Diagnoser('get_enable') &&  PrognoserSet('get_enable')
        fprintf('***** Simulation, Diagnosis and Prognosis*****\n');
        sim('Off_line/hybrid_system_diagprog.mdl', str2num(get(obj_frame{3}, 'String')), options);
        type Results/Real_hybrid_system.txt
        type Results/Diagnoser_tracker.txt
        Index = 16;
        results.self = results.self(1:Index);
     elseif  Diagnoser('get_enable')
        fprintf('***** Simulation and Diagnosis*****\n');
        sim('Off_line/hybrid_system_diag.mdl', str2num(get(obj_frame{3}, 'String')), options);
        type Results/Real_hybrid_system.txt
        type Results/Diagnoser_tracker.txt
        Index = 11;
        results.self = results.self(1:Index);
      elseif  PrognoserSet('get_enable')
        fprintf('***** Simulation and Prognosis *****\n');
        sim('Off_line/hybrid_system_prog.mdl', str2num(get(obj_frame{3}, 'String')), options);
        type Results/Real_hybrid_system.txt
        %type Results/Diagnoser_tracker.txt
        Index = 12;
        results.self = {
                {'__separator__' '-- Simulator : --'} ...
                {'t' 'Simulation time'} ...
                {'U' 'Continuous input(s)'} ...
                {'Y' 'Continuous output(s)'} ...
                {'events' 'Observables and unobservables discretes events'} ...
                {'events_obs' 'Observables discretes events'} ...
                {'real_state' 'Real state of the automaton'} ...
                {'__separator__' '-- Prognoser : --'} ...
                {'Ages' 'Faults ages' } ...
                {'FaultsMaxDates' 'Predicted dates of fault occurrence' } ...
                {'TimeElapsed' 'Prognosis process computation time' } ...
                {'RUL' 'RUL (or date of the last fault if failure is not accesible)' }...
               };
     else
         fprintf('***** Simulation Only *****\n');
         sim('Off_line/hybrid_system_new.mdl', str2num(get(obj_frame{3}, 'String')), options);
         type Results/Real_hybrid_system.txt
         Index = 7;
         results.self = results.self(1:Index);
     end

        
        
                 %Store here output to store (global variable)
                for i=1:Index
                    data_to_save=results.self{i};
                    buff = data_to_save{1};
                    %buff = buff{1}
                    if ~strcmp(buff, '__separator__')
                        eval(['results.' buff ' = ' buff ';']);
                    end
                end

              end

                %refresh frame
                GUI_right_frame('clean');
                GUI_right_frame('run_simulation');
                results.mark = 1;
                
            end
