clc; clear all; close all; warning off;
%%
addpath('.././');
AddPaths('.././');

%% Parameter
Info.Iteration=1000;
Info.Npop=350;

Info.PCrossover=0.7;
Info.PMutation=0.3;
Info.MaskMutationIndex=2;

% K-means Clustering Parameters
Info.cluster_sizes = 4;
Info.minClusterSize = 30; % Minimum number of elements per cluster

% DBSCAN Clustering Parameters
Info.epsilon = 10;
Info.minpts = 50;

% Speciation operators
Info.alpha = 0.11;
Info.gamma = 0.1;

% Noise proportion for regeneration
Info.regenerate = 0.8;

Info.NCrossover_Scenario=0.5;
Info.NMutation_Scenario=0.2;

%% Run Ga
Repeat=30;
MyStruct.MinCost=[];
MyStruct.BestCost=[];
Ans=repmat(MyStruct,Repeat,1);
model=c300695();  %Select the data set
model_name = 'c300695';
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
    [Ans(j,1).MinCost, Ans(j,1).BestSol, Ans(j,1).BestCost, Ans(j, 1).pop_GA, Ans(j, 1).CPU]=Algorithm_GA_Speciation_GQAP(Solution, Info);
    Ans(j,1).Gap_GA=(Heuristic2.Cost-Ans(j,1).MinCost)/Heuristic2.Cost;

%% mean
save(['Saved_Data_Quadratic_Speciation' model_name]);
end