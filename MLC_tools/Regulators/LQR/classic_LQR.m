%% Linear Quadratic Regulator (classic)
clear all; close all; clc;
%% Define system matrices
sigma=1; omega=1;
A=[sigma -omega;
    omega sigma];
B=[0;1];
C=[1 0 ;
    0 1];
D=[0;0];
sys=ss(A,B,C,D);

%% Compute LQR controller
Q=eye(2);
R=1;
[K,S,e] = lqr(A,B,Q,R);

%% simulate closed-loop system
dt=0.001;
Acl=A-B*K;
Bcl=[0;0];
sysK=ss(Acl,Bcl,C,D);
[s,t]=initial(sysK,[1;0],0:dt:10);

%% compute cost function
b = -K*s';
J(1) = 0;

%% For each dt, integrate cost function
for k=2:length(t)
    J(k)=J(k-1)+dt*(s(k-1,:)*Q*s(k-1,:)'+R*b(k-1)^2);
end