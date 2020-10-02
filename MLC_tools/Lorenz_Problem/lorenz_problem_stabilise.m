function [J,sys]=lorenz_problem_stabilise(ind,gen_param,i,fig)
    % copyright
    verb=gen_param.verbose;
    contro{1}=ind.formal{1};
    contro{2}=ind.formal{2};
    contro{3}=ind.formal{3};
    gamma=gen_param.problem_variables.gamma;
    if verb
        fprintf('(%i) Simulating ...\n',i)
    end
    try
        [sys]=x0_rate_my_lorenz_stabilise(contro,i,verb>1);		%% Evaluates individual
        if strncmp(lastwarn,'Failure',7)
            warning('reset')
            sys.crashed=1;
        else
            sys.crashed=0;
        end        
        if verb;fprintf('(%i) Simulation finished.\n',i);end
    catch err
        sys=[];
        sys.crashed=1;
        if verb;fprintf('(%i) Simulation crashed: ',i);end
        if strncmp(err.message,'Output argument f (and maybe others) not assigned during call to ',15)
            if verb;fprintf('Time is up\n');end
        else
            if verb;fprintf(['(%i) ' err.message '\n'],i);end
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
        if verb>1;fprintf('(%i) Bad fitness: sim crashed\n',i);end        
    elseif length(sys.T)<401
        fprintf('Time is up\n')
        J=gen_param.badvalue;
    %Evaluation of cost function
    else
        objective=zeros(length(sys.Y),3);
        Jt=cumtrapz(sys.T,(sys.Y(:,1)-objective(:,1)).^2+(sys.Y(:,2)-objective(:,2)).^2+(sys.Y(:,3)-objective(:,3)).^2);
        J=Jt(end);
        if verb
            fprintf(['J= ' num2str(J) '\n'])
        end
    end
    if nargin<4
        fig=0;
    end
    if fig==1
        figure(969)
        plot(sys.T,sys.Y(:,1:3));
        figure(970)
        plot3(sys.Y(:,1),sys.Y(:,2),sys.Y(:,3))
    end
end