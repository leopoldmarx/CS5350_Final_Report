function lorenz = lorenzeq(x, par, dim)
 
% This function calculates the values of the ODEs for use
% in a fourth order Runge-Kutta integration scheme.
 
x_dot  = -par(1)*x(1) + par(1)*x(2);
y_dot  = -x(1)*x(3) + par(2)*x(1) - x(2);
z_dot  =  x(1)*x(2) - par(3)*x(3);
lorenz = [x_dot y_dot z_dot];