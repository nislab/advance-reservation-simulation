rho = 0.001:0.001:0.999; 
NP = zeros(length(rho),1);
HPR = zeros(length(rho),1);
for i = 1:length(rho)
   p = rho(i);
   if p < 0.66666
       NP(i) = p^3/(8*(1-p)^2);
   else
       NP(i) = (p*(2*p-1))/(2*(1-p));
   end
   phiopt = 0;
   HPR(i) = (p*(1-p)*(1-phiopt)*(1-p*(1-phiopt))+(1/2)*p^2*phiopt*(1-phiopt))/((1-p*(1-phiopt))^2*(1-p)) - p*(1-phiopt);   
end
F = HPR - NP;
sum(F < 0)