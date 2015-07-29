%% Test of diagnosability
function are_diagnosable_matrix = are_diagnosable()
    % matrix that store weather qi and qj are diagnosable 
    % (values are on the LOWER part)
    are_diagnosable_matrix=zeros(SysHybride('get_automate_size'));

    %diagnosability is computed for the highest order of parity space
    p = max(Diagnoser('get_ARR_order_optimal'));

    for i=1:SysHybride('get_automate_size')
        [W1,W2,Op1,Dp1] = calcul_RRAs_n(SysHybride('get_matA',i), SysHybride('get_matB',i), SysHybride('get_matC',i), SysHybride('get_matD',i), p);
        
        for j=1:SysHybride('get_automate_size')

            %compute OBS matrix
            [W1,W2,Op2,Dp2]=calcul_RRAs_n(SysHybride('get_matA',j), SysHybride('get_matB',j), SysHybride('get_matC',j), SysHybride('get_matD',j), p);

            %evaluate diagnosability with rank considerations
            if (rank(Op1) == rank(Op2)) && (rank(Op2) == rank([Op1 Op2 Dp1-Dp2]))
                %modes aren't diagnosable
                are_diagnosable_matrix(i,j) = 0;
            else
                %modes are diagnosable
                are_diagnosable_matrix(i,j) = 1;
            end
        end
    end

    %tempo /!\
    %are_diagnosable_matrix = [0 1 0 1; 1 0 1 0; 0 1 0 1; 1 0 1 0];
    %are_diagnosable_matrix = [ 0 0 1 1; 0 0 1 1; 1 1 0 0; 1 1 0 0];
    %are_diagnosable_matrix = [ 0 0 0 0; 0 0 0 0; 0 0 0 0; 0 0 0 0];
