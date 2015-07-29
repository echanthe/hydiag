%% Fonction-Objet stockant l'ensemble des paramètres du prognoser
function  return_value =PrognoserSet(method, param1, param2)
    
    global Sys_hybride
    global Prognoser
    
    
    Sys_hybride.states = SysHybride('get_states');
    Sys_hybride.events = SysHybride('get_events');
    
    for k=1:length(Sys_hybride.states)
        Sys_hybride.states(k).Gr = GroupOf(k);
    end
    
    
 switch method  
     case'update' 
     % get faults name & number:
     N_Faults = 0;
     i=1;
     for j=1:length(Sys_hybride.events)
     
       if Sys_hybride.events(j).fault
            N_Faults = N_Faults + 1;
            Prognoser.fault(i).name = Sys_hybride.events(j).name;
            Prognoser.fault(i).id = Sys_hybride.events(j).id;
            i = i+1;    
        end
    
     end
     % get states name & number:
     N_states = length(Sys_hybride.states);
     for j=1:N_states

            Prognoser.state(j).name = Sys_hybride.states(j).id;
            may_panne = [];
            next_id   = [];
            for i=1:N_Faults
                may_panne(i) = (Sys_hybride.states(j).next_id(Prognoser.fault(i).id))~=0;
                next_id(i) = Sys_hybride.states(j).next_id(Prognoser.fault(i).id);
            end
            Prognoser.state(j).may_panne = may_panne;
            Prognoser.state(j).next_id = next_id;
     end
      Prognoser.Enable = 1;

     %Initialize parameters 
     case 'init'
         N_Faults = SysHybride('get_NFaults');
     if ~exist('param1', 'var')
     %% Initailisation
     I = 1;
     else 
        N_Faults = N_Faults+1;      
        I = N_Faults;
     end
     N_states = length(Sys_hybride.states);

     for j=I:N_Faults
        % Pmax 
        Prognoser.fault(j).Pfmax = 0.8;
        Prognoser.fault(j).Pf    = 0;
        Prognoser.fault(j).age   = 0;

        Prognoser.fault(j).Dmax = zeros(N_states,1);

        Prognoser.fault(j).Beta = NaN *ones(N_states,1);
        Prognoser.fault(j).Eta = NaN *ones(N_states,1);
        Prognoser.fault(j).Gama = zeros(N_states,1);
        Prognoser.fault(j).GamaPr = zeros(N_states,1);
     end
     Prognoser.Dmin = 0;
     Prognoser.DminPr = 0;
     
    
     return_value = 0;  
     
     case 'get_enable'
         return_value = Prognoser.Enable;
     case 'set_enable'
         Prognoser.Enable = param1;
     case 'get_Beta'
         return_value =  Prognoser.fault(param1).Beta(param2);
     case 'get_Eta'
         return_value =  Prognoser.fault(param1).Eta(param2);   
     case 'get_Gama'
         return_value =  Prognoser.fault(param1).Gama(param2);
     case 'get_Pf0'
         return_value =  Prognoser.fault(param1).Pf; 
     case 'get_Pfmax'
         return_value =  Prognoser.fault(param1).Pfmax;     
 
 end
end