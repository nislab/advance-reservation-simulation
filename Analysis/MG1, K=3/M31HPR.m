rho = 0.18:0.01:0.24;
AnsGrid1 = zeros(length(rho),3);
for i = 1:length(rho)
    p = rho(i);
    syms phi
    eqn = (-2*p^3+2*p^2)*phi^3 + (6*p^3 - 12*p^2 + 6*p)*phi^2 +(-6*p^3 + 18*p^2 - 13*p - 2)*phi + (2*p^3 - 8*p^2 + 7*p - 1) == 0;
    solphi = solve(eqn,phi);
    solnumeric = vpa(solphi);
    phiopt = solnumeric(1);
    R = (p*(1-p)*(1-phiopt)*(1-p*(1-phiopt))+(3/2)*p^2*phiopt*(1-phiopt))/((1-p*(1-phiopt))^2*(1-p)) - p*(1-phiopt);
    AnsGrid1(i,:) = [p,phiopt,R];
end

rho = 0.26:0.04:0.98;
AnsGrid2 = zeros(length(rho),7);
for i = 1:length(rho)
    p = rho(i);
    syms phi
    eqn = (-2*p^3+2*p^2)*phi^3 + (6*p^3 - 12*p^2 + 6*p)*phi^2 +(-6*p^3 + 18*p^2 - 13*p - 2)*phi + (2*p^3 - 8*p^2 + 7*p - 1) == 0;
    solphi = solve(eqn,phi);
    solnumeric = vpa(solphi);
    phiopt = solnumeric(1);
    if p == 0.5
       phiopt = solnumeric(2); 
    end
    R = (p*(1-p)*(1-phiopt)*(1-p*(1-phiopt))+(3/2)*p^2*phiopt*(1-phiopt))/((1-p*(1-phiopt))^2*(1-p)) - p*(1-phiopt);
    C = ((1-p)*(1-p*(1-phiopt))+(3/2)*p*phiopt)/((1-p)*(1-p*(1-phiopt))^2) - 1;
    C1 = (3*p)/(2*(1-p));
    if C < C1
        R1 = R;
    else
        syms phi
        eqn = ((1-p)*(1-p*(1-phi))+(3/2)*p*phi)/((1-p)*(1-p*(1-phi))^2) - 1 == C1;
        solphi = solve(eqn, phi);
        solnumeric = vpa(solphi);
        phi1 = solnumeric(1);
        R1 = (p*(1-p)*(1-phi1)*(1-p*(1-phi1))+(3/2)*p^2*phi1*(1-phi1))/((1-p*(1-phi1))^2*(1-p)) - p*(1-phi1);
    end
    PoC = R/R1;
    AnsGrid2(i,:) = [p,phiopt,C,C1,R,R1,PoC];
end

rho = 0.532:0.0001:0.533;
AnsGrid3 = zeros(length(rho),7);
for i = 1:length(rho)
    p = rho(i);
    syms phi
    eqn = (-2*p^3+2*p^2)*phi^3 + (6*p^3 - 12*p^2 + 6*p)*phi^2 +(-6*p^3 + 18*p^2 - 13*p - 2)*phi + (2*p^3 - 8*p^2 + 7*p - 1) == 0;
    solphi = solve(eqn,phi);
    solnumeric = vpa(solphi);
    phiopt = solnumeric(1);
    if p == 0.5
       phiopt = solnumeric(2); 
    end
    R = (p*(1-p)*(1-phiopt)*(1-p*(1-phiopt))+(3/2)*p^2*phiopt*(1-phiopt))/((1-p*(1-phiopt))^2*(1-p)) - p*(1-phiopt);
    C = ((1-p)*(1-p*(1-phiopt))+(3/2)*p*phiopt)/((1-p)*(1-p*(1-phiopt))^2) - 1;
    C1 = (3*p)/(2*(1-p));
    if C < C1
        R1 = R;
    else
        syms phi
        eqn = ((1-p)*(1-p*(1-phi))+(3/2)*p*phi)/((1-p)*(1-p*(1-phi))^2) - 1 == C1;
        solphi = solve(eqn, phi);
        solnumeric = vpa(solphi);
        phi1 = solnumeric(1);
        R1 = (p*(1-p)*(1-phi1)*(1-p*(1-phi1))+(3/2)*p^2*phi1*(1-phi1))/((1-p*(1-phi1))^2*(1-p)) - p*(1-phi1);
    end
    PoC = R/R1;
    AnsGrid3(i,:) = [p,phiopt,C,C1,R,R1,PoC];
end