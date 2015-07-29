function rf_Callback_create_new_system(source, eventdata, obj_frame)
    % validation for the frame 'new_frame'
    is_valid = 0;
    status = 0;
    
    Error_buf{1} =['                                         '];
    %get the values
    get(obj_frame{3}, 'String')
    [automate_size status] = str2num(get(obj_frame{3}, 'String'));
    if ~status || isnan(automate_size) || automate_size < 1
         Error_buf =[Error_buf,'Value for "Number of modes" is not correct'];
    else
        is_valid = is_valid+1;
    end

    [events_size status] = str2num(get(obj_frame{5}, 'String'));
    if ~status || isnan(events_size) || events_size < 1
        Error_buf =[Error_buf '"Number of events" is not correct'];
    else
        is_valid = is_valid+1;
    end

    [sample_time status] = str2num(get(obj_frame{7}, 'String'));
    if ~status || isnan(sample_time) || sample_time < eps
        Error_buf =[Error_buf,'Value for "sample time" is not correct'];
    else
        is_valid = is_valid+1;
    end 

    desc = get(obj_frame{9}, 'String'); % no check on it    


    % Should we try to automaticaly initialize the new system ?
    
    [input_size status] = str2num(get(obj_frame{12}, 'String'));
    if status && ~isnan(input_size) && input_size > 0
        is_valid = is_valid+1;
    else
        Error_buf =[Error_buf,'Value for "Input size" is not correct'];
    end 
    
    [output_size status] = str2num(get(obj_frame{14}, 'String'));
    if status && ~isnan(output_size) && output_size > 0 
        is_valid = is_valid+1;
    else
        Error_buf =[Error_buf,'Value for "Output size" is not correct'];
    end 
    
    [default_order status] = str2num(get(obj_frame{16}, 'String'));
    if status && ~isnan(default_order) && default_order > 0
        is_valid = is_valid+1;
    else
        Error_buf =[Error_buf,'Value for "Continuous states order " is not correct'];
    end         

    
    if is_valid == 6
        % It's ok; we can initialize the new system
       
            % All parameters have been filled in 
            SysHybride('init', 'new_auto', [automate_size, events_size, sample_time, ...
                       input_size, output_size, default_order]);
        

        SysHybride('set_description', desc);
        %empty the frame
        GUI_right_frame('clean');

        %update the info box
        GUI_left_frame('set_info', '', 1);

        %allow the new system to be saved (even if it is not fully
        %specified
        GUI_left_frame('update_btn');

    else
        Error_buf =[Error_buf,'******************************************* '];
        Error_buf =[Error_buf,'***Please fill in all the gaps correctly*** '];
        Error_buf =[Error_buf,'******************************************* '];
        errordlg(Error_buf,'Error');
    end