%%  MLC_LQR_script    parameters script for MLC
%%  Type mlc=MLC2('MLC_Kalman_script') to create corresponding MLC object

%number of individuals                      
% prompt = {'Number of individuals'};
% dlgtitle = 'Input';
% dims = [1 35];
% definput = {'1000'};
% parameters.size = str2double(inputdlg(prompt,dlgtitle,dims,definput));
parameters.size = 50;
parameters.sensors=1;                       %number of sensors(Ns)
parameters.sensor_spec=0;
parameters.controls=4;                      %number of actuation commands(Nb)
parameters.sensor_prob=0.33;
parameters.leaf_prob=0.3;
parameters.range=10;
parameters.precision=4;
parameters.opsetrange=1:3;                  %operations(see MLC_tools/opset.m)
parameters.formal=1;
parameters.end_character='';
parameters.individual_type='tree';
%%  GP algortihm parameters
parameters.maxdepth=10;                 %max depth of a tree
parameters.maxdepthfirst=10;             %initial max depth of a tree
parameters.mindepth=2;                  %min depth of a tree
parameters.mutmindepth=2;               %min depth of a tree after mutation
parameters.mutmaxdepth=10;              %max depth of a tree after mutation
parameters.mutsubtreemindepth=2;        %max depth of a branch after mutation

% list = {'mixed_ramped_gauss','random_maxdepth','fullga',...                   
% 'fixed_maxdepthfirst','random_maxdepthfirst','full_maxdepthfirst',...
% 'full_maxdepthfirst','mixed_maxdepthfirst','mixed_ramped_even'};
% idx = listdlg('PromptString',{'Select Generation Method',...
%     'Only one Generation Method can be selected.',''},...
%     'SelectionMode','single','ListString',list);
% parameters.generation_method=list{idx};
parameters.generation_method='mixed_ramped_gauss';
parameters.gaussigma=3;                 %sigma of the gaussian method(?)
parameters.ramp=2:8;                    %ramp of the gaussian method(?)
parameters.maxtries=10;                 %maximum number of tries
parameters.mutation_types=1:4;          %types of mutation(up to 4)

%%  Optimization parameters
% prompt = {'Elitism','probrep','probmut','probcro'};
% dlgtitle = 'Input';
% dims = [1 35];
% definput = {'10','0.1','0.4','0.5'};
% answer = inputdlg(prompt,dlgtitle,dims,definput);
% parameters.elitism=str2double(answer{1});
% parameters.probrep=str2double(answer{2});
% parameters.probmut=str2double(answer{3});
% parameters.probcro=str2double(answer{4});

parameters.elitism=10;
parameters.probrep=0.1;
parameters.probmut=0.4;
parameters.probcro=0.5;

parameters.selectionmethod='tournament';
parameters.tournamentsize=7;            %number of individuals selected for the tournament(Np)
parameters.lookforduplicates=1;         %look for duplicates(T,F)
parameters.simplify=0;                  %simplify(?)
% parameters.cascade=[1 1];
% parameters.badvalues_elimswitch=1;

%% Evaluation method (select one of them)
% parameters.evaluation_method='test';                  %just test, not meaningful
% parameters.evaluation_method='mfile_multi';           %multithread evaluation (need
% verbose=4 probably)
% parameters.evaluation_method='mfile_all';
parameters.evaluation_method='mfile_standalone';        %default

%%  Evaluator parameters 
parameters.evaluation_function='MLC_Kalman';
parameters.indfile='ind.dat';                           %where individual data is stored
parameters.Jfile='J.dat';                               %where cost function data is stored
parameters.exchangedir='../@MLC2/evaluator0';
parameters.evaluate_all=0;                              %evaluate all ind (T,F)
parameters.ev_again_best=0;                             %reevaluate best ind (T,F)
parameters.ev_again_nb=5;                               %number of reevaluated ind
parameters.ev_again_times=5;                            %number of reevaluations
parameters.artificialnoise=0;                           %artificial noise imposed (T,F)
parameters.execute_before_evaluation='';                %(?)

%% Bad value settings
parameters.badvalue=1e+36;                              %J imposed if bad value
parameters.badvalues_elim='first';                      %default                  
% parameters.badvalues_elim='none';
% parameters.badvalues_elim='all';

parameters.preevaluation=0;                             %preevaluation(?)
parameters.preev_function='';                           %preevaluation function

%% Problem variables (Tf,Tevmax and objective only active in Dyn Sys)
% prompt = {'Sigma','Omega','Tf','Objective'};
% dlgtitle = 'Input Dynamic System Variables';
% dims = [1 35];
% definput = {'1','1','10','0'};
% answer = inputdlg(prompt,dlgtitle,dims,definput);
% parameters.problem_variables.sigma=str2double(answer{1});
% parameters.problem_variables.omega=str2double(answer{2});
% parameters.problem_variables.Tf=str2double(answer{3});
% parameters.problem_variables.objective=str2double(answer{4});

parameters.problem_variables.sigma=0;
parameters.problem_variables.omega=1;
parameters.problem_variables.Tf=10;
parameters.problem_variables.objective=0;
parameters.problem_variables.Tevmax=1;                  %waiting time before throwing error

%% MLC behaviour parameters 
parameters.save=1;                                      %save parameters (T,F)
parameters.saveincomplete=1;                            %save incomplete (T,F)
parameters.verbose=2;                                   %verbose (from 0 to 4)
parameters.fgen=250;                                    %fgen(?)
parameters.show_best=1;                                 %show best(?)
parameters.savedir=fullfile(pwd,'save_GP');             %save directory