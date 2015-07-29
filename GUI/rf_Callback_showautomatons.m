function rf_Callback_showautomatons(source, eventdata, obj_frame)
   


fpng_behavior  = [pwd '/Results/behavior_automaton.png'];    
fpng_diagnoser = [pwd '/Results/diagnoser_automaton.png'];

persistent figure1 figure2
global Behavior
global Diagnoser 
global Sys_hybride


Behavior = ComputeBehaviorAutomaton();    
Diagnoser = ComputeDiagnoserAutomaton(fpng_diagnoser, Behavior,Sys_hybride);
if ~isempty(figure1) 
   try
       close (figure1) 
   end
end
if ~isempty(figure2) 
    try
        close (figure2)
    end
end
        

BuildAutomatonGraph(fpng_behavior, Behavior,'B');
figure1=figure('Color', 'white','Name', 'View automatons','Toolbar','none');
image(imread(fpng_behavior));
title('DES Automaton enriched with residuals', 'FontSize', 12, 'FontWeight', 'bold');
axis off
axis image



BuildAutomatonGraph(fpng_diagnoser, Diagnoser,'D');
figure2=figure('Color', 'white','Name', 'View automatons','Toolbar','none');
image(imread(fpng_diagnoser));
title('The diagnoser of the hybrid system built from the behavior automaton', 'FontSize', 12, 'FontWeight', 'bold');
axis off
axis image

end