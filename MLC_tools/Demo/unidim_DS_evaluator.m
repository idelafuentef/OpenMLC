function J=unidim_DS_evaluator(ind,mlc_parameters,i,fig)
%% Obtaining parameters from MLC object.
Tf=mlc_parameters.problem_variables.Tf;                 %final time
objective=mlc_parameters.problem_variables.objective;   %objective
gamma=mlc_parameters.problem_variables.gamma;           %gamma
Tevmax=mlc_parameters.problem_variables.Tevmax;         %maximum evaluation time

%% Interpret individual.
m=ind.formal;
m=strrep(m,'S0','y');
K=@(y)(y);
eval(['K=@(y)(' m ');']);
f=@(t,y)(y+K(y)+testt(toc,Tevmax));

%% Evaluation
try                             % Encapsulation in try/catch.
    tic 
    %to include the warning of integration tolerances as error
    lastwarn('') % Clear last warning message
    [T,Y]=ode45(f,[0 Tf],1);    % Integration.
    warnMsg = lastwarn;
    if ~isempty(warnMsg)
        fprintf('Integration tolerance reached. Individual discarded.')
        error(warnMsg)
    end
    if T(end)==Tf                                           % Check if Tf is reached.
        b=Y*0+K(Y);                                         % Computes b.
        Jt=1/Tf*cumtrapz(T,(Y-objective).^2+gamma*b.^2);    % Computes J vector over time
        J=Jt(end);                                          % Computes (last) J
    else
        J=mlc_parameters.badvalue;  % Return high value if Tf is not reached.
    end
catch err
   J=mlc_parameters.badvalue;    % Return high value if ode45 fails.
end
    
if nargin==4   % If a fourth argument is provided, plot the result
    subplot(3,1,1)
    plot(T,Y,'-k','linewidth',1.2)
    ylabel('$Sensor (a)$','interpreter','latex','fontsize',20)
    xlabel('$t$','interpreter','latex','fontsize',20)
    subplot(3,1,2)
    plot(T,b,'-k','linewidth',1.2)
    ylabel('$Actuator (b)$','interpreter','latex','fontsize',20)
    xlabel('$t$','interpreter','latex','fontsize',20)
    subplot(3,1,3)
    plot(T,Jt,'-k','linewidth',1.2)
    ylabel('$(a-a_0)^2+\gamma b^2$','interpreter','latex','fontsize',20)
    xlabel('$t$','interpreter','latex','fontsize',20)
end
end