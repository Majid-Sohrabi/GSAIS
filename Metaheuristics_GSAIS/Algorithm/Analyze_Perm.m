function [DominantGenes, Mask, DominantChromosome, Mask_Dominant]=Analyze_Perm(pop,Info)
%% Data Definition
Npop=size(pop,1);
n=size(pop(1).Position1,2);
NFixedX=floor(Info.PFixedX*Npop);
Mask=zeros(Info.PScenario1*Info.Npop, n);
%% Find Dominant Gene
row=1;
while(row<=Npop)
    col=1;
    while(col<n)
        row_inner=1;
        temp=0;
        while(row_inner<=Npop)
            if (row==row_inner)
                row_inner=row_inner+1;
                continue
            end

            if (pop(row).Position1(1,col) == pop(row_inner).Position1(1,col))
                if (pop(row).Position1(1,col+1) == pop(row_inner).Position1(1,col+1))
                    temp=temp+1;
                end
            end
            row_inner=row_inner+1;
        end

        if (temp>=NFixedX)
            Mask(row, col) = 1;
            Mask(row, col+1) = 1;
            col=col+2;
        else
            col=col+1;
        end
    end
    row=row+1;
end
%%
% i=1;
% while (i<n)
%     % DominantGene=[];
%     Gens_1 = [];
%     Gens_2 = [];
%     for j=1:Npop
%         Gens_1=[Gens_1,pop(j).Position(1,i)];
%         Gens_2=[Gens_2,pop(j).Position(1,i+1)];
%     end
% 
%     for k=1:size(Gens_1,2)
%         temp = 0;
%         for kk=1:size(Gens_1,2)
%             if (k==kk)
%                 continue
%             end
%             if (Gens_1(k)==Gens_1(kk))
%                 if (Gens_2(k)==Gens_2(kk))
%                     temp=temp+1;
%                 end
%             end
%         end
% 
%         if (temp>=NFixedX)
%             Mask(k, i) = 1;
%             Mask(k, i+1) = 1;
%         end
% 
%     end
% end

%%

%% Create Ans :
%Dominant
% DominantGenes=Ans(1,:);
count = 0;
Domin = [];
Mask_Dominant = [];
for i=1:Npop
    temp=sum(Mask(i,:)==1);
    % Mask(i,:);
    if (temp>=count)
        if (size(Domin,2)==0)
            Domin=pop(i).Position1;
            Mask_Dominant=Mask(i,:);
        else
            decision = rand(1);
            if (decision>0.5)
                Domin=pop(i).Position1;
                Mask_Dominant=Mask(i,:);
            end
        end
        count = temp;
    end
end

DominantChromosome.Position1=Domin;
[DominantChromosome(1).Position1, DominantChromosome(1).Xij] = CreateXij(DominantChromosome(1).Position1, Info.Model);
% evaluate
[DominantChromosome(1).Cost, DominantChromosome(1).Xij, DominantChromosome(1).CVAR]=CostFunction(DominantChromosome(1).Xij, Info.Model);
DominantGenes.Position1 = DominantChromosome;
end






% %% Data Definition
% Npop=size(pop,1);
% IndexI=Info.Model.I;
% IndexJ=Info.Model.J; 
% % n=size(pop(1).Position1,2);
% NFixedX=floor(Info.PFixedX*Npop);
% 
% individual.mask=[];
% Mask=repmat(individual,Npop,1);
% for i=1:Npop
%     Mask(i).mask=zeros(IndexI, IndexJ);
% end
% 
% % Mask=zeros(Info.PScenario1*Info.Npop, n);
% %% Find Dominant Gene
% 
% chrom=1;
% while(chrom<=Npop)
%     col=1;
%     while(col<=IndexJ)
%         row=1;
%         while(row<IndexI)
%             Innerchrom=1;
%             counter=0;
%             while(Innerchrom<=Npop)
%                 if (chrom==Innerchrom)
%                     Innerchrom=Innerchrom+1;
%                     continue
%                 end
% 
%                 if (pop(chrom).Position1(row,col) == pop(Innerchrom).Position1(row,col))
%                     if (pop(chrom).Position1(row+1,col) == pop(Innerchrom).Position1(row+1,col))
%                         counter=counter+1;
%                     end
%                 end
%                 Innerchrom=Innerchrom+1;
%             end
% 
%             if (counter>=NFixedX)
%                 Mask(chrom).mask(row, col) = 1;
%                 Mask(chrom).mask(row+1, col) = 1;
%                 row=row+2;
%             else
%                 row=row+1;
%             end
%         end
%         col=col+1;
%     end
%     chrom=chrom+1;
% end
% 
% %% Create Ans :
% %Dominant
% % DominantGenes=Ans(1,:);
% num_of_fixed=0;
% for i=1:Npop
%     temp=sum(sum(Mask(i).mask));
%     if (num_of_fixed<temp)
%         num_of_fixed=temp;
%         % dominant_index=i;
%         DominantChromosome=pop(i);
%         Mask_Dominant=Mask(i).mask;
%     end
% end
% 
% 
% % count = 0;
% % DominantChromosome = [];
% % Mask_Dominant = [];
% % for i=1:Npop
% %     temp=sum(Mask(i,:)==1);
% %     % Mask(i,:);
% %     if (temp>=count)
% %         if (size(DominantChromosome,2)==0)
% %             DominantChromosome=pop(i).Position;
% %             Mask_Dominant=Mask(i,:);
% %         else
% %             decision = rand(1);
% %             if (decision>0.5)
% %                 DominantChromosome=pop(i).Position;
% %                 Mask_Dominant=Mask(i,:);
% %             end
% %         end
% %         count = temp;
% %     end
% % end
% 
% DominantGenes = DominantChromosome;
% end
