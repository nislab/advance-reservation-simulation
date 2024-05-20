% compare R_PR, R_HPR for rho between .01, .99 and K between 1,50

rhovals = .01:.02:.99;
Kvals = 1:50;
R_PR = zeros(50,50);
R_HPR = zeros(50,50);

for i = 1:50
    rho = rhovals(i);
    for j = 1:50
        K = Kvals(j);
        % compute R_PR
        R_PR(i,j) = (K*rho^2)/(8*(1-rho)^2);
        % compute R_HPR
        syms phi1
        eqn = (2*(1-phi1)*(1-rho)*(1-rho*(1-phi1))*(2-rho*(1-phi1)))/(1-2*phi1-rho*(1-phi1)) == K;
        solphi = solve(eqn,phi1);
        solnumeric = vpa(solphi);
        x = size(solnumeric);
        n = 1;
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
        R_HPR(i,j) = (2*rho*(1-rho)*(1-phiopt)*(1-rho*(1-phiopt))+K*rho^2*phiopt*(1-phiopt))/(2*(1-rho)*(1-rho*(1-phiopt))^2)-rho*(1-phiopt); 
    end
end
%%
% Plot difference
diff = R_HPR - R_PR;
figure(1)
set(gca, 'fontsize',14)
view(45,45)
surf(Kvals,rhovals,diff)
ylabel('$$\rho$$','Interpreter','latex')
xlabel('$$K$$','Interpreter','latex')
zlabel('$$R_{HPR}^* - R_{PR}^*$$','Interpreter','latex')