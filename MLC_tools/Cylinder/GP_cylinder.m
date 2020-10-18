%%  MLC_LQR_script    parameters script for MLC
%%  Type mlc=MLC2('GP_cylinder') to create corresponding MLC object

%number of individuals  
parameters.size=5;
parameters.sensors=1;                   %number of sensors(Ns)->3 because we have three equations(?)
parameters.sensor_spec=0;
parameters.controls=3;                  %number of actuation commands(Nb)=number of polynomials generated
parameters.sensor_prob=0.33;
parameters.leaf_prob=0.3;
parameters.range=10;
parameters.precision=4;
parameters.opsetrange=[1:3];            %operations(see MLC_tools/opset.m)
parameters.formal=0;
parameters.end_character='';
parameters.individual_type='tree';


%%  GP algortihm parameters 
parameters.maxdepth=10;                                 %max depth of a tree
parameters.maxdepthfirst=5;                             %initial max depth of a tree
parameters.mindepth=2;                                  %min depth of a tree
parameters.mutmindepth=2;                               %min depth of a tree after mutation
parameters.mutmaxdepth=10;                              %max depth of a tree after mutation
parameters.mutsubtreemindepth=2;                        %max depth of a branch after mutation

parameters.generation_method='mixed_ramped_gauss';
parameters.gaussigma=3;                                 %sigma of the gaussian method(?)
parameters.ramp=[2:8];                                  %ramp of the gaussian method(?)
parameters.maxtries=10;                                 %maximum number of tries
parameters.mutation_types=1:4;                          %types of mutation(up to 4)


%%  Optimization parameters
parameters.elitism=1;                                   %parameters selected for elitism
parameters.probrep=0.1;
parameters.probmut=0.4;
parameters.probcro=0.5;

parameters.selectionmethod='tournament';
parameters.tournamentsize=7;            %number of individuals selected for the tournament(Np)
parameters.lookforduplicates=1;         %look for duplicates(T,F)
parameters.simplify=0;                  %simplify(?)
parameters.cascade=[1 1];

%% Evaluation method (select one of them)
% parameters.evaluation_method='mfile_standalone';
parameters.evaluation_method='mfile_multi';

%%  Evaluator parameters
% parameters.evaluation_function='lorenz_problem_stabilise';  %just force an equilibrium point
parameters.evaluation_function='Cylinder_problem';            %look for stable system
parameters.indfile='ind.dat';                           %where individual data is stored
parameters.Jfile='J.dat';                               %where cost function data is stored
parameters.exchangedir='../@MLC2/evaluator0';
parameters.evaluate_all=0;                              %evaluate all ind (T,F)
parameters.ev_again_best=0;                             %reevaluate best ind (T,F)
parameters.ev_again_nb=5;                               %number of reevaluated ind
parameters.ev_again_times=5;                            %number of reevaluations
parameters.artificialnoise=0;                           %artificial noise imposed (T,F)
%parameters.execute_before_evaluation='delete my_lyapunov_ev*;';

%% Bad value settings
parameters.badvalue=10^36;
parameters.badvalues_elim='first';
%parameters.badvalues_elim='none';
%parameters.badvalues_elim='all';
parameters.preevaluation=0;
parameters.preev_function='';

%% Relative weight of cost function
parameters.problem_variables.gamma=1e-6;


%% MLC behaviour parameters 
parameters.save=1;                                      %save parameters (T,F)
parameters.saveincomplete=1;                            %save incomplete (T,F)
parameters.verbose=4;                                   %output messages (from 0 to 4)
parameters.fgen=250;                                    %fgen(?)
parameters.show_best=1;                                 %show best(?)
parameters.savedir=fullfile(pwd,'save_GP');             %save directory
