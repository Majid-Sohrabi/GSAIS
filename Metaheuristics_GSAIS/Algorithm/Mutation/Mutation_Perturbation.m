function Ans=Mutation_Perturbation(q,Model)
n=size(q,2);
Point=randsample(1:n,1);
q(Point)=q(Point)+(1/(Model.Max-Model.Min));
if (q(Point)>=Model.Max)
   q(Point)=q(Point)-Model.Min; 
end

Ans.Position=q;
Ans.Cost=Cost(q,Model);
end
