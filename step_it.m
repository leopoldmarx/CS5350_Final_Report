function xout = step_it(func, xin, par, stepsize, dim)
 
% The function stepit is used to integrate a system of autonomous
% differential equations.
%
% It performs a numerical integration over a time 'stepsize' of a
% specified function, 'func', using a 4th order Runge-Kutta scheme 
% (see, for example, Press et al, 1986. Numerical Recipes in FORTRAN, 
% Cambridge University Press).
%
% Useage;
% stepit('func', xin, par, stepsize, dim)
%
% where func is the name of the function to be integrated, xin is the
% current state of the system, par contains any necessary parameters, 
% stepsize is the integration step size, and dim is the number of ODEs.
%
% You would normally include this function in a loop.
 
x = xin;
f = feval(func, x, par, dim);
 
c1 = stepsize .* f;
x = xin + c1 /2;
f = feval(func, x, par, dim);
 
c2 = stepsize .* f;
x = xin + c2 /2;
f = feval(func, x, par, dim);
 
c3 = stepsize .* f;
x = xin + c3;
f = feval(func, x, par, dim);
 
c4 = stepsize .* f;
xout = xin + (c1 + 2.*c2 + 2.*c3 + c4)./6;