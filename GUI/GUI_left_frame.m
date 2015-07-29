% the left frame
function GUI_left_frame(param1, param2, param3)
    global conf
    persistent f
    persistent sys_panel
    persistent sysinfo_panel %parent figure and panels
    persistent obj_main_menu
    persistent conf_sysp
    persistent conf_sysinfop
    persistent infobox_id
    global load_from_filename %remember the name of the system loaded (should we diplay it in the GUI ??)
    
%     if nargin == 0
%         param1 = 'init';
%     end
    
    switch param1
        case 'init'
            f = param2;
               obj_main_menu = {};

               % {name to display, visible by default, callback, n° in the obj_main_menu struct}
               conf_sysp = {...
                   {'New', 'on', '@btn_new_Callback', 0}, ... %1
                   {'Open', 'on', '@btn_open_Callback', 0}, ... %2
                   {'Save', 'off', '@btn_save_Callback', 0}, ... %3
                   {'Run Simulation', 'off', '@btn_runsim_Callback', 0} ... %4
               };
               conf_sysinfop = {...
                   {'Edit modes', 'off', '@btn_editmodes_Callback', 0}, ... %1
                   {'Edit static event', 'off', '@btn_editevents_Callback',0}, ... %2
                   {'Edit dynamic event', 'off', '@btn_editautomaton_Callback',0}, ... %3
                   {'Prognosis', 'off', '@btn_editprognosis_Callback',0}, ... %3
               };             
               
               % Setting up the panels
               % - System (New, Open, Save, Run Simulation)
               sys_panel = uipanel('Parent',f,'Title','System', ...
                         'Units', 'pixels', ...
                         'BackgroundColor',conf.BG_COLOR, ...
                         'ForegroundColor',conf.FG_COLOR, ...
                         'Position',[
                            conf.MARGIN ...
                            conf.Y_SIZE-conf.HEADER- conf.MARGIN-6*conf.Y_BTN_SIZE ...
                            conf.LEFT_MENU-conf.MARGIN ...
                            6*conf.Y_BTN_SIZE ...
                          ]);
               
               % - System Information (infobox, Edit modes, Edit events,
               % Edit automate).
               sysinfo_panel = uipanel('Parent',f,'Title','Characteristics', ...
                         'Units', 'pixels', ...
                         'BackgroundColor',conf.BG_COLOR, ...
                         'ForegroundColor',conf.FG_COLOR, ...
                         'Position',[
                            conf.MARGIN ...
                            conf.Y_BTN_SIZE+3*conf.MARGIN ...
                            conf.LEFT_MENU-conf.MARGIN ...
                            conf.Y_SIZE-11*conf.Y_BTN_SIZE-2*conf.MARGIN ...
                          ]);
               
               % Setting up the controls for sys_panel
               for i=1:length(conf_sysp)                  
                   obj_main_menu{i} = uicontrol(...
                       'Parent', sys_panel, ...
                       'Style', 'pushbutton', ...
                       'String', conf_sysp{i}(1), ...
                       'Visible', cell2mat(conf_sysp{i}(2)), ...
                       'Position', [...
                            2*conf.MARGIN, ...
                            conf.MARGIN + (length(conf_sysp)-i)*(conf.MARGIN+conf.Y_BTN_SIZE), ...
                            conf.X_BTN_SIZE, ...
                            conf.Y_BTN_SIZE ...
                            ], ...
                       'Callback', eval(cell2mat(conf_sysp{i}(3))) ...
                   );
               end
               % Setting up the controls for sysinfo_panel
               for i=1:length(conf_sysinfop)
                   obj_main_menu{i+length(conf_sysp)} = uicontrol(...
                       'Parent', sysinfo_panel, ...
                       'Style', 'pushbutton', ...
                       'String', conf_sysinfop{i}(1), ...
                       'Visible', cell2mat(conf_sysinfop{i}(2)), ...
                       'Position', [...
                            2*conf.MARGIN, ...
                            conf.MARGIN + (length(conf_sysinfop)-i)*(conf.MARGIN+conf.Y_BTN_SIZE), ...
                            conf.X_BTN_SIZE, ...
                            conf.Y_BTN_SIZE ...
                            ], ...
                       'Callback', eval(cell2mat(conf_sysinfop{i}(3))) ...
                   );
               end
               infobox_id = length(conf_sysinfop)+length(conf_sysp)+1;
               obj_main_menu{infobox_id} = uicontrol('Style','text',...
                    'Parent', sysinfo_panel, 'BackgroundColor',conf.BG_COLOR_BIS, ...
                    'ForegroundColor',conf.FG_COLOR_BIS, ...
                    'Position',[...
                         conf.MARGIN, ...
                         conf.MARGIN + length(conf_sysinfop)*(conf.Y_BTN_SIZE+conf.MARGIN), ... 
                         conf.LEFT_MENU-4*conf.MARGIN, ...
                         (conf.Y_SIZE-11*conf.Y_BTN_SIZE-2*conf.MARGIN) - length(conf_sysinfop)*(conf.Y_BTN_SIZE+conf.MARGIN) - conf.Y_BTN_SIZE ...
                         ]);


                %obj_main_menu{length(conf_sysp)+length(conf_sysinfop)} = uicontrol(...
                uicontrol(...
                    'Parent', f, 'Style','pushbutton','String','Exit',...
                    'Position',[...
                         3*conf.MARGIN, ...
                         conf.MARGIN, ...
                         conf.X_BTN_SIZE, ...
                         conf.Y_BTN_SIZE], ...
                    'Callback',{@btn_quit_Callback});
                
     
                load_from_filename = '';
                GUI_left_frame('set_info', '',0);                
                
               
        case 'quit'
            'quit left frame'

        case 'update_btn'
            if SysHybride('is_valid') > 11            
                set(obj_main_menu{3}, 'Visible', 'Off') % save btn
                set(obj_main_menu{4}, 'Visible', 'Off') % Run sim btn
                set(obj_main_menu{5}, 'Visible', 'Off') % Edit modes
                set(obj_main_menu{6}, 'Visible', 'Off') % Edit events
                set(obj_main_menu{7}, 'Visible', 'Off') % Edit automaton
                set(obj_main_menu{8}, 'Visible', 'Off') % Edit automaton

            else
                set(obj_main_menu{3}, 'Visible', 'On') % save btn
                set(obj_main_menu{5}, 'Visible', 'On') % Edit modes
                set(obj_main_menu{6}, 'Visible', 'On') % Edit events
                set(obj_main_menu{7}, 'Visible', 'On') % Edit automaton 
                set(obj_main_menu{8}, 'Visible', 'On') % Edit automaton 

                

                if SysHybride('is_valid') == 0
                    set(obj_main_menu{4}, 'Visible', 'On') % Run sim btn
                else
                    set(obj_main_menu{4}, 'Visible', 'Off') % Run sim btn
                end
            end
            
        case 'set_info'
            if nargin == 3 
                % a specific code has been specified
                switch param3
                    case 0
                        param2 = 'No system loaded';
                    case 1
                        param2 = {'System loaded:' ...
                                    '---' ...
                                    SysHybride('get_description') ...
                                    '---' ...
                                    [ ' - ' num2str(SysHybride('get_automate_size')) ' modes.' ] ...
                                    [ ' - ' num2str(SysHybride('get_events_size')) ' events.' ] ...
                                    [ ' - sampling time : ' num2str(SysHybride('get_time_step')) 's.']
                                    
                                    };
                end
            end
            
            set(obj_main_menu{infobox_id}, 'String', param2);
            
    end
    

    %% Callback
function btn_new_Callback(source,eventdata)
    load_from_filename = 'Untitled_system.mat';

    % clear current system (TODO: check for unsaved work)
    SysHybride('init','clean');
    GUI_left_frame('set_info', '',0);
    GUI_left_frame('update_btn');

    GUI_right_frame('frame_new');
    
function btn_open_Callback(source,eventdata)
    % Open button open a select file box and load its content
    'open'
    global load_from_filename 
    file_to_load = uigetfile({'*.mat', 'Hybrid System (*.mat)'});
    if file_to_load ~= 0 %&& exist(file_to_load, 'file') == 2
        SysHybride('init', 'clean');
        status = SysHybride('init', 'load_file', file_to_load);
        % Basic check on 
        if status >= 100
            errordlg('This file doesn''t contain a valid system. Unable to load it.');
            SysHybride('init', 'clean');
            GUI_left_frame('set_info', '',0);
        else
            load_from_filename = file_to_load; % remember the name
            GUI_left_frame('set_info', '',1);
        end

        % Sum up of the system loaded
        
        GUI_left_frame('update_btn');
        %reset right frame
        GUI_right_frame('clean');
    end

function btn_save_Callback(source,eventdata)
    'save'
    global load_from_filename 
    [filename, pathname] = uiputfile(...
        {'*.mat','Hybrid System (*.mat)';...
         '*.*',  'All Files (*.*)'},...
         'Save as ...',...
         load_from_filename);
     SysHybride('save', strcat(pathname, filename));
     
function btn_runsim_Callback(source, eventdata)
    'run simulation'
    GUI_right_frame('run_simulation');
        
function btn_editevents_Callback(source,eventdata)
    'edit events'
    GUI_right_frame('edit_events');
    

function btn_editmodes_Callback(source,eventdata)      
    'edit modes'
    GUI_right_frame('edit_modes');
    
function btn_editautomaton_Callback(source,eventdata)
    'edit automaton'
    GUI_right_frame('edit_automaton');
    
 function btn_editprognosis_Callback(source,eventdata)
'edit prognosis'
GUI_right_frame('edit_prognosis_parameters');


     function btn_quit_Callback(source,eventdata)
    'quit'
    GUI_main_window('quit')      