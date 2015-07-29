function Diagnoser_automaton(block)
% S-function (Level-2) 
% INPUT: Events_obs, Events_residuals
% OUTPUT: current belief state

%% The setup method is used to setup the basic attributes of the
%% S-function such as ports, parameters, etc. Do not add any other
%% calls to the main body of the function.
%%
setup(block);

%endfunction

%% Function: setup ===================================================
%% Abstract:
%%   Set up the S-function block's basic characteristics such as:
%%   - Input ports
%%   - Output ports
%%   - Dialog parameters
%%   - Options
%%
%%   Required         : Yes
%%   C-Mex counterpart: mdlInitializeSizes
%%
function setup(block)

% Register number of ports
block.NumInputPorts  = 2; % 
block.NumOutputPorts = 1; %

% Setup port properties to be inherited or dynamic
%block.SetPreCompInpPortInfoToDynamic;
%block.SetPreCompOutPortInfoToDynamic;
block.SetPreCompPortInfoToDefaults;

% Override output port properties
block.InputPort(1).Dimensions  = SysHybride('get_events_size');
block.InputPort(1).DatatypeID  = 8; % boolean
block.InputPort(1).Complexity  = 'Real';

block.InputPort(2).Dimensions  = SysHybride('get_automate_size');
block.InputPort(2).DatatypeID  = 8; % boolean
block.InputPort(2).Complexity  = 'Real';


block.OutputPort(1).Dimensions  = 1;
block.OutputPort(1).DatatypeID  = 0; % double
block.OutputPort(1).Complexity  = 'Real';


% Register parameters
block.NumDialogPrms = 0;

% Register sample times
%  [0 offset]            : Continuous sample time
%  [positive_num offset] : Discrete sample time
%
%  [-1, 0]               : Inherited sample time
%  [-2, 0]               : Variable sample time
block.SampleTimes = [-1 0];

%% -----------------------------------------------------------------
%% The M-file S-function uses an internal registry for all
%% block methods. You should register all relevant methods
%% (optional and required) as illustrated below. You may choose
%% any suitable name for the methods and implement these methods
%% as local functions within the same file. See the the comments
%% provided for each function for more information.
%% -----------------------------------------------------------------

block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
%block.RegBlockMethod('Start', @Start);

    block.RegBlockMethod('InitializeConditions', @InitializeConditions);
    block.RegBlockMethod('Outputs', @Outputs);     % Required
    block.RegBlockMethod('Update', @Update);


%block.RegBlockMethod('Derivatives', @Derivatives);
block.RegBlockMethod('Terminate', @Terminate); % Required
%block.RegBlockMethod('SetInputPortSamplingMode', @SetInpPortFrameData);
end
%end setup

%%
%% PostPropagationSetup:
%%   Functionality    : Setup work areas and state variables. Can
%%                      also register run-time methods here
%%   Required         : No
%%   C-Mex counterpart: mdlSetWorkWidths
%%
%Not used 
function DoPostPropSetup(block)
end
    
%%
%% InitializeConditions:
%%   Functionality    : Called at the start of simulation and if it is 
%%                      present in an enabled subsystem configured to reset 
%%                      states, it will be called when the enabled subsystem
%%                      restarts execution to reset the states.
%%   Required         : No
%%   C-MEX counterpart: mdlInitializeConditions
%%

function InitializeConditions(block)
end
%end InitializeConditions


%%
%% Start:
%%   Functionality    : Called once at start of model execution. If you
%%                      have states that should be initialized once, this 
%%                      is the place to do it.
%%   Required         : No
%%   C-MEX counterpart: mdlStart
%%
function Start(block)
end
%%
%% Outputs:
%%   Functionality    : Called to generate block outputs in
%%                      simulation step
%%   Required         : Yes
%%   C-MEX counterpart: mdlOutputs
%%


function Outputs(block)
    current_time = get_param(bdroot,'SimulationTime'); %used for debug messages only
    
    Obs_events = block.InputPort(1).Data;
    Res_events = block.InputPort(2).Data;

    
    global Diagnoser
    persistent first_step
    persistent Belief_Mode 
    persistent f
    
    if isempty(first_step)
       Belief_Mode = 1;
      
       f = fopen('Results/Diagnoser_tracker.txt','w'); 
       fprintf(f,'\n***********          Diagnser Evolution          ***********\n');
       fprintf(f,'************************************************************\n');
       fprintf(f,'Start Mode %s\n',Diagnoser.States(Belief_Mode).name);
       fprintf(f,'************************************************************\n');
       first_step = 1;
        
    end
    priority = 0;
    M = find(Diagnoser.States(Belief_Mode).next_id);
  
    for i=1:length(M)
        if isempty(Diagnoser.Events(M(i)).id)
            Residu_to_watch = str2num( Diagnoser.Events(M(i)).name(end));
            if ~Res_events(Residu_to_watch)
                
                Belief_Mode = Diagnoser.States(Belief_Mode).next_id(M(i));
                
                fprintf(f,'at [t=%f]  Diagnoser automaton receive the residu: R%d\n',current_time,Residu_to_watch);
                fprintf(f,'Diagnoser automaton bascule to a new mode : %s\n',Diagnoser.States(Belief_Mode).name);
                fprintf(f,'************************************************************\n');
                priority =1;
                break;
            end
        end
    end
    stat_buff = [];
    event_buff = [];
    for i=1:length(M)    
        if priority
            break;
        end
        
        if ~isempty(Diagnoser.Events(M(i)).id)
            Event_to_watch = Diagnoser.Events(M(i)).id;
            if Obs_events(Event_to_watch) && ~(SysHybride('get_event_commandable', Event_to_watch))
               Belief_Mode = Diagnoser.States(Belief_Mode).next_id(M(i));
               
               fprintf(f,'at [t=%f]  Diagnoser automaton receive the event: %s\n',current_time,SysHybride('get_event_name',Event_to_watch));
               fprintf(f,'Diagnoser automaton bascule to a new mode : %s\n',Diagnoser.States(Belief_Mode).name);
               fprintf(f,'************************************************************\n');
               break;
            elseif Obs_events(Event_to_watch)
                event_buff = [event_buff Event_to_watch];
                stat_buff = [stat_buff M(i)];
                
            end
        end
    end
    
    if ~priority && length(stat_buff) ==1
        Belief_Mode = Diagnoser.States(Belief_Mode).next_id(stat_buff(1));
               
        fprintf(f,'at [t=%f]  Diagnoser automaton receive the event: %s\n',current_time,SysHybride('get_event_name',event_buff(1)));
        fprintf(f,'Diagnoser automaton bascule to a new mode : %s\n',Diagnoser.States(Belief_Mode).name);
        fprintf(f,'************************************************************\n');
    end
    
   block.OutputPort(1).Data = Belief_Mode;  
end
%end Outputs

%%
%% Update:
%%   Functionality    : Called to update discrete states
%%                      during simulation step
%%   Required         : No
%%   C-MEX counterpart: mdlUpdate
%%
function Update(block)
end
%end Update

%%
%% Derivatives:
%%   Functionality    : Called to update derivatives of
%%                      continuous states during simulation step
%%   Required         : No
%%   C-MEX counterpart: mdlDerivatives
%%
function Derivatives(block)
end
%end Derivatives

%%
%% Terminate:
%%   Functionality    : Called at the end of simulation for cleanup
%%   Required         : Yes
%%   C-MEX counterpart: mdlTerminate
%%
function Terminate(block)
end
%end Terminate

%% Empty:
%% Do nothing; used when block isn't enable
function Empty(block)

end
end