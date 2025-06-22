function [bestLabels, popLabels_k, Clusters] = PerformWishartClustering(popMatrix, pop, Info)

% Parameters
k = Info.cluster_sizes;                 % e.g., 5 (number of neighbors)
alpha = 0.05;                   % Significance level
df = size(popMatrix, 2) + 1;    % Degrees of freedom for Wishart (p+1)

% Step 1: Estimate local density
n = size(popMatrix, 1);
density = zeros(n, 1);

for i = 1:n
    dists = sqrt(sum((popMatrix - popMatrix(i, :)).^2, 2));
    sortedDists = sort(dists);
    density(i) = 1 / (mean(sortedDists(2:k+1)) + eps);
end

% Step 2: Generate threshold using Wishart samples
covMat = cov(popMatrix);
samples = zeros(1000, 1);
for i = 1:1000
    W = wishrnd(covMat, df);
    samples(i) = trace(W);  % Can change to other metrics
end
wishart_threshold = quantile(samples, 1 - alpha);
density_threshold = prctile(density, 100 * (1 - alpha));

% Step 3: Identify dense points
densePoints = find(density > density_threshold);

% Step 4: Cluster expansion (like DBSCAN)
labels = zeros(n, 1);
clusterID = 0;
visited = false(n, 1);

for i = densePoints'
    if ~visited(i)
        clusterID = clusterID + 1;
        queue = i;
        visited(i) = true;
        labels(i) = clusterID;

        while ~isempty(queue)
            idx = queue(end); queue(end) = [];
            dists = sqrt(sum((popMatrix - popMatrix(idx, :)).^2, 2));
            neighbors = find(dists <= mean(dists(densePoints)));

            for j = neighbors'
                if ~visited(j) && density(j) > density_threshold
                    visited(j) = true;
                    labels(j) = clusterID;
                    queue(end + 1) = j;
                elseif labels(j) == 0
                    labels(j) = clusterID;  % Border point
                end
            end
        end
    end
end

% Assign unclustered points to -1 (noise)
labels(labels == 0) = -1;

% Silhouette for non-noise points
validIdx = labels ~= -1;
if sum(validIdx) > 1
    silhouetteValues = silhouette(popMatrix(validIdx, :), labels(validIdx), 'sqeuclidean');
else
    silhouetteValues = zeros(sum(validIdx), 1);
end

popLabels_k = {labels};
bestLabels = {labels};

% Cluster structures
unique_labels = unique(labels(labels ~= -1));
Clusters = struct();
for i = 1:length(unique_labels)
    label = unique_labels(i);
    cluster_indices = find(labels == label);
    Clusters(i).Label = label;
    Clusters(i).Chromosomes = popMatrix(cluster_indices, :);
    Clusters(i).Individual_Costs = [pop(cluster_indices).Cost]';
    Clusters(i).Fitness = mean(Clusters(i).Individual_Costs);
end
end