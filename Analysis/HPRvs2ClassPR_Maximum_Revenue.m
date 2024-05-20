K = [1:50]; % service variance
RHO = 0.001:0.001:0.999; % traffic load

R_HPR = zeros(50,999); % HPR
R_PR2 = zeros(50,999); % PR

for j=1:50
    k = K(j);
    for i=1:999
        rho = RHO(i);
        if k < 4 && rho <= (3-sqrt(2*k+1))/2
            R_HPR(j,i) = rho^2/(1-rho);
        else
            syms phi1
            eqn = (2*(1-phi1)*(1-rho)*(1-rho*(1-phi1))*(2-rho*(1-phi1)))/(1-2*phi1-rho*(1-phi1)) == 1;
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
            R_HPR(j,i) = (2*rho*(1-rho)*(1-phiopt)*(1-rho*(1-phiopt))+rho^2*phiopt*(1-phiopt))/(2*(1-rho)*(1-rho*(1-phiopt))^2)-rho*(1-phiopt);
        end
        if k > 4 && rho < (3/2)-(1/2)*sqrt((5*k-2)/(k-2))
            R_PR2(j,i) = (2*(k-2)-rho*(3*k-4))/(2*(1-rho)) - (k-2)*sqrt((k-2-2*rho*(k-1))/((k-2)*(1-rho)));
        else
            R_PR2(j,i) = (k*rho^2+(2-k)*rho^2*(1-rho))/(2*(1-rho)^2);
        end
    end
end