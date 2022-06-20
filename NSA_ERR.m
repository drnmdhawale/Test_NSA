function [MSE]=NSA_ERR(D, Z)
    WB=D; % clone data
    %w=0;
    m=max(Z(:)); % maximum number of variables
    %N=length(Z(:))-length(Z(find(Z==0))); % actual total number of elements used in calculation
    N=length(Z(find(Z~=0))); 
    for i=1:m
        WB(find(Z==i))=mean(D(find(Z==i))); % assign the mean of all elements for in a particular zone
        %w=w+length(find(Z==i));
    end
    
    [MSE]=(sum(sum((D-WB).^2)))/(N-m); % calculate and report the mean squared error.
   
    end
