K = 6;
rhovals = 0.1:0.1:0.9;

for i = 1:9
   rho = rhovals(i);
   PR = (K*rho^2)/(8*(1-rho)^2);
   syms phi1
   eqn = (2*(1-phi1)*(1-rho)*(1-rho*(1-phi1))*(2-rho*(1-phi1)))/(1-2*phi1-rho*(1-phi1)) == K;
   solphi = solve(eqn,phi1);
   solnumeric = vpa(solphi);
   x = size(solnumeric);
   j = 1;
   while true
       phiopt = solnumeric(j);
       if phiopt >= 0 && phiopt <= 1
           break;
       end
       j = j+1;
       if j > x(1)
           phiopt = 0;
           break
       end
   end
   HPR = (2*rho*(1-rho)*(1-phiopt)*(1-rho*(1-phiopt))+K*rho^2*phiopt*(1-phiopt))/(2*(1-rho)*(1-rho*(1-phiopt))^2)-rho*(1-phiopt); 
   fprintf('rho = %.1f PR = %.4f HPR = %.4f\n',rho,PR,HPR)
end
