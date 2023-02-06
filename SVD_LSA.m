clear all
clc
format short g

%jättefult skrivet oså, också ineffektiv, men det funkar

filnamn = input("Ange filnamn ('*.txt') >>");

A = readmatrix(filnamn);
AAT = A*A';

AAT = normalizeRows(AAT);

[U, S, V] = svd(A);

A = nolla(A);

VT = V';

num_topics = 4;
num_words = 10;

topic1 = topic(VT,1,num_words);
topic2 = topic(VT,2,num_words);
topic3 = topic(VT,3,num_words);
topic4 = topic(VT,4,num_words);

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

TOPICS = zeros(  num_words,2*num_topics)  ;
[n,m] = size(topic1);
TOPICS(1:1:n,1:1:2) = topic1;
[n,m] = size(topic2);
TOPICS(1:1:n,3:1:4) = topic2;
[n,m] = size(topic3);
TOPICS(1:1:n,5:1:6) = topic3;
[n,m] = size(topic4);
TOPICS(1:1:n,7:1:8) = topic4;
disp('-------------TOPIC 1-------------------TOPIC 2---------------------TOPIC 3-------------------TOPIC 4--------')
disp('-------ord-index---styrka----------ord-index---styrka-------ord-index---styrka--------ord-index---styrka--------')
%disp(           31     -0.25324         2508        0.122           50      0.45002           43      0.10303
disp(TOPICS)


% STEG 1 (Skapa ny matris B=A-Aavg)


% STEG 2 (Hitta SVD av B)



function T = topic(VT,kolumn,num_words) 
%num_words gör inget just nu, du får nu istället
% alla ord som är värt mer än 0.1,  take it or leave it
T = zeros(1,2);

[N,M] = size(VT);
j = 1;
for i=1:1:M 
    if abs( VT(kolumn,i)  ) > 0.1 % denna tolerans kan man ändra om man vill
        T(j,1:1:2) = [ i, VT(kolumn,i) ];
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

