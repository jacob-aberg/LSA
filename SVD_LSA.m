clear all, clc, close all, close all hidden
format short g


%filnamn = input("Ange filnamn ('*.txt') >>");
%<<<<<<< HEAD
filnamn = 'Matriser\Farkost_matris.txt';%partier.txt%'Matriser\BIBELMATRISEN_V2.txt';
%=======
%filnamn = 'Matriser\Kmatris.txt';
%>>>>>>> 45e77d6f0d06d35f0e4a1a7adcff30e6d836fc1e


ordbok_fil = strcat(strrep(filnamn,'.txt',''),'_ordbok.txt');
dok_fil = strcat(strrep(filnamn,'.txt',''),'_dokindex.txt');

%hämtar data
A = readmatrix(filnamn);
Ord = ordbok( ordbok_fil);
Doks = ordbok( dok_fil );


%%%%%%%%%%%%-HITTAR OCH VISAR ÄMNEN-%%%%%%%%%%%%%%%%%%%%%%%%%%5
[~, ~, V] = svd(A);

num_topics = 3;
num_words = 10;

V = V(:,1:1:num_topics);

TOPICS = cell(num_words,2*num_topics);
header = cell(1,num_topics*2);
j=1;
for i = 1:num_topics
    TOPICS(:,j:1:j+1) = topic(V',i,num_words, Ord);
    header{1,j}   =   ['Ämne ', char(string(i)), ':']; 
    header{1,j+1} =   ['(',char(string(i)),') Ordstyrka:' ];%char( strcat(string(i),', Ordstyrka:') ) ; 
    j = j + 2;
end, clear j, clear V

% TopicTable = cell2table(TOPICS,"VariableNames",header);
% disp(newline)
% disp(TopicTable)

%skapar tabell figure
fig = uifigure;
set(fig, 'Name', "Texternas huvudsakliga ämnen");
fig.Position = [100 100 20+200*num_topics 20+30*num_words]; % [left bottom width height]
for i =1:1:num_topics
    Tabell = cell2table(TOPICS(:,2*i-1:2*i),"VariableNames",{['Ämne ', char(string(i))],'Ordstyrka:'});
    uit = uitable(fig,'Data',Tabell);
    pos = [10+200*(i-1) 20 180 30*num_words];
    uit.Position = pos;
end,clear fig, clear pos, clear Tabell;


tema123 = [ TOPICS(1,1),TOPICS(1,3),TOPICS(1,5)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% STEG 1 (Skapa ny matris B=A-Aavg)

Aavg = mean(A, 2);

cLen = size(A, 2);
B = A - Aavg * ones(1, cLen); % Subtraherar varje kolonnvektor i A (ordvektor) med alla radvektorer i A:s medelvärden.


% STEG 2 (Hitta SVD av B)

[U, S, V] = svd(B, 'econ');


% STEG 3 (Skapa plot)

x = V(:, 1)' * B';
y = V(:, 2)' * B';
z = V(:, 3)' * B';

% Vill försöka skapa en plot i en for loop så att kompendiumens data
% markeras med olika färger så man kan urskilja dem i plotten sen göra en
% legend ---- %legend kan skapas m.h.a vektorn 'Doks'

subplot(1, 3, 1)
plotta_med_legend(abs(x),abs(y),Doks,3)
%plot(x, y, 'ko', 'LineWidth', 3)
grid on, xlabel( ['Ämne 1: ', tema123(1)] ), ylabel( ['Ämne 2: ', tema123(2)] ), title('PCA 2D')
axis equal
%axis([-2 15 -2 15])


subplot(1, 3, 2)
%plot3(x, y, z, 'ko', 'LineWidth', 3)
plotta_med_legend(abs(x),abs(y),Doks,3,abs(z))
grid on, xlabel( ['Ämne 1: ', tema123(1)] )
         ylabel( ['Ämne 2: ', tema123(2)] )
         zlabel( ['Ämne 3: ', tema123(3)] )
title('PCA 3D')
%axis equal
%axis([-2 15 -2 15])

subplot(1, 3, 3)
semilogy(diag(S), 'k-o', 'LineWidth', 2.5) % Visar hur viktiga singulärvärdena är
axis tight, xlabel('Singulärvärdets "ranking"'), ylabel('Singulärvärde'), title('Singulärvärdesrelevans')

set(gcf, 'Name', 'PCA');

%FUNKTIONER:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function T = topic(VT,kolumn,num_words,ord) 

% Lägger till rad-(*ord*-)index före vektorns element
Tn = [ [1:1:length( VT(kolumn,:) )]' , VT(kolumn,:)'];

% sorterar efter absolutbelopp
[~, idx] = sort(abs(Tn(:,2)));  % hämtar indexvektor för vektorn i storleksordning (minst-->störst)
idx = fliplr(idx');             % vänder; störst --> minst
Tn = Tn(idx, :);               %sorterar utefter index-vektorn
Tn = Tn(1:num_words,:);         % hämtar de *antal* största elementen i vektorn

T = [ ord( Tn(:,1)) , num2cell( Tn(:,2) )] ; % hämtar motsvarande ord från ordvektorn och skapar cell-array; ord,värde

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function A = nolla(A)
[n,m] = size(A);
for rad=1:1:n
    for kol=1:1:m
        if A(rad,kol) < 0.0000001 
            A(rad,kol) = 0;
        end
            A(rad,kol) = floor(A(rad,kol)*10000000)/10000000; 
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function norm_matrix = normalizeRows(matrix)
    norm_matrix = zeros(size(matrix));
    for i = 1:size(matrix, 1)
        row = matrix(i, :);
        row_norm = norm(row);
        norm_matrix(i, :) = row / row_norm;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ordvektor = ordbok(filnamn)

delimiter = '';
formatSpec = '%s';
fileID = fopen(filnamn);
ordvektor = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
fclose(fileID);
ordvektor = ordvektor{1};

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  NaN = plotta_med_legend(x,y,namn,linewidth,z)

punkter = {'o', 'x','s','d','v', '+', '*', '.', '_', '|', '^', '<', '>', 'p', 'h'};

%----om 2D--------------------------------------------
if nargin == 4 % om 4 argument angavs (inget z)
    for i=1:length(x)
        if i < 105, punkt = punkter{ceil(i/7)}; end
        plot(x(i), y(i),punkt,'LineWidth', linewidth,'DisplayName',namn{i})
        hold on
    end
    legend
    hold off

%---om 3D--------------------------------------------
elseif nargin == 5 % om ett z-argument angavs
    for i=1:length(x)
        if i < 105, punkt = punkter{ceil(i/7)}; end
        plot3(x(i), y(i), z(i), punkt, 'LineWidth', linewidth,'DisplayName',namn{i})
        hold on
    end
    legend
    hold off
end

end
