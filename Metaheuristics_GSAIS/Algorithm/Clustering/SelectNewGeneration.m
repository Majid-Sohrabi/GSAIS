function pop = SelectNewGeneration(Clusters, selectionProportions, Info, pop_random, BestSol)
% Updated version with full 4-step pipeline and dimension safety

    newGeneration = [];
    newFitnessList = [];
    nClusters = length(Clusters);
    meaningfulClusterCount = 0;
    hasAddedPopRandom = false;

    %% Step 1: Select individuals from each cluster by proportion
    for i = 1:nClusters
        cluster_pop = Clusters(i).Chromosomes;
        fitness_values = Clusters(i).Individual_Costs;

        if isempty(cluster_pop) || size(cluster_pop, 1) < 2
            fprintf('Cluster %d has insufficient population (less than 2). Skipping.\n', i);
            continue;
        end

        meaningfulClusterCount = meaningfulClusterCount + 1;

        [sorted_fitness, sorted_idx] = sort(fitness_values);
        sorted_cluster_pop = cluster_pop(sorted_idx, :);

        num_selected = min(round(selectionProportions(i) * Info.Npop), size(sorted_cluster_pop, 1));
        num_selected = max(num_selected, 1);

        selected_individuals = sorted_cluster_pop(1:num_selected, :);
        selected_fitness = sorted_fitness(1:num_selected);

        for j = 1:size(selected_individuals, 1)
            candidate = reshape(selected_individuals(j, :), 1, []);
            if isempty(newGeneration) || size(candidate, 2) == size(newGeneration, 2)
                if isempty(newGeneration) || ~ismember(candidate, newGeneration, 'rows')
                    newGeneration = [newGeneration; candidate];
                    newFitnessList = [newFitnessList; selected_fitness(j)];
                end
            end
        end
    end

    %% Step 2: Add best individual from each cluster (avoid duplicates)
    for i = 1:nClusters
        cluster_pop = Clusters(i).Chromosomes;
        fitness_values = Clusters(i).Individual_Costs;

        if isempty(cluster_pop) || size(cluster_pop, 1) < 2
            continue;
        end

        [min_fitness, idx] = min(fitness_values);
        best_individual = reshape(cluster_pop(idx, :), 1, []);

        if isempty(newGeneration) || size(best_individual, 2) == size(newGeneration, 2)
            if ~ismember(best_individual, newGeneration, 'rows')
                newGeneration = [newGeneration; best_individual];
                newFitnessList = [newFitnessList; min_fitness];
            end
        end
    end

    %% Step 3: Inject pop_random if too few clusters AND newGeneration too small
    if meaningfulClusterCount < 2 && size(newGeneration, 1) < 20 && ~isempty(pop_random) && ~hasAddedPopRandom
        for k = 1:length(pop_random)
            rand_individual = reshape(pop_random(k).Position1, 1, []);
            rand_cost = pop_random(k).Cost;

            if isempty(newGeneration) || size(rand_individual, 2) == size(newGeneration, 2)
                if isempty(newGeneration) || ~ismember(rand_individual, newGeneration, 'rows')
                    newGeneration = [newGeneration; rand_individual];
                    newFitnessList = [newFitnessList; rand_cost];
                end
            end
        end
        hasAddedPopRandom = true;
    end

    %% Step 4: Padding - add random individuals from clusters if needed
    if size(newGeneration, 1) < Info.Npop && nClusters > 0 && any(arrayfun(@(c) ~isempty(c.Chromosomes), Clusters))
        deficit = Info.Npop - size(newGeneration, 1);
        while deficit > 0
            for i = 1:nClusters
                cluster_pop = Clusters(i).Chromosomes;
                fitness_values = Clusters(i).Individual_Costs;

                if isempty(cluster_pop)
                    continue;
                end

                rand_idx = randi(size(cluster_pop, 1));
                random_candidate = reshape(cluster_pop(rand_idx, :), 1, []);
                candidate_cost = fitness_values(rand_idx);

                if size(newGeneration, 1) > 0 && size(random_candidate, 2) ~= size(newGeneration, 2)
                    continue;
                end

                if isempty(newGeneration) || ~ismember(random_candidate, newGeneration, 'rows')
                    newGeneration = [newGeneration; random_candidate];
                    newFitnessList = [newFitnessList; candidate_cost];
                    deficit = deficit - 1;
                end

                if deficit <= 0
                    break;
                end
            end
        end
    end

    %% Final sort and formatting
    [~, final_sorted_idx] = sort(newFitnessList);
    newGeneration = newGeneration(final_sorted_idx, :);
    newFitnessList = newFitnessList(final_sorted_idx);

    %% Output population structure
    pop = repmat(struct('Position1', [], 'Cost', []), Info.Npop, 1);
    for i = 1:Info.Npop
        if i <= size(newGeneration, 1)
            pop(i).Position1 = newGeneration(i, :);
            pop(i).Cost = newFitnessList(i);
        else
            % In case of a mismatch, fill default
            if ~isempty(Clusters) && isfield(Clusters, 'Chromosomes') && ~isempty(Clusters(1).Chromosomes)
                chromosomeLength = size(Clusters(1).Chromosomes, 2);
            else
                chromosomeLength = Info.Model.J;  % Fallback
            end
            % pop(i).Position1 = zeros(1, chromosomeLength);
            % pop(i).Cost = inf;

            pop(i).Position1 = Mutation(BestSol.Position1  ,Info.Model);
            % Evaluation
            [pop(i).Cost, ~, ~]=CostFunction(pop(i).Position1, Info.Model);
        end
    end
end











