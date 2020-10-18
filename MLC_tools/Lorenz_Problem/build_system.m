function []=build_system(list_of_eqs,list_of_controls,thread_number)
% copyright
	n=length(list_of_eqs);
    m=length(list_of_controls);
	fid=fopen(['my_system_ev' num2str(thread_number) '.m'],'w');
%% Construction of the file
    fprintf(fid,['function f=my_system_ev' num2str(thread_number) '(t,y)\n']);
	fprintf(fid,'if t==0; tic;end\n');
    fprintf(fid,'S0=y(1);S1=y(2);S2=y(3);\n');
%% Construction of the system
    fprintf(fid,['f=zeros(' num2str(n+m) ',1);\n']);
    for i=1:n
        eq=list_of_eqs{i};
        fprintf(fid,['f(' num2str(i) ')= ' readmylisp_to_formal_MLC(eq) '+' list_of_controls{i} ';\n']);
%         fprintf(fid,['f(' num2str(i) ')= ' readmylisp_to_formal_MLC(eq) ';\n']); %just to see how it would be without control
    end
    for j=1:m
        fprintf(fid,['f(' num2str(n+j) ')= ' list_of_controls{j} ';\n']);
    end
    fprintf(fid,'end');
	fclose(fid);
	pause(0.2)
end