function [bestLabels, bestK, silhouetteValues, popLabels_k, silhouetteHistory, Clusters] = PerformNNWithSilhouette(popMatrix, pop, Info)

nPoints = size(popMatrix,1);

% Step 1: Compute pairwise distances
distMatrix = pdist2(popMatrix, popMatrix, 'euclidean');

% Step 2: k-th nearest neighbor distances (k = MinPts)
kNN = min(Info.MinPts, nPoints-1);  % you can tune MinPts
sortedDists = sort(distMatrix, 2);
kthDist = sortedDists(:, kNN+1);  % distance to k-th neighbor

% Step 3: Estimate epsilon threshold automatically
% epsilon = median(kthDist);  % or mean(kthDist) for smoother clustering
epsilon = Info.alpha_eps * median(kthDist);

% Step 4: Build adjacency matrix: neighbors within epsilon
adj = distMatrix <= epsilon;

% Step 5: Find connected components as clusters
G = graph(adj);
bins = conncomp(G);  % each connected component is a cluster

bestLabels = bins;       % cluster labels
bestK = max(bins);       % number of clusters

% Store labels for compatibility
popLabels_k = {bestLabels};

% Compute Silhouette Values
silhouetteValues = silhouette(popMatrix, bestLabels, 'sqeuclidean');
silhouetteHistory = silhouetteValues;

% Create cluster structures
Clusters = struct();
for i = 1:bestK
    idxCluster = find(bestLabels == i);
    Clusters(i).Label = i;
    Clusters(i).Chromosomes = popMatrix(idxCluster, :);
    Clusters(i).Individual_Costs = [pop(idxCluster).Cost]';
    Clusters(i).Fitness = mean(Clusters(i).Individual_Costs);
end

end
