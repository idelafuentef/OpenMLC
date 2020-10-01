%% Kalman Filter (classic)
clear all; close all; clc;
%% Define system matrices
sigma=0; omega=1;       %neutrally stable oscillator
A=[sigma -omega;        %dynamics
    omega sigma];
B=[eye(2) [0;0]];       %Disturbance plus actuation
C=[1 0];                %Measure first state
D=0;                    %No feedthrough term
sys=ss(A,B,C,D);        %continuous state-space system

%% Disturbance and noise covariance matrices
Vd=eye(2);              %disturbance covariance(because wd has 2 terms, they could affect each other too)
Vn=.1;                  %noise covariance(because wn has 1 term)
Vdn=[0;0];              %no cross-terms

%% Compute Kalman filter using LQE
[L,P,E] = lqe(A,eye(2),C,Vd,Vn,Vdn);    %L is the gain matrix
Aest = A-L*C;                           %Estimator dynamics
Best = L;                               %Input to estimator
Cest = eye(2);                          %Estimator outputs both states
Dest=[0;0];                             %No feedthrough
sysK = ss(Aest,Best,Cest,Dest);         %Estimator system

%% Loop through 50 noise realizations for average
for count = 1:50
    t=0:0.01:20;                        %duration of simulation
    d1 = 1*randn(size(t));              %disturbance to state a1
    d2 = 1*randn(size(t));              %distruabance to state a2
    n = .1*randn(size(t));              %%noise
    b = zeros(size(d1));                %noi actuation
    
    %simulate noisy system with disturbance
    [s,tout,a] = lsim(sys,[d1;d2;b],t,[1;0]);
    
    %simulate clean system for truth baseline
    [sclean,tout,aclean] = lsim(sys,[0*d1;0*d2;b],t,[1;0]);
    
    %Simulate kalman filter to estimate a_hat
    sn=s+n';
    [ahat,tout] = lsim(sysK,sn,t,[1;0]);
    
    %compute cost function
    for k=1:size(a,1)
        err=a(k,:)-ahat(k,:);           %choice: use a or aclean
        Jlong(k) = err*err';
    end
    Jindiv = cumtrapz(t,Jlong);         %trapezoidal integration
    Jall(count,:)=Jindiv;               %store current realization
end
J=mean(Jall,1);                         %average cost across realizations


subplot(3,1,1)
plot(t,ahat(:,1),'linewidth',1.2)
hold on
plot(t,ahat(:,2),'linewidth',1.2)
plot(t,a(:,1),'linewidth',1.2)
plot(t,a(:,2),'linewidth',1.2)
ylabel('$a_k$','interpreter','latex','fontsize',20)
xlabel('$t$','interpreter','latex','fontsize',20)
subplot(3,1,2)
plot(t,s,'-k','linewidth',1.2)
ylabel('$s$','interpreter','latex','fontsize',20)
xlabel('$t$','interpreter','latex','fontsize',20)
subplot(3,1,3)
plot(t,Jall,'color',[0.5 0.5 0.5],'linewidth',0.8)
hold on
plot(t,J,'-k','linewidth',1.2)
ylabel('$J$','interpreter','latex','fontsize',20)
xlabel('$t$','interpreter','latex','fontsize',20)
