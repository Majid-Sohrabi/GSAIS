function [z, X, cvar]=CostFunction(position, model)
% X = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0;0,0,1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0;1,1,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,1,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0;0,0,0,1,0,1,0,1,0,0,0,0,0,0,0,0,0,1,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1];
[~, X] = CreateXij(position, model);
z=0; 
cij=model.cij; 
bi=model.bi; 
aij=model.aij; 
I=model.I; 
J=model.J;
DIS=model.DIS; 
F=model.F; 
%% Check the feasibility 
% Wij=zeros(I,J);
cvar=zeros(I,1); 
count=zeros(I,1); 
for i=1:I
   for j=1:J
       count(i)=X(i,j)*aij(i,j)+count(i); 
   end
   cvar(i)=bi(i)-count(i);
   % for j=1:J
   %     Wij(i,j)=aij(i,j)*X(i,j); 
   % end
end

%% Objective function 
if sum(cvar<0) > 0
    z = inf;
else

    % for i=1:I
    %     for j=1:J
    %         for k=1:I
    %             for l=1:j
    %         z=z+cij(i,j)*X(i,j)+X(i,j)*X(k,l)*DIS(i,k)*F(j,l);
    %             end
    %         end
    %     end
    % end

 % Objective
    c1=0;
    for i=1:I
        for j=1:J
            c1=c1+cij(i,j)*X(i,j);
        end
    end

    c2=0;
    for i=1:I
        for j=1:J
            for k=1:I
                for l=1:J
                    c2=c2+F(j,l)*DIS(i,k)*X(i,j)*X(k,l);
                end
            end
        end
    end

    z=c1+c2;

% if sum(cvar<0) > 0
%     initial_penalty=100000;
%     z=z+sum(cvar<0)*initial_penalty;
% 
%     mul_penalty=10000;
%     z=z+sum(abs(cvar(cvar<0)) * mul_penalty);
% end

% for i=1:I
%     if X(i,:)==0
%         z = inf;
%         break;
%     end
% end

cvar = sum(cvar<0);
% cvar=cvar;
end

