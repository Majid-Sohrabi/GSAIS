function [Ans, BestSol, BestCost, pop, time]=Algorithm_GSAIS_DBSCAN_GQAP(Solution, Info)

global NFE;
NFE=0;

%% initialization
% Info.Model.eta=0.1;
costfunction=@(q) Cost(q,Info.Model);       % Cost Function

BestCost=[];

individual.Position1=[];
individual.Xij=[];
individual.Cost=[];
individual.CVAR=[];

% Main population
pop=repmat(individual,Info.Npop,1);

% Random population for duplicating states
pop_random=repmat(individual,round(Info.Npop*Info.regenerate),1);

% BestSol=Solution;
[BestSol, ~] = find(Solution.Solution);
BestSol = reshape(BestSol, 1, size(BestSol,1));  % Convert the 2D solution to 1D chromosome
Heuristic_Sol = BestSol;
%% Initial population

pop(1).Position1 = BestSol;
[pop(1).Cost, ~, ~]=CostFunction(pop(1).Position1, Info.Model);

for i=2:Info.Npop
    
    pop(i).Position1 = Mutation(pop(1).Position1 ,Info.Model);

    % Evaluation
    [pop(i).Cost, ~, ~]=CostFunction(pop(i).Position1, Info.Model);

    while pop(i).Cost == inf
        pop(i).Position1 = Mutation(pop(1).Position1 ,Info.Model);
        % Evaluation
        [pop(i).Cost, ~, ~]=CostFunction(pop(i).Position1, Info.Model);
    end
end

% Generate 80% of the main population for replacing
% during the duplation and convergence
pop_random(1).Position1 = pop(1).Position1;
pop_random(1).Cost= pop(1).Cost;
for i=2:round(Info.Npop * Info.regenerate)
    
    pop_random(i).Position1 = Mutation(pop_random(1).Position1 ,Info.Model);

    % Evaluation
    [pop_random(i).Cost, ~, ~]=CostFunction(pop_random(i).Position1, Info.Model);

    while pop_random(i).Cost == inf
        pop_random(i).Position1 = Mutation(pop_random(1).Position1 ,Info.Model);
        % Evaluation
        [pop_random(i).Cost, ~, ~]=CostFunction(pop_random(i).Position1, Info.Model);
    end
end

% Sort Population
Costs=[pop.Cost];
[Costs, SortOrder]=sort(Costs);
pop=pop(SortOrder);
pop=pop(1:Info.Npop);

% Store Cost (just arbitarary - b/c we don't sort)
BestSol=pop(1);
WorstCost=pop(end).Cost;
beta=10;         % Selection Pressure (Roulette Wheel)

% Pre-allocate arrays for fixed k
clusterSize = Info.cluster_sizes;  % Should be a scalar now, e.g., 4
bestK = repmat(clusterSize, 1, Info.Iteration);  % Store fixed k for all iterations

% Initialize matrix to store silhouette values for each iteration
silhouetteHistory = cell(Info.Iteration, 1);  % Only one column now

% Initialize other storage
allSilhouettes = cell(Info.Iteration, 1);     % Only one set of values per iteration
popBestLabels = cell(Info.Iteration, 1);      % Cluster labels history

tic;  % Start timer

%% GA Main loop
for It = 1:Info.Iteration
    
    % Extract population matrix
    popMatrix = vertcat(pop.Position1);
    
    % Call clustering function (with fixed cluster size)
    [bestLabels, bestK, silhouetteValues, popLabels_k, silhouetteHistory_k, Clusters] = ...
    PerformDBSCANWithSilhouette(popMatrix, pop, Info);

    % Save silhouette values and cluster label assignments
    silhouetteHistory{It} = silhouetteHistory_k;
    allSilhouettes{It} = silhouetteValues;
    popBestLabels{It} = bestLabels;
    
    % Assign labels to population
    for i = 1:Info.Npop
        pop(i).Cluster = bestLabels(i);
    end

    % Assign predator and prey roles to clusters
    sortByFitness = true;  % Set to false if you want random assignment
    gamma2 = 0.25;
    Clusters = AssignPredatorPreyRoles(Clusters, Info.Npop, gamma2);

    %% Recalculate average fitness based on predator-prey interactions
    [Clusters, updatedAvgCosts] = UpdateClusterFitnessAndFilter(Clusters, Info);

    %% Determine Selection Proportions for the Next Generation
    selectionProportions = CalculateSelectionProportions(Clusters);
    % Optional: to get number of individuals per cluster for Npop = 100
    numIndividualsPerCluster = round(selectionProportions * Info.Npop);

    %% Offspring Generation per Cluster
    Clusters = GenerateClusterOffspring(Clusters, selectionProportions, Info);

    %% Update Population (Post-Crossover and Mutation)
    pop = SelectNewGeneration(Clusters, selectionProportions, Info, pop_random, BestSol);

    %% Sort population and store the best solution
    Costs = [pop.Cost];
    [Costs, SortOrder] = sort(Costs);
    pop = pop(SortOrder);
    pop = pop(1:Info.Npop);

    WorstCost = max(WorstCost, pop(end).Cost);
    
    if pop(1).Cost < BestSol.Cost
        BestSol = pop(1);
    end

    BestCost(It) = BestSol.Cost;
    BestPosition = pop(1).Position1;
    
    nfe(It) = NFE;
    
    % Display iteration information
    disp(['Iteration ' num2str(It) ', Best Cost = ' num2str(BestCost(It))]);
    
    time = toc;  % End timer
    if time >= Info.TimeLimit
        break;
    end
end
time;
Ans = BestCost(end);
BestSol;
end