function PrognoserOnline(block)
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
block.NumInputPorts  = 1; % Diagnoser Belief state
block.NumOutputPorts = 4; %

% Setup port properties to be inherited or dynamic
%block.SetPreCompInpPortInfoToDynamic;
%block.SetPreCompOutPortInfoToDynamic;
block.SetPreCompPortInfoToDefaults;

% Override output port properties

block.InputPort(1).Dimensions  = 1;
block.InputPort(1).DatatypeID  = 0; % double
block.InputPort(1).Complexity  = 'Real';

block.OutputPort(1).Dimensions  = SysHybride('get_NFaults');
block.OutputPort(1).DatatypeID  = 0; % double
block.OutputPort(1).Complexity  = 'Real';

block.OutputPort(2).Dimensions  = SysHybride('get_NFaults');
block.OutputPort(2).DatatypeID  = 0; % double
block.OutputPort(2).Complexity  = 'Real';

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
    tic;
    global Prognoser
    global Mydates
    persistent FirstPass  Ages Date_max
    persistent  i k OldMode
    
    %% Initialize first pass(q6,{f1})(q7,{f2})
   
    if isempty(FirstPass) 
        k=1;
        %i=1;
        OldMode = 0;
        FirstPass =1;
        Date_max = zeros(1,SysHybride('get_NFaults'));
        Mydates = [];
  
    end
    
    %% Read Input && time:
    
    current_time = get_param(bdroot,'SimulationTime'); 
    Mode =block.InputPort(1).data;
 
    
 
    %% Update ageing data:
    
    %1/Update age:
    for j=1:length(Prognoser.fault)           

        age(j) =  weibullcdf(current_time,Prognoser.fault(j).Beta(k),Prognoser.fault(j).Eta(k),Prognoser.fault(j).Gama(k)) -...
              weibullcdf(Prognoser.Dmin,Prognoser.fault(j).Beta(k),Prognoser.fault(j).Eta(k),Prognoser.fault(j).Gama(k));
        Prognoser.fault(j).age =Prognoser.fault(j).age +  age(j);
        Ages(j) = Prognoser.fault(j).age;
        %fprintf('Age(f%d) = %f \n',j,Prognoser.fault(j).age)
    end
    Prognoser.Dmin = current_time;
    
    %2/Calculate Gamaji for the next step if mode change
    
    i = Mode;
    
        %Prognoser.Dmin = current_time;
       
        for j=1:length(Prognoser.fault)
             %2/ Calculate Gamaji:
             delta = weibullinv(Prognoser.fault(j).age,Prognoser.fault(j).Beta(i),Prognoser.fault(j).Eta(i),0);
             Prognoser.fault(j).Gama(i) = Prognoser.Dmin-delta;        
        end
        
    

        
     %% Predict Faults series:
     debug = 0; 
     
     if Mode ~= OldMode
         if (debug)
             disp('new state detected')
             Mode
         end
         Dmax = NaN(1,length(Prognoser.fault));
         Date_max = Dmax;
         
         l = i;  %% New predicted mode
         %m = k;  %% Past predicted mode
         Prognoser.DminPr = current_time;
         
         for j=1:length(Prognoser.fault)
             Prognoser.fault(j).Pf = Prognoser.fault(j).age;
         end
         if  (sum(Prognoser.state(l).next_id) ==0)
             if debug
                 disp('No prognosis : In this mode no fault can occur') 
             end
             %Date_max = Dmax;
         else
             
             % while No failure
             while(sum(Prognoser.state(l).next_id) ~=0)
                 
                 % For all faults that may occur
                 Dmax = NaN(1,length(Prognoser.fault));
                 for j=1:length(Prognoser.fault)
                     if Prognoser.state(l).may_panne(j)
                         
                         %1/ Calculate Gamajl:
                         
                         delta1 = weibullinv(Prognoser.fault(j).Pf,Prognoser.fault(j).Beta(l),Prognoser.fault(j).Eta(l),0);
                         Prognoser.fault(j).GamaPr(l) = Prognoser.DminPr - delta1 ;
                         
                         %2/ Calculate Dmaxjl
                         Prognoser.fault(j).Dmax(l) = weibullinv(Prognoser.fault(j).Pfmax,Prognoser.fault(j).Beta(l),Prognoser.fault(j).Eta(l),Prognoser.fault(j).GamaPr(l));
                         %a = weibullcdf(Prognoser.fault(j).Dmax(l),Prognoser.fault(j).Beta(l),Prognoser.fault(j).Eta(l),Prognoser.fault(j).Gama(l))
                         
                         Dmax(j) = Prognoser.fault(j).Dmax(l);
                         
                     end
                 end
                 if (sum(isnan(Dmax)) ~= length(Prognoser.fault))
                     % There is a possible fault in this mode
                     
                     % update Date_max
                     [Prognoser.DminPr ,s] = min(Dmax);
                     Date_max(s) = min(Dmax);
                     for j=1:length(Prognoser.fault)
                         Ev = weibullcdf(Prognoser.DminPr,Prognoser.fault(j).Beta(l),Prognoser.fault(j).Eta(l),Prognoser.fault(j).GamaPr(l));
                         
                         if ~isnan(Ev)
                             Prognoser.fault(j).Pf = Ev;
                         end
                         
                     end
                     
                     m = l;
                     l = Prognoser.state(m).next_id(s);
                     
                     %fprintf('f%d at [t=%f]  \t ---> Mode q%d\n',s,Prognoser.DminPr,l);
                 else
                     disp('problem in function PrognoserOnline????')
                     %break;
                 end
             end
             if (debug)
                 disp('Prognosis end')
                 Date_max
             end
         end
         k = i;
         OldMode = Mode;
     else
         Date_max = Date_max;
     end
    %Mydates = [Mydates  ;Date_max-current_time];
    % compute the RUL 
    RUL = max(Date_max -current_time);
    % update Output Ports
    block.OutputPort(1).Data = Ages;
    block.OutputPort(2).Data = Date_max;
    block.OutputPort(3).Data = toc;
    block.OutputPort(4).Data = RUL;     
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