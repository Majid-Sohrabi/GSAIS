function AddPaths(Str)
%% Algorithm directory
addpath([Str , 'Algorithm']);
addpath([Str , 'Algorithm/Clustering']);
addpath([Str , 'Algorithm/Crossover']);
addpath([Str , 'Algorithm/MaskMutation']);
addpath([Str , 'Algorithm/Mutation']);

%% Problem directory
addpath([Str , 'Problem']);
addpath([Str , 'Problem/Generalized_Quadratic']);
addpath([Str , 'Problem/Generalized_Quadratic/data']);
end
