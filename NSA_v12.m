function  NSA_v12(handles)
%% %%%%%%%%%%%%%%%
%%% STEP-5  %%%%%%
%%%%%%%%%%%%%%%%%%
load NSA_DATA;%%load intermediately saved data
%load NSA_GDATA1; %load  raster cell size
objF(1,:)=0; objFG(1,:)=0; MSEF(1,:)=0;%create a 2D array to save values of the objective funtion
RLU=0; R2max=1; GROWTH=0; ABORT=0; RUNOUT1=0; RUNOUT2=0; GROWTHTYPE=0;%status flag
[rr cc pp]=size(NSA_DATA);%%get row,col and page information from the input data layer
S=[rr,cc];I=1;%%parameters used during conversion between matrix and vectors
m=2; n=2;%Group No. 
handles.maxGRPNo=str2num(get(handles.edit2, 'String'))

%% code to calculate the average of shortest distance variances(SDV) 
ELMT=find(NSA_ZONE1==1);%find all points in data that are not zeros
for i=1:1:length(ELMT)
    IND=ELMT(i);[row,col]=ind2sub(S,IND);
    for k=3:1:pp
        NSA_TDATA=NSA_DATA(:,:,k);
        ZWINDOW=NSA_TDATA(row-I:row+I,col-I:col+I);%%select a window of 3X3 cells
        NHOOD_VALID=NSA_NHOOD_VALID(ZWINDOW);%%check for valid elements,
        %%if valid element then 1 else 0
        if NHOOD_VALID>0,
            SDV(i,k-2)=var(ZWINDOW(:));%%calculate MSE with test element
        else
            NSA_ZONE1(IND)=0;
        end
    end
end
for i=1:1:size(SDV, 2)
SDV((find(SDV(:,i)==0)),:)=nan;
end
SDV=nanmean(SDV);

%% Testing patch to be or not to be deleted- 26/5/2016
for k=3:1:pp
    NSA_TDATA=NSA_DATA(:,:,k);
    NSA_TDATA(find(NSA_ZONE1==0))=0;
    NSA_DATA(:,:,k)=NSA_TDATA;
end
%%%%testing patch ends%%%%

%% code to calculate the farthest distance variance(FDV)
for k=3:1:pp
    NSA_TDATA=NSA_DATA(:,:,k);
    FDV(1,k-2)=var(NSA_TDATA(find(NSA_ZONE1==1)));
end

%%  code to test the ratio SDV:FDV
for k=3:1:pp
    if  SDV(k-2)/FDV(k-2)>1,
        SDV(k-2)=FDV(k-2);
    end
end

%% code to calculate the relative local uncertainity(RLU)
for k=3:1:pp
    RLU(1,k-2)=SDV(k-2)/FDV(k-2);
end

%% code to calculate the max Rsquare values
for k=3:1:pp
    R2max(1,k-2)=1-RLU(k-2);
end

%% Code to display SDV and FDV
disp('SDV   FDV	RLU	R2max')
disp([SDV' FDV' RLU' R2max'])
OFOLDBASE=prod((1-FDV./FDV).^R2max); %calculate the objective productR2
                                     %(FZOFOLD stands for the  old value of 
                                     % the objective funtion calculated with first zone)
NSA_ZONE=NSA_ZONE1; %clone the ZONE layer matrix
NSA_ZONES(:,:,1)=NSA_DATA(:,:,1); NSA_ZONES(:,:,2)=NSA_DATA(:,:,2);
NSA_ZONES(:,:,3)=NSA_ZONE;
MSEF=FDV;

%% find and establish the second zone
[OFNEWBASE, IND, MSENEWBASE]=NSA_Base(NSA_DATA, NSA_ZONE, FDV, SDV, R2max, S, I, pp, m);
if OFNEWBASE>OFOLDBASE,
[row,col]=ind2sub(S,IND);
NSA_ZONE(row-I:row+I,col-I:col+I)=m;%%replace the chosen element with group numbers value
disp('Opened a second base group consisting of 3x3 grid size cells')
disp('Zone_No. OF_OLD OF_NEW')
disp([m OFOLDBASE OFNEWBASE ])
OFOLDBASE=OFNEWBASE;
objF(end+1:end+8,:)=NaN; objF(end+1,:)=OFNEWBASE;
objFG(end+1:end+8,:)=NaN; objFG(end+1,:)=m;
MSEF(end+1:end+8,:)=NaN; MSEF(end+1,:)=MSENEWBASE;
NSA_ZONES(:,:,4)=NSA_ZONE;
end

while(ABORT~=1), % get and grow is true
%% calculate the value of the ojective function for current configuration
for k=3:1:pp
    OF1OLDBASE(k-2)=NSA_ERR(NSA_DATA(:,:,k),NSA_ZONE);%%Error with new zone but before virtual growth
