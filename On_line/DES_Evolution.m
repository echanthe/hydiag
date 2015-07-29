% New method to program the FSM model by using the SysHybride() struct

function [sys,x0,str,ts] = DES_Evolution(t,x,u,flag)
%SFUNTMPL General M-file S-function template
%   With M-file S-functions, you can define you own ordinary differential
%   equations (ODEs), discrete system equations, and/or just about
%   any type of algorithm to be used within a Simulink block diagram.
%
%   The general form of an M-File S-function syntax is:
%       [SYS,X0,STR,TS] = SFUNC(T,X,U,FLAG,P1,...,Pn)
%
%   What is returned by SFUNC at a given point in time, T, depends on the
%   value of the FLAG, the current state vector, X, and the current
%   input vector, U.
%
%   FLAG   RESULT             DESCRIPTION
%   -----  ------             --------------------------------------------
%   0      [SIZES,X0,STR,TS]  Initialization, return system sizes in SYS,
%                             initial state in X0, state ordering strings
%                             in STR, and sample times in TS.
%   1      DX                 Return continuous state derivatives in SYS.
%   2      DS                 Update discrete states SYS = X(n+1)
%   3      Y                  Return outputs in SYS.
%   4      TNEXT              Return next time hit for variable step sample
%                             time in SYS.
%   5                         Reserved for future (root finding).
%   9      []                 Termination, perform any cleanup SYS=[].
%
%
%   The state vectors, X and X0 consists of continuous states followed
%   by discrete states.
%
%   Optional parameters, P1,...,Pn can be provided to the S-function and
%   used during any FLAG operation.
%
%   When SFUNC is called with FLAG = 0, the following information
%   should be returned:
%
%      SYS(1) = Number of continuous states.
%      SYS(2) = Number of discrete states.
%      SYS(3) = Number of outputs.
%      SYS(4) = Number of inputs.
%               Any of the first four elements in SYS can be specified
%               as -1 indicating that they are dynamically sized. The
%               actual length for all other flags will be equal to the
%               length of the input, U.
%      SYS(5) = Reserved for root finding. Must be zero.
%      SYS(6) = Direct feedthrough flag (1=yes, 0=no). The s-function
%               has direct feedthrough if U is used during the FLAG=3
%               call. Setting this to 0 is akin to making a promise that
%               U will not be used during FLAG=3. If you break the promise
%               then unpredictable results will occur.
%      SYS(7) = Number of sample times. This is the number of rows in TS.
%
%
%      X0     = Initial state conditions or [] if no states.
%
%      STR    = State ordering strings which is generally specified as [].
%
%      TS     = An m-by-2 matrix containing the sample time
%               (period, offset) information. Where m = number of sample
%               times. The ordering of the sample times must be:
%
%               TS = [0      0,      : Continuous sample time.
%                     0      1,      : Continuous, but fixed in minor step
%                                      sample time.
%                     PERIOD OFFSET, : Discrete sample time where
%                                      PERIOD > 0 & OFFSET < PERIOD.
%                     -2     0];     : Variable step discrete sample time
%                                      where FLAG=4 is used to get time of
%                                      next hit.
%
%               There can be more than one sample time providing
%               they are ordered such that they are monotonically
%               increasing. Only the needed sample times should be
%               specified in TS. When specifying than one
%               sample time, you must check for sample hits explicitly by
%               seeing if
%                  abs(round((T-OFFSET)/PERIOD) - (T-OFFSET)/PERIOD)
%               is within a specified tolerance, generally 1e-8. This
%               tolerance is dependent upon your model's sampling times
%               and simulation time.
%
%               You can also specify that the sample time of the S-function
%               is inherited from the driving block. For functions which
%               change during minor steps, this is done by
%               specifying SYS(7) = 1 and TS = [-1 0]. For functions which
%               are held during minor steps, this is done by specifying
%               SYS(7) = 1 and TS = [-1 1].

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.18 $

%
% The following outlines the general structure of an S-function.
%
persistent fid
switch flag,

  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0,
    fid = fopen('Results/Real_hybrid_system.txt','w');
    [sys,x0,str,ts]=mdlInitializeSizes(fid);
  %%%%%%%%%%
  % Update %
  %%%%%%%%%%
  case 2,
    sys=mdlUpdate(t,x,u,fid);

  %%%%%%%%%%%
  % Outputs %
  %%%%%%%%%%%
  case 3,
    sys=mdlOutputs(t,x,u);

  %%%%%%%%%%%%%%%%%%%%%%%
  % GetTimeOfNextVarHit %
  %%%%%%%%%%%%%%%%%%%%%%%
  case {1,4,9}
    sys=[];
  %%%%%%%%%%%%%%%%%%%%
  % Unexpected flags %
  %%%%%%%%%%%%%%%%%%%%
  otherwise
    error(['Unhandled flag = ',num2str(flag)]);

