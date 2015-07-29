function Disambiguator(block)
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
block.NumInputPorts  = 2; % Diagnoser Belief state 
                          % Fault ages
block.NumOutputPorts = 1; % Most probable hypotheses

% Setup port properties to be inherited or dynamic
%block.SetPreCompInpPortInfoToDynamic;
%block.SetPreCompOutPortInfoToDynamic;
block.SetPreCompPortInfoToDefaults;

% Override output port properties

block.InputPort(1).Dimensions  = 1;
block.InputPort(1).DatatypeID  = 0; % double
block.InputPort(1).Complexity  = 'Real';

block.InputPort(2).Dimensions  = SysHybride('get_NFaults');
block.InputPort(2).DatatypeID  = 0; % double
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
    
    global Diagnoser 
    persistent FirstPass  
    persistent NewBeliefMode OldBeliefMode 
    
    %% Initialize first pass
   
    if isempty(FirstPass) 
        OldBeliefMode = 0;
        FirstPass =1;
    end
    
    %% Read Input && time:
    
    Mode = Diagnoser.States(block.InputPort(1).data).name;
    [F_max,f] = max(block.InputPort(2).data);
    %% Extract Mode's name
    Mode = regexp(Mode,')(','split');
    
    if length(Mode) == 1 
        Mode = regexp(Mode{1},'q\d','match');
        if ~isempty(Mode)
        i = regexp(Mode{1},'\d','match');
        NewBeliefMode  = str2num(i{1});
        end
        
    else
        for m=1:length(Mode)
        M = regexp(Mode{m},'\d','match');
        Hyp(m,1) = str2num(M{1});
        Hyp(m,2) = str2num(M{2});
        
            if  f == Hyp(m,2)
                 NewBeliefMode = Hyp(m,1);
            end
        end
    end
    
    
    
    
    
    %2/Calaculate Gamaji for the next step if mode change
    if NewBeliefMode ~= OldBeliefMode %% New stable mode
        OldBeliefMode = NewBeliefMode;
    end
    
    block.OutputPort(1).Data = NewBeliefMode;
  
          
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