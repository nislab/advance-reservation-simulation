% compare ratios of max values of R_PR, R_HPR for rho between .001, 
% .999, and K between 1 and 50 in an MG1 queue.

% vectors of rho values and empty vectors to hold max revenues under each
% policy
rhovals = .01:.02:.99;
Kvals = 1:50;
R_PR = zeros(50,50);
R_HPR = zeros(50,50);

for i = 1:50
    rho = rhovals(i);
    for j = 1:50
        K = Kvals(j);
        % compute R_PR
        R_PR(j,i) = (K*rho^2)/(8*(1-rho)^2);
        % compute R_HPR
        if (K < 4) && (rho <= (3-(2*K+1)^(1/2))/2)
            % monotone decreasing case, R_HPR max is R_HPR(0).
            R_HPR(j, i) = rho^2/(1-rho);
        else
            % unimodal, must solve numerically to determine where maximum is
            syms phi1
            % condition that must be statistisfied for phi to be where the max
            % value is
            eqn = (2*(1-phi1)*(1-rho)*(1-rho*(1-phi1))*(2-rho*(1-phi1)))/(1-2*phi1-rho*(1-phi1)) == K;
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
            R_HPR(j, i) = (2*rho*(1-rho)*(1-phiopt)*(1-rho*(1-phiopt))+K*rho^2*phiopt*(1-phiopt))/(2*(1-rho)*(1-rho*(1-phiopt))^2)-rho*(1-phiopt); 
        end
    end
end
%%
% Plot quotients with respect to rho, both for larger view and to prove
% that ratios > 1 for all rho

discount = R_HPR./R_PR;

figure(1)
set(gca, 'fontsize', 16, 'fontweight', 'bold')
surf(Kvals,rhovals,discount)
xlabel('\textbf{Variance Parameter} $$\mathbf{K}$$','Interpreter','latex', 'fontsize', 16)
ylabel('\textbf{System Load} $$\mathbf{\rho}$$','Interpreter','latex', 'fontsize', 16)
zlabel('\textbf{Ratio of Revenues}','Interpreter','latex', 'fontsize', 16)
hold off

