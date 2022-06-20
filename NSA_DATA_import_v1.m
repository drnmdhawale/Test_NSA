function  NSA_DATA_import_v1(FILENAME)
%close all%%close all figures

%%%%%%%%%%%%%%%%%
%%%STEP-1%%%
%%%%%%%%%%%%%%%%%

M=importdata(FILENAME,'\t');
[n,m]=size(M.data); t=1:n;
for i=1:1:m
NSA_RDATA(:,i)=M.data(:,i);
NSA_RDATA_COLHEAD(:,i)=M.colheaders(:,i);
end
save('NSA_RDATA','NSA_RDATA'); %saving raw data
save('NSA_RDATA_COLHEAD','NSA_RDATA_COLHEAD');%saving raw data column headers
save('NSA_FILENAME','FILENAME') %saving raw data file name
clear 

%%%%%%%%%%%%%%%%%
%%%STEP-2%%%
%%%%%%%%%%%%%%%%%

load NSA_RDATA;
%Paramters/formulas
phi=mean(NSA_RDATA(:,2));
h=mean(NSA_RDATA(:,3));%height over elipsoid
a=6378137;%semi-major axis
b=6356732.3142;%semi-minor axis
f=0.0033528;%inverse of ellipsoid flattening
N=6388838;%radii
M=6367382;%radii
W=0.998325;
F_lon=cos(pi/180*phi)*(N+h)*pi/180;%%using stand alone
F_lat=pi/180*(M+h);%%using stand alone

for l=1:1:size(NSA_RDATA,2)
NSA_MDATA(:,l)=NSA_RDATA(:,l);
end

%%code to scale the projected co-ordinates from zero to max
MIN_X=min(NSA_RDATA(:,1));
MIN_Y=min(NSA_RDATA(:,2));
for j=1:1:length(NSA_RDATA)
NSA_MDATA(j,1)=F_lon*(NSA_RDATA(j,1)-MIN_X);
NSA_MDATA(j,2)=F_lat*(NSA_RDATA(j,2)-MIN_Y);
end

%%code to scale the remaining variables between 0 -to max or between 0- to 100%
for i=3:1:size(NSA_RDATA,2)
MIN_Zn=min(NSA_RDATA(:,i));%-((0.01/100)*min(NSA_RDATA(:,i)));%scaling type1
%MAX_Zn=max(NSA_RDATA(:,i));%scaling type2
%STD_Zn=std(NSA_RDATA(:,i)); %scaling type3
for j=1:1:length(NSA_RDATA)
NSA_MDATA(j,i)=(NSA_RDATA(j,i)-(MIN_Zn+0.00001));%scaling type1
%NSA_MDATA(j,i)=((NSA_RDATA(j,i)-MIN_Zn)/(MAX_Zn-MIN_Zn))*100;%scaling type2
%NSA_MDATA(j,i)=((NSA_RDATA(j,i)-MIN_Zn)/STD_Zn);%scaling type3
end
end

NSA_MDATA1=[MIN_X MIN_Y F_lon F_lat];
save('NSA_MDATA','NSA_MDATA');%saving metric transformed data
save('NSA_MDATA1','NSA_MDATA1');%saving back transformation data
clear 

%%%%%%%%%%%%%%%%%
%%%STEP-3%%%
%%%%%%%%%%%%%%%%%

load NSA_MDATA;
gdsz=20;%grid size
hgd=gdsz/2;%center of the grid cell

londx=0:gdsz:round(max(NSA_MDATA(:,1))); %grid elements
latdx=0:gdsz:round(max(NSA_MDATA(:,2))); %grid elements

%%code using loop
for k=1:size(NSA_MDATA,2)
    for i=1:length(latdx)
        for j=1:length(londx)
ind=find(NSA_MDATA(:,2)<=latdx(i)+hgd & NSA_MDATA(:,2)>latdx(i)-hgd...
 & NSA_MDATA(:,1)<=londx(j)+hgd & NSA_MDATA(:,1)>londx(j)-hgd);

    if k==1,
        NSA_GDATA(i,j,k)=londx(j)+hgd;
    end

    if k==2,
        NSA_GDATA(i,j,k)=latdx(i)+hgd;
    end

    if k>2
        NSA_GDATA(i,j,k)=nanmean(NSA_MDATA(ind,k));%nanmean()
    end

        end
    end
