K = 6;
rhovals = 0.1:0.1:0.9;

for i = 1:9
    rho = rhovals(i);
    if rho <= 2/3
        PR = (K*rho^2)/(8*(1-rho)^2);
    else
        PR = (K*(2*rho-1))/(2*(1-rho));
    end
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
        HPR = (2*rho*(1-rho)*(1-phiopt)*(1-rho*(1-phiopt))+K*rho^2*phiopt*(1-phiopt))/(2*(1-rho)*(1-rho*(1-phiopt))^2)-rho*(1-phiopt); 
    fprintf('rho = %.1f PR = %.4f HPR = %.4f\n',rho,PR,HPR)
end
