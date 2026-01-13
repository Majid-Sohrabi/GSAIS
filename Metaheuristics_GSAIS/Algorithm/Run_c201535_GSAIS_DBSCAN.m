close all;
clear all;
clc;
%% Add path & Address manage
addpath('../.');
AddPaths('.././');

%% Data
Info.Iteration=1000;    % Maximum iteration
Info.TimeLimit = 1000;        % Maximum time (sec.)

% Noise proportion for regeneration
Info.regenerate = 0.8;

% Speciation operators
Info.alpha = 0.2;
Info.gamma = 0.1;

Info.cluster_sizes = 4;

Info.Npop=150;    % Population size
Info.PCrossover=0.6;   % Crossover probability
Info.PMutation=0.1;
% List_alpha_eps=[1.3 1.5 1.7];
Info.alpha_eps=0.5;
Info.MinPts=10;

%% Run GSAIS-DBSCAN
Repeat=30;
MyStruct.MinCost=[];
MyStruct.BestCost=[];
Ans=repmat(MyStruct,Repeat,1);
model=c201535();  %Select the data set
model_name = 'c201535';
Info.Model=model;

%% Call the heuristic
tic;  % This solution is very optimal and feasible
[z, X, cvar]=Heuristic2(model);   %Provides the best local optimum
Heuristic2.Cost=z;
Heuristic2.Solution=X;
Heuristic2.Feasibility=cvar; 
Heuristic2.CPU=toc; 

for j = 1:Repeat
    Solution=Heuristic2;
    % display('.........run GA Speciation.........');
    [Ans(j,1).MinCost, Ans(j,1).BestSol, Ans(j,1).BestCost, Ans(j, 1).pop_GA, Ans(j, 1).CPU]=Algorithm_GSAIS_DBSCAN_GQAP(Solution, Info);
    Ans(j,1).Gap_GA=(Heuristic2.Cost-Ans(j,1).MinCost)/Heuristic2.Cost;
end

%% mean
save(['Saved_Data_Quadratic_GSAIS_DBSCAN_' model_name]);