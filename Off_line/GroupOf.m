function  Grp= GroupOf(Mode)
    Grp = [];
    [n, groups] = diagnosables_groups();
    for k=1:n
        SubGroup = groups{k};
        for j=1:length(SubGroup)
            if SubGroup(j) == Mode
                Grp = k;
                return;
            else
              % Nothing TO DO  
            end
        end
    end
    if isempty(Grp) 
        Grp = NaN;
    end

end