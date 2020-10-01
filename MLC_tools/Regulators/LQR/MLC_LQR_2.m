function J=MLC_LQR(ind,mlc_parameters,i,fig)
%% Obtaining parameters from MLC object.
%   Problem with 2 sensors and 1 actuator. 
%   2 ODEs
Tf=mlc_parameters.problem_variables.Tf;                 %final time
sigma=mlc_parameters.problem_variables.sigma;           %sigma
omega=mlc_parameters.problem_variables.omega;           %omega
Tevmax=mlc_parameters.problem_variables.Tevmax;         %maximum evaluation time

A=[sigma -omega;...
    omega sigma];
C=[1 0; 0 1]; 
B=[0;1];
D=[0;0];
Q=[1 0; 0 1];   %Signal cost function weight
R=1;            %Control cost function weight

LQR_sys=ss(A,B,C,D);

%% Interpret individual.
m=simplify_my_LISP(ind.value);
m=readmylisp_to_formal_MLC(m);
m=strrep(m,'S0','u');           %sensor ID (need to modify script accordingly)

for i=1:length(m)
    m_coeff{i}=formal_to_tf(m{i});
end

warning('off');
%% Evaluation
try                             % Encapsulation in try/catch.
    %run Simulink file
    tsim=20;
    options = simset('SrcWorkspace','current', 'DstWorkspace', 'current','TimeOut',15);      %to use the function workspace
    %throws error if simulation time is too long
    output = sim('MLC_LQR_Sim.slx', tsim, options);   
    %transforms warnings into errors(thrown away)
    if ~isempty(lastwarn)
        disp('Error: sim timeout or tolerance reached')
        error('');
    end
    objective=zeros(length(output.a.Data(:,1)),2);
    Jt=cumtrapz(output.a.Time,(output.a.Data(:,1)-objective(:,1)).^2+(output.a.Data(:,2)-objective(:,2)).^2+R*output.b.Data(:,1).^2);
    J=Jt(end);
catch err
   J=mlc_parameters.badvalue;    % Return high value if ode45 fails.
end
    
if nargin==4   % If a fourth argument is provided, plot the result
    subplot(3,1,1)
    plot(output.a.Time,output.a.Data(:,1),'-k','linewidth',1.2)
    hold on
    plot(output.a.Time,output.a.Data(:,2),'-b','linewidth',1.2)
    hold off
    ylabel('$a$','interpreter','latex','fontsize',20)
    xlabel('$t$','interpreter','latex','fontsize',20)
    legend('$a_1$','$a_2$')
    subplot(3,1,2)
    plot(output.a.Time,output.b.Data(:,1),'-k','linewidth',1.2)
    ylabel('$b$','interpreter','latex','fontsize',20)
    xlabel('$t$','interpreter','latex','fontsize',20)
    subplot(3,1,3)
    plot(output.a.Time,Jt,'-k','linewidth',1.2)
    ylabel('$J$','interpreter','latex','fontsize',20)
    xlabel('$t$','interpreter','latex','fontsize',20)    
end
end