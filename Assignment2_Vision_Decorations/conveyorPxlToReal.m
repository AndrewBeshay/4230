function realPts = conveyorPxlToReal(xPxl, yPxl)
%% Calibrate the conveyor camera
C2_world = [20, 146]; % bottom left
C3_world = [-270, 151]; % top left
C4_world = [-266, 667]; % top right
C5_world = [24, 677]; % bottpm right

C2_pxl = [485, 541];
C3_pxl = [500, 159];
C4_pxl = [1181, 165];
C5_pxl = [1188, 549];

Mx = (C2_world(1)-C3_world(1))/(C2_pxl(2) - C3_pxl(2)); 
xReal = Mx*yPxl - Mx*C2_pxl(2) + C2_world(1);
My = (C5_world(2)-C3_world(2))/(C5_pxl(1)-C3_pxl(1));
yReal = My*xPxl - My*C3_pxl(1) + C3_world(2);
display('This is the point you converted to the real world (conveyor): ');
realPts = [xReal, yReal, ones(size(xReal,1),1)*0.0221];

end