% L63 integrates the Lorenz equations.
%
% This is a self-contained program that integrates the Lorenz
% equations and plots the resulting attractor.  The code is not
% interactive, but the initial conditions, parameters, and
% integration time scales are easily changed by hand.
 
% The Lorenz equations are:
%     x_dot = -sigma*x + sigma*y
%     y_dot = -x*z + r*x - y
%     z_dot =  x*y - b*z
%
% The parameters sigma, r, and b are set at their default
% values of 10, 28, and 8/3, respectively.
 
% Written by Jim Hansen, August 2002 for use by 12.800 students.
 
% Specify the dimension of the system
dim = 3;
 
% Specify the initial conditions
%   x = [10 20 30];
% x=[5,7, 9];
 x=[1,2,1];
%  x=[1,1,1];
%   x=[0,0,0]
XLOW = -50;
XHIGH = 50;
% Specify the parameter values (sigma, r, and b)
   par = [10 28 8/3];
%    par = [10 0.5 8/3];
%    par= [4 26 8/3];
 
% Specify the integration step size
h = 0.01;
 
% Specify the length of integration
 steps = 2^14;
% steps = 10;
% steps = 50;

%Number of data sets
N = 2000;
data = zeros(N, steps);
state=zeros(steps,3);
%x = xinit;
FID = fopen('16384x1,2,1.csv', 'w');
if FID == -1, error('Cannot create file.'); end
%for k=1:N 
    %xinit = (XHIGH-XLOW)*rand(1,dim) + XLOW;
    %x = xinit;
    
    % Integrate the equations over length steps to remove any transient behavior
    for i=1:steps
        xout=step_it('lorenzeq',x,par,h,dim);
        x=xout;
    end

    % Integrate the equations over length steps and record state for plotting
    for i=1:steps
        xout=step_it('lorenzeq',x,par,h,dim);
        state(i,:)=xout;
        fprintf(FID, '%g,%g,%g\n',xout(1),xout(2),xout(3));
        x=xout;
    end
%     V = state(:)';
%     % x data
%     fprintf(FID, '%g,', xinit);
%     % parameters
%     fprintf(FID, '%g,', par);
%     % points on graph
%     fprintf(FID, '%g,', V(1:end-1));
%     fprintf(FID, '%g\n',V(steps*dim));
%end


fclose(FID);

% Make a pretty picture
figure;plot(state(:,1),state(:,3),'.');
title('The Lorenz attractor');
xlabel('x');ylabel('y');

figure
rotate3d on
scatter3(state(:,1),state(:,2),state(:,3),'.y','MarkerEdgeColor','k')
colormap(jet)
% 
% %Save picture to disk
% print -depsc lorenz.ps
% sprintf('%s','The plot is saved as lorenz.ps')