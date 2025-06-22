function Clusters = GenerateClusterOffspring(Clusters, selectionProportions, Info)
% Generate offspring per cluster based on selection proportions
% Each cluster will produce enough offspring to reach 1.5x of assigned size

    Npop = Info.Npop;
    totalClusters = numel(Clusters);

    for i = 1:totalClusters
        clusterPop = Clusters(i).Chromosomes;
        clusterSize = size(clusterPop, 1);
        
        if clusterSize < 2
            continue;  % Skip undersized clusters
        end

        % Determine how many individuals should be in the next generation
        numSelected = round(selectionProportions(i) * Npop);
        targetCount = round(1 * numSelected);

        % Initialize storage for valid offspring
        offspring = [];
        offspringCosts = [];

        while size(offspring, 1) < targetCount
            % Randomly choose two parents from current cluster
            idx = randperm(clusterSize, 2);
            parents = clusterPop(idx, :);

            % Crossover & Mutation
            [child1, child2] = Crossover(parents, Info.Model);
            child1 = Mutation(child1, Info.Model);
            child2 = Mutation(child2, Info.Model);

            % Evaluate Offspring Cost
            [cost1, ~, ~] = CostFunction(child1, Info.Model);
            [cost2, ~, ~] = CostFunction(child2, Info.Model);

            % Accept only valid offspring
            if cost1 ~= inf
                offspring = [offspring; child1];
                offspringCosts = [offspringCosts; cost1];
            end
            if cost2 ~= inf && size(offspring, 1) < targetCount
                offspring = [offspring; child2];
                offspringCosts = [offspringCosts; cost2];
            end
        end

        % Append offspring to the cluster
        Clusters(i).Chromosomes = [Clusters(i).Chromosomes; offspring];
        Clusters(i).Individual_Costs = [Clusters(i).Individual_Costs; offspringCosts];
    end
end