clear all, 
clc, close all, close all hidden
format short g


filnamn = '';
while ~endsWith(filnamn, '.txt') || ~exist(filnamn, 'file')
    filnamn = input('Ange filnamn (*.txt) >> ', 's');

    if ~endsWith(filnamn, '.txt')
        filnamn = strcat(filnamn, '.txt');
    end
    
    if exist(filnamn, 'file')
        disp('fil hittad!');
    else
        if ~startsWith(filnamn, 'Matriser/')
        filnamn = strcat('Matriser/', filnamn);
        end
    end

    if exist(filnamn, 'file')
        disp('fil hittad!');
    else
        disp('hittade inte filen');
    end
end


ordbok_fil = strcat(strrep(filnamn,'.txt',''),'_ordbok.txt');
dok_fil = strcat(strrep(filnamn,'.txt',''),'_dokindex.txt');

%hämtar data
A = readmatrix(filnamn);
Ord = ordbok( ordbok_fil);
Doks = ordbok( dok_fil );


JaNej = '';
while ~strcmp(JaNej, 'j') && ~strcmp(JaNej, 'n')
    JaNej = input('Vill du göra TF-normalisering? j/n >> ','s');
end, Ja = strcmp(JaNej, 'j');

%-- gör TF-normalisering
if Ja
    A = TF(A);
end

JaNej = '';
while ~strcmp(JaNej, 'j') && ~strcmp(JaNej, 'n')
    JaNej = input('Vill du göra IDF-normalisering? j/n >> ','s');
end, Ja = strcmp(JaNej, 'j');

%-- gör IDF-normalisering
if Ja
    A = IDF(A);
end, clc



%%%%%%%%%%%%-HITTAR OCH VISAR ÄMNEN-%%%%%%%%%%%%%%%%%%%%%%%%%%5
[~, S, VT] = svd(A);

num_topics = 3;
num_words = size(A,2);

TOPICS = cell(num_words,2*num_topics);
header = cell(1,num_topics*2);
j=1;

%hämtar teman ur VT och skapar tabell
for i = 1:num_topics
    v = VT(:,i);
    TOPICS(:,j:1:j+1) = topic(v,num_words, Ord);
    header{1,j}   =   ['Ämne ', char(string(i)), ':']; 
    header{1,j+1} =   ['(',char(string(i)),') Ordstyrka:' ];    %char( strcat(string(i),', Ordstyrka:') ) ; 
    j = j + 2;
end, clear j,

%skapar tabell figure
fig = uifigure;
set(fig, 'Name', "Texternas huvudsakliga ämnen; Principal Components; kolonnvektorer i VT");
fig.Position = [100 100 20+200*num_topics 20+30*15]; % [left bottom width height]
for i =1:1:num_topics
    Tabell = cell2table(TOPICS(:,2*i-1:2*i),"VariableNames",{['Ämne ', char(string(i))],'Ordstyrka:'});
    uit = uitable(fig,'Data',Tabell);
    pos = [10+200*(i-1) 20 180 30*15];
    uit.Position = pos;
end,clear fig, clear pos, clear Tabell;

%hämtar lite titlar till grafer
tema1 = [char(TOPICS(1,1)) ', ' char(TOPICS(2,1)) ', ' char(TOPICS(3,1)) ];
tema2 = [char(TOPICS(1,3)) ', ' char(TOPICS(2,3)) ', ' char(TOPICS(3,3)) ];
tema3 = [char(TOPICS(1,5)) ', ' char(TOPICS(2,5)) ', ' char(TOPICS(3,5)) ];
tema123 = [ string(tema1), string(tema2), string(tema3) ];


%%%%%%%%%%%%%%%%%%%%  PROJEKTION PÅ DELRUM  %%%%%%%%%%%%%%%%%%%%%

%skapar basvektorer
bas_3D = VT(:,1:1:3);           %basbytes-matris för 3D-rum (ON-bas)
vt1 = bas_3D(:,1);              %basvektorer
vt2 = bas_3D(:,2);
vt3 = bas_3D(:,3);

fig = figure(5);
set(fig, 'Name', 'Dokumentens ord i PC-rum');
punkter = {'o', 's','x','d','v', '+', '*', '.', '_', '|', '^', '<', '>', 'p', 'h'};

%projicerar varje radvektor på ortonormala basvektorerna, (dok på principal komponent)

%radvektorns alla komponenter, ord, får blir en punkt
for i = 1:size(A,1)
    dokvek = A(i,:)';

    %radvektorn får 3 ortogonal komposanter,
    x = dot(vt1, dokvek)*vt1;
    y = dot(vt2, dokvek)*vt2;
    z = dot(vt3, dokvek)*vt3;

    %radvektorns alla komponenter, ord, blir en punkt med scatter
    if i < 105, punkt = punkter{ceil(i/7)}; end
    scatter3(x,y,z,punkt,'DisplayName',Doks{i},'LineWidth',3)
    hold on
end

legend('Location','NorthEastOutside')
title('Projektion av A:s radvektorer på ett 3D-delrum av col(VT) ')
xlabel( 'Ämne 1: '), ylabel( 'Ämne 2: ' ), zlabel('Ämne 3: ')

