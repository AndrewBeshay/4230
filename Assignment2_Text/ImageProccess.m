I = imread("ImageTwo.jpg");
imshow(I);

BW = im2bw(I);

% BW = imbinarize(I);

[B,L,N,A] = bwboundaries(BW);

imshow(BW); hold on;
colors=['b' 'g' 'r' 'c' 'm' 'y'];
for k=1:length(B),
  boundary = B{k};
  cidx = mod(k,length(colors))+1;
  plot(boundary(:,2), boundary(:,1),...
       colors(cidx),'LineWidth',2);

  %randomize text position for better visibility
  rndRow = ceil(length(boundary)/(mod(rand*k,7)+1));
  col = boundary(rndRow,2); row = boundary(rndRow,1);
  h = text(col+1, row-1, num2str(L(row,col)));
  set(h,'Color',colors(cidx),'FontSize',14,'FontWeight','bold');
end
%% %% Vertex filter
LineEnd1 = [0 1 0 ; 0 1 0 ; 0 0 0];
LineEnd2 = [0 0 0 ; 0 1 1 ; 0 0 0];
LineEnd3 = [0 0 0 ; 0 1 0 ; 0 1 0];
LineEnd4 = [0 0 0 ; 1 1 0 ; 0 0 0];
LineEnd5 = [1 0 0 ; 0 1 0 ; 0 0 0];
LineEnd6 = [0 0 1 ; 0 1 0 ; 0 0 0];
LineEnd7 = [0 0 0 ; 0 1 0 ; 1 0 0];
LineEnd8 = [0 0 0 ; 0 1 0 ; 0 0 1];
%{
cnr1 = [0 1 0 ; 1 1 0 ; 0 0 0];
cnr2 = [0 1 0 ; 0 1 1 ; 0 0 0];
cnr3 = [0 0 0 ; 0 1 1 ; 0 1 0];
cnr4 = [0 0 0 ; 1 1 0 ; 0 1 0];
%}
LineEnds = [];
%Cnrs = [];

for i = 2:size(out,1)-1
    for j = 2:size(out,2)-1
        matrix = out(i-1:i+1,j-1:j+1);
        if(isequal(matrix,LineEnd1)||isequal(matrix,LineEnd2)...
                ||isequal(matrix,LineEnd3)||isequal(matrix,LineEnd4)||...
                isequal(matrix,LineEnd5)||isequal(matrix,LineEnd6)...
                ||isequal(matrix,LineEnd7)||isequal(matrix,LineEnd8))
            LineEnds = [LineEnds;i j];
        end
        %{
        if(isequal(matrix,cnr1)||isequal(matrix,cnr2)...
                ||isequal(matrix,cnr3)||isequal(matrix,cnr4))
            Cnrs = [Cnrs;i j];
        end
        %}
    end
end

figure(50);
imshow(BWoverlay);
hold on;
plot(LineEnds(:,2),LineEnds(:,1),'bo')
