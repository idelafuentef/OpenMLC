%% DYN_SYS    parameters script for MLC
%%    Type mlc=MLC2('dyn_sys') to create corresponding MLC object
parameters.size=50;                     %number of individuals
parameters.sensors=3;                   %number of sensors
% parameters.sensor_spec=0;
parameters.controls=3;                  %number of controllers
% parameters.sensor_prob=0.33;
% parameters.leaf_prob=0.3;
parameters.range=10;                    %range(?)
parameters.precision=4;                 %precision(?)
parameters.opsetrange=[1 2 3];          %operations(see MLC_tools/opset.m)
% parameters.formal=1;
% parameters.end_character='';
% parameters.individual_type='tree';
%%  GP algortihm parameters
parameters.maxdepth=15;                 %max depth of a tree
parameters.maxdepthfirst=5;             %initial max depth of a tree
parameters.mindepth=2;                  %min depth of a tree
parameters.mutmindepth=2;               %min depth of a tree after mutation
parameters.mutmaxdepth=15;              %max depth of a tree after mutation
parameters.mutsubtreemindepth=2;        %max depth of a branch after mutation
parameters.generation_method='mixed_ramped_gauss';     % 50% full 50% random gaussian distrib
% parameters.generation_method='random_maxdepth';
% parameters.generation_method='fullga';
% parameters.generation_method='fixed_maxdepthfirst';
% parameters.generation_method='random_maxdepthfirst';
% parameters.generation_method='full_maxdepthfirst';
% parameters.generation_method='mixed_maxdepthfirst'; %% 50% at full, 50% random, at maxdepthfirst
% parameters.generation_method='mixed_ramped_even';   %% 50% full, 50% random with ramped depth
parameters.gaussigma=3;                 %sigma of the gaussian method(?)
parameters.ramp=2:8;                    %ramp of the gaussian method(?)
parameters.maxtries=10;                 %maximum number of tries
parameters.mutation_types=1:4;          %types of mutation(up to 4)

%%  Optimization parameters
parameters.elitism=5;                   %number of individuals that go through elitism
parameters.probrep=0.1;                 %prob of replication of the remaining
parameters.probmut=0.6;                 %prob of mutation of the remaining
parameters.probcro=0.3;                 %prob of crossover of the remaining
parameters.selectionmethod='tournament';
parameters.tournamentsize=7;            %number of individuals selected for the tournament
parameters.lookforduplicates=1;         %look for duplicates(T,F)
parameters.simplify=0;                  %simplify(?)
% parameters.cascade=[1 1];
% parameters.badvalues_elimswitch=1;

%% Evaluation method (select one of them)
% parameters.evaluation_method='test';                  %just test, not meaningful
% parameters.evaluation_method='mfile_multi';           %multithread evaluation (need verbose=4 probably)
% parameters.evaluation_method='mfile_all';
% parameters.evaluation_method='mfile_standalone';      %default
parameters.evaluation_method='multithread_function';

%%  Evaluator parameters 
parameters.evaluation_function='dyn_sys_problem';       %
parameters.indfile='ind.dat';                           %where individual data is stored
parameters.Jfile='J.dat';                               %where cost function data is stored
parameters.exchangedir='../@MLC2/evaluator0';
parameters.evaluate_all=0;                              %evaluate all ind (T,F)
parameters.ev_again_best=1;                             %reevaluate best ind (T,F)
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
parameters.problem_variables.gamma=0.1;                 %gamma of Sys
% parameters.problem_variables.Tf=10;
% parameters.problem_variables.Tevmax=1;
% parameters.problem_variables.objective=0;

%% MLC behaviour parameters 
parameters.save=1;                                      %save parameters (T,F)
parameters.saveincomplete=1;                            %save incomplete (T,F)
parameters.verbose=[0 0 0 0 0 0];                       %verbose (from 0 to 4)
parameters.fgen=250;                                    %fgen(?)
parameters.show_best=1;                                 %show best(?)
parameters.savedir=fullfile(pwd,'save_GP');             %save directory