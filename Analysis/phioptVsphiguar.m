% compare phi opt for max, phi guar for guarenteed for rho between .01, .99 and K between
% 2,52

rhovals = .01:.02:.99;
Kvals = 3:52;
max = zeros(50,50);
guar = zeros(50,50);

for i = 1:50
    rho = rhovals(i);
    for j = 1:50
        K = Kvals(j);
        % compute phiopt for R_HPR max
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
        max(i,j) = phiopt;
        % compute phiguar for R_HPR guarenteed 
        guar(i,j) = ((K-2)*(rho-1)^2)/(rho*(2+rho*(K-2)));
    end
end
%%
% Plot difference
diff = max - guar;
figure(1)
set(gca, 'fontsize',14)
view(45,45)
surf(rhovals,Kvals(5:50),diff(:,5:50))
xlabel('$$\rho$$','Interpreter','latex')
ylabel('$$K$$','Interpreter','latex')
zlabel('$$\phi^{opt}* - \phi^{guar}$$','Interpreter','latex')