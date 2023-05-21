%% DCT Basis Functions
disp("The 16x16 visual representation of the DCT basis functions.");
f_ns = DCT_Basis(16, 32);
figure('Name','DCT Basis Functions'), tiledlayout(16, 16,...
    "TileSpacing","tight",...
    "Padding", "tight");
for i = 1:16
    for j = 1:16
        nexttile
        f_i_j = squeeze(f_ns(i,j,:,:));
        imshow(f_i_j,[])
    end
end
disp("Press any key to continue ...");
pause;
close all
%% Bit Planes
disp("The 32 bit planes of the DCT of Cover_Image.png");
img = imread('Inputs/Cover_Image.png');
dct_img = round(dct2(img));
for i=1:32
    name = sprintf("Bit Plane #%d", i);
    figure('Name',name), imshow(bitget(dct_img, i, "int32"), []);
end
disp("Press any key to continue ...");
pause;
close all
rand_plane = uint8(round(rand(size(img))));
disp("The DCT-1 of Cover_Image.png with randomized DCT bit planes");
for i=1:32
    dct_copy = dct_img;
    bitset(dct_copy, i, rand_plane, "int32");
    name = sprintf("DCT-1 for Randomized Bit Plane #%d", i);
    figure('Name', name), imshow(idct2(dct_copy), []);
end
disp("Press any key to continue ...");
pause;
close all
disp("Cover_Image.png with randomized bit planes");
for i=1:8
    img_copy = img;
    bitset(img_copy, i, rand_plane);
    name = sprintf("Original Image with Replaced Bit Plane #%d", i);
    figure('Name', name), imshow(img_copy);
end
disp("Press any key to continue ...");
pause;
close all
%% Steganography
% Encrypting the jpg image
cover = imread('Inputs/Cover_Image.png');
secret = imread('Inputs/IUT.jpg');
disp("Embedding secret message in cover image ...");
stego = StegHide('Inputs/Cover_Image.png', 'Inputs/IUT.jpg');
fprintf("PSNR(stego_image, cover_image): %f\n", PSNR(stego.stego_image, cover));
disp("Extracting secret message from cover image ...");
restored_secret = stego.ExtractSecret('Deliverables/Results/IUT_restored.jpg');
fprintf("PSNR(restored_secret, original_secret): %f\n", PSNR(secret, restored_secret));
disp("Bit Planes of the Stego Image");
for i=1:8
    name = sprintf("Bit Plane #%d of the Stego Image", i);
    figure('Name', name), imshow(bitget(stego.stego_image, i), []);
end
disp("Press any key to continue ...");
pause;
close all