end

save('NSA_GDATA','NSA_GDATA');%saving grid averaged data
save('NSA_GDATA1','gdsz'); %saving grid cell size
clear 

%%%%%%%%%%%%%%%%%
%%%STEP-4%%%
%%%%%%%%%%%%%%%%%

load NSA_GDATA
load NSA_RDATA_COLHEAD
load NSA_GDATA1

% code to add top/bottom rows and left/right columns
% and assign zeroes to all border elements
NSA_DATA=NSA_GDATA;
nan_ind=find(isnan(NSA_DATA));%%find indices of all NaN elements
NSA_DATA(nan_ind)=0;%%replace NaN elements by zeros
r=size(NSA_DATA,1);c=size(NSA_DATA,2); %get size of row and column
addcol=1:1:r; addcol(:)=0; addcol=addcol'; %enter col values according to size
addrow =1:1:c+2; addrow(:)=0; %enter row values according to size

for k=1:1:size(NSA_DATA,3)
    tempNSA_DATA=NSA_DATA(:,:,k); % use a temporary matrix
    tempNSA_DATA=[addcol tempNSA_DATA] ;
    tempNSA_DATA=[tempNSA_DATA addcol];
    tempNSA_DATA=[addrow; tempNSA_DATA];
    tempNSA_DATA=[tempNSA_DATA; addrow];
    NSA_DATA1(:,:,k)=tempNSA_DATA;
end
    k=1; %enter new longitude values according to added columns and rows
    tempNSA_DATA=NSA_DATA1(:,:,k); % use a temporary matrix
    tempNSA_DATA(1,:)=NSA_DATA1(2,:,k);
    tempNSA_DATA(end,:)=NSA_DATA1(end-1,:,k);
    tempNSA_DATA(:,1)=tempNSA_DATA(:,2)-gdsz ;
    tempNSA_DATA(:,end)=tempNSA_DATA(:,end-1)+gdsz;
    NSA_DATA1(:,:,k)=tempNSA_DATA;

    k=2; %enter new latitude vlaues according to added columns and rows
    tempNSA_DATA=NSA_DATA1(:,:,k); % use a temporary matrix
    tempNSA_DATA(:,1)=tempNSA_DATA(:,2);
    tempNSA_DATA(:,end)=tempNSA_DATA(:,end-1);
    tempNSA_DATA(1,:)= tempNSA_DATA(2,:)-gdsz ;
    tempNSA_DATA(end,:)=tempNSA_DATA(end-1,:)+gdsz;
    NSA_DATA1(:,:,k)=tempNSA_DATA;

NSA_DATA=NSA_DATA1;
clear NSA_DATA1 tempNSA_DATA

%%code to perform median filter
for k=3:1:size(NSA_DATA,3)
NSA_DATA1(:,:,k)=medfilt2(NSA_DATA(:,:,k), [5 5]);%apply single run filter
NSA_DATA1(:,:,k)=medfilt2(NSA_DATA1(:,:,k), [5 5]);%apply double run filter
[r,c]=find(NSA_DATA(:,:,k)==0);
for i=1:1:length(r)
NSA_DATA(r(i),c(i),k)=NSA_DATA1(r(i),c(i),k);
end
clear r; clear c;
end

%%%%%%%%%%########TestCodeFollows#########%%%%%%%%%%
% for i=3:size(NSA_DATA,3)
% figure(i)
% NSA_STR1=NSA_RDATA_COLHEAD(i);
% surf(NSA_DATA(:,:,1),NSA_DATA(:,:,2),NSA_DATA(:,:,i))
% view(-4,60)
% colorbar
% xlabel('Easting')
% ylabel('Northing')
% zlabel(NSA_STR1)
% title(NSA_STR1)
% end
%%%%%%%%%%########TestCodeEnds#########%%%%%%%%%%

%Creating a flag matrix
NSA_ZONE1=NSA_DATA(:,:,3);
NSA_ZONE1(find(NSA_DATA(:,:,3)~=0))=1;
save('NSA_DATA','NSA_DATA','NSA_ZONE1')%%stores only the specified variables.
clear 
end
