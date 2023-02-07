clear all
clc
format short g


%filnamn = input("Ange filnamn ('*.txt') >>");
%<<<<<<< HEAD
filnamn = 'C:\Users\anton\OneDrive\Dokument\GitHub\LSA\Matriser\BIBELMATRISEN.txt';
%=======
%filnamn = 'Matriser\Kmatris.txt';
%>>>>>>> 45e77d6f0d06d35f0e4a1a7adcff30e6d836fc1e

A = readmatrix(filnamn);

AAT = A*A';

AAT = normalizeRows(AAT);

[U, S, V] = svd(A);

A = nolla(A);

VT = V';

num_topics = 4;
num_words = 10;

ordbok_namn = 'Matriser\Kmatris_ordbok.txt';%input('ordbok >>');
Ord = ordbok( ordbok_namn);

topic1 = topic(VT,1,num_words, Ord);
topic2 = topic(VT,2,num_words, Ord);
topic3 = topic(VT,3,num_words, Ord);
topic4 = topic(VT,4,num_words, Ord);

M = size(topic1);
if size(topic2) > M
    M = size(topic2);
end
if size(topic3) > M
    M = size(topic3);
end
if size(topic4) > M
    M = size(topic4);
end
num_words = M(1,1); 

TOPICS = cell(  num_words,2*num_topics)  ;
[n,m] = size(topic1);
TOPICS(1:1:n,1:1:2) = topic1;
[n,m] = size(topic2);
TOPICS(1:1:n,3:1:4) = topic2;
[n,m] = size(topic3);
TOPICS(1:1:n,5:1:6) = topic3;
[n,m] = size(topic4);
TOPICS(1:1:n,7:1:8) = topic4;
disp('-------------TOPIC 1----------------------------------TOPIC 2-----------------------------------TOPIC 3---------------------------------TOPIC 4-----------------')
disp('-------ord---------------styrka-------------ord---------------------styrka-----------ord--------------------styrka----------ord----------------------styrka-----')
    %    {'ar'         }    {["-0.74645"]}    {'hjulparet'       }    {["-0.10953"]}    {'drosnin'        }    {["0.10878"]}    {'2050'            }    {["0.12612"]}
disp(TOPICS)
% for i=1:1:num_words
% disp('    '+ string(Ord( topic1(i,1) ))+' '+string(topic1(i,2))+'           '+string(Ord( topic2(i,1) ))+' '+string(topic2(i,2))+ ...
%      '    '+ string(Ord( topic3(i,1) ))+' '+string(topic3(i,2))+'           '+string(Ord( topic4(i,1) ))+' '+string(topic4(i,2))+'    ') 
% end


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
% legend

subplot(1, 3, 1)
plot(x, y, 'ko', 'LineWidth', 3)
hold on, grid on, xlabel('Ämne 1'), ylabel('Ämne 2'), title('PCA 2D')
%axis([-2 15 -2 15])


subplot(1, 3, 2)
plot3(x, y, z, 'ko', 'LineWidth', 3)
hold on, grid on, xlabel('Ämne 1'), ylabel('Ämne 2'), zlabel('Ämne 3'), title('PCA 3D')
%axis([-2 15 -2 15])

subplot(1, 3, 3)
semilogy(diag(S), 'k-o', 'LineWidth', 2.5) % Visar hur viktiga singulärvärdena är
axis tight, xlabel('Singulärvärdets "ranking"'), ylabel('Singulärvärde'), title('Singulärvärdesrelevans')



function T = topic(VT,kolumn,num_words,ord) 
%num_words gör inget just nu, du får nu istället
% alla ord som är värt mer än 0.1,  take it or leave it
%T = zeros(1,2);
T = cell(1,2);

[N,M] = size(VT);
j = 1;
for i=1:1:M 
    if abs( VT(kolumn,i)  ) > 0.1 % denna tolerans kan man ändra om man vill
%        T(j,1:1:2) = [ i, VT(kolumn,i) ];
        T(j,1) = ord(i);
        T(j,2) = {string(VT(kolumn,i))} ; 
        j = j + 1;
    end
end

end


function A = nolla(A)
[n,m] = size(A);
for rad=1:1:n
    for kol=1:1:m
        if A(rad,kol) < 0.0000001 
            A(rad,kol) = 0;
        end
            A(rad,kol) = floor(A(rad,kol)*1000000000)/1000000000; 
    end
end
end

function norm_matrix = normalizeRows(matrix)
    norm_matrix = zeros(size(matrix));
    for i = 1:size(matrix, 1)
        row = matrix(i, :);
        row_norm = norm(row);
        norm_matrix(i, :) = row / row_norm;
    end
end

function ordvektor = ordbok(filnamn)

delimiter = '';
formatSpec = '%s';
fileID = fopen(filnamn);
ordvektor = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
fclose(fileID);
ordvektor = ordvektor{1};

end

