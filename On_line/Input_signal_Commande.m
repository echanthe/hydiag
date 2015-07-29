function [sys,x0,str,ts] = Input_signal_Commande(t,x,u,flag,Phase)
% An example M-file S-function for defining a discrete system.
% This S-function compute several discrete equations from this form:
%      x(n+1) = A*x(n) + B*u(n)
%      y(n)   = C*x(n) + D*u(n)
% to a big one
%      X(n+1) = An*X(n) + Bn*u(n)    %rq: same input for each mode
%      Y(n)   = Cn*X(n) + Dn*u(n)    
% with the output as a vector Y = [y1; y2; ... yN]

% Number of mode
%%
% *BOLD TEXT*
persistent i
persistent Input


switch flag,
  case 0 % Initialization
      
      if Diagnoser('get_spec_input')
           
          try
            load 'Input.mat';  
%             f = fopen('input.dat','r');
%             Input = fscanf(f,'%f\n');
          end
          
      end


      i=0;
    [sys,x0,str,ts] = mdlInitializeSizes();

  case 3 % Calculate outputs
          i = i+1;
    sys = mdlOutputs(t,x,u,Phase,i,Input);

  case {1,2, 4, 9} % Unused flags
    sys = [];

  otherwise % Error handling
    error(['unhandled flag = ',num2str(flag)]); 
end


%==========================================================================
% Initialization
% Return the sizes, initial conditions, and sample times for the S-function.
%==========================================================================
function [sys,x0,str,ts] = mdlInitializeSizes()
global sim_sample_time
sizes = simsizes;
sizes.NumContStates  = 0;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = SysHybride('get_input_size');
sizes.NumInputs      = 0;
sizes.DirFeedthrough = 1; % TODO (A voir) Matrix D is non-empty. (sizes.DirFeedthrough = any(any(D~=0));)
sizes.NumSampleTimes = 1;
sys = simsizes(sizes);

x0 =[];              % Initial states.
str = [];                               % Always empty. Why ?
%ts  = [SysHybride('get_time_step') 0];  % sample time: [period, offset]
ts = [ sim_sample_time 0 ];



%display a progressbar


% End of mdlInitializeSizes.

%==============================================================
% Update the discrete states
%==============================================================
% End of mdlUpdate.

%==============================================================
% Calculate outputs
%==============================================================
function sys = mdlOutputs(t,x,u,Phase,i,Input)

if(isempty(Input))
N = SysHybride('get_input_size');
Amp = 1;%[0.0105;0.0075;0.0020];
Freq = 1; % 1hz
sys = Amp*sin(2*pi*Freq*ones(N,1)*t + Phase);
else
    sys = (Input(i,:))';
end





