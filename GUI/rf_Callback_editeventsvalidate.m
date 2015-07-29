function rf_Callback_editeventsvalidate(source, eventdata, obj_frame, event_n)
    'ask for validation of an event'
    is_valid = 0;

    %nocheck on the description
    desc = get(obj_frame{3}, 'String');

    obs= get(obj_frame{4}, 'Value');
    is_a_fault = get(obj_frame{5}, 'Value');
%     if is_a_fault
%         PrognoserSet('init',event_n);
%     end
    is_commandable = get(obj_frame{8}, 'Value');

    %Validation for is a fault (can be set only if observable isn't
    %checked
    if obs && is_a_fault
        errordlg('An event can''t be both observable and a fault. Uncheck one.');
    else
        is_valid = is_valid + 1;
    end

    %Validation for time schedule
    time_schedule = str2num(get(obj_frame{7}, 'String'));
    if isempty(time_schedule) && is_commandable
        warndlg('No occurence of this event has been scheduled. This is permitted but strange.', 'Time Schedule');
    end

    if is_valid == 1
        %Store the data
        SysHybride('set_event_name', event_n, desc);
        SysHybride('set_event_obs', event_n, obs);
        SysHybride('set_event_fault', event_n, is_a_fault);
        SysHybride('set_event_commandable', event_n, is_commandable);
        SysHybride('set_event_schedule', event_n, time_schedule);

        %refresh screen
        GUI_right_frame('clean');
        GUI_right_frame('edit_events', event_n);

    else
        % Keep current frame
    end