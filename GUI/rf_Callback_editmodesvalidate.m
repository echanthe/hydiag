function return_value = rf_Callback_editmodesvalidate(source, eventdata, obj_frame, mode_n)
    'ask for validation'
    is_valid = 0;

    %no check on the description
    desc = get(obj_frame{3}, 'String');

    % Validation for A-matrix
    % - need to be not empty but square
    %-> Apply matA
    matA = str2num(get(obj_frame{7}, 'String'));

    if isempty(matA) || size(matA, 1) ~= size(matA, 2)
        errordlg('Matrix A must be square (not empty).');
    else
        is_valid = is_valid + 1;


    % Validation for B-matrix
    % - need get_dyn_size rows
    % - if this is not the first matrix, check length cols match get_input_size; if not warn !
    %-> Apply matB
    matB = str2num(get(obj_frame{9}, 'String'));

    if isempty(matB) || size(matB,1) ~= length(matA)
        errordlg('Number of row not valid for B.');
    elseif mode_n > 1 && size(matB,2) ~= SysHybride('get_input_size')
        errordlg('Number of cols for B doesn''t satisfy the number of input.');
    else
        is_valid = is_valid + 1;
        %matB = str2num(obj_frame{9})


    % Validation for C-matrix
    % - need get_dyn_size cols
    % - check length rows match get_output_size; if not warn !
    %-> Apply matC
    matC = str2num(get(obj_frame{11}, 'String'));

    if isempty(matC) || size(matC,2) ~= length(matA)
        errordlg('Number of cols not valid for C.');
    elseif mode_n > 1 && size(matC,1) ~= SysHybride('get_output_size')
        errordlg('Number of rows for C doesn''t satisfy the number of output.');
    else
        is_valid = is_valid + 1; 

    % Validation for D-matrix
    % - need length rows match get_output_size
    % - need length cols match get_input_size
    %-> Apply matD
    matD = str2num(get(obj_frame{13}, 'String'));

    if isempty(matD) || size(matD,1) ~= SysHybride('get_output_size')
        errordlg('Number of cols for D doesn''t satisfy the number of input.');
    elseif size(matD,2) ~= SysHybride('get_input_size')
        errordlg('Number of rows for D doesn''t satisfy the number of output.');
    else
        is_valid = is_valid + 1; 

    % Validation for initial state 
    x0 = str2num(get(obj_frame{15}, 'String'));
    if isempty(x0) || size(x0,1) ~= length(matA) || size(x0,2) ~= 1
        errordlg('Initial state is not valid.');
    else
        is_valid = is_valid + 1;


    %Validation for next mode array
    %next_id = str2num(get(obj_frame{20}, 'String'));

%             if isempty(next_id) || sum(size(next_id) - [SysHybride('get_events_size') 1]) 
%                 errordlg(['Next modes must be an array of ' num2str(SysHybride('get_events_size')) ' cols.']);
%             elseif min(next_id) < 0 || max(next_id) > SysHybride('get_events_size')
%                 errordlg(['Next modes values must be in the range [0-' num2str(SysHybride('get_events_size')) '].']);
%             else    
        is_valid = is_valid + 1;

%            end % end of if next id
    end % end of if x0
    end % end of if matD
    end % end of if matC
    end % end of if matB
    end % end of if matA

    if is_valid == 6
        % data are valid we can store them
        SysHybride('set_matA', mode_n, matA);
        SysHybride('set_matB', mode_n, matB);                
        SysHybride('set_matC', mode_n, matC);
        SysHybride('set_matD', mode_n, matD); 
        SysHybride('set_x0', mode_n, x0);
        SysHybride('set_description', mode_n, desc);
        %SysHybride('set_next_id', mode_n, next_id);

        %display next mode or display validated mode ?
        GUI_right_frame('edit_modes', mode_n);
        return_value = 0;
    else
        return_value = -1;
    end