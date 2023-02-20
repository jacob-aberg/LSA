clear all, clc, close all, close all hidden

m1 = conv_img("Moon 1");
m2 = conv_img("Moon 2");
m3 = conv_img("Moon 3");
m4 = conv_img("Moon 4");
m5 = conv_img("Moon 5");

A = [m1, m2, m3, m4, m5];

Aavg = mean(A, 2);
cLen = size(A, 2);

B = A - Aavg * ones(1, cLen);

[U, S, V] = svd(B, 'econ');
avg_moon = reshape(Aavg, [250, 250]);

figure(1)
imagesc(avg_moon)
title('Medelmåne')

U1 = reshape(U(:, 1), [250,250]);
U2 = reshape(U(:, 2), [250,250]);
U3 = reshape(U(:, 3), [250,250]);
U4 = reshape(U(:, 4), [250,250]);
U5 = reshape(U(:, 5), [250,250]);
U_mat = [U1 U2 U3 U4 U5];

figure(2), axes('position', [0 0 1 1]), axis off
imagesc(U_mat)

figure(3)
subplot(1, 5, 1), imagesc(U1)
subplot(1, 5, 2), imagesc(U2)
subplot(1, 5, 3), imagesc(U3)
subplot(1, 5, 4), imagesc(U4)
subplot(1, 5, 5), imagesc(U5)

function img = conv_img(img_name)
    img = imread("C:\Users\anton\OneDrive\Bilder\Moon\" + img_name + ".jpg");
    img = rgb2gray(img);
    %imshow(img);
    img = reshape(img, [62500, 1]);
    img = im2double(img);
    
end