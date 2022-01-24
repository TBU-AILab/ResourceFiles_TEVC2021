clc
format SHORTENG;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       BOUND
% 		- 0	- vychozi
% 		- 1	- HARD
% 		- 2	- Random
% 		- 3	- Periodic
% 		- 4	- Reflection
% 		- 5	- Halving
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%for BOUND = [0 1 2 3 4 5]
for BOUND = [3]


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       DIM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for DIM = [100]    %[10 30 50 100]

    
%%%%%%%%%%%%%%%%% global var for ticks
clear global ticks;
clear global ticks1;
global ticks;
global ticks1;
ticks = [];
ticks1 = [];


    
%%  introductory Definitions
num_prbs = 30;                      %% number of test problems
max_runs=51;                        %% number of runs
outcome=zeros(max_runs,1);          %% to save the solutions of each run
com_time=zeros(max_runs,1);         %% Computational time
SR=zeros(max_runs,1);               %% How many times the optimal solution is obtained
Avg_FES=zeros(max_runs,1);          %% average fitness evaluations to reach f*+1e08
Final_results=zeros(num_prbs,8);    %% to save the final results

%% run on more than one processor
%myCluster = parcluster('local');
%myCluster.NumWorkers = 1;  % define how many processors to use

%% ========================= main loop ====================================
for I_fno= 1:30
    Par= Introd_Par(I_fno, DIM);
    sol=zeros(51*1,Par.n); %% the best solution vector of each run
    vv=[];
    %parfor run=1:max_runs
    for run=1:max_runs
        [outcome(run),com_time(run),SR(run), Avg_FES(run),res,seed_run(run), sol(run,:)]=EBO_BIN(run,I_fno, DIM, BOUND);
        
        %%%%%%%%%%%%%  SAVE TICKS
        ticks_name=strcat('ticks\','ticks_t',num2str(I_fno),'_b',num2str(Par.n),'_b',num2str(BOUND),'_r',num2str(run),'.dat');
        save(ticks_name, 'ticks', '-ascii');
        ticks1_name=strcat('ticks1\','ticks1_t',num2str(I_fno),'_b',num2str(Par.n),'_b',num2str(BOUND),'_r',num2str(run),'.dat');
        save(ticks1_name, 'ticks1', '-ascii');
        ticks = [];
        ticks1 = [];
        
        %% to print the convergence of ech run % set 0 if not
        if Par.Printing==1
            res= res- repmat(Par.f_optimal,1,size(res,2));
            res(res<=1e-08)=0;
            if size(res,2)<Par.Max_FES
                res(size(res,2):Par.Max_FES)=0;
            end
            vv(run,:)= res(1:Par.Max_FES);
        end
    end
    
    Final_results(I_fno,:)= [min(outcome),max(outcome),median(outcome), mean(outcome),std(outcome),mean(com_time),mean(SR),mean(Avg_FES)];
    
    disp(Final_results);
   
    %% save the results in a text
    save('results.txt', 'Final_results', '-ascii');
    
    %% fitness values at different levels of the optimization process
    %%% required by the competition
    if Par.Printing==1
        lim= [0.01, 0.02, 0.03, 0.05, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0].*Par.Max_FES;
        res_to_print= vv(:,lim);
        name1 = 'Results_Record\EBOwithCMAR_t';
        name2 = num2str(I_fno);
        name3 = '_d';
        name4 = num2str(Par.n);
        name4a = '_b';
        name4b = num2str(BOUND);
        name5 = '.dat';
        f_name=strcat(name1,name2,name3,name4,name4a,name4b,name5);
        res_to_print=res_to_print';
        save(f_name, 'res_to_print', '-ascii');
        name1 = 'Results_Record\seeds_';
        f_name=strcat(name1,name2,name3,name4,name4a,name4b,name5);
        %% save the seeds used - if needed
        myMatrix2= double(seed_run);
        save(f_name, 'myMatrix2', '-ascii');
        
    end
end

end

end