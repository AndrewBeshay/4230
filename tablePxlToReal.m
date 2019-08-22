function realPts = tablePxlToReal(xPxl, yPxl)
%% Calibrate the table camera
T1_world = [175,0];
T2_world = [175,-520];
T3_world = [175,520];
T4_world = [548.6,0];

T1_pxl = [795, 285];
T2_pxl = [15, 285];
T3_pxl = [1590, 290];
T4_pxl = [795, 857];

Mx = (548.6-175)/(T4_pxl(2) - T1_pxl(2)); 
xReal = Mx*yPxl - Mx*T1_pxl(2) + 175;
My = (520*2)/(T3_pxl(1)-T2_pxl(1));
yReal = My*xPxl - My*T2_pxl(1) - 520;
zReal = ones(size(xReal,1),1)*147;
%display('This is the point you converted to the real world (table): ');
realPts = [xReal, yReal, zReal];

end