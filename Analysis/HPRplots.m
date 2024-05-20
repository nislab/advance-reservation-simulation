%Compute and plot Max revenue M|D|1
rho = 0.001:0.001:0.999; 
HPR = zeros(length(rho),1);
for i = 1:length(rho)
   p = rho(i);
   if p < (3-sqrt(3))/2
       phiopt = 0;
   else
        syms phi
        eqn = (-2*p^3+2*p^2)*phi^3 + (6*p^3 - 12*p^2 + 6*p)*phi^2 +(-6*p^3 + 18*p^2 - 15*p + 2)*phi + (2*p^3 - 8*p^2 + 9*p - 3) == 0;
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
   HPR(i) = (p*(1-p)*(1-phiopt)*(1-p*(1-phiopt))+(1/2)*p^2*phiopt*(1-phiopt))/((1-p*(1-phiopt))^2*(1-p)) - p*(1-phiopt);   
end


figure(1)
hold on
xlabel('\rho')
ylabel('Revenue')
title('R* per load \rho, M|D|1-HPR')
xlim([0 0.9])
plot(rho,HPR)


% Compute and plot Max Guarenteed Revenue M|D|1
gHPR = zeros(length(rho),1);
for i = 1:length(rho)
   p = rho(i);
   phiopt = 0;
   gHPR(i) = (p*(1-p)*(1-phiopt)*(1-p*(1-phiopt))+(1/2)*p^2*phiopt*(1-phiopt))/((1-p*(1-phiopt))^2*(1-p)) - p*(1-phiopt);   
end

figure(2)
hold on
xlabel('\rho')
ylabel('Revenue')
title('R** per load \rho, M|D|1-HPR')
xlim([0 0.9])
plot(rho,gHPR)


% Compute and Plot PoC M|D|1
pocHPR = HPR./gHPR;
figure(3)
hold on
xlabel('\rho')
ylabel('PoC')
title('Price of Conservatism per load \rho, M|D|1-HPR')
xlim([0 0.9])
plot(rho,pocHPR)

%%
%Compute and plot Max revenue M|M|1
rho = 0.001:0.001:0.999; 
HPR = zeros(length(rho),1);
for i = 1:length(rho)
   p = rho(i);
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


figure(1)
hold on
xlabel('\rho')
ylabel('Revenue')
title('R* per load \rho, M|M|1-HPR')
xlim([0 0.9])
plot(rho,HPR)


% Compute and plot Max Guarenteed Revenue M|M|1
gHPR = zeros(length(rho),1);
for i = 1:length(rho)
   p = rho(i);
   phiopt = 0;
   gHPR(i) = (p*(1-p)*(1-phiopt)*(1-p*(1-phiopt))+p^2*phiopt*(1-phiopt))/((1-p*(1-phiopt))^2*(1-p)) - p*(1-phiopt);   
end

figure(2)
hold on
xlabel('\rho')
ylabel('Revenue')
title('R** per load \rho, M|M|1-HPR')
xlim([0 0.9])
plot(rho,gHPR)


% Compute and Plot PoC M|M|1
pocHPR = HPR./gHPR;
figure(3)
hold on
xlabel('\rho')
ylabel('PoC')
title('Price of Conservatism per load \rho, M|M|1-HPR')
xlim([0 0.9])
plot(rho,pocHPR)

%%
%Compute and plot Max revenue M|G|1, K=3
rho = 0.001:0.001:0.999; 
HPR = zeros(length(rho),1);
for i = 1:length(rho)
   p = rho(i);
   if p < 0.177124
       phiopt = 0;
   else
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
   end
   HPR(i) = (p*(1-p)*(1-phiopt)*(1-p*(1-phiopt))+(3/2)*p^2*phiopt*(1-phiopt))/((1-p*(1-phiopt))^2*(1-p)) - p*(1-phiopt);   
end


figure(1)
hold on
xlabel('\rho')
ylabel('Revenue')
title('R* per load \rho, M|G|1-HPR K=3')
xlim([0 0.9])
plot(rho,HPR)


% Compute and plot Max Guarenteed Revenue M|G|1, K=3
gHPR = zeros(length(rho),1);
for i = 1:length(rho)
   p = rho(i);
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
   gHPR(i) = (p*(1-p)*(1-phiopt)*(1-p*(1-phiopt))+(3/2)*p^2*phiopt*(1-phiopt))/((1-p*(1-phiopt))^2*(1-p)) - p*(1-phiopt);   
end

figure(2)
hold on
xlabel('\rho')
ylabel('Revenue')
title('R** per load \rho, M|G|1-HPR K=3')
xlim([0 0.9])
plot(rho,gHPR)


% Compute and Plot PoC M|G|1, K=3
pocHPR = HPR./gHPR;
figure(3)
hold on
xlabel('\rho')
ylabel('PoC')
title('Price of Conservatism per load \rho, M|G|1-HPR K=3')
xlim([0 0.9])
plot(rho,pocHPR)
