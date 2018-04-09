function Sij=func_Sij_bootsrap(func_temp_i,func_temp_j, func_base,repetition_of_sampling)

% Calculation of sensitivity indices

V_2nd=0;
Ex2=0;
E=0;

% Initialize matrices

for w=1:repetition_of_sampling       

    Ex2=Ex2+(func_base(w))^2/repetition_of_sampling;       
    E=E+func_base(w)/repetition_of_sampling;    
    
    V_2nd=V_2nd+(func_temp_i(w)-func_temp_j(w))^2/(2*repetition_of_sampling);

end

V=Ex2-E^2;
Sij=V_2nd/V;

            