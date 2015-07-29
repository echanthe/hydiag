function rf_Callback_editeventsdynamique(source, eventdata, obj_frame, event_n)
    'ask for validation of an event'
    check2=1;
    N_Output = SysHybride('get_output_size');
    check1 = SysHybride('get_event_commandable', event_n);
    if ~check1 
            
       
          
       for i=1:N_Output
          
           Min(i,1) =  str2num(get(obj_frame{2*(i+24)+1}, 'String'));
           Max(i,1) =  str2num(get(obj_frame{2*(i+24)}, 'String'));
           check2 = check2 *(Min(i,1) <= Max(i,1));
       end
      
       if check2
           SysHybride('set_dynamic', event_n,[Min Max]);
           SysHybride('get_dynamic', event_n)
       end
       
    else
         errordlg('This is a static event','Error');
         
         for i=1:N_Output 
         SysHybride('set_dynamic', i, [-Inf*ones( N_Output,1) Inf*ones( N_Output,1)]);
         end
         
    end
       
    
        %refresh screen
        GUI_right_frame('clean');
        GUI_right_frame('edit_automaton', event_n);

    
     
    end