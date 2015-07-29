function [sys,x0,str,ts] = simom(t,x,u,flag)
% An example M-file S-function for defining a discrete system.
% This S-function compute several discrete equations from this form:
%      x(n+1) = A*x(n) + B*u(n)
%      y(n)   = C*x(n) + D*u(n)
% to a big one
%      X(n+1) = An*X(n) + Bn*u(n)    %rq: same input for each mode
%      Y(n)   = Cn*X(n) + Dn*u(n)    
% with the output as a vector Y = [y1; y2; ... yN]

% Number of mode

switch flag,
  case 0 % Initialization
    [sys,x0,str,ts] = mdlInitializeSizes();

  case 2 % Update discrete states
    sys = mdlUpdate(t,x,u);

  case 3 % Calculate outputs
    sys = mdlOutputs(t,x,u);

  case {1, 4, 9} % Unused flags
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
sizes.NumDiscStates  = SysHybride('get_dyn_size',1);
sizes.NumOutputs     = SysHybride('get_output_size');
sizes.NumInputs      = SysHybride('get_input_size') + 1;

sizes.DirFeedthrough = 1; % TODO (A voir) Matrix D is non-empty. (sizes.DirFeedthrough = any(any(D~=0));)
sizes.NumSampleTimes = 1;
sys = simsizes(sizes);

x0 = SysHybride('get_x0');              % Initial states.
str = [];                               % Always empty. Why ?
%ts  = [SysHybride('get_time_step') 0];  % sample time: [period, offset]
ts = [ sim_sample_time 0 ];

%display a progressbar
try
    progressbar(0, 0);
end

% End of mdlInitializeSizes.

%==============================================================
% Update the discrete states
%==============================================================
function sys = mdlUpdate(t,x,u)
sys = SysHybride('get_matA',u(end))*x + SysHybride('get_matB',u(end))*u(1:end-1);
% End of mdlUpdate.

%==============================================================
% Calculate outputs
%==============================================================
function sys = mdlOutputs(t,x,u)
sys = SysHybride('get_matC',u(end))*x + SysHybride('get_matD',u(end))*u(1:end-1);
persistent finished

%update progressbar
% if t>0
%      progressbar(t/SysHybride('get_total_time'));
% end
% if (SysHybride('get_total_time')-t) < SysHybride('get_time_step') & finished ~= 1
%     %close bar
%     fprintf('fermeture de la barre d''avancement')
%     progressbar(1);
%     finished = 1;
% end
% End of mdlOutputs.


