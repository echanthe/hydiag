function  rf_Callback_show_hybridsystem( source, eventdata, obj_frame ) 
persistent figure1 

global Sys_hybride          
global Behavior             
global Diagnoser            


    hybridSystemFileName = 'Current_system.mat';
    
    if isunix
       pathname = strcat('Off_line/', hybridSystemFileName); 
       elseif ispc
           pathname = strcat(pwd,'\Off_line\', hybridSystemFileName); 
    end
    
    SysHybride('save',pathname);
    hybridSystem = load(pathname);
    


    hybridAutomaton =...
    createHybridAutomatonFromHybridSystem(hybridSystem);

    figureTitle = 'Underlying discrete event system';
    displayBehaviorAutomaton(hybridAutomaton,figureTitle);
   
end

