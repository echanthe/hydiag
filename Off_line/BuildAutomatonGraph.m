function BuildAutomatonGraph(fpng, Behavior,type)

    switch type
        case 'B', shape = 'circle';
        case 'D', shape = 'rectangle';
    end
            
    fdot = [ fpng(1:end-3) 'dot' ];
    fid = fopen(fdot, 'wt');
    
    fprintf(fid, 'digraph output {\n');
    fprintf(fid, '    rankdir=TB;\n');
    fprintf(fid, '    node [shape = %s];\n',shape);
    
    N_States = length(Behavior.States);
    %N_Events = length(Behavior.Events);

    labelcolor = 'blue';
    for i=1:N_States
       
        [N,M,Next_States] = find(Behavior.States(i).next_id);
        source = Behavior.States(i).name;
        fprintf(fid, '    %d  [label="%s" ]\n',Behavior.States(i).id,source);

        for j =1:length(Next_States)
            
            dest   = Behavior.States(Next_States(j)).name;
            label  = Behavior.Events(M(j)).name;
            
            fprintf(fid, '    %d->%d [label="%s" fontcolor="%s" ]\n',Behavior.States(i).id, Behavior.States(Next_States(j)).id,label, labelcolor);
        end
    end
    fprintf(fid, '}\n');
    
    if isunix
    system(['dot ' fdot ' -Tpng -o' fpng ' -K dot']);
    elseif ispc
        system(['dot.exe ' fdot ' -Tpng -o ' fpng ' -K dot']);
    end
end