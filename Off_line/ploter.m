function ploter
    global results
    global conf
    global Diagnoser
    global Sys_hybride
%% Use Save As in the File menu to create 
% an editable version of this M-file
%
% Create example to illustrate function handle callbacks
% and the use of uipanels

% Copyright 2004 The MathWorks, Inc.


%% Use system background color for GUI components
%panelColor = get(0,'DefaultUicontrolBackgroundColor');

%% ------------ Callback Functions ---------------

% Figure resize function
function figResize(src,evt)
    fpos = get(f,'Position');
    set(botPanel,'Position',...
        [1/20 1/20 fpos(3)-.1 fpos(4)*4/35])
    set(rightPanel,'Position',...
        [fpos(3)*85/120 fpos(4)*4/35 fpos(3)*35/120 fpos(4)*29/35])
    set(centerPanel,'Position',...
        [1/20 fpos(4)*4/35 fpos(3)*85/120 fpos(4)*29/35]);
    set(topPanel, 'Position', ...
        [1/20 fpos(4)*33/35 fpos(3)-.1 fpos(4)*2/35])
end
    
% Bottom panel resize function
function botPanelResize(src, evt)
    bpos = get(botPanel,'Position');
    set(plotButton,'Position',...
        [bpos(3)*10/120 bpos(4)*2/8 bpos(3)*24/120 2])
    set(holdToggle,'Position',...
        [bpos(3)*45/120 bpos(4)*2/8 bpos(3)*24/120 2])
    set(popUp,'Position',...
        [bpos(3)*80/120 bpos(4)*2/8 bpos(3)*24/120 2])
    set(popUpLabel,'Position',...
        [bpos(3)*80/120 bpos(4)*4/8 bpos(3)*24/120 2])
end

% Top panel resize function
function topPanelResize(src, evt)
%     bpos = get(topPanel,'Position');
%     set(plotButton,'Position',...
%         [bpos(3)*110/120 bpos(4)*2/8 bpos(3)*24/120 2])
%     set(holdToggle,'Position',...
%         [bpos(3)*45/120 bpos(4)*2/8 bpos(3)*24/120 2])
end

% Right panel resize function
function rightPanelResize(src,evt)
    rpos = get(rightPanel,'Position');
    set(listBox,'Position',...
        [rpos(3)*4/32 rpos(4)*2/27 rpos(3)*24/32 rpos(4)*20/27]);
    set(listBoxLabel,'Position',...
        [rpos(3)*4/32 rpos(4)*22/27 rpos(3)*24/32 rpos(4)*4/27]);
end

%% Callback for list box
  function listBoxCallback(src,evt)
%         global results
        % Load workspace vars into list box
        %vars = evalin('base','who');
        %vars = fieldnames(results);
        %compute Datas available to be plot:
        vars = cell(1,length(results.self));
        for i=1:length(results.self)
            buff = results.self{i};
            if ~strcmp(buff{1}, '__separator__')
                vars{i} = ['  ' buff{2} ]; % indent items in a category
            else
                vars{i} = buff{2};
            end
        end
        set(src,'String',vars)
    end % listBoxCallback

%% Callback for plot button
    function plotButtonCallback(src,evt)
        persistent min_y
        persistent max_y
        persistent buff_legend
        persistent first_use
        persistent Diag Real
