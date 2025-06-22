function [Ans1 Ans2]=Crossover_Uniform(p,Model)
n=size(p(1).Position,2);
Mask=randsample(0:1,n,1);
Position1=p(1).Position;
Position2=p(2).Position;
for i=1:n
    if(Mask(i)==0)
        temp=Position1(i);
        Position1(i)=Position2(i);
        Position2(i)=temp;
    end
end 
Ans1.Position=Position1;
Ans1.Cost=Cost(Ans1.Position,Model);
Ans2.Position=Position2;
Ans2.Cost=Cost(Ans2.Position,Model);
end
