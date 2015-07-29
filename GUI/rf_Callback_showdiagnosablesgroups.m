function rf_Callback_showdiagnosablesgroups(source, eventdata, obj_frame)
    [n_groups, groups] = diagnosables_groups();
    buff = cell(1,n_groups+1 + 2 + SysHybride('get_automate_size'));
    buff{1} = 'Below are the diagnosables groups: ';
    
    for i=1:n_groups
        buff{i+1} = ['Group ' num2str(i) ' : ' mat2str(groups{i}) ] ;
    end
    
    buff{n_groups + 2} = '';
    buff{n_groups + 3} = 'For recall, names of the states: ';
    
    %Fetch names of states:
    for i=1:SysHybride('get_automate_size')
        buff{n_groups+3+i} = [num2str(i) ' : ' SysHybride('get_description', i) ];
    end
    
    msgbox(buff, 'Diagnosables groups');
    
end