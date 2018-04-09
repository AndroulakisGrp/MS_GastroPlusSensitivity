function Si=func_Si(func_temp,func_aux,func_base,repetition_of_sampling)

% Calculation of sensitivity indices

VxNew=0;
Ex2=0;
E=0;

% Initialize matrices

for w=1:repetition_of_sampling       

    Ex2=Ex2+(func_base(w))^2/repetition_of_sampling;       
    E=E+func_base(w)/repetition_of_sampling;    
    
    VxNew = VxNew + func_aux(w)*(func_temp(w)-func_base(w))/repetition_of_sampling;
end

V=Ex2-E^2;
Si=VxNew/V;