%lägger till PC-tabellen i samma figure
tabell = cell2table( [ TOPICS(1:6,1) TOPICS(1:6,3) TOPICS(1:6,5)], "VariableNames",[{'Ämne 1;'},{'Ämne 2;'},{'Ämne 3;'}]);
tabell_cell = table2cell(tabell);
p = uipanel(fig, 'Position', [0.7 0.1 0.5 0.2], 'Parent', fig); %[left bottom width height]
table_handle = uitable(p, 'Data', tabell_cell, 'ColumnName', tabell.Properties.VariableNames, 'Position', [10 0 400 120]);



%plottar dokumenten som seperata vektorer (inte alla ord)

x = abs( vt1' * A(:,:)' ); %alla dokuments "x"-komponenter
y = abs( vt2' * A(:,:)' ); % osv
z = abs( vt3' * A(:,:)' );

fig2 = figure(2);
plotta_med_legend(x,y,Doks,3,z)
grid on, xlabel( 'Ämne 1: ' ),   ylabel( 'Ämne 2: ' ), zlabel( 'Ämne 3: ' )
title('PCA 3D')
set(gcf, 'Name', 'Dokumenten i PC-rum');
legend('Location','NorthEastOutside')

p = uipanel(fig2, 'Position', [0.7 0.1 0.5 0.2], 'Parent', fig2); %[left bottom width height]
table_handle = uitable(p, 'Data', tabell_cell, 'ColumnName', tabell.Properties.VariableNames, 'Position', [10 0 400 120]);


% 2D-plot

%figure(1)
%subplot(1, 2, 1)
%plotta_med_legend(x,y,Doks,3)
%grid on, xlabel( ['Ämne 1: ', tema123(1)] ), ylabel( ['Ämne 2: ', tema123(2)] ), title('PCA 2D')
%axis equal

%plottar singulärvärden

%subplot(1, 2, 2)
% semilogy(diag(S), 'k-o', 'LineWidth', 2.5) % Visar hur viktiga singulärvärdena är
% axis tight, xlabel('Singulärvärdets "ranking"'), ylabel('Singulärvärde'), title('Singulärvärdesrelevans')
% set(gcf, 'Name', 'Singulärvärden');











%---------FUNKTIONER-----------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function T = topic(VT1,num_words,ord) 

% Lägger till rad-(*ord*-)index före vektorns element
Tn = [ [1:1:length( VT1 )]' , VT1];

% sorterar efter absolutbelopp
[~, idx] = sort(abs(Tn(:,2)));  % hämtar indexvektor för vektorn i storleksordning (minst-->störst)
idx = fliplr(idx');             % vänder; störst --> minst
Tn = Tn(idx, :);               %sorterar utefter index-vektorn
Tn = Tn(1:num_words,:);         % hämtar de *antal* största elementen i vektorn

T = [ ord( Tn(:,1)) , num2cell( Tn(:,2) )] ; % hämtar motsvarande ord från ordvektorn och skapar cell-array; ord,värde

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function idx = maxabs(v)
%returnerar index för det element med största absolutvärdet i en vektor
[~, idx] = max(abs(v(:)));
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

function ordvektor = ordbok(filnamn)

delimiter = '';
formatSpec = '%s';
fileID = fopen(filnamn);
ordvektor = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
fclose(fileID);
ordvektor = ordvektor{1};

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function A = TF(A)
%term-frequency
%dividerar elementen med antal ord, normaliserar långa-korta texter

[n, ~] = size(A);
for j = 1:n
    antal_ord = sum(A(j,:)~= 0);
    A(j,:) = A(j,:)*(1/antal_ord) ;
end 

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function A = IDF(A)
% IDF - Inverse Document Frequency
% denna funktion skrev jag med gpt på mobilen i sängen kl.0157 :)

[n, m] = size(A);

for j = 1:m
    frek = sum(A(:,j) ~= 0);
    if frek ~= 0
        A(:,j) = A(:,j) * log10(n / frek);
    end
end

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  NaN = plotta_med_legend(x,y,namn,linewidth,z)

punkter = {'o', 'x','s','d','v', '+', '*', '.', '_', '|', '^', '<', '>', 'p', 'h'};
colors = [0, 0.4470, 0.7410;0.8500, 0.3250, 0.0980;0.9290, 0.6940, 0.1250;0.4940, 0.1840, 0.5560;0.4660, 0.6740, 0.1880;0.3010, 0.7450, 0.9330;0.6350, 0.0780, 0.1840];
j = 1;

%----om 2D--------------------------------------------
if nargin == 4 % om 4 argument angavs (inget z)
    for i=1:length(x)
        if i < 105, punkt = punkter{ceil(i/7)}; end     %väljer punkt
        if j > 7, j = 1; end,  color = colors(j,1:3);   %väljer färg

        plot(x(i), y(i),punkt,'MarkerEdge',color,'LineWidth', linewidth,'DisplayName',namn{i})
        hold on
        j = j + 1;
    end
    %legend
    hold off

%---om 3D--------------------------------------------
elseif nargin == 5 % om ett z-argument angavs
    for i=1:length(x)
        if i < 105, punkt = punkter{ceil(i/7)}; end     %väljer punkt
        if j > 7, j = 1; end,  color = colors(j,1:3);   %väljer färg

        plot3(x(i), y(i), z(i), punkt, 'MarkerEdge',color,'LineWidth', linewidth,'DisplayName',namn{i})
        hold on
        j = j + 1;
    end
    %legend
    hold off
end

end
