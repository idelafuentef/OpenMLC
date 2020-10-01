function J=toy_problem2(ind,parameters,i,fig)
%toy_problem2 implements a simple regression for MLC in a 2D space
%   J=toy_problem2(IND,MLC_PARAMETERS)   returns the average distance
%       between the relation described by the LISP expression IND and the
%       points (s_i,b_i) so that b_i=tanh(1.256*s_i)+1.2.
%
%   J=toy_problem2(IND,MLC_PARAMETERS,I,FIG)   additionally provides a
%       visual output as long as I and FIG are provided (any value will
%       trigger the plot)
nargin=4;
xmin=-10;
xmax=10;
ymin=-10;
ymax=10;
dx=0.5;
dy=0.5;

[x0,y0]=meshgrid(xmin:dx:xmax,ymin:dy:ymax);
z0=tanh(1.256*x0*y0)+1.2*sin(x0);
%% calculating the surface over the grid
try
    m=ind.formal;
    m=strrep(m,'S0','x0');
    m=strrep(m,'S1','y0');
    z0_2=x0*0;
    eval(['z0_2=' simplify_my_LISP(m) ';']);
    z0_2=z0_2+x0*0;
    J=sum(sum((z0-z0_2).^2))/(length(z0)^2);
    
    %% Plot the resulting function z(individual)
%     [x,y]=meshgrid(xmin:dx/100:xmax,ymin:dy/100:ymax);
%     m=strrep(m,'x0','x');
%     m=strrep(m,'y0','y');
%     z=x*0;
%     eval(['z=' simplify_my_LISP(m) ';']);   %problem when there is no x or y
%     if nargin==4
%         s=surf(x,y,z);hold on
%         plot3(x0,y0,z0,'o','color','k','markerfacecolor','k','markersize',10);
%         for i=1:length(x0(:))
%         plot3([x0(i) x0(i)],[y0(i) y0(i)],[0 z0(i)],'k','linewidth',3);
%         end
%         hold off
%         shading interp
%         set(s,'facealpha',0.5);
%     end
catch err
    J=parameters.badvalue;
end