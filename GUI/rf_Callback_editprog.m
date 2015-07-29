function rf_Callback_editprog(source, eventdata, obj_frame, N_fault,N_mode)
    'ask for validation of an fault weibull parameters'
    global Prognoser
   
   
   Beta =  str2num(get(obj_frame{30}, 'String'));
   Eta  =  str2num(get(obj_frame{31}, 'String'));
   Gama =  str2num(get(obj_frame{32}, 'String'));
   Pf0  =  str2num(get(obj_frame{33}, 'String'));
   Pfmax=  str2num(get(obj_frame{34}, 'String'));

    
   if (isa(Beta,'double') && isa(Eta,'double') && isa(Gama,'double') && isa(Pf0,'double') && isa(Pfmax,'double'))

    
    
        Prognoser.fault(N_fault).Pfmax = Pfmax;
        Prognoser.fault(N_fault).Pf    = Pf0;
        Prognoser.fault(N_fault).age    = Pf0;

        
        Prognoser.fault(N_fault).Beta(N_mode)   = Beta;
        Prognoser.fault(N_fault).Eta (N_mode)   = Eta;
        Prognoser.fault(N_fault).Gama (N_mode)  = Gama;
        Prognoser.fault(N_fault).GamaPr (N_mode)= Gama;
    
   else
     errordlg('Verify your parameters value','Error');
   end

        GUI_right_frame('clean');
        GUI_right_frame('edit_prognosis_parameters', N_fault,N_mode);
    
     
    end