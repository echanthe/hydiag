function U_Y_buffer(block)
% S-function (Level-2) that compute the U_p, Y_p vectors
% INPUT: u, y
% OUTPUT: U_p, Y_p
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
block.NumInputPorts  = 2; % u & y
block.NumOutputPorts = 2; % vector of results of estimation

% Setup port properties to be inherited or dynamic
%block.SetPreCompInpPortInfoToDynamic;
%block.SetPreCompOutPortInfoToDynamic;
block.SetPreCompPortInfoToDefaults;

% Override output port properties
block.InputPort(1).Dimensions  = SysHybride('get_input_size');
block.InputPort(1).DatatypeID  = 0; % double
block.InputPort(1).Complexity  = 'Real';

block.InputPort(2).Dimensions  = SysHybride('get_output_size');
block.InputPort(2).DatatypeID  = 0; % double
block.InputPort(2).Complexity  = 'Real';

block.OutputPort(1).Dimensions  = (max(Diagnoser('get_ARR_order_optimal'))+1)*SysHybride('get_input_size');
block.OutputPort(1).DatatypeID  = 0; % double
block.OutputPort(1).Complexity  = 'Real';

block.OutputPort(2).Dimensions  = (max(Diagnoser('get_ARR_order_optimal'))+1)*SysHybride('get_output_size');
block.OutputPort(2).DatatypeID  = 0; % double
block.OutputPort(2).Complexity  = 'Real';

% Register parameters
block.NumDialogPrms     = 0;

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
block.RegBlockMethod('InitializeConditions', @InitializeConditions);
%block.RegBlockMethod('Start', @Start);
if Diagnoser('get_enable') == 1
    block.RegBlockMethod('Outputs', @Outputs);     % Required
    block.RegBlockMethod('Update', @Update);
else
    block.RegBlockMethod('Outputs', @Empty);
    block.RegBlockMethod('Update', @Empty);
end
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
    %% Setup Dwork
%     block.NumDworks = 2;
%     block.Dwork(1).Name = 'U_p'; 
%     block.Dwork(1).Dimensions      = SysHybride('get_automate_size');
%     block.Dwork(1).DatatypeID      = 0;
%     block.Dwork(1).Complexity      = 'Real';
%     block.Dwork(1).UsedAsDiscState = true;
%     block.Dwork(2).Name = 'Y_p';
%     block.Dwork(2).Dimensions      = SysHybride('get_automate_size');
%     block.Dwork(2).DatatypeID      = 0;
%     block.Dwork(2).Complexity      = 'Real';
%     block.Dwork(2).UsedAsDiscState = true;   
    
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
%block.Dwork(1).Data = zeros(SysHybride('get_input_size'),3); %Store previous values of u

    
%     block.Dwork(1).Data = U_p;
%     block.Dwork(2).Data = Y_p;
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
    persistent Y_p
    persistent U_p
    persistent first_pass
    
    p=Diagnoser('get_ARR_order_optimal');
    
    if isempty(first_pass)
%         % Initialize structures
%         U_p = cell(1,SysHybride('get_automate_size'));
%         Y_p = cell(1,SysHybride('get_automate_size'));
% 
%         %for each mode, initalize initial values with an 0-array
%         for i=1:SysHybride('get_automate_size')
%             U_p{i} = zeros(SysHybride('get_input_size'), p(i));
%             Y_p{i} = zeros(SysHybride('get_output_size'), p(i));
%         end
        U_p = zeros(SysHybride('get_input_size'), max(p)+1);
        Y_p = zeros(SysHybride('get_output_size'), max(p)+1);

        first_pass = 1;
    end
    

    U_p = circshift(U_p, [0,-1]);
    Y_p = circshift(Y_p, [0,-1]);
    
    %Update new value
    U_p(:,end) = block.InputPort(1).Data;
    Y_p(:,end) = block.InputPort(2).Data;
    
    
    %Update output
    block.OutputPort(2).Data=reshape(Y_p, (max(p)+1)*SysHybride('get_output_size'), 1);
    block.OutputPort(1).Data=reshape(U_p, (max(p)+1)*SysHybride('get_input_size'), 1);
    
% current_time = get_param(gcs,'SimulationTime');
% events_size = SysHybride('get_events_size');
% events_observables_size = SysHybride('get_events_observables_size');
% output_all = zeros(1,events_size);
% output_obs = zeros(1,events_observables_size);
% 
% base_vect = zeros(1,events_size);
% base_vect(1) = 1;
% base_vect_obs = zeros(1,events_observables_size);
% base_vect_obs(1) = 1;
% 
% %for each event
% for event=1:events_size
%     % for each occurence of this event
%     schedule = SysHybride('get_event_schedule',event);
%     for occ=1:length(schedule)
%         %test if it's time to do it (+ tolerance of TIME_STEP)
%         if abs(schedule(occ) - current_time) <= SysHybride('get_time_step')/2
%            %add event to all-events output
%            output_all = output_all + circshift(base_vect, [0 event-1]); %output_all + circ([1 0 0 0...], event);
%            %add event to observable-events output if needed
%            if SysHybride('get_event_obs', event)
%                %find number of non-obs event before 'event' event;
%                %we need to ajust size of output_obs
%                buff=0;
%                for i=1:event
%                    if SysHybride('get_event_obs', event) == 0
%                        buff = buff+1;
%                    end
%                end
%                output_obs = output_obs + circshift(base_vect_obs, [0 event-buff-1]); %output_obs + circ([1 0 0], event);
%            end
%         end
%         
%     end
% end
% 
% block.OutputPort(2).Data=output_obs;
% block.OutputPort(1).Data=output_all;
% block.OutputPort(1).Data=block.Dwork(1).Data{1};

%end Outputs

%%
%% Update:
%%   Functionality    : Called to update discrete states
%%                      during simulation step
%%   Required         : No
%%   C-MEX counterpart: mdlUpdate
%%
function Update(block)
% buff = block.InputPort(2).Data;
%block.Dwork(1).Data = buff(1:2); %TODO
    %buff = block.Dwork(1).Data;



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

%% Empty:
%% Do nothing; used when block isn't enable
function Empty(block)

