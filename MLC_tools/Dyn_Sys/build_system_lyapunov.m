function []=build_system_lyapunov(ind,parameters,thread_number)
%    ind = individual
%    parameters = parameters of the individual
%    thread_number = index of the ind being analyzed
%
%    For more info about lyapunov see lyapunov.m, this only explains the    
%    structure
%
%    Example, Lorenz system:
%               dx/dt = sigma*(y - x) = f1
%               dy/dt = r*x - y - x*z = f2
%               dz/dt = x*y - b*z     = f3
%
%    The Jacobian of system: 
%        | -sigma  sigma  0 |
%    J = |   r-z    -1   -x |
%        |    y      x   -b |
%
%    Then, the variational equation has a form:
% 
%    F = J*Y
%    where Y is a square matrix with the same dimension as J.
%    Corresponding m-file:
%         function f=lorenz_ext(t,X)
%         SIGMA = 10; R = 28; BETA = 8/3;
%         x=X(1); y=X(2); z=X(3);
%
%         Y= [X(4), X(7), X(10);
%             X(5), X(8), X(11);
%             X(6), X(9), X(12)];
%         f=zeros(9,1);
%         f(1)=SIGMA*(y-x); f(2)=-x*z+R*x-y; f(3)=x*y-BETA*z;
%
%         Jac=[-SIGMA,SIGMA,0; R-z,-1,-x; y, x,-BETA];
%  
%         f(4:12)=Jac*Y;
%       n=number of nonlinear odes = number of controllers
%       n2=n*(n+1)=total number of odes
%
	n=parameters.controls;
    %% Construction of the file
	fid=fopen(['my_lyapunov_ev' num2str(thread_number) '.m'],'w');
    fprintf(fid,['function f=my_lyapunov_ev' num2str(thread_number) '(t,y)\n']);
	fprintf(fid,'if t==0; tic;end\n');
    %% Construction of the Vector applied to the derived Jacobian
	for i=1:n
		for j=1:n
			fprintf(fid,['Y(' num2str(i) ',' num2str(j) ')=y(' num2str(i+n+(j-1)*n) ');\n']);
        end
    end
    fprintf(fid,'if toc<30\n');
%% Construction of the system
    fprintf(fid,['f=zeros(' num2str(n*(n+1)) ',1);\n']);
    fprintf(fid,['b=zeros(' num2str(n) ',1);\n']);
    a=readmylisp_to_formal_MLC(ind,parameters);
    for i=1:n
        m=strrep(a.formal{i},'S0','y(1)');
        m=strrep(m,'S1','y(2)');
        m=strrep(m,'S2','y(3)');
        fprintf(fid,['f(' num2str(i) ')= ' simplify_my_LISP(m) ';\n']);
    end
%% Construction of the Jacobian
    stru=[find(((cumsum(double(double(ind.value)=='('))-cumsum(double(double(ind.value)==')'))).*double(double(ind.value==' '))==1)) length(ind.value+1)];
    list_of_eqs=cell(1,parameters.controls);
    for i=1:parameters.controls
        list_of_eqs{i}=ind.value((stru(i)+1):(stru(i+1)-1));
    end
	for i=1:n
		%dumstring=[];
		for j=1:n
			%fprintf(['eq: ' list_of_eqs{i} '\n']);
			%fprintf(['control: ' list_of_controls{i} '\n']);
			eq=list_of_eqs{i};
			%fprintf(['compond: ' eq '\n']);
			%fprintf(num2str(j-1));fprintf('\n')
			%fprintf(eq);fprintf('\n')
			devstring=readmylisp_to_formal_MLC(Derivate_My_Lisp(eq,j-1),parameters);             %"eq" needs to be in LISP format, and so does "list_of_eqs"
			devstring=strrep(devstring,'S0','y(1)');
            devstring=strrep(devstring,'S1','y(2)');
            devstring=strrep(devstring,'S2','y(3)');
            fprintf(fid,['Jac(' num2str(i) ',' num2str(j) ')=' simplify_my_LISP(devstring) ';\n']);
		end
		%fprintf(fid,[dumstring '\n']);
    end
%% Variational equation
	fprintf(fid,['f(' num2str(n+1) ':' num2str(n*(n+1)) ')=Jac*Y;\n']);
	fprintf(fid,['f(' num2str(n*(n+1)+1) ')=sum(b.^2)/200;\n']);
    fprintf(fid,'else\n');
    fprintf(fid,'return\n');
    fprintf(fid,'end\n');
	fclose(fid);
	pause(0.2)
end