function Clusters = AssignPredatorPreyRoles(Clusters, Npop, gamma)
% AssignPredatorPreyRoles assigns each cluster a role: 'Predator' or 'Prey'
% using a probabilistic method based on cluster size and a constant γ.
%
% INPUTS:
%   Clusters - Struct array with field Chromosomes (to get N_i)
%   Npop     - Total number of individuals in the population
%   gamma    - Constant (e.g., 0.25)
%
% OUTPUT:
%   Clusters - Updated struct with new field 'Type' = 'Predator' or 'Prey'

    s = length(Clusters);  % Number of clusters

    for i = 1:s
        N_i = size(Clusters(i).Chromosomes, 1);  % Number of individuals in cluster i

        % Compute probability of being a predator
        p_i = (Npop / (N_i * s)) * (gamma / (1 + gamma));

        % Assign type based on random draw
        if rand() < p_i
            Clusters(i).Type = 'Predator';
        else
            Clusters(i).Type = 'Prey';
        end

        % Optional: Store the probability for debugging/analysis
        Clusters(i).PredatorProbability = p_i;
    end
end