%         global results
        % Get workspace variables
        vars = get(listBox,'String');
        var_index = get(listBox,'Value');
        if length(var_index) < 1
            errordlg('You must select at least 1 data to plot',...
            'Incorrect Selection','modal')
        return
        end
        
        % Get data from base workspace
        x = results.t;
        length(var_index);
        data_available = results.self;
        current_hold = ishold;
        if ~exist('buff_title', 'var')
            buff_title = [];
        end
        
        if current_hold ~= 1
            min_y = +Inf;
            max_y = -Inf;
            buff_legend = {};
            buff_title = [];
        else
            fprintf('keep max_y=%d\n', max_y);
        end
        Comment1 = {};
        Comment2 = {};
        try
            close(Diag);
            close(Real);
        end
        
        for data=1:length(var_index)
            %y = evalin('base', [ 'results.' vars{var_index(2)} ]);
            buff = data_available{var_index(data)};
            if strcmp(buff{1}, '__separator__')
                fprintf('[Ploter] WARNING: a separator has been selected -> skipping\n');
                if length(var_index) == 1
                    error('[Ploter] Only a separator has been selected: unable to plot.');
                end
            else
                y = evalin('base', [ 'results.' buff{1} ]);
                % Get plotting command
                selected_cmd = get(popUp, 'Value');
                % Make the GUI axes current and create plot
                axes(a)
                switch selected_cmd
                case 1 % user selected plot
                    plot(x,y)
                case 2 % user selected bar
                    bar(x,y)
                case 3 % user selected stem
                    stem(x,y)
                end
                hold all
                if isempty(buff_title)
                    buff_title = buff{2};
                else
                    buff_title = [buff_title ' & ' buff{2} ];
                end
                
                %Building legend
                buff_buff_legend = {};
                

                for j=1:size(y,2)
                    plop = [ buff{2} ' (' num2str(j) ')' ];
                    buff_legend{size(buff_legend,2)+1} = plop;
                end
          if strcmp(buff{1}, 'belief_state')
              Comment1 = belief_states_axe();
          end
          if strcmp(buff{1}, 'real_state')
             Comment2 = real_states_axe();
          end
%                 if isempty(buff_legend)
%                     buff_legend = buff_buff_legend;
%                 else
%                     buff_legend{size(buff_legend,2)+1} = buff_buff_legend;
%                 end
                
                
                min_y = min(min(min(y)), min_y);
                max_y = max(max(max(y)), max_y);
            end
        end

        if min_y == max_y & min_y == 0
            min_y = -1;
            max_y = 1;
        end
        
        if min_y > 0
            min_y = 0;
        end
        
        axis([0 1.1*max(x) 1.1*min_y 1.1*max_y])
        title(buff_title)
        grid on
        xlabel 'time (s)'
        %legend('show')
        legend(buff_legend)
        if current_hold ~= 1
            hold off
        end
      
        if ~isempty(Comment1)
        Diag = msgbox(Comment1, 'Diagnoser_Belief_States')  ;      
        end
        if ~isempty(Comment2)
        Real = msgbox(Comment2, 'Real States');
        end
        
        

    end % plotButtonCallback

    function Comment = belief_states_axe()
        N=length(Diagnoser.States);
        for i=1:N
        Comment{i,1} =  [num2str(N+1-i) '-->' Diagnoser.States(N+1-i).name];
        end
    end
    

    function Comment = real_states_axe()
        N=length(Sys_hybride.states);
       for i=1:N
        Comment{i,1} =  [num2str(N+1-i) '-->' Sys_hybride.states(N+1-i).id];
        end 
    end

%% Callback for hold state toggle button
    function holdToggleCallback(src, evt)
        button_state = get(src,'Value');
        if button_state == get(src,'Max')
            % toggle button is depressed
            hold(a,'on')
            set(src,'String','Hold On plot')
        elseif button_state == get(src,'Min')
            % toggle button is not depressed
            hold(a,'off')
            set(src,'String','Hold Off plot')
        end
    end % holdToggleCallback

