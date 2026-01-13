function [Ans1 Ans2]=Crossover(p, model)
    
    Index = randi([1, 2]);
    Index = 1;

    if(Index==1)
        [Ans1 Ans2]=Crossover_OnePoint(p,model);
        
    elseif (Index==2)
        [Ans1 Ans2]=Crossover_TwoPoint(p,model);
        
    % elseif (Index==3)
    %     [Ans1 Ans2]=Crossover_Uniform(p,model);
    % 
    % elseif (Index==4)
    %     [Ans1 Ans2]=Crossover_OnePoint_Perm(p,model);
end

