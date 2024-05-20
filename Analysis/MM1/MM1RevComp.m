rho = 0.001:0.001:0.999; 
NP = zeros(length(rho),1);
HPR = zeros(length(rho),1);
for i = 1:length(rho)
   p = rho(i);
   NP(i) = p^3/(4*(1-p)^2);
   if p < 0.381966
       phiopt = 0;
   else
        syms phi
        eqn = (-2*p^3+2*p^2)*phi^3 + (6*p^3 - 12*p^2 + 6*p)*phi^2 +(-6*p^3 + 18*p^2 - 14*p)*phi + (2*p^3 - 8*p^2 + 8*p - 2) == 0;
        solphi = solve(eqn,phi);
        solnumeric = vpa(solphi);
        j = 1;
        while true
            phiopt = solnumeric(j);
            if phiopt >= 0 && phiopt <= 1
                break;
            end
            j = j+1;
        end
   end
   HPR(i) = (p*(1-p)*(1-phiopt)*(1-p*(1-phiopt))+p^2*phiopt*(1-phiopt))/((1-p*(1-phiopt))^2*(1-p)) - p*(1-phiopt);   
end
F = HPR - NP;
sum(F < 0)