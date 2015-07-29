function Behavior = ComputeBehaviorAutomaton()


%% Function that initialize the diagnoser automaton
% Off-line procedure that enrich the real automaton with events coming from
% residual computation.

fprintf('\n***** Initializing diagnoser automaton *****\n');

%Evaluate diagnosability of each pairs of states:
are_diagnosable_matrix = are_diagnosable();

global Sys_hybride

N_States = length(Sys_hybride.states);
N_Events = length(Sys_hybride.events);


for i=1:N_States
    
Behavior.States(i) =  struct(...
                            'id',i,...
                            'name',['q' num2str(i)],...
                            'next_id', Sys_hybride.states(i).next_id);

end

for i=1:N_Events
    
Behavior.Events(i) =  struct(...
                    'name', Sys_hybride.events(i).name, ...
                    'fault',Sys_hybride.events(i).fault, ...
                    'obs',Sys_hybride.events(i).obs ...
                    );

end

for i=1:N_States
    [n, next_states, events] = automaton_next_states(i);% 
    %fprintf(' -> %d events may occurs in mode %d\n', n, i);
    
    for j=1:n %n =taille du vecteur succ(Next_states)
            % De i -> next_states(j) , evenement events(j)
        fprintf('     -> Transition from %d -> %d (event %d) : ', i, next_states(j), events(j));
        
        %Event observable si SysHybride('get_event_obs', events(j)) == 1
        %Residu disponible si are_diagnosable_matrix(i, next_states(j)) == 1

        % Vérifier si l'option 'Modele lineaire ou matrice de signature'
        % existe
        try option = SysHybride('get_optionSignatures');
        catch err
        fprintf('error : no option');
        end
        if exist('option')==0 % Cas ou l'option n'est pas paramétrée
         fprintf('\n L option parametrage par modele lineaire ou matrice de signature n existe pas');
            is_diag = (are_diagnosable_matrix(i, next_states(j)) == 1);
                if is_diag

                    fprintf('Add residual event + transient mode \n');
                    N_Events = N_Events + 1;
                    N_States = N_States + 1;
                    fprintf('N_Events : %d', N_Events);
                    % Ajouter un evenement residuel:
                    Behavior.Events(N_Events).name = ['Ro' num2str(i) '_' num2str(next_states(j))];
                    Behavior.Events(N_Events).obs = 1;
                    Behavior.Events(N_Events).fault = 0;

                    % Ajouter d'un etat intermediaire:
                    Behavior.States(N_States).id = i*SysHybride('get_automate_size') + next_states(j);    
                    % Behavior.States(N_States).id = str2num([num2str(i) num2str(next_states(j))]);
                    Behavior.States(N_States).next_id = [zeros(1,N_Events-1) next_states(j)];
                    Behavior.States(N_States).name = ['q_' num2str(Behavior.States(N_States).id)];

                    Behavior.States(i).next_id(events(j)) = N_States;

                else

                    fprintf('No residual event to add   \n');
                end
                
                
        else % Cas ou l'option existe
            if option == 0 % cas paramétrage par modeles lineaires
            fprintf('\n Paramétrage par modele lineaire');
                is_diag = (are_diagnosable_matrix(i, next_states(j)) == 1);
                if is_diag

                    fprintf('Add residual event + transient mode \n');
                    N_Events = N_Events + 1;
                    N_States = N_States + 1;
                    fprintf('N_Events : %d', N_Events);
                    % Ajouter un evenement residuel:
                    Behavior.Events(N_Events).name = ['Ro' num2str(i) '_' num2str(next_states(j))];
                    Behavior.Events(N_Events).obs = 1;
                    Behavior.Events(N_Events).fault = 0;

                    % Ajout d'un etat intermediaire:
                    Behavior.States(N_States).id = i*SysHybride('get_automate_size') + next_states(j); 
                    %Behavior.States(N_States).id = str2num([num2str(i) num2str(next_states(j))]);
                    Behavior.States(N_States).next_id = [zeros(1,N_Events-1) next_states(j)];
                    Behavior.States(N_States).name = ['q_' num2str(i) '_' num2str(next_states(j))];
                    %Behavior.States(N_States).name = ['q_' num2str(Behavior.States(N_States).id)];

                    Behavior.States(i).next_id(events(j)) = N_States;

                else

                    fprintf('No residual event to add   \n');
                end

                
            else % cas paramétrage par matrices de signatures
            fprintf('\n Paramétrage par matrice de signatures');
            fprintf('Add residual event + transient mode \n');
            N_Events = N_Events + 1;
            N_States = N_States + 1;
            fprintf('N_Events : %d \n', N_Events);
            
            Behavior.Events(N_Events).name = ['Ro' num2str(i) '_' num2str(next_states(j))];    
            if isequal(SysHybride('get_sig', i), SysHybride('get_sig', next_states(j)))
                    if Behavior.Events(events(j)).fault == 0
                        Behavior.Events(N_Events).obs = 1;
                    else
                        Behavior.Events(N_Events).obs = 0;
                    end
                else
                     Behavior.Events(N_Events).obs = 1;
                end
            Behavior.Events(N_Events).fault = 0;
            
            % Ajouter d'un mode intermÃ©diaire:
        Behavior.States(N_States).id = i*SysHybride('get_automate_size') + next_states(j);    
        %Behavior.States(N_States).id = str2num([num2str(i) num2str(next_states(j))]);
        Behavior.States(N_States).next_id = [zeros(1,N_Events-1) next_states(j)];
        fprintf('Taille next_id : %d  \n', length(Behavior.States(N_States).next_id));
        Behavior.States(N_States).name = ['q_' num2str(i) '_' num2str(next_states(j))];
        %Behavior.States(N_States).name = ['q_' num2str(Behavior.States(N_States).id)];

        Behavior.States(i).next_id(events(j)) = N_States;
            
            end
        end
    end
end

    % Donner à toutes les variables 'next-id' la même taille
    N_Events = size(Behavior.Events,2);
    N_States = size(Behavior.States,2);   
    fprintf('%d \n', N_Events);
    fprintf('%d \n', N_States);
    for i = 1:N_States
%         fprintf('N_Events %d \t Taille next_id %d \t diff %d  \n', N_Events, ...
%             size(Behavior.States(i).next_id,2), ...
%             N_Events - size(Behavior.States(i).next_id,2));
        Behavior.States(i).next_id = ...
           cat(2, Behavior.States(i).next_id,...
           zeros(1, N_Events - size(Behavior.States(i).next_id,2)));
%         fprintf('%d \t %d \t %d  \n', N_Events, ...
%             size(Behavior.States(i).next_id,2), ...
%             N_Events - size(Behavior.States(i).next_id,2));
    end


%                 for i=1:N_States
%     
%                        l = length(Behavior.States(i).next_id);
%                       fprintf('Taille next_id 2 : %d  \n', length(Behavior.States(i).next_id));
%                        Behavior.States(i).next_id =  [ Behavior.States(i).next_id   zeros(1,N_States-l)];
%                        fprintf('Taille next_id 3 : %d  \n', length(Behavior.States(i).next_id));
% 
%                 end
end