%% This is the old code which works properly
%% But at some iteration the algorithm has relaxation
%% Regarding the clustering because of the convergence of the population

% function pop = SelectNewGeneration(Clusters, selectionProportions, Info, pop_random)
% % Selects top individuals from each cluster based on selectionProportions
% % Avoids duplicates and appends best individuals from each cluster to the end.
% 
%     newGeneration = [];
%     newFitnessList = [];
% 
%     for i = 1:length(Clusters)
%         cluster_pop = Clusters(i).Chromosomes;
%         fitness_values = Clusters(i).Individual_Costs;
% 
%         fprintf('Cluster %d: Population size = %d, Fitness size = %d\n', i, size(cluster_pop, 1), length(fitness_values));
% 
%         if isempty(cluster_pop) || isempty(fitness_values)
%             fprintf('Cluster %d has no valid population or fitness values. Skipping.\n', i);
%             continue;
%         end
% 
%         [sorted_fitness, sorted_idx] = sort(fitness_values);
%         sorted_cluster_pop = cluster_pop(sorted_idx, :);
% 
%         num_selected = min(round(selectionProportions(i) * Info.Npop), size(sorted_cluster_pop, 1));
%         if num_selected < 1
%             num_selected = 1;
%         end
% 
%         fprintf('Cluster %d: Selecting %d individuals\n', i, num_selected);
% 
%         selected_individuals = sorted_cluster_pop(1:num_selected, :);
%         selected_fitness = sorted_fitness(1:num_selected);
% 
%         for j = 1:size(selected_individuals, 1)
%             candidate = reshape(selected_individuals(j, :), 1, []);
%             if isempty(newGeneration) || ~ismember(candidate, newGeneration, 'rows')
%                 newGeneration = [newGeneration; candidate];
%                 newFitnessList = [newFitnessList; selected_fitness(j)];
%             end
%         end
%     end
% 
%     %% Append best individual from each cluster
%     for i = 1:length(Clusters)
%         cluster_pop = Clusters(i).Chromosomes;
%         fitness_values = Clusters(i).Individual_Costs;
%         if isempty(cluster_pop)
%             continue;
%         end
% 
%         [min_fitness, idx] = min(fitness_values);
%         best_individual = reshape(cluster_pop(idx, :), 1, []);
%         if size(best_individual, 2) ~= size(newGeneration, 2)
%             continue;
%         end
%         if ~ismember(best_individual, newGeneration, 'rows')
%             newGeneration = [newGeneration; best_individual];
%             newFitnessList = [newFitnessList; min_fitness];
%         end
%     end
% 
%     %% Truncate or pad
%     [~, final_sorted_idx] = sort(newFitnessList);
%     newGeneration = newGeneration(final_sorted_idx, :);
%     newFitnessList = newFitnessList(final_sorted_idx);
% 
%     if size(newGeneration, 1) > Info.Npop
%         newGeneration = newGeneration(1:Info.Npop, :);
%         newFitnessList = newFitnessList(1:Info.Npop);
%     elseif size(newGeneration, 1) < Info.Npop
%         deficit = Info.Npop - size(newGeneration, 1);
% 
%         if size(newGeneration, 1) > 0
%             % Step 1: Duplicate via modulo
%             fill_indices = mod(1:deficit, size(newGeneration, 1));
%             fill_indices(fill_indices == 0) = size(newGeneration, 1);
%             newGeneration = [newGeneration; newGeneration(fill_indices, :)];
%             % Ensure newFitnessList is a column vector
%             if isrow(newFitnessList)
%                 newFitnessList = newFitnessList';
%             end
% 
%             % Ensure fill_indices is a column vector
%             fill_indices = fill_indices(:);
% 
%             % Append replicated fitness values
%             newFitnessList = [newFitnessList; newFitnessList(fill_indices)];
%         else
%             warning('newGeneration is empty. No individuals to replicate.');
%         end
% 
%         % Step 2: Add noise to create new individuals
%         deficit = Info.Npop - size(newGeneration, 1);
%         if deficit > 0 && size(newGeneration, 1) > 0
%             for d = 1:deficit
%                 idx = randi(size(newGeneration, 1));
%                 noisy = newGeneration(idx, :) + randn(1, size(newGeneration, 2)) * 0.01;
%                 newGeneration = [newGeneration; noisy];
%                 newFitnessList = [newFitnessList; inf];
%             end
%         end
%     end
% 
%     %% Format final population
%     pop = repmat(struct('Position1', [], 'Cost', []), Info.Npop, 1);
%     for i = 1:Info.Npop
%         if i <= size(newGeneration, 1)
%             pop(i).Position1 = newGeneration(i, :);
%             pop(i).Cost = newFitnessList(i);
%         else
%             % Handle any potential index mismatch by duplicating the last individual
%             if size(newGeneration, 1) > 0
%                 pop(i).Position1 = newGeneration(end, :); % Duplicate last row
%                 pop(i).Cost = newFitnessList(end);
%             else
%                 % Handle case when newGeneration is empty
%                 warning('newGeneration is empty. Filling with default individuals.');
%                 if ~isempty(Clusters) && isfield(Clusters, 'Chromosomes') && ~isempty(Clusters(1).Chromosomes)
%                     chromosomeLength = size(Clusters(1).Chromosomes, 2);
%                 else
%                     chromosomeLength = Info.Model.J; % fallback if possible
%                 end
%                 pop(i).Position1 = zeros(1, chromosomeLength); % Default empty individual
%                 pop(i).Cost = inf; % Assign infinity cost for empty individuals
%             end
%         end
%     end
% end
