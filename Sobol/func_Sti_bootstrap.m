function Sti=func_Sti_bootsrap(func_temp,func_base,repetition_of_sampling)

% Calculation of sensitivity indices

V_x=0;
Ex2=0;
E=0;

% Initialize matrices

for w=1:repetition_of_sampling       

    Ex2=Ex2+(func_base(w))^2/repetition_of_sampling;       
    E=E+func_base(w)/repetition_of_sampling;    
    
    V_x=V_x+(func_base(w)-func_temp(w))^2/(2*repetition_of_sampling);        

end

V=Ex2-E^2;
Sti=V_x/V;