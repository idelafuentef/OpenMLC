function J=MLC_Kalman(ind,mlc_parameters,i,fig)
%% Obtaining parameters from MLC object.
%   Problem with 2 sensors and 1 actuator. 
%   2 ODEs
Tf=mlc_parameters.problem_variables.Tf;                 %final time
Tevmax=mlc_parameters.problem_variables.Tevmax;         %maximum evaluation time
%Neutrally stable oscillator
sigma=mlc_parameters.problem_variables.sigma;           %sigma=0
omega=mlc_parameters.problem_variables.omega;           %omega=1


A=[sigma -omega;        %dynamics
    omega sigma];
B=[1 0;0 1];                %Here we are accounting for the process noise(wd), not actuation
C=[1 0;0 1];                %Measure first state (we need both a1 and a2)
D=[0 0;0 0];                %No feedthrough term
% B=[eye(2) [0;0]];       %Disturbance plus actuation
% C=[1 0];                %Measure first state
% D=0;                    %No feedthrough term

KF_sys=ss(A,B,C,D);
% Disturbance and noise covariance matrices
% Vd=eye(2);              %disturbance covariance
% Vn=.1;                  %noise covariance
% Vdn=[0;0];

%% Interpret individual
m=simplify_my_LISP(ind.value);
m=readmylisp_to_formal_MLC(m);
m=strrep(m,'S0','u');
%The frequency-domain filters need the denominator to be of higher order than the numerator
for i=1:length(m)
    if i==2 || i==4
        m_coeff{i}=formal_to_tf([m{i} '.*u']);
    else
        m_coeff{i}=formal_to_tf(m{i});
    end
end

% eval(['K_1=@(u)(' m{1} ');']);                  %evaluation of K (actuator value b)
% eval(['K_2=@(u)(' m{2} ');']);
% eval(['K_3=@(u)(' m{3} ');']);
% eval(['K_4=@(u)(' m{4} ');']);
%% Evaluation
try                             % Encapsulation in try/catch.
    %run Simulink file
    if length(m_coeff{2})<=2 || length(m_coeff{4})<=1
        error('denominator has lower order than numerator')
    end
    tsim=20;
    options = simset('SrcWorkspace','current', 'DstWorkspace', 'current');      %to use the function workspace
    output = sim('MLC_Kalman_Sim.slx', tsim, options);
    Jt=cumtrapz(output.dJ.Time,output.dJ.Data(:,1)+output.dJ.Data(:,2));
    J=Jt(end);
catch err
   J=mlc_parameters.badvalue;    % Return high value if ode45 fails.
end
    
if nargin==4   % If a fourth argument is provided, plot the result
    subplot(3,1,1)
    plot(output.t.Data,output.ahat.Data(:,1),'linewidth',1.2)
    hold on
    plot(output.t.Data,output.ahat.Data(:,2),'linewidth',1.2)
    plot(output.t.Data,output.a.Data(:,1),'linewidth',1.2)
    plot(output.t.Data,output.a.Data(:,2),'linewidth',1.2)
    legend('$\hat a_1$','$\hat a_2$','$a_1$','$a_2$')
    ylabel('$a$','interpreter','latex','fontsize',20)
    xlabel('$t$','interpreter','latex','fontsize',20)
    hold off
    subplot(3,1,2)
    plot(output.t.Data,output.s.Data(:,1),'linewidth',1.2)
    ylabel('$s$','interpreter','latex','fontsize',20)
    xlabel('$t$','interpreter','latex','fontsize',20)
    subplot(3,1,3)
    plot(output.t.Data,Jt,'-k','linewidth',1.2)
    ylabel('$J_t$','interpreter','latex','fontsize',20)
    xlabel('$t$','interpreter','latex','fontsize',20)
end
end