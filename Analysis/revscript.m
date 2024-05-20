% compute and display cost corresponding to given threshold
phi = 0.1:0.1:0.9;
rho = 0.5;
for i = 1:9
   C = (2*rho*(1-rho)*(1-phi(i))*(1-rho*(1-phi(i)))+2*rho^2*phi(i)*(1-phi(i)))/(2*(1-rho)*(1-rho*(1-phi(i)))^2)-rho*(1-phi(i));
   fprintf('phi = %.1f C = %.5f\n',phi(i),C)
end