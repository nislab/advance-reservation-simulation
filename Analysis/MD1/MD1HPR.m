rho = 0.65:0.03:0.98;
AnsGrid = zeros(length(rho),5);
for i = 1:length(rho)
    p = rho(i);
    syms phi
    eqn = (-2*p^3+2*p^2)*phi^3 + (6*p^3 - 12*p^2 + 6*p)*phi^2 +(-6*p^3 + 18*p^2 - 15*p + 2)*phi + (2*p^3 - 8*p^2 + 9*p - 3) == 0;
    solphi = solve(eqn,phi);
    solnumeric = vpa(solphi);
    phiopt = solnumeric(1);
    R = (p*(1-p)*(1-phiopt)*(1-p*(1-phiopt))+(1/2)*p^2*phiopt*(1-phiopt))/((1-p*(1-phiopt))^2*(1-p)) - p*(1-phiopt);
    R0 = p/(1-p) - p;
    PoC = R/R0;
    AnsGrid(i,:) = [p,phiopt,R,R0,PoC];
end
