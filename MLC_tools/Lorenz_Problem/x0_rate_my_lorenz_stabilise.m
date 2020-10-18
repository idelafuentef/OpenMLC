function [sys]=x0_rate_my_lorenz_stabilise(contro,ev,verb)
    warning off
    load lorenz                                       %load canonical lorenz problem (3 equations right side)
    cont=contro;                                      %load control function
    init(:,1)=[1 1 1 0 0 0];                          %set initial conditions (vars,ctrl)
    init(1:3,1)=init(1:3,1)+rand(3,1);                %variate a bit the initial conditions 


    %% function to create the system equation
%     build_system_after40(equa,cont,ev); 
    build_system(equa,cont,ev);    
    
    %% 
    systemthere=exist(['my_system_ev' num2str(ev) '.m'],'file');
    while systemthere==0
        systemthere=exist(['my_system_ev' num2str(ev) '.m'],'file');
        pause(0.1)
    end
    if verb;fprintf(['(%i) Started at ' datestr(now,13) '\n'],ev);end
    xoverFcn = @(T, Y) MyEventFunction(T, Y);
    options = odeset('Events',xoverFcn,'RelTol',1e-6,'AbsTol',1e-8);
    tic
    eval(['[T,Y]=ode45(@my_system_ev' num2str(ev) ',0:0.005:200,init(:,1),options);']);
    if verb;fprintf(['(%i) done in ' num2str(toc) ' seconds\n'],ev);end
    delete(['my_system_ev' num2str(ev) '.m']);
    sys.T=T;
    sys.Y=Y;
%     highrate=sum(sum(abs((sys.Y(2:end-1,1:3)-sys.Y(1:end-2,1:3))/(sys.T(2)-sys.T(1)))>500)); %checks if rate goes beyond limit
%     if highrate>=1
%         error('too much variation')
%     end
end