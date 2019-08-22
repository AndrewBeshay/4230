%% Load struct from image

PxlPoints = ImageProcessing_Final();

%% Initialisation
numChars = numel(PxlPoints);
cakeHeight = 100; %Cake is 10cm high = 100mm
travelHeight = 50; %Travel moves are a further 50mm higher

outMtx = zeros(500,5,numChars); %[X,Y,Z,Bold,InkOn] * NumCharsDeep in 3rd Dim


for charIdx=1:1:numChars
    RealPoints =  tablePxlToReal(PxlPoints(charIdx).points(:,1),PxlPoints(charIdx).points(:,2));
    RealPoints(:,3) = RealPoints(:,3) + cakeHeight;
    
    
    offset = 0;
    
    for ptRowIdx=1:1:(size(RealPoints,1) - 1)
            deltaXY = sqrt((RealPoints(ptRowIdx+1,1) - (RealPoints(ptRowIdx,1)))^2 ...
                + ((RealPoints(ptRowIdx+1,2)) - (RealPoints(ptRowIdx,2)))^2);
        if(deltaXY > 5)
           outMtx(ptRowIdx + offset,:,charIdx) = ...
               [RealPoints(ptRowIdx-1,1) RealPoints(ptRowIdx-1,2) RealPoints(ptRowIdx-1,3)+travelHeight PxlPoints(charIdx).Bold 0];
            
           outMtx(ptRowIdx + offset + 1,:,charIdx) = ...
               [RealPoints(ptRowIdx,1) RealPoints(ptRowIdx,2) RealPoints(ptRowIdx+1,3)+travelHeight PxlPoints(charIdx).Bold 0];
           
           offset = offset+2;
           
           outMtx(ptRowIdx + offset,:,charIdx) = ...
               [RealPoints(ptRowIdx,:) PxlPoints(charIdx).Bold 1];
           
        else
           outMtx(ptRowIdx + offset,:,charIdx) = ...
               [RealPoints(ptRowIdx,:) PxlPoints(charIdx).Bold 1]; 
            
        end

    end

end


%% Sending to Robot

outStr = "";

for charIdx=1:1:numChars
    
    for rowIdx = 1:1:size(outMtx,1)
        outStr = sprintf("X%3.3fY%3.3fZ%3.3fV%1iI%1i",...
            outMtx(rowIdx,1,charIdx),outMtx(rowIdx,2,charIdx),outMtx(rowIdx,3,charIdx),...
            outMtx(rowIdx,4,charIdx),outMtx(rowIdx,5,charIdx));
        if(sum(outMtx(rowIdx,:,charIdx)) == 0)
           %String out to turn off ink and return to ink printing home
            continue; 
        end
        
       %%Add code here to send to robot via TCP 
       
       %Wait/check response
       
    end
end




