function GET_ZONE_COI_v12(handles)
%% Import NSA DATA
clc; 
load NSA_FILENAME
load NSA_RDATA_COLHEAD
load NSA_GDATA1
load NSA_OUTPUT

%% Start processing
ZONES=NSA_ZONE;
FZONE=ZONES; %clone data
FZONE2=FZONE; %clone data
LON=NSA_DATA(:,:,1);
LAT=NSA_DATA(:,:,2);
[ZH,ZW,~]=size(FZONE);
S=[ZH,ZW];%%size
t=linspace(0,2*pi,500);%%approximate circle

for ZONES=1:1:max(FZONE(:))%%to scan each independant zone
disp('Searching for COI in Group No.')
disp(ZONES)
ZH1=range(LON(find(FZONE==ZONES)))/20;
ZW1=range(LAT(find(FZONE==ZONES)))/20;
S1=[ZH1+1,ZW1+1];%% size
X=[];Y=[];Z=[];%%define some variables
PPI1=[];PPI2=[];tp=[];%%define some variables
summary=[];ZIND1=[];%%clear variables on referenced memory
COUNT3=[];COUNT4=[];%%define some variables
ZIND1=find(FZONE==ZONES);%%get the reference memory locations 
                               %on all pixels inside the selected zone

for r=1:max(S1);%%loop to change the circle radius

for CEN=1:length(ZIND1)%%get the first original referenced position

%%circle params
[row,col]=ind2sub(S,ZIND1(CEN));%%radius
c=[col row];%%center

%%createacircularmask
BW=poly2mask(r*cos(t)+c(1),r*sin(t)+c(2),ZH,ZW);

COUNT1=length(find(FZONE(find(BW==1))==ZONES))/length(find(BW==1));
COUNT2=length(find(FZONE(find(BW==1))==ZONES));
COUNT3(CEN,r)=COUNT1;
COUNT4(CEN,r)=COUNT2;

end

end

summary=[max(COUNT3);max(COUNT4)];%%choose the max from counts and save in another variable
tp=find(summary(1,:)==1);%%define a temporary variable
cellcount=max(summary(2,tp(end)));%%%perhaps not correct
PPI1=find(COUNT4(:,tp(end))==cellcount);%%%perhaps not correct
ltp=length(tp);
ii=1;

if length(PPI1)==1
PPI=PPI1;
ii=tp(end);
else
PPI2=PPI1;
end

ii=tp(end);
jj=1;

while length(PPI2)>1,
cellcount=max(COUNT4(PPI1,tp(end)+jj));%%%perhaps not correct
PPI=find(COUNT4(PPI1,tp(end)+jj)==cellcount);%%%perrhaps not correct
PPI=PPI1(PPI);%%%perhaps not correct
PPI2=PPI;

if (ii+jj)>=r,
if length(PPI2)>1;
PPI=PPI(1);
jj=0;
end
break;
end

jj=jj+1;

end

ii=ii+jj-1;

TEST_LOC(ZONES)=ZIND1(PPI);
TEST_LOC_RADIUS(ZONES)=ltp;
% [row,col]=ind2sub(S,ZIND1(PPI));%#radius
% c=[col row];%#center
% X=(ltp-0.5)*gdsz*cos(t)+((col*gdsz)-0.5);
% Y=(ltp-0.5)*gdsz*sin(t)+((row*gdsz)-0.5);
% Z=Y;
% Z(:)=ZONES;
% figure(2)
% fill3(X,Y,Z,ZONES)
% pause(0.0000001)
% clear X Y Z
end

%% Display figure
%h=figure(20);
handles.Lon=NSA_DATA(:,:,1);
handles.Lat=NSA_DATA(:,:,2);
for i=1:1:ZONES,
FZONE2(TEST_LOC(i))=ZONES+1;
handles.Grp=FZONE2;
surf(handles.Lon,handles.Lat,handles.Grp)
colorbar
view(0,90)
hold on
end
NSA_MAXTICK=0:max(max(FZONE2));
view(0,90)
axis([0,max(max(handles.Lon)),0,max(max(handles.Lat))])
% xlabel('Easting')
% ylabel('Northing')
% zlabel('GroupNo.')
% STR1 = strrep(FILENAME,'.txt','');
% STR1 = strrep(STR1,'_',' ');
% STR2=strcat(STR1, ' ','Centers');
% print(h,STR2,'-djpeg')
% clear h

%% Save data
load NSA_MDATA
load NSA_MDATA1
for i=1:1:ZONES,
[row,col]=ind2sub(S,TEST_LOC(i));
format long
NSA_TEST_LOC_DATA(i,:)=[TEST_LOC(i), TEST_LOC_RADIUS(i), row, col, ...
    ((gdsz*(col-1.7071))+(NSA_MDATA1(3)*NSA_MDATA1(1)))/NSA_MDATA1(3),...
    ((gdsz*(row-1.7071))+(NSA_MDATA1(4)*NSA_MDATA1(2)))/NSA_MDATA1(4)];
end

format short
for i=1:1:ZONES,
    [row,col]=ind2sub(S,TEST_LOC(i));
    for j=3:1:size(NSA_DATA,3),
        NSA_TEST_LOC_VAL(i,j)=NSA_DATA(row,col,j);
    end
end
NSA_TEST_LOC_VAL(:,1:2)=[];

%% Write data to existing excel file
NEW_FILENAME = strrep(FILENAME,'.txt','.xls');

col_header1={'Centre','Radius','Row No.','Column No.','Longitude','Latitude'};
col_header2=NSA_RDATA_COLHEAD(:,3:end);
xlswrite(NEW_FILENAME,col_header1,'GRPCELCOUNT','C1');
xlswrite(NEW_FILENAME,col_header2,'GRPCELCOUNT','I1');
xlswrite(NEW_FILENAME,NSA_TEST_LOC_DATA,'GRPCELCOUNT','C2');
xlswrite(NEW_FILENAME,NSA_TEST_LOC_VAL,'GRPCELCOUNT','I2');

result=xlsread(NEW_FILENAME, 'GRPCELCOUNT');
%delete (NEW_FILENAME)
NSA_STR1=strcat('_', FILENAME);
dlmwrite(NSA_STR1,result,'delimiter','\t','precision',9)
end