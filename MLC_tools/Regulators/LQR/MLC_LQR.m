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
Q=[1 0; 0 1];   %cost function weights
R=1;            %cost function weights

%% Interpret individual.
m=ind.formal;
m=strrep(m,'S0','a(1)');                   %a is the sensor value considering full-state measurement(s=a)
m=strrep(m,'S1','a(2)');                   %a is the sensor value considering full-state measurement(s=a)
K=@(a)(a);
eval(['K=@(a)(' m ');']);                  %evaluation of K (actuator value b)
f=@(t,a)(A*a+B*K(a)+testt(toc,Tevmax));

%% Evaluation
try                             % Encapsulation in try/catch.
    tic
    [T,Y]=ode45(f,[0 Tf],[1;0]);                            % Integration.
    if T(end)==Tf                                           % Check if Tf is reached.
        for i=1:length(Y(:,1))
            b(i,2)=K(Y(i,:));                                         % Computes b(not sure)
        end
        objective=zeros(length(Y),2);
        Jt=cumtrapz(T,(Y(:,1)-objective(:,1)).^2+(Y(:,2)-objective(:,2)).^2+R*b(:,2).^2);
%         Jt=1/Tf*cumtrapz(T,(Y-objective).^2+gamma*b.^2);    % Computes J vector over time
        J=Jt(end);                                          % Computes sum of the two(last) J
    else
        J=mlc_parameters.badvalue;  % Return high value if Tf is not reached.
    end
catch err
   J=mlc_parameters.badvalue;    % Return high value if ode45 fails.
end
    
if nargin==4   % If a fourth argument is provided, plot the result
    subplot(3,1,1)
    plot(T,Y(:,1),'-k','linewidth',1.2)
    hold on
    plot(T,Y(:,2),'-b','linewidth',1.2)
    hold off
    ylabel('$a$','interpreter','latex','fontsize',20)
    xlabel('$t$','interpreter','latex','fontsize',20)
    legend('$a_1$','$a_2$')
    subplot(3,1,2)
    plot(T,b(:,2),'-k','linewidth',1.2)
    ylabel('$b$','interpreter','latex','fontsize',20)
    xlabel('$t$','interpreter','latex','fontsize',20)
    subplot(3,1,3)
    plot(T,Jt,'-k','linewidth',1.2)
    ylabel('$J$','interpreter','latex','fontsize',20)
    xlabel('$t$','interpreter','latex','fontsize',20)    
end
end