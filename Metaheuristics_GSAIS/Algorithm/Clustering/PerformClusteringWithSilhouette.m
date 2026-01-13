function [bestLabels, bestK, silhouetteValues, popLabels_k, silhouetteHistory, Clusters] = ...
    PerformClusteringWithSilhouette(popMatrix, pop, Info)

% Fixed cluster size
k = Info.cluster_sizes;  % e.g., 4
bestK = k;

% Apply K-means clustering
[bestLabels, ~] = kmeans(popMatrix, Info.cluster_sizes, ...
    'Distance', 'sqeuclidean', ...
    'Replicates', 5, ...
    'MaxIter', 100);

% Compute Silhouette Scores
silhouetteValues = silhouette(popMatrix, bestLabels, 'sqeuclidean');
silhouetteHistory = silhouetteValues;

% Store labels (as cell for compatibility)
popLabels_k = {bestLabels};

% Assign clusters to structure
unique_labels = unique(bestLabels);
Clusters = struct();
for i = 1:length(unique_labels)
    label = unique_labels(i);
    cluster_indices = find(bestLabels == label);
    Clusters(i).Label = label;
    Clusters(i).Chromosomes = popMatrix(cluster_indices, :);
    Clusters(i).Individual_Costs = [pop(cluster_indices).Cost]';
    Clusters(i).Fitness = mean(Clusters(i).Individual_Costs);
end

end