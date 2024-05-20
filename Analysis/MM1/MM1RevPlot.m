%Compute and plot Max revenue
rho = 0.001:0.001:0.999; 
NP = zeros(length(rho),1);
PR = zeros(length(rho),1);
HPR = zeros(length(rho),1);
for i = 1:length(rho)
   p = rho(i);
   NP(i) = p^3/(4*(1-p)^2);
   PR(i) = p^2/(4*(1-p)^2);
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

%%

figure(1)
hold on
xlabel('\rho')
ylabel('Revenue')
title('Max Revenue per load \rho, K=2')
plot(rho,NP,rho,PR,rho,HPR)
xlim([0 0.8])
legend('NP','PR','HPR')

%%

% Compute and plot Max Guarenteed Revenue
gNP = zeros(length(rho),1);
gPR = zeros(length(rho),1);
gHPR = zeros(length(rho),1);
for i = 1:length(rho)
   p = rho(i);
   if p < 0.66666
       gNP(i) = p^3/(4*(1-p)^2);
       gPR(i) = p^2/(4*(1-p)^2);
   else
       gNP(i) = (p*(2*p-1))/((1-p));
       gPR(i) = (2*p-1)/(1-p);
   end
   phiopt = 0;
   gHPR(i) = (p*(1-p)*(1-phiopt)*(1-p*(1-phiopt))+p^2*phiopt*(1-phiopt))/((1-p*(1-phiopt))^2*(1-p)) - p*(1-phiopt);   
end

%%
figure(2)
hold on
xlabel('\rho')
ylabel('Revenue')
title('Maximum Guarenteed Revenue per load \rho, K=2')
plot(rho,gNP,rho,gPR,rho,gHPR)
xlim([0 0.8])
legend('NP','PR','HPR')

%%

% Compute and Plot PoC
pocNP = NP./gNP;
pocPR = PR./gPR;
pocHPR = HPR./gHPR;
figure(3)
hold on
xlabel('\rho')
ylabel('PoC')
title('Price of Conservatism per load \rho')
plot(rho,gNP,rho,gPR,rho,gHPR)
ylim([0 10])
legend('NP','PR','HPR')

