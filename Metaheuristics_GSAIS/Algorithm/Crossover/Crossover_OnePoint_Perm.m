function [Ans1 Ans2]=Crossover_OnePoint_Perm(p,model)
    
    q1=p(1).Position;
    q2=p(2).Position;
    n=numel(q1);
    s=1:n;
    i=randsample(1:n-1,1);
    y1=[q1(1:i) q2(i+1:end)];
    y2=[q2(1:i) q1(i+1:end)];
    
    %% First Child
    j=intersect(y1(1:i),y1(i+1:end));
    if j>0
        for h=1:numel(j)
            l(h)=find(y1==j(h),1,'first');
            y1(l(h))=inf;
        end
        f=intersect(y1,s);
        s(f)=0;
        d=find(s>0);
        g=1;
        for ii=l
            y1(ii)=d(g);
            g=g+1;
        end
    end
    
    Ans1.Position=y1;
    Ans1.Cost=Cost(Ans1.Position,model);
    
    %% Second Child
    m=1:numel(q1);
    k=intersect(y2(1:i),y2((i+1:end)));
    if k>0
       for h=1:numel(k) 
          l(h)=find(y2==k(h),1,'first');
          y2(l(h))=inf;
       end
       t=intersect(y2,m);
       m(t)=0;
       r=find(m>0);
       g=1;
       for ii=l
         y2(ii)=r(g);
         g=g+1; 
         if numel(r)<g
             break
         end
       end
    end
    
    Ans2.Position=y2;  
    Ans2.Cost=Cost(Ans2.Position,model);

end