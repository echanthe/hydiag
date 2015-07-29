function events_input(block)
%MSFUNTMPL_BASIC A template for a Leve-2 M-file S-function
%   The M-file S-function is written as a MATLAB function with the
%   same name as the S-function. Replace 'msfuntmpl_basic' with the 
%   name of your S-function.
%
%   It should be noted that the M-file S-function is very similar
%   to Level-2 C-Mex S-functions. You should be able to get more
%   information for each of the block methods by referring to the
%   documentation for C-Mex S-functions.
%
%   Copyright 2003-2007 The MathWorks, Inc.

%%
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
block.NumInputPorts  = 1;
block.NumOutputPorts = 2; % 1st port for observable events only; 2nd for all events

% Setup port properties to be inherited or dynamic
%block.SetPreCompInpPortInfoToDynamic;
%block.SetPreCompOutPortInfoToDynamic;
block.SetPreCompPortInfoToDefaults;

block.InputPort(1).Dimensions  = SysHybride('get_output_size'); % Continous output
block.InputPort(1).DatatypeID  = 0; % double
block.InputPort(1).Complexity  = 'Real';

% Override output port properties
block.OutputPort(2).Dimensions  = SysHybride('get_events_size'); % Only observables events will output
block.OutputPort(2).DatatypeID  = 8; % boolean
block.OutputPort(2).Complexity  = 'Real';

block.OutputPort(1).Dimensions  = SysHybride('get_events_size'); % All events
block.OutputPort(1).DatatypeID  = 0; % double
block.OutputPort(1).Complexity  = 'Real';

% Register parameters
block.NumDialogPrms     = 0;

% Register sample times
%  [0 offset]            : Continuous sample time
%  [positive_num offset] : Discrete sample time
%
%  [-1, 0]               : Inherited sample time
%  [-2, 0]               : Variable sample time
block.SampleTimes = [0 0];

%% -----------------------------------------------------------------
%% The M-file S-function uses an internal registry for all
%% block methods. You should register all relevant methods
%% (optional and required) as illustrated below. You may choose
%% any suitable name for the methods and implement these methods
%% as local functions within the same file. See the the comments
%% provided for each function for more information.
%% -----------------------------------------------------------------

%block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
%block.RegBlockMethod('InitializeConditions', @InitializeConditions);
%block.RegBlockMethod('Start', @Start);
block.RegBlockMethod('Outputs', @Outputs);     % Required
%block.RegBlockMethod('Update', @Update);
%block.RegBlockMethod('Derivatives', @Derivatives);
block.RegBlockMethod('Terminate', @Terminate); % Required
%block.RegBlockMethod('SetInputPortSamplingMode', @SetInpPortFrameData);

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

%%
%% Outputs:
%%   Functionality    : Called to generate block outputs in
%%                      simulation step
%%   Required         : Yes
%%   C-MEX counterpart: mdlOutputs
%%
function Outputs(block)
current_time = get_param(bdroot,'SimulationTime');
events_size = SysHybride('get_events_size');
% events_observables_size = SysHybride('get_events_observables_size');
output_all = zeros(1,events_size);
% output_obs = zeros(1,events_observables_size);
global sim_sample_time

base_vect = zeros(1,events_size);
base_vect(1) = 1;
fault =0;
% base_vect_obs = zeros(1,events_observables_size);
% base_vect_obs(1) = 1;

%for each event
for event=1:events_size
    % for each occurence of this event
   if ~(SysHybride('get_event_commandable', event))
      Output_size = SysHybride('get_output_size');
      Dynamic_constraints = SysHybride('get_dynamic', event);
      Min = Dynamic_constraints(:,1);
      Max = Dynamic_constraints(:,2);
      
      Smin = sum(block.InputPort(1).Data >= Min);
      Smax = sum(block.InputPort(1).Data <= Max);
      
      if(Smin+Smax == 2*Output_size)
          
         %output_all = zeros(1,events_size);
         output_all = output_all + circshift(base_vect, [0 event-1]); %output_all + circ([1 0 0 0...], event); 
      %break;
      end  
  
  else
      
    schedule = SysHybride('get_event_schedule',event);
    for occ=1:length(schedule)
        
        %test if it's time to do it (+ tolerance of TIME_STEP)
        if abs(schedule(occ) - current_time) <= sim_sample_time/2
          if(SysHybride('get_event_fault', event))
            output_all = zeros(1,events_size);
            output_all = output_all + circshift(base_vect, [0 event-1]); %output_all + circ([1 0 0 0...], event);  
            fault =1;
            break;
          else 
            %add event to all-events output
            output_all = output_all + circshift(base_vect, [0 event-1]); %output_all + circ([1 0 0 0...], event); 
          end
        end
    %break;   
        
    end
    if fault, break; end  
  end
      
      
end

% mask unobservables events (should be static)
mask = zeros(1,events_size)>1;
for i=1:events_size
    if SysHybride('get_event_obs', i) == 1
        mask(i) = true;
    end
end

block.OutputPort(2).Data=output_all & mask;
block.OutputPort(1).Data=output_all;

%end Outputs

%%
%% Update:
%%   Functionality    : Called to update discrete states
%%                      during simulation step
%%   Required         : No
%%   C-MEX counterpart: mdlUpdate
%%
% function Update(block)
% buff = block.InputPort(2).Data;
% block.Dwork(1).Data = buff(1:2); %TODO

%end Update

%%
%% Derivatives:
%%   Functionality    : Called to update derivatives of
%%                      continuous states during simulation step
%%   Required         : No
%%   C-MEX counterpart: mdlDerivatives
%%
function Derivatives(block)

%end Derivatives

%%
%% Terminate:
%%   Functionality    : Called at the end of simulation for cleanup
%%   Required         : Yes
%%   C-MEX counterpart: mdlTerminate
%%
function Terminate(block)

%end Terminate





