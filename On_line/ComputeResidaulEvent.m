function ComputeResidaulEvent(block)
% S-function (Level-2) that produce pseudo events from changes of boolean
% residual vector.
% 1 event for 1 possible transition (we keep non-diagnosables modes)
%
% INPUT: boolean_residual, filter_is_stable
% OUTPUT: pseudo_event (integer !)
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
block.NumInputPorts  = 2; 
block.NumOutputPorts = 2; 

% Setup port properties to be inherited or dynamic
%block.SetPreCompInpPortInfoToDynamic;
%block.SetPreCompOutPortInfoToDynamic;
block.SetPreCompPortInfoToDefaults;

% Override output port properties
block.InputPort(1).Dimensions  = (max(Diagnoser('get_ARR_order_optimal')+1))*SysHybride('get_input_size');
block.InputPort(1).DatatypeID  = 0; % double
block.InputPort(1).Complexity  = 'Real';

block.InputPort(2).Dimensions  = (max(Diagnoser('get_ARR_order_optimal')+1))*SysHybride('get_output_size');
block.InputPort(2).DatatypeID  = 0; % double
block.InputPort(2).Complexity  = 'Real';

block.OutputPort(1).Dimensions  = SysHybride('get_automate_size');
block.OutputPort(1).DatatypeID  = 8; % boolean
block.OutputPort(1).Complexity  = 'Real';

block.OutputPort(2).Dimensions  = SysHybride('get_automate_size');
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
%block.RegBlockMethod('Start', @Start);
if Diagnoser('get_enable') == 1
    block.RegBlockMethod('InitializeConditions', @InitializeConditions);
    block.RegBlockMethod('Start', @Start);
    block.RegBlockMethod('Outputs', @Outputs);     % Required
    block.RegBlockMethod('Update', @Update);
else
    block.RegBlockMethod('InitializeConditions', @Empty);   
    block.RegBlockMethod('Start', @Empty);
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

persistent N_states Wc_u Wc_y Stable Residu P firstpass next_change St

if isempty(firstpass)
    
    N_states = SysHybride('get_automate_size');
    Wc_u = cell(1,N_states);
    Wc_y = cell(1,N_states);
    Stable =  cell(1,N_states);       
    Residu =  cell(1,N_states);
    next_change = cell(1,N_states);
    St = true(1,N_states);
    P = Diagnoser('get_ARR_order_optimal');
      
        
        for i=1:N_states
            
            [Wc_u{i},Wc_y{i}]=calcul_RRAs_n(SysHybride('get_matA', i),SysHybride('get_matB', i), ...
                                            SysHybride('get_matC', i), SysHybride('get_matD', i),  P(i));
             Stable{i} = ones(1,Diagnoser('get_filter_dt'));
             next_change{i}=0;
             
        end
    firstpass = 1; 
    St(1) = 0;
    Stable{1} = zeros(1,Diagnoser('get_filter_dt'));
    next_change{1}=Diagnoser('get_filter_dt');
end


    U_p = block.InputPort(1).Data;
    Y_p = block.InputPort(2).Data;
    
    %% Evaluer les ARRj  j=1,2,....,N_states.
    for j=1:N_states
        m=(P(j)+1)*SysHybride('get_input_size');
        n=(P(j)+1)*SysHybride('get_output_size');
        Residu{j} =  Wc_u{j}*U_p(1:m) + Wc_y{j}*Y_p(1:n); 
    end
    
    %% Filtering 
    for j=1:N_states
        Stable{j} = circshift(Stable{j},[0,1]);
        
        Stable{j}(1) =  sum(abs(Residu{j}) > Diagnoser('get_filter_dy'));
    end
    %% Output
    % Check residue stability
    Res=[];
    for j=1:N_states
        if (sum(Stable{j} ) == next_change{j});
            
            St(j) = ~St(j);
            next_change{j} =(next_change{j} ~= Diagnoser('get_filter_dt'))*Diagnoser('get_filter_dt');
        
        end
        Res = [Res;sum(abs(Residu{j}))];
        
    end
    
    block.OutputPort(1).Data = St;
    block.OutputPort(2).Data = Res;
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

