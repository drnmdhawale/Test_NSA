function  [OFNEWBASE, IND, MSENEWBASE]  = NSA_Base(NSA_DATA, NSA_ZONE, FDV, SDV, R2max, S, I, pp, m)
%ELMT=find(NSA_ZONE<m & NSA_ZONE~=0);%find all points in data that are not zeros
ELMT=find(NSA_ZONE==1); 
%% code to find group centers resulting in highest OF. This code is to search 
% for a new uniform group within the area of the all groups and to establish 
% it as the a new base, that could potentially grow bigger.

for i=1:1:length(ELMT) % until last element
IND=ELMT(i);[row,col]=ind2sub(S,IND); % get local value of the row and col of the test element
ZWINDOW=NSA_ZONE(row-I:row+I,col-I:col+I);%%select a window of 3X3 cells
NHOOD_VALID=NSA_NHOOD_VALID(ZWINDOW);%%check for valid elements, value is 1 if element is valid else it is 0
if NHOOD_VALID==1,
NSA_ZONE(row-I:row+I,col-I:col+I)=m;%%replace the test element with group numbers value
for k=3:1:pp
MSE(k-2)=NSA_ERR(NSA_DATA(:,:,k),NSA_ZONE);%%calculate MSE with test element for the layer pp 
end
% code to fix the negative value if occured
for k=3:1:pp
    if  MSE(k-2)/FDV(k-2)>1
        MSE(k-2)=FDV(k-2);
    end
end
OF=prod((1-MSE./FDV).^R2max); % calculate the objective funtion (product of R2 with power term)
E(i,:)=[OF, IND, MSE]; % save the error and the indice of the test element
NSA_ZONE(row-I:row+I,col-I:col+I)=ZWINDOW;%relace the test element with its original value

end %if NHOOD_VALID~=1

end

if exist('E')
CAND=sortrows(E,1);%clear E %%sort the errors and indices in order
CAND((find(CAND(:,1)==0)),:)=[];
IND=CAND(end,2);%%choose the largest and the last test element
OFNEWBASE=CAND(end,1);
MSENEWBASE=CAND(end,3:end);
else
%disp('Ran out of 1s to form new base')
IND=0; OFNEWBASE=0; MSENEWBASE(:,1:(pp-2))=0;
end
    




