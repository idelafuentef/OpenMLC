function J=toy_problem(ind,parameters,i,fig)
%TOY_PROBLEM implements a simple regression for MLC
%   J=TOY_PROBLEM(IND,MLC_PARAMETERS)   returns the average distance
%       between the relation described by the LISP expression IND and the
%       points (s_i,b_i) so that b_i=tanh(1.256*s_i)+1.2.
%
%   J=TOY_PROBLEM(IND,MLC_PARAMETERS,I,FIG)   additionally provides a
%       visual output as long as I and FIG are provided (any value will
%       trigger the plot).
%   s: sensor value
%   b: actuator value

%% 1 sensor
s=-10:0.1:10;                       %range of sensor values
b=tanh(1.256*s)+1.2;                %the equation it must fit
b2=b*0;
try
    m=ind.formal;                   %equation proposed (individual)
    m=strrep(m,'S0','s');
    eval(['b2=' m ';'])             %actuator value proposed (individual)
    J=sum((b2-b).^2)/length(b2);    %calculate cost function
catch err
    % If something goes wrong , assign a bad value
    J=parameters.badvalue;
    fprintf(err.message);
end

if nargin==4
    subplot(2,1,1)
    plot(s,b,'*','marker','o','markersize',8,'color','k');hold on
    plot(s,b2,'-k','linewidth',1.2);hold  off
    set(gca,'fontsize',13,'xlim',[min(s(:)),max(s(:))],'ylim',[min(b(:))-0.1*(max(b(:))-min(b(:))),max(b(:))+0.1*(max(b(:))-min(b(:)))])
    l=legend('$b_i$','${K(s_i)}$');
    set(l,'location','northwest','interpreter','latex')
    grid on
    xlabel('$Sensor value (s)$','fontsize',16,'interpreter','latex')
    ylabel('$Actuator value (b)$','fontsize',16,'interpreter','latex')
    subplot(2,1,2),
    plot(s,sqrt((b-b2).^2),'*k')
    set(gca,'yscale','log')
    set(gca,'fontsize',13)
    xlabel('$Sensor value (s)$','fontsize',16,'interpreter','latex')
    ylabel('$|b-K(s)|$','fontsize',16,'interpreter','latex')
    set(gcf,'PaperPositionMode','auto')
    grid on
    set(gcf,'Position',[100 500 600 500])
end
end