end

% end sfuntmpl

%
%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
%
function [sys,x0,str,ts]=mdlInitializeSizes(fid)

%
% call simsizes for a sizes structure, fill it in and convert it to a
% sizes array.
%
% Note that in this example, the values are hard coded.  This is not a
% recommended practice as the characteristics of the block are typically
% defined by the S-function parameters.
%
sizes = simsizes;

sizes.NumContStates  = 0;
sizes.NumDiscStates  = 1;
sizes.NumOutputs     = 1;
sizes.NumInputs      = SysHybride('get_events_size');
sizes.DirFeedthrough = -1;
sizes.NumSampleTimes = 1;   % at least one sample time is needed

sys = simsizes(sizes);

%
% initialize the initial conditions
%
x0  = 1; %Intial state must be defined here

fprintf(fid,'\n****       Hybrid System Evolution       ***** \n');
fprintf(fid,'**********************************************\n');
fprintf(fid,'Start mode:q0\n');
fprintf(fid,'**********************************************\n');
%
% str is always an empty matrix
%
str = [];

%
% initialize the array of sample times
%
ts  = [0 0];


% end mdlInitializeSizes


%
%=============================================================================
% mdlUpdate
% Handle discrete state updates, sample time hits, and major time step
% requirements.
%=============================================================================
%the underlying DES is modeled by its matrix incidence
%rows=states
%columns=events
%input: u=events
%the occurence of an event is modeled as an impulsion during a sampling
%period
%the output: y=the FSM mode
%the state x: the FSM mode
function sys=mdlUpdate(t,x,u,fid)
% u is the vector of evenement(s) occurence(s)
current_time = get_param(bdroot,'SimulationTime');
q_current=round(x); %q_current=integer

if sum(u) == 0
    % no event 
    x = q_current;

else
    % One event or more
    event_id = find(u==1);
    buff=SysHybride('get_next_id', q_current);
    Stat_buff = [];
    event_buff = [];
    dynamic = 0;
    fault =0;
    %% First Fault_Event
    for j=1:length(event_id)
        if buff(event_id(j)) > 0 && (SysHybride('get_event_fault', event_id(j)))
        fprintf(fid,'at [t=%f]  Hybrid system receive the event:%s\n',current_time,SysHybride('get_event_name',event_id(j)));
        q_next = buff(event_id(j));
        fprintf(fid,'Hybrid system bascule to a new mode : %s\n',SysHybride('get_id',q_next));
        fprintf(fid,'**********************************************\n');   
        fault =1;
        break;
        end
    end
    %% Second Othre Event (if no fault_event)
    for j=1:length(event_id)
        
        if fault 
            break;
        end
        %% A/ Dynamic Events
        if buff(event_id(j)) > 0 && ~(SysHybride('get_event_commandable', event_id(j)))
        
        fprintf(fid,'at [t=%f]  Hybrid system receive the event:%s\n',current_time,SysHybride('get_event_name',event_id(j)));
        q_next = buff(event_id(j));
        fprintf(fid,'Hybrid system bascule to a new mode : %s\n',SysHybride('get_id',q_next));
        fprintf(fid,'**********************************************\n');   
        dynamic =1;
        break;
        %% B/ Static normal event    
        elseif buff(event_id(j)) > 0
        event_buff = [event_buff event_id(j)];
        Stat_buff = [Stat_buff buff(event_id(j))];
        
        else
        %% C/ No Event    
           q_next = q_current;
        end
    end
    %% Case "unique static event
    if ~dynamic && length(Stat_buff) ==1
        fprintf(fid,'at [t=%f]  Hybrid system receive the event:%s\n',current_time,SysHybride('get_event_name',event_buff(1)));
        q_next = Stat_buff(1);
        fprintf(fid,'Hybrid system bascule to a new mode : %s\n',SysHybride('get_id',q_next));
        fprintf(fid,'**********************************************\n');      
    %% Case "Multiple static event
    elseif length(Stat_buff) >1
        q_next = q_current;
        fprintf('Multiple static event received so ignored\n');
    end
    x = q_next;
end
sys = x;

% end mdlUpdate

%
%=============================================================================
% mdlOutputs
% Return the block outputs.
%=============================================================================
%
function sys=mdlOutputs(t,x,u)

y=x;

sys = y;


% end mdlOutputs