%% ------------ GUI layout ---------------
    %check there is results
    if results.mark > 0
        %% Set up the figure and defaults
    
        f = figure('Units','characters',...
                'Position',[30 30 120 35],...
                'Color',conf.BG_COLOR,...
                'HandleVisibility','callback',...
                'IntegerHandle','off',...
                'Renderer','painters',...
                'Toolbar','figure',...
                'NumberTitle','off',...
                'Name','Results Plotter - Hybrid multimode system simulator',...
                'ResizeFcn',@figResize);
        
        %% Create the bottom uipanel
        botPanel = uipanel('BorderType','etchedin',...
            'BackgroundColor',conf.BG_COLOR,...
            'Units','characters',...
            'Position',[1/20 1/20 119.9 1],...
            'Parent',f,...
            'ResizeFcn',@botPanelResize);

        %% Create the top uipanel
        topPanel = uipanel('BorderType','etchedin',...
            'BackgroundColor',conf.BG_COLOR_BIS,...
            'ForegroundColor', conf.FG_COLOR_BIS, ...
            'Units','characters',...
            'Position',[1/20 1/20 119.9 1],...
            'Parent',f,...
            'ResizeFcn',@topPanelResize);
        
        %% Create the right side panel
        rightPanel = uipanel('bordertype','etchedin',...
            'BackgroundColor',conf.BG_COLOR,...
            'Units','characters',...
            'Position',[88 8 38 27],...
            'Parent',f,...
            'ResizeFcn',@rightPanelResize);

        %% Create the center panel
        centerPanel = uipanel('bordertype','etchedin',...
            'Units','characters',...
            'BackgroundColor',conf.BG_COLOR,...
            'Position', [1/20 8 88 27],...
            'Parent',f);

        %% Add an axes to the center panel
        a = axes('parent',centerPanel);

        %% Add listbox and label
        listBoxLabel = uicontrol(f,'Style','text','Units','characters',...
                'Position',[4 22 28 6],...
                'String','Select data(s) to plot. You may select more than one by pressing Ctrl key and clicking on wanted datas.',...
                'BackgroundColor',conf.BG_COLOR,...
                'Parent',rightPanel);
        listBox = uicontrol(f,'Style','listbox','Units','characters',...
                'Position',[4 2 24 20],...
                'BackgroundColor','white',...
                'Max',10,'Min',1,...
                'Parent',rightPanel,...
                'Callback',@listBoxCallback);

        %% Add popup and label
        popUpLabel = uicontrol(f,'Style','text','Units','characters',...
                'Position',[80 4 24 2],...
                'String','Plot Type',...
                'BackgroundColor',conf.BG_COLOR,...
                'Parent',botPanel);
        popUp = uicontrol(f,'Style','popupmenu','Units','characters',...
                'Position',[80 2 24 2],...
                'BackgroundColor','white',...
                'String',{'Plot','Bar','Stem'},...
                'Parent',botPanel);
        headerLabel = uicontrol(f,'Style','text','Units','characters',...
                'Position',[15 1/4 100 1.2],...
                'String','Hybrid multimode system simulator - Plot results of simulation',...
                'FontSize', 12, ...
                'FontWeight', 'bold', ...
                'BackgroundColor',conf.BG_COLOR_BIS,...
                'ForegroundColor', conf.FG_COLOR_BIS, ...
                'Parent',topPanel);
        headerLogo = uicontrol(f,'Style', 'pushbutton','Units','pixels', ...
                'Position',[1 1 104 32], ...
                'String',' ', ...
                'CDATA', imread('logo-laas_32.png'), ...
                'Parent',topPanel);

        %% Add hold and plot buttons      
        holdToggle = uicontrol(f,'Style','toggle','Units','characters',...
                'Position',[45 2 24 2],...
                'String','Hold State',...
                'Parent',botPanel,...
                'Callback',@holdToggleCallback);
        plotButton = uicontrol(f,'Style','pushbutton','Units','characters',...
                'Position',[10 2 24 2],...
                'String','Create Plot',...
                'Parent',botPanel,...
                'Callback',@plotButtonCallback);

        %% Initialize list box and make sure
        % the hold toggle is set correctly

        listBoxCallback(listBox,[])
        holdToggleCallback(holdToggle,[])  
        set(f, 'Position', [0 0 200 42]);
        figResize(f, '');
        

    else
        msgbox('You must run the simulation first', 'Unable to plot', 'error');
        fprintf('[ploter] Unable to plot; no simulation results.\n');
    end
end 




