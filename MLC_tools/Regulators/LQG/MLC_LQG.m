function J=MLC_Kalman(ind,mlc_parameters,i,fig)
%% Info
%   Problem with 1 sensor and 1 actuator. 
%   Ignacio de la Fuente Fernández
%   01/09/2020
%
%   TO DO
%   Needs to include ensemble averaging of cost function


Tf=mlc_parameters.problem_variables.Tf;                 %final time
Tevmax=mlc_parameters.problem_variables.Tevmax;         %maximum evaluation time
%Unstable oscillator
sigma=mlc_parameters.problem_variables.sigma;           %sigma=1
omega=mlc_parameters.problem_variables.omega;           %omega=1


A=[sigma -omega;            %dynamics
    omega sigma];
B=[1 0;0 1];                %Here we are accounting for the process noise(wd), not actuation
B=[B [0;1]];                %Disturbance plus actuation (need to define input accordingly)
C=[1 0;0 1];                %Measure first state (we need both a1 and a2, then we derive s)
D=[0 0 0;0 0 0];            %No feedthrough term

Q_cost=[1 0; 0 1];          %Signal cost function weight
R_cost=1;                   %Control cost function weight
KF_sys=ss(A,B,C,D);

%% Interpret individual 
m=simplify_my_LISP(ind.value);
m=readmylisp_to_formal_MLC(m);
m=strrep(m,'S0','u');                   


%The frequency-domain filters need the denominator to be of higher order than the numerator
for i=1:length(m)
    if i==2 || i==4
        m_coeff{i}=formal_to_tf([m{i} '.*u']);
    elseif i==1 || i==3 || i==5
        m_coeff{i}=formal_to_tf(m{i});
    end
end

% myTimer = timer('StartDelay',5, 'TimerFcn','set_param("MLC_LQG_Sim.slx","SimulationCommand","stop")');
warning('off');
%% Evaluation
try
    %run Simulink file
    if length(m_coeff{2})<=2 || length(m_coeff{4})<=1
        disp('Error: In filter, denominator has lower order than numerator')
        error('')
    end
    tsim=20;
    options = simset('SrcWorkspace','current', 'DstWorkspace', 'current','TimeOut',15);      %to use the function workspace
    %throws error if simulation time is too long
    output = sim('MLC_LQG_Sim.slx', tsim, options);   
    %transforms warnings into errors(thrown away)
    if ~isempty(lastwarn)
        disp('Error: sim timeout or tolerance reached')
        error('');
    end
    Jt=cumtrapz(output.dJ.Time,output.dJ.Data(:,1));
    J=Jt(end);
catch err
   J=mlc_parameters.badvalue;    % Return high value if ode45 fails.
end
    
if nargin==4   % If a fourth argument is provided, plot the result
    subplot(4,1,1)
    plot(output.t.Data,output.a.Data(:,1),'linewidth',1.2)
    hold on
    plot(output.t.Data,output.a.Data(:,2),'linewidth',1.2)
    plot(output.t.Data,output.ahat.Data(:,1),'--','linewidth',1.2)
    plot(output.t.Data,output.ahat.Data(:,2),'--','linewidth',1.2)
    legend('$a_1$','$a_2$','$\hat a_1$','$\hat a_2$')
    ylabel('$a$','interpreter','latex','fontsize',20)
    xlabel('$t$','interpreter','latex','fontsize',20)
    hold off
    subplot(4,1,2)
    plot(output.t.Data,output.s.Data(:,1),'-k','linewidth',1.2)
    ylabel('$s$','interpreter','latex','fontsize',20)
    xlabel('$t$','interpreter','latex','fontsize',20)
    subplot(4,1,3)
    plot(output.t.Data,output.b.Data(:,1),'-k','linewidth',1.2)
    ylabel('$b$','interpreter','latex','fontsize',20)
    xlabel('$t$','interpreter','latex','fontsize',20)
    subplot(4,1,4)
    plot(output.t.Data,Jt,'-k','linewidth',1.2)
    ylabel('$J_t$','interpreter','latex','fontsize',20)
    xlabel('$t$','interpreter','latex','fontsize',20)
end
end