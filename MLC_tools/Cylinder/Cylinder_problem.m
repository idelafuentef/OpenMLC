function [J,sys]=Cylinder_problem(ind,gen_param,i,fig)
    
    verb=gen_param.verbose;
    %As we are dealing with genetic programming, we give the value of a
    %supposed sensor and what changes is the function that evaluates the
    %corresponding control law
    S0   =  5;
    control{1}=ind.formal{1};
    control{2}=ind.formal{2};
    control{3}=ind.formal{3};
    
    K=@(S0)(S0);
    eval(['freq=' control{1} ';']);                  %evaluation of K (actuator value b)
    eval(['phase=' control{2} ';']);                  %evaluation of K (actuator value b)
    eval(['ampl=' control{3} ';']);                  %evaluation of K (actuator value b)
    
    fprintf('freq=%d, phase=%d, amplitude=%d \n',freq,phase,ampl)
    gamma=gen_param.problem_variables.gamma;
    
    if verb
        fprintf('(%i) Simulating ...\n',i)
    end
    
    try
        if abs(freq)>2*pi || abs(phase)>2*pi || abs(ampl)>1
            error('error')
        end
        %Run python script
        system(['python lbmFlowAroundCylinder.py ' num2str(freq) ' ' num2str(phase) ' ' num2str(ampl)])
        %Read output
        for i=1:9
            fin(i,:,:)=csvread(['fin' num2str(i-1) '.csv']);
        end
        rho(:,:)=csvread('rho.csv');
        vel(1,:,:)=csvread('u.csv');
        vel(2,:,:)=csvread('v.csv');
        if strncmp(lastwarn,'Failure',7)
            warning('reset')
            sys.crashed=1;
        else
            sys.crashed=0;
        end        
        if verb;fprintf('(%i) Simulation finished.\n',i);end
    catch err
        % A "normal" source of error is a too long evaluation.
        % The function is set-up to "suicide" after 30s.
        % In that case the error "Output argument f (and maybe others)
        % not assigned during call to..." gets out.
        % In that case we don't keep the trace.
        % In the other cases, the errors are sent to "errors_in_GP.txt"
        % with the number of the defective individual.
        % In all cases, as the subroutine that erase the files crashes
        % we do it here.     
        sys=[];
        sys.crashed=1;
        if abs(freq)>2*pi || abs(phase)>2*pi || abs(ampl)>1
            fprintf('Control values out of bounds \n')
        end
        
        if verb;fprintf('(%i) Simulation crashed: ',i);end
%         if strncmp(err.message,'Output argument f (and maybe others) not assigned during call to ',15)
%             if verb;fprintf('Time is up\n');end
%         else
%             if verb;fprintf(['(%i) ' err.message '\n'],i);end
%             system(['echo "' ind.value '">> errors_in_GP.txt']);
%             system(['echo "' err.message '">> errors_in_GP.txt']);
%             
%         end
%         try
%             delete(['my_lyapunov_ev' num2str(i) '.m']);
%         catch err
%         end
%         try
%             delete(['my_lyapunov_ev' num2str(i) '.']);
%         catch err
%         end
    end
    crashed=sys.crashed;
    if crashed==1
        J=gen_param.badvalue;
        if verb>1;fprintf('(%i) Bad fitness: sim crashed\n',i);end     
    else
        nx=size(vel,2); ny=size(vel,3);
        x=1:nx; y=1:ny;
        [X,Y] = meshgrid(x,y);
        uv(:,:)=sqrt(vel(1,:,:).^2+vel(2,:,:).^2);

        dx=1; dt=1;                         %timestep size
        cs=sqrt((1/3)*(dx^2/dt^2));         %sound velocity 
        p = (cs^2)./rho;                    %pressure
        g=1.4;                              %gamma (CHECK)

        M = uv./cs;
        Minf=0.04/cs;
        p_pt = (1 + (g-1)/2*M.^2).^(-g/(g-1));
        pinf_pt = (1 + (g-1)/2*Minf^2)^(-g/(g-1));
        p_pinf = p_pt./(pinf_pt);
        cp = 2./(g*Minf^2).*(p_pinf - 1);
        
        %% cD calculation
        cx = nx/4; 
        cy = ny/2; 
        r =ny/9;
        k=1;
        for i=cx-r:cx+r
            theta(k)=acos((cx-i)/(r));
            j=int64(floor(cy+r*sin(theta(k))));
        %     j_double=cy+r*sin(theta);
            cp_cyl(k)=cp(i,j); 
            k=k+1;
            %check cylinder shape
        %     figure(10)
        %     scatter(i,j)
        %     hold on
        %     axis equal
        end

        Cd_int=cp_cyl.*cos(theta);  Cl_int=cp_cyl.*sin(theta);
        C_D=trapz(theta,Cd_int);  C_L=trapz(theta,Cl_int);
    
        J=abs(C_D-C_L*gamma);
        if verb==4
            fprintf(['C_D= ' num2str(C_D) '\n'])
            fprintf(['C_L= ' num2str(C_L) '\n'])
            fprintf(['J= ' num2str(J) '\n'])
        end
    end
    if nargin==4   % If a fourth argument is provided, plot the result
        %% Plots

        figure(1)
        s = mesh(X,Y,uv');
        view(2)
        c=colorbar;
        c.Label.String = 'Velocity';
        s.FaceColor = 'flat';
        
        u(:,:)=vel(1,:,:);
        figure(2)
        s = mesh(X,Y,u');
        view(2)
        c=colorbar;
        c.Label.String = 'U';
        s.FaceColor = 'flat';
        
        v(:,:)=vel(2,:,:);
        figure(3)
        s = mesh(X,Y,v');
        view(2)
        c=colorbar;
        c.Label.String = 'V';
        s.FaceColor = 'flat';

        figure(4)
        s = mesh(X,Y,p');
        view(2)
        c=colorbar;
        c.Label.String = 'P'; 
        s.FaceColor = 'flat';
    end   
    
end