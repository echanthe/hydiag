% Return cells contening a group of diagnosable states per cell
function [n, return_groups] = diagnosables_groups()
    function return_value = sort_groups(input)
        buff = [];
        for i=1:length(input)
            buff(i) = length(input{i});
        end
        [a, b] = sort(buff);
        return_value = input(b); 
    end
        
    function return_value = simplify_groups(input)
        %check intersection of any pairs of group is empty; if not, remove
        %group with smaller cardinal
        break_this_group = false;
        index_to_delete = [];
        
        for group1_i = 1:(length(input)-1)
            group1 = input{group1_i};
            
            for group2 = input(length(input):-1:group1_i+1)
                group2 = group2{1};
%                 fprintf('>>> compare [%s] with [%s]\n', num2str(group1), num2str(group2));

                for k=group1
                    if sum(group2==k) > 0
                        index_to_delete = [index_to_delete group1_i];
%                         fprintf('   >>> delete !\n');
                        break_this_group = true;
                        break
                    end
                end
                if break_this_group
                    break_this_group=false;
                    break
                end
            end

        end

        %clean
        input(index_to_delete) = '';

        return_value = input;
    end


    N = SysHybride('get_automate_size');
    
    %build pre-groups
    pre_groups = {};
    buff = are_diagnosable();
    %buff = [0 0 1 1; 0 0 1 1; 1 1 0 0; 1 1 0 0];

    for l=1:N
        %fetch groups by lines (ie position of 0)
        pre_groups{l} = find(buff(l,1:l)==0);
    end
    
    %start by sort groups by cardinal size
    groups = sort_groups(pre_groups);

    %simplify (delete groups included in other group)
    groups = simplify_groups(groups);
    

    return_groups = groups;
    n=length(groups);
    
%     %display
%     fprintf('\n***** Building diagnosability groups *****\n');
%     fprintf('   %d groups have been built\n', n);
%     for gid=1:n
%         fprintf('   gid=%d :  %s ;', gid, mat2str(groups{gid}));
%     end
%     fprintf('\n');
    
end