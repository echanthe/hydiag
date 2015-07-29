function progressbar_display(block)
% S-function (Level-2) that display progress bar of the simulation
%%
%% The setup method is used to setup the basic attributes of the
%% S-function such as ports, parameters, etc. Do not add any other
%% calls to the main body of the function.
%%
setup(block);
function setup(block)

% Register number of ports
block.NumInputPorts  = 0; 
block.NumOutputPorts = 0; 

% Setup port properties to be inherited or dynamic
%block.SetPreCompInpPortInfoToDynamic;
%block.SetPreCompOutPortInfoToDynamic;
block.SetPreCompPortInfoToDefaults;

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
block.RegBlockMethod('InitializeConditions', @Empty);
block.RegBlockMethod('Outputs', @Outputs);
block.RegBlockMethod('Update', @Empty);

%block.RegBlockMethod('Derivatives', @Derivatives);
block.RegBlockMethod('Terminate', @Terminate); % Required
%block.RegBlockMethod('SetInputPortSamplingMode', @SetInpPortFrameData);

%end setup

function DoPostPropSetup(block)


function Outputs(block)
    t = get_param(bdroot,'SimulationTime');
    persistent finished
    
    %update progressbar
    if t>0
         progressbar(t/SysHybride('get_total_time'));
    end
    if (SysHybride('get_total_time')-t) < SysHybride('get_time_step') & finished ~= 1
        %close bar
        %fprintf('fermeture de la barre d''avancement')
        progressbar(1);
        finished = 1;
        fprintf('[progressbar] End of simulation\n');
    end
    
    
function Terminate(block)

function Empty(block)