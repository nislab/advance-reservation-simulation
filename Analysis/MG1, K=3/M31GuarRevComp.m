rho = 0.001:0.001:0.999; 
NP = zeros(length(rho),1);
HPR = zeros(length(rho),1);
for i = 1:length(rho)
   p = rho(i);
   if p < 0.66666
       NP(i) = (3*p^3)/(8*(1-p)^2);
   else
       NP(i) = (3*p*(2*p-1))/(2*(1-p));
   end
   if p < 0.177124
       phiopt = 0;
   elseif p < 0.530
        syms phi
        eqn = (-2*p^3+2*p^2)*phi^3 + (6*p^3 - 12*p^2 + 6*p)*phi^2 +(-6*p^3 + 18*p^2 - 13*p - 2)*phi + (2*p^3 - 8*p^2 + 7*p - 1) == 0;
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
   else
        syms phi
        eqn = ((1-p)*(1-p*(1-phi))+(3/2)*p*phi)/((1-p)*(1-p*(1-phi))^2) - 1 == (3*p)/(2*(1-p));
        solphi = solve(eqn, phi);
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
   HPR(i) = (p*(1-p)*(1-phiopt)*(1-p*(1-phiopt))+(3/2)*p^2*phiopt*(1-phiopt))/((1-p*(1-phiopt))^2*(1-p)) - p*(1-phiopt);   
end
F = HPR - NP;
sum(F < 0)