end
    OFOLDBASE=prod((1-OF1OLDBASE./FDV).^R2max); 
    GROWTHTYPE=0;

    %% Calculate the values of new ojective function under future possible configurations 
    for m=max(NSA_ZONE(:)):-1:2,
        [OFNEWBASE, IND1, MSENEWBASE]=NSA_Addcell(NSA_DATA, NSA_ZONE, FDV, R2max, pp, m); 
        if OFNEWBASE==0,
            TEMPOF(m,:)=[OFNEWBASE-OFOLDBASE, OFNEWBASE, OFOLDBASE, IND1, m, GROWTHTYPE, MSENEWBASE];
            TEMPOF(m,:)=[];
            RUNOUT1=1;
        else
        TEMPOF(m,:)=[OFNEWBASE-OFOLDBASE, OFNEWBASE, OFOLDBASE, IND1, m, GROWTHTYPE, MSENEWBASE];
        end
    end
m=max(NSA_ZONE(:))+1; % increment m for new possible base
[OFNEWBASE, IND, MSENEWBASE]=NSA_Base(NSA_DATA, NSA_ZONE, FDV, SDV, R2max, S, I, pp, m);
if OFNEWBASE==0,
    TEMPOF(m,:)=[OFNEWBASE-OFOLDBASE, OFNEWBASE, OFOLDBASE, IND, m, GROWTHTYPE, MSENEWBASE];
    TEMPOF(m,:)=[];
    RUNOUT2=1;
else
    GROWTHTYPE=1;
    TEMPOF(end+1,:)=[(OFNEWBASE-OFOLDBASE)/9, OFNEWBASE, OFOLDBASE, IND, m, GROWTHTYPE, MSENEWBASE];
end
m=max(NSA_ZONE(:))+1; % decrement m with original configuration

        maxCAND=TEMPOF((find(TEMPOF(:,1)==max(TEMPOF(:,1)))),:);
        CAND2=maxCAND((find(maxCAND(:,5)==min(maxCAND(:,5)))),:); % select the array with the best possible configuration
        OFDIFF=CAND2(end,1);
        OFNEWBASE=CAND2(end,2); 
        OFOLDBASE=CAND2(end,3); 
        ELMT=CAND2(end,4);
        m=CAND2(end,5);
        GROWTHTYPE=CAND2(end,6);
        MSENEWBASE=CAND2(end,7:end);
        clear TEMPOF maxCAND;

    % decision to add cell to existing groups
    if OFDIFF>0 && GROWTHTYPE==0 %&& RUNOUT==0, %if error/objective after virtual growth decreases or stayed constant    NSA_ZONE(IND1)=M;%%grow
        NSA_ZONE(ELMT)=m;%%replace the chosen element with group numbers value
        OFOLDBASE=OFNEWBASE;
        GROWTH=GROWTH+1; %nbr cell was added
        objF(end+1,:)=OFNEWBASE; objFG(end+1,:)=n;
        MSEF(end+1,:)=MSENEWBASE;

    % decision to add a new base       
    elseif RUNOUT2==0 && OFDIFF>0 && GROWTHTYPE==1 %&& RUNOUT==0, %%test if new calculated objective funtion is lower than the previous calculated objective
        beep; [row,col]=ind2sub(S,ELMT);
        NSA_ZONE(row-I:row+I,col-I:col+I)=m;%%replace the chosen element with group numbers value
        disp('Opened a next base group consisting of 3x3 grid size cells')
        disp('Zone_No. OF_OLD OF_NEW')
        disp([m OFOLDBASE OFNEWBASE])
        OFOLDBASE=OFNEWBASE;
        objF(end+1:end+8,:)=NaN; objF(end+1,:)=OFNEWBASE;
        MSEF(end+1:end+8,:)=NaN; MSEF(end+1,:)=MSENEWBASE;
        objFG(end+1:end+8,:)=NaN; objFG(end+1,:)=m; n=n+1;
     
%% Display groups chart
%h.PaperPositionMode = 'auto';
handles.Lon=NSA_DATA(:,:,1);
handles.Lat=NSA_DATA(:,:,2);
handles.Grp=NSA_ZONE;
surf(handles.Lon,handles.Lat,handles.Grp)
handles.NSA_MAXTICK=0:max(max(NSA_ZONE));
set(colorbar,'YTick',handles.NSA_MAXTICK)
view(0,90)
axis([0,max(max(NSA_DATA(:,:,1))),0,max(max(NSA_DATA(:,:,2)))])
xlabel('Easting')
ylabel('Northing')
zlabel('GroupNo.')
pause(0.000001)
NSA_ZONES(:,:,(m+2))=NSA_ZONE;
    
% decision to terminate   
    else
        disp('Program Terminated - unable to open new base group consisting of 3x3 grid size cells')
        disp([m OFOLDBASE OFNEWBASE]);
        ABORT=1;
        surf(handles.Lon,handles.Lat,handles.Grp)
        handles.NSA_MAXTICK=0:max(max(handles.Grp));
        view(0,90)
        axis([0,max(max(NSA_DATA(:,:,1))),0,max(max(NSA_DATA(:,:,2)))])
        xlabel('Easting')
        ylabel('Northing')
        zlabel('GroupNo.')
        set(colorbar,'YTick',handles.NSA_MAXTICK)
    end
    
    if (handles.maxGRPNo<999) && (m>handles.maxGRPNo)
        ABORT=1;
        disp('Program Terminated - on user demand to limit number of groups')
    end
end % while (main)

%% save data
save('NSA_OUTPUT','NSA_DATA','NSA_ZONE','NSA_ZONES','SDV','FDV','R2max', ...
'MSEF','objF','objFG'); %saving output data
end

