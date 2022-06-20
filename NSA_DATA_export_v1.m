function NSA_DATA_export_v1
load NSA_OUTPUT
load NSA_RDATA_COLHEAD
load NSA_FILENAME
%FZONE=NSA_ZONE;%%the output map
[rr cc pp]=size(NSA_DATA);

NSA_STR1='w/o-Median-';
NSA_STR2=FILENAME;
NSA_STR3=strrep(NSA_STR2, '.txt', ' ');
NSA_STR3=strrep(NSA_STR3, '_', ' ');

%% calculate the R2 for all input layers
for i= 1:1:pp-2,
    R2(:,i)=1-(MSEF(:,i)/FDV(:,i));
end
PERFORM_INDX=[(0:1:(length(R2)-1))',objFG,objF,R2];

%% %%%%%%%%########Enable CODE to display all input layers#########%%%%%%%%%%
for i=3:size(NSA_DATA,3)
h=figure(i);
%h.PaperPositionMode = 'auto';
NSA_STR4=NSA_RDATA_COLHEAD(i);
Temp_NSA_DATA=NSA_DATA(:,:,i);
Temp_NSA_DATA(find(NSA_ZONE==0))=0;
surf(NSA_DATA(:,:,1),NSA_DATA(:,:,2),Temp_NSA_DATA)
%view(-4,60)
view(0,90)
colorbar
xlabel('Easting')
ylabel('Northing')
zlabel(NSA_STR4)
title(NSA_STR4)
pause(0.000001)
NSA_STR5=strcat(NSA_STR3, ' ', num2str(i));
print(h,NSA_STR5,'-djpeg')
clear h
%calculate general statistics and used parameters according to input layers
GEN_STATS(i-2,:)=[min(Temp_NSA_DATA(find(Temp_NSA_DATA>0))), ...
    median(Temp_NSA_DATA(find(Temp_NSA_DATA>0))), max(Temp_NSA_DATA(find(Temp_NSA_DATA>0))), ...
    mean(Temp_NSA_DATA(find(Temp_NSA_DATA>0))), range(Temp_NSA_DATA(find(Temp_NSA_DATA>0)))];
SPA_PARAM(i-2,:)=[SDV(:,i-2),FDV(:,i-2),R2max(:,i-2)];
end
%%%%%%%%%%########CodeEnds#########%%%%%%%%%%

%% %%%%%%%%########Enable CODE to display output map#########%%%%%%%%%%
h=figure(20);
%h.PaperPositionMode = 'auto';
colormap('default');
surf(NSA_DATA(:,:,1),NSA_DATA(:,:,2),NSA_ZONE)
NSA_MAXTICK=0:max(max(NSA_ZONE));
set(colorbar,'YTick',NSA_MAXTICK)
view(0,90)
xlabel('Easting')
ylabel('Northing')
zlabel('GroupNo.')
title(strcat(NSA_STR1,NSA_STR2))
pause(0.000001)
print(h,NSA_STR3,'-djpeg')
clear h;

%% %%%%%%%%########Enable CODE to display chart for objective function values #########%%%%%%%%%%
h=figure(21);
plot(objF, 'k.', ...
    'LineWidth',2,...
    'MarkerSize',7,...
    'MarkerEdgeColor','k',...
    'MarkerFaceColor',[0,0,0])
grid on; legend
xlabel('No. of cells')
ylabel('Objective function')
axis([0,length(objF),0,1])
pause(0.000001)
NSA_STR10=strcat(NSA_STR3, ' ','OF');
print(h,NSA_STR10,'-djpeg')
clear h;
%%%%%%%%%%########CodeEnds#########%%%%%%%%%%

%% %%%%%%%%########Enable CODE to display chart for objective function values #########%%%%%%%%%%
h=figure(22);
    plot(R2, '.', ...
        'LineWidth',2,...
        'MarkerSize',7)
grid on; legend
xlabel('No. of cells')
ylabel('R^2')
axis([0,length(MSEF),0,1])
legend (NSA_RDATA_COLHEAD(:,3:end), 'Location','northwest')
pause(0.000001)
NSA_STR11=strcat(NSA_STR3, ' ','R2');
print(h,NSA_STR11,'-djpeg')
clear h;
%%%%%%%%%%########CodeEnds#########%%%%%%%%%%

%% %%%%%%%%########Enable CODE to display chart illustrating analysis-1#########%%%%%%%%%%
% TEMPNSA_DATA1=NSA_DATA(:,:,4);
% TEMPNSA_DATA2=NSA_DATA(:,:,5);
% TEMPNSA_DATA3=NSA_DATA(:,:,6);
% NSA_STR6=NSA_RDATA_COLHEAD(4);
% NSA_STR7=NSA_RDATA_COLHEAD(5);
% NSA_STR8=NSA_RDATA_COLHEAD(6);
% NSA_STR9='ZONEDATA';
% NSA_STR10=strcat(NSA_STR3, ' ', NSA_STR9);
% colorstring='brgymckbrgymckbrgymckbrgymck';
% symbolstring='<+d*s.x*o^pvh><+d*s.x*o^pvh>';
% h=figure(23); 
% %h.PaperPositionMode = 'auto';
% cla; hold on
% for i = 1:1:max(NSA_ZONE(:))
%     plot3(TEMPNSA_DATA2(find(NSA_ZONE==i)), TEMPNSA_DATA3(find(NSA_ZONE==i)), ...
%         TEMPNSA_DATA1(find(NSA_ZONE==i)), symbolstring(i),'Color', colorstring(i))
% end
% view(48,18)
% grid on
% xlabel(NSA_STR7)
% ylabel(NSA_STR8)
% zlabel(NSA_STR6)
% 
% %print(h,NSA_STR10,'-djpeg')
% clear h;
% %%%%%%%%%%########CodeEnds#########%%%%%%%%%%
% 
% %% %%%%%%%%########Enable CODE to display chart illustrating analysis-2#########%%%%%%%%%%
% h=figure(24); 
% %h.PaperPositionMode = 'auto';
% cla; hold on
% for i = 1:1:max(NSA_ZONE(:))
%     plot(TEMPNSA_DATA2(find(NSA_ZONE==i)), TEMPNSA_DATA1(find(NSA_ZONE==i)), ...
%         symbolstring(i),'Color', colorstring(i))
% end
% grid on
% xlabel(NSA_STR7)
% ylabel(NSA_STR6)
% 
% %print(h,NSA_STR10,'-djpeg')
% clear h;
% 
% h=figure(25); 
% %h.PaperPositionMode = 'auto';
% cla; hold on
% for i = 1:1:max(NSA_ZONE(:))
%     plot(TEMPNSA_DATA3(find(NSA_ZONE==i)), TEMPNSA_DATA1(find(NSA_ZONE==i)), ...
%         symbolstring(i),'Color', colorstring(i))
% end
% grid on
% xlabel(NSA_STR8)
% ylabel(NSA_STR6)
% 
% %print(h,NSA_STR10,'-djpeg')
% clear h;
% 
% h=figure(26); 
% %h.PaperPositionMode = 'auto';
% cla; hold on
% for i = 1:1:max(NSA_ZONE(:))
%     plot(TEMPNSA_DATA2(find(NSA_ZONE==i)), TEMPNSA_DATA3(find(NSA_ZONE==i)), ...
%         symbolstring(i),'Color', colorstring(i))
% end
% grid on
% xlabel(NSA_STR7)
% ylabel(NSA_STR8)
% 
% %print(h,NSA_STR10,'-djpeg')
% clear h;
%%%%%%%%%%########CodeEnds#########%%%%%%%%%%

%% %%%%%%%%########Enable CODE to display chart illustrating analysis-2#########%%%%%%%%%%
h=figure(27); 
subplot (2,1,1);
plot(objF,'.k')
xlabel('No. of cells')
ylabel('Objective function')
axis([0,length(objF),0,1])
grid on
pause(0.000001)
for i=1:1:max(NSA_ZONE(:))
GRPCELCOUNT(i,:) =[i,length(find(NSA_ZONE==i))];
subplot (2,1,2);
plot(i, GRPCELCOUNT(i,2), '.k')
hold on

end
grid on
xlabel('No. of groups')
ylabel('Group cell count')
xlim([1,(max(NSA_ZONE(:))+1)])
pause(0.000001)
clear h
%%%%%%%%%########CodeEnds#########%%%%%%%%%%

%% code to save data in xls file%%%%%%%%%%
NEW_FILENAME = strrep(FILENAME,'.txt','.xls');
row_header1=NSA_RDATA_COLHEAD(:,3:end)';
col_header1={'Min','Median','Max','Average','Range'};
col_header2={'SDV','FDV','R2Max'};
col_header3={'No. of Cell','Group No.','OF'};
col_header4=NSA_RDATA_COLHEAD(:,3:end);
col_header5={'Group No.','Cell Count'};

for i=1:1:pp
xlswrite(NEW_FILENAME,NSA_DATA(:,:,i),cell2mat(NSA_RDATA_COLHEAD(i)))
end
xlswrite(NEW_FILENAME,NSA_ZONE,'NSA_ZONE');

xlswrite(NEW_FILENAME,col_header1,'GEN_STATS','B1');
xlswrite(NEW_FILENAME,row_header1,'GEN_STATS','A2');
xlswrite(NEW_FILENAME,GEN_STATS,'GEN_STATS', 'B2');

xlswrite(NEW_FILENAME,col_header2,'SPA_PARAM','B1');
xlswrite(NEW_FILENAME,row_header1,'SPA_PARAM','A2');
xlswrite(NEW_FILENAME,SPA_PARAM,'SPA_PARAM','B2');

xlswrite(NEW_FILENAME,col_header3,'PERFORM_INDX','A1');
xlswrite(NEW_FILENAME,col_header4,'PERFORM_INDX','D1');
xlswrite(NEW_FILENAME,PERFORM_INDX,'PERFORM_INDX','A2');

xlswrite(NEW_FILENAME,col_header5,'GRPCELCOUNT','A1');
xlswrite(NEW_FILENAME,GRPCELCOUNT,'GRPCELCOUNT','A2');
%%%%%%%%%########CodeEnds#########%%%%%%%%%%

%% code to save Zones in a *.mat file %%%%%%%%%%
NSA_STR13=strcat(NSA_STR3, ' ','ZONES');
save(NSA_STR13, 'NSA_ZONES');
%%%%%%%%%########CodeEnds#########%%%%%%%%%%
end



