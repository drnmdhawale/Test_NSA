function  [OFAFTER, IND1, OF1AFTER]  = NSA_Addcell(NSA_DATA, NSA_ZONE, FDV, R2max, pp, m)
%TEMP_INDS=find(NSA_ZONE~=m & NSA_ZONE~=0);%%get indices of all cells except that are having the value of the present m
TEMP_INDS=find(NSA_ZONE==1);
NBRS=0;%%array element to store the valid neighbours

%% code to select only neighbour cell elements among rest
for i=1:1:length(TEMP_INDS)
IND=TEMP_INDS(i);
NBR_VALID=NSA_NBR_VALID(IND,NSA_ZONE,m);%%test the chosen neighbor element if valid
if NBR_VALID==1,
NBRS(i)=IND;
end
NBRS(NBRS==0)=[];%%store the potential neighbors
end

%% the next part of the code is to check the value of stored neighbor
%%indices and to decide the strategy to grow the cluster
%%now its time to define what are the strategies
if length(NBRS~=0)
                          
for i=1:1:length(NBRS)
    TEMPm=NSA_ZONE(NBRS(i));
    NSA_ZONE(NBRS(i))=m;

for k=3:1:pp
    OF1AFTER(k-2)=NSA_ERR(NSA_DATA(:,:,k),NSA_ZONE);%%Error after virtual growth
end
    OFAFTER=prod((1-OF1AFTER./FDV).^R2max); 
    E1(i,:) = [OFAFTER, NBRS(i), OF1AFTER];
    NSA_ZONE(NBRS(i))=TEMPm;
end
    
    CAND1=sortrows(E1,1); %clear E1;
    CAND1((find(CAND1(:,1)==0)),:)=[];
    IND1=CAND1(end,2);
    OFAFTER=CAND1(end,1);
    OF1AFTER=CAND1(end,3:end);
else
    %disp('Ran out of neighbour cells (1s)')
    OFAFTER=0; IND1=0; OF1AFTER(:,1:(pp-2))=0;
end

end