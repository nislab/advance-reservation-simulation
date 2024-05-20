% compare R_PR, R_HPR for rho between .01, .99 and K between 2,51

rhovals = .01:.02:.99;
Kvals = 2:51;
R_PR = zeros(50,50);
R_HPR = zeros(50,50);

for i = 1:50
    rho = rhovals(i);
    for j = 1:50
        K = Kvals(j);
        % compute R_PR - guarenteed max dependant on rho
        if rho <= 2/3
            R_PR(i,j) = (K*rho^2)/(8*(1-rho)^2);
        else
            R_PR(i,j) = (K*(2*rho-1))/(2*(1-rho));
        end
        % compute R_HPR - guarenteed max dependant on rho, K
        % get phi_opt candidate
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
        %compare to value of C(1). Normalization is implict since both
        %values are multiplied by same constant 1/mu anyway
        C_phi = (2*(1-rho)*(1-rho*(1-phiopt))+K*rho*phiopt)/(2*(1-rho)*(1-rho*(1-phiopt))^2)-1;
        if C_phi > (K*rho)/(2*(1-rho))
            % C(phiopt) is in multi eq region, must update phiopt to be max
            % value in single eq region
            phiopt = ((K-2)*(rho-1)^2)/(rho*(2+rho*(K-2)));
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
surf(Kvals, rhovals, diff)
ylabel('$$\rho$$','Interpreter','latex')
xlabel('$$K$$','Interpreter','latex')
zlabel('$$R_{HPR}^{**} - R_{PR}^{**}$$','Interpreter','latex')