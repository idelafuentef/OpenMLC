% Flow Around a Cylinder (LBM)
%
% author: Rodrigo Castellanos. 
% Experimental Aerodynamics group at UC3M.
%
% 2D flow around a cylinder based on LBM solver.
%-----------------------------------------------------------------------------
clear all; clc; close all
% set(gcf, 'Position', get(0, 'Screensize'));
set(groot,'defaulttextinterpreter','latex');
set(groot,'defaultAxesTickLabelInterpreter','latex');
set(groot,'defaultLegendInterpreter','latex');
% set(0,'DefaultAxesXGrid','on')
% set(0,'DefaultAxesYGrid','on')

%%%%%% Flow definition %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
maxIter = 200000;               % Total number of time iterations.
Re      = 100;                   % Reynolds number.
nx      = 420;                  % Numer of lattice nodes.
ny      = 180;                  % Numer of lattice nodes.
ly      = ny-1;                 % Height of the domain in lattice units.
cx      = floor(nx/4);                 % Coordinates of the cylinder.
cy      = floor(ny/2);
r       = floor(ny/9);
uLB     = 0.04;                 % Velocity in lattice units.
nulb    = uLB*r/Re;             % Viscoscity in lattice units.
omega   = 1 / (3*nulb+0.5);     % Relaxation parameter.
[X,Y] = meshgrid(1:nx,1:ny);

% Remember:
% Sound speed: cs²=1/3·dx²/dt²
% Pressure: p = cs²/rho
% Viscosity: nu = dt·cs²·(1/omega-1/2)
% Reynolds: Re = u·r/nu

%%%%%% Lattice Constants %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Lattice velocities in the 2D lattice. We are using a D2Q9, that means:
% 2 dimensions with 9 possible vectors (north-east,east,south-east,north,origin,
% south,north-west,west,south-west)
v    = [ 1,  1;
    1,  0;
    1, -1;
    0,  1;
    0,  0;
    0, -1;
   -1,  1;
   -1,  0;
   -1, -1];
% Weight factor of each direction: to compensate for the different lengths of
% velocities v[i]:
t    = [ 1/36, 4/36, 1/36, 4/36, 16/36, 4/36, 1/36, 4/36, 1/36];
% Numbering the columns of the lattice:
col1 = [1, 2, 3];
col2 = [4, 5, 6];
col3 = [7, 8, 9];

%%%%%% Setup: cylindrical obstacle and velocity inlet with perturbation %%%%%%%
% Creation of a mask with 1/0 values, defining the shape of the obstacle.
% Definition of the obstacle location: circle of radius r and centered at
%(cx,cy). The function requires an x,y position as an input and it will return
%a true/false (1/0) value. True (1) corresponds to those positions that belongs
%to the obstacle. False (0) are the positions outside the obstacle """
for i=1:nx
    for j=1:ny
        obstacle(i,j)=((i-1)-cx)^2+((j-1)-cy)^2<r^2;
    end
end
% 
% figure(10)
% grid off
% contourf(X,Y,obstacle',75,'edgecolor','none')
% axis equal
        
% Initial velocity profile: almost zero,
%with a slight perturbation to trigger the instability.
for i=1:nx
    for j=1:ny
        for h=1:2
            vel(h,i,j)= (1-(h-1)) * uLB * (1 + 1e-1*sin(((j-1)/ly)*2*pi));
        end
    end
end


% Initialization of the populations at equilibrium with the given velocity.
fin = equilibrium(1,vel,nx,ny,v,t);

%% Main time loop
for time=1:maxIter
    % Right wall: outflow condition.
    fin(col3,end,:) = fin(col3,end-1,:);

    % Compute macroscopic variables, density and velocity.
    [rho, u] = macroscopic(fin,nx,ny,v);

    % Left wall: inflow condition.
    u(:,1,:) = vel(:,1,:);
    rho(1,1,:) = 1./(1-u(1,1,:)) .* ( sum(fin(col2,1,:)) + 2.*sum(fin(col3,1,:)) );
    
    % Compute equilibrium.
    feq = equilibrium(rho,u,nx,ny,v,t);
    fin([1,2,3],1,:) = feq([1,2,3],1,:) + fin([9,8,7],1,:) - feq([9,8,7],1,:);

    % Collision step.
    fout = fin - omega * (fin - feq);

    % Bounce-back condition for obstacle.
    for i=1:9
        fout(i, obstacle) = fin(10-i, obstacle);
    end
    % Streaming step. 
    for i=1:9
        fin(i,:,:) = circshift(fout(i,:,:),[v(i,1),v(i,2)]);
    end
    
%     for ix=1:nx
%         for iy=1:ny
%             for i=1:9
%                 next_x=ix+v(i,1);
%                 if next_x <1
%                     next_x = nx;
%                 end
%                 if next_x>nx
%                     next_x=1;
%                 end
%                 
%                 next_y=ix+v(i,2);
%                 if next_y <1 
%                     next_y = ny;
%                 end
%                 if next_y>ny
%                     next_y=1;
%                 end
%                 fin(i,next_x,next_y)=fout(i,ix,iy);
%             end
%         end
%     end
    
    % Visualization of the velocity.
    
    if mod(time,100)==0
        figure(1)
        grid off
        Z(:,:)=(sqrt(u(1,:,:).^2+u(2,:,:).^2));
        Ztrans=Z';
        contourf(X,Y,Ztrans,100,'edgecolor','none')
        view(2)
        axis equal
        c=colorbar;
        c.Label.String = 'U';
        caxis([0 uLB])
    end
end

%%%%%% Function Definitions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [rho,u]=macroscopic(fin,nx,ny,v)
    %Obtain the macroscopic quantities of the population: U,rho
    rho = zeros(1,nx, ny);
    rho = sum(fin,1);
%     for ix=1:nx
%         for iy=1:ny
%             rho(1,ix,iy)=0;
%             for i=1:9
%                 rho(1,ix,iy)=rho(1,ix,iy)+fin(i,ix,iy);
%             end
%         end        
%     end
    u = zeros(2, nx, ny);
    for i=1:9
        u(1,:,:) = u(1,:,:) + v(i,1) * fin(i,:,:);
        u(2,:,:) = u(2,:,:) + v(i,2) * fin(i,:,:);
    end
    u = u./rho;
%     for ix=1:nx
%         for iy=1:ny
%             u(1,ix,iy)=0;
%             u(2,ix,iy)=0;
%             for i=1:9
%                 u(1,ix,iy) = u(1,ix,iy) + v(i,1) * fin(i,ix,iy);
%                 u(2,ix,iy) = u(2,ix,iy) + v(i,2) * fin(i,ix,iy);
%             end
%             u(1,ix,iy)= u(1,ix,iy)/rho(1,ix,iy);
%             u(2,ix,iy)= u(2,ix,iy)/rho(1,ix,iy);
%         end
%     end
end

function feq=equilibrium(rho,u,nx,ny,v,t)
    % Equilibrium distribution function: feq. The equilibrium is obtained
    %from a truncated series of Maxwell-Boltzmann distribution.
    usqr = 3/2 * (u(1,:,:).^2 + u(2,:,:).^2);
    feq = zeros(9,nx,ny); % f is a 3D array of 9states x nx nodes x ny nodes
    for i=1:9
        cu = 3 * (v(i,1)*u(1,:,:) + v(i,2)*u(2,:,:));
        feq(i,:,:) = rho.* t(i) .* (1 + cu + 0.5*cu.^2 - usqr);
    end
end


