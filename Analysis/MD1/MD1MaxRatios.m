% compare ratios of max values of R_NP, R_PR, R_HPR for rho between .001, 
% .999 in an MD1 queue.

% vectors of rho values and empty vectors to hold max revenues under each
% policy
rhovals = .001:.001:.999;
R_NP = zeros(1,999);
R_PR = zeros(1,999);
R_HPR = zeros(1,999);

for i = 1:999
    rho = rhovals(i);
    % compute R_NP
    R_NP(i) = (rho^3)/(8*(1-rho)^2);
    % compute R_PR
    R_PR(i) = (rho^2)/(8*(1-rho)^2);
    % compute R_HPR
    if rho <= (3-3^(1/2))/2
        % monotone decreasing case, R_HPR max is R_HPR(0).
        R_HPR(i) = rho^2/(1-rho);
    else
        % unimodal, must solve numerically to determine where maximum is
        syms phi1
        % condition that must be statistisfied for phi to be where the max
        % value is
        eqn = (2*(1-phi1)*(1-rho)*(1-rho*(1-phi1))*(2-rho*(1-phi1)))/(1-2*phi1-rho*(1-phi1)) == 1;
        solphi = solve(eqn,phi1);
        solnumeric = vpa(solphi);
        x = size(solnumeric);
        n = 1;
        % get solution located within valid bounds
        while true
            phiopt = solnumeric(n);
            if phiopt >= 0 && phiopt <= 1
                break;
            end
            n = n+1;
            if n > x(1)
                phiopt = 0;
                break
            end
        end
        % phiopt found, compute R_HPR max
        R_HPR(i) = (2*rho*(1-rho)*(1-phiopt)*(1-rho*(1-phiopt))+rho^2*phiopt*(1-phiopt))/(2*(1-rho)*(1-rho*(1-phiopt))^2)-rho*(1-phiopt); 
    end
end
%%
% Plot quotients with respect to rho, both for larger view and to prove
% that ratios > 1 for all rho

discount1 = R_PR./R_NP ;
discount2 = R_HPR./R_PR;
%quot3 = R_HPR./R_NP;

figure(1)
hold on
set(gca, 'fontsize',16)
plot(rhovals, discount1, 'r--')
plot(rhovals, discount2, 'k')
%plot(rhovals, quot3, '-.')
%legend({'$$\frac{R^*_{PR}}{R^*_{NP}}$$','$$\frac{R^*_{HPR}}{R^*_{PR}}$$','$$\frac{R^*_{HPR}}{R^*_{NP}}$$'},'Interpreter','latex')
legend({'\textbf{Ratio of PR over NP}','\textbf{Ratio of HPR over PR}'},'Interpreter','latex', 'fontsize', 16)
xlabel('\textbf{System Load} $$\rho$$','Interpreter','latex', 'fontsize', 16, 'fontweight', 'bold')
ylabel('\textbf{Ratio of Revenues}','Interpreter','latex', 'fontsize', 16)
axis([0 1 0 20])
hold off

%%figure(2)
%%hold on
%%set(gca, 'fontsize',14)
%%plot(rhovals, quot1, '--')
%%plot(rhovals, quot2)
%plot(rhovals, quot3, '-.')
%%plot(rhovals, ones(999,1), ':')
%legend({'$$\frac{R^*_{PR}}{R^*_{NP}}$$','$$\frac{R^*_{HPR}}{R^*_{PR}}$$','$$\frac{R^*_{HPR}}{R^*_{NP}}$$'},'Interpreter','latex')
%%legend({'$$\frac{R^*_{PR}}{R^*_{NP}}$$','$$\frac{R^*_{HPR}}{R^*_{PR}}$$'},'Interpreter','latex')
%%xlabel('$$\rho$$','Interpreter','latex')
%%ylabel('Ratio of Max Revenues','Interpreter','latex')
%%axis([0.9 1 0.8 1.2])
%%hold off
