function [J,sys]=lorenz_problem_stabilise(ind,gen_param,i,fig)
    % copyright
    verb=gen_param.verbose;
    contro{1}=ind.formal{1};
    contro{2}=ind.formal{2};
    contro{3}=ind.formal{3};
    gamma=gen_param.problem_variables.gamma;
    if verb
%         fprintf('(%i) Simulating ...\n',i)
    end
    try
        [sys]=x0_rate_my_lorenz_stabilise(contro,i,verb>1);		%% Evaluates individual
        if strncmp(lastwarn,'Failure',7)
            warning('reset')
            sys.crashed=1;
        else
            sys.crashed=0;
        end        
%         if verb;fprintf('(%i) Simulation finished.\n',i);end
    catch err
        sys=[];
        sys.crashed=1;
%         if verb;fprintf('(%i) Simulation crashed: ',i);end
        if strncmp(err.message,'Output argument f (and maybe others) not assigned during call to ',15)
%             if verb;fprintf('Time is up\n');end
        else
%             if verb;fprintf(['(%i) ' err.message '\n'],i);end
            system(['echo "' ind.value '">> errors_in_GP.txt']);
            system(['echo "' err.message '">> errors_in_GP.txt']);
            
        end
        try
            delete(['my_system_ev' num2str(i) '.m']);
        catch err
        end
        try
            delete(['my_system_ev' num2str(i) '.']);
        catch err
        end
    end
    crashed=sys.crashed;
    if crashed==1
        J=gen_param.badvalue;
%         if verb>1;fprintf('(%i) Bad fitness: sim crashed\n',i);end        
    elseif length(sys.T)<length(0:0.005:200)
%         fprintf('Time is up\n')
        J=gen_param.badvalue;
    %Evaluation of cost function
    else
        objective=zeros(length(sys.Y),3);
        at=cumtrapz(sys.T,(sys.Y(:,1)-objective(:,1)).^2+(sys.Y(:,2)-objective(:,2)).^2+(sys.Y(:,3)-objective(:,3)).^2);
        a=at(end);
        bt=cumtrapz(sys.T,(sys.Y(:,4)).^2+(sys.Y(:,5)).^2+(sys.Y(:,6)).^2);
        b=bt(end);
        J=a+b*1e-5;
        if verb==5
            fprintf(['Fn cost= ' num2str(a) '\n'])
            fprintf(['Ctrl cost= ' num2str(b*1e-5) '\n'])
            fprintf(['Total cost= ' num2str(J) '\n'])
        end
    end
    if nargin<4
        fig=0;
    end
    if fig==1
        figure(969)
        plot(sys.T,sys.Y(:,1:3));
        title('State variables')
        ylabel('s')
        xlabel('t')
        legend('s1','s2','s3')
        figure(970)
        plot(sys.T,sys.Y(:,4:6));
        title('Control variables')
        ylabel('b')
        xlabel('t')
        legend('b1','b2','b3')
        figure(971)
        plot3(sys.Y(1:40/0.005,1),sys.Y(1:40/0.005,2),sys.Y(1:40/0.005,3))
        hold on
        plot3(sys.Y(40/0.005:end,1),sys.Y(40/0.005:end,2),sys.Y(40/0.005:end,3))
        title('3d Evolution')
        legend('No control','Controlled')
        hold off
        figure(972)
        plot(sys.T(1:end-1),(sys.Y(2:end,1:3)-sys.Y(1:end-1,1:3))/0.005);
        title('State variables variation')
        ylabel('ds/dt')
        xlabel('t')
        legend('s1','s2','s3')
%         hold on 
%         for i=1:10:length(sys.Y(:,1))
%             figure(970)
%             scatter3(sys.Y(i,1),sys.Y(i,2),sys.Y(i,3))
%         end
    end
end