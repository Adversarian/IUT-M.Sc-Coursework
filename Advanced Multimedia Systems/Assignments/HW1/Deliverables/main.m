% testing MSE and PSNR
sample_img = imread('Inputs/Baboon.png');
disp('Testing MSE and PSNR ...');
disp('MSE of an array against itself: ');
fprintf('    %f\n', MSE(sample_img, sample_img));
disp('PSNR of an array against itself: ');
fprintf('    %f\n', PSNR(sample_img, sample_img));
% testing GetBestBNW
disp('Testing GetBestBNW ...');
[bnw1, psnr1] = GetBestBNW("Inputs/Baboon.png");
figure('name', 'Baboon Black&White'), imshow(bnw1);
fprintf('PSNR between Baboon.png and Baboon_bnw.png: %f\n', psnr1);
[bnw2, psnr2] = GetBestBNW("Inputs/Boat.png");
figure('name', 'Boat Black&White'), imshow(bnw2);
fprintf('PSNR between Boat.png and Boat_bnw.png: %f\n', psnr2);
[bnw3, psnr3] = GetBestBNW("Inputs/Goldhill.png");
figure('name', 'Goldhill Black&White'), imshow(bnw3);
fprintf('PSNR between Goldhill.png and Goldhill_bnw.png: %f\n', psnr3);
% testing ReadPPM
disp('Testing ReadPPM');
figure('name', 'Baboon.ppm'), imshow(ReadPPM('Inputs/Baboon.ppm'));
figure('name', 'Boat.ppm'), imshow(ReadPPM('Inputs/Boat.ppm'));
figure('name', 'Goldhill.ppm'), imshow(ReadPPM('Inputs/Goldhill.ppm'));
% testing Entropy
[ent1, cr1] = ent('Inputs/Baboon_Gray.png');
fprintf('Baboon_Gray.png -> Entropy: %f, Redundancy: %f\n', ent1, cr1);
[ent2, cr2] = ent('Inputs/Boat_Gray.png');
fprintf('Boat_Gray.png -> Entropy: %f, Redundancy: %f\n', ent2, cr2);
[ent3, cr3] = ent('Inputs/Goldhill_Gray.png');
fprintf('Goldhill_Gray.png -> Entropy: %f, Redundancy: %f\n', ent3, cr3);
save("Results\Entropy\Baboon_Gray.mat", "ent1", "cr1");
save("Results\Entropy\Boat_Gray.mat", "ent2", "cr2");
save("Results\Entropy\Goldhill_Gray.mat", "ent3", "cr3");
% testing NaiveUnaryCodec
disp('Testing NaiveUnaryCodec ...');
disp('Encoding Baboon_Gray.png ...');
ncodec = NaiveUnaryCodec('Inputs/Baboon_Gray.png');
[~, cr1, et11, cdsize1, tsize1, dsize1] = ncodec.encode('Results/NaiveUnaryCodec/Encoded/Baboon_Gray.enc');
disp('Decoding Baboon_Gray.png ...');
ncodec = NaiveUnaryCodec('Results/NaiveUnaryCodec/Encoded/Baboon_Gray.enc');
[~, et12] = ncodec.decode('Results/NaiveUnaryCodec/Decoded/Baboon_Gray_Decoded.png');
save("Results/NaiveUnaryCodec/Saved Vars/Baboon_Summary.mat", "cr1", "et11", "cdsize1", "tsize1", "dsize1", "et12");

disp('Encoding Boat_Gray.png ...');
ncodec = NaiveUnaryCodec('Inputs/Boat_Gray.png');
[~, cr2, et21, cdsize2, tsize2, dsize2] = ncodec.encode('Results/NaiveUnaryCodec/Encoded/Boat_Gray.enc');
disp('Decoding Boat_Gray.png ...');
ncodec = NaiveUnaryCodec('Results/NaiveUnaryCodec/Encoded/Boat_Gray.enc');
[~, et22] = ncodec.decode('Results/NaiveUnaryCodec/Decoded/Boat_Gray_Decoded.png');
save("Results/NaiveUnaryCodec/Saved Vars/Boat_Summary.mat", "cr2", "et21", "cdsize2", "tsize2", "dsize2", "et22");

disp('Encoding Goldhill_Gray.png ...');
ncodec = NaiveUnaryCodec('Inputs/Goldhill_Gray.png');
[~, cr3, et31, cdsize3, tsize3, dsize3] = ncodec.encode('Results/NaiveUnaryCodec/Encoded/Goldhill_Gray.enc');
disp('Decoding Goldhill_Gray.png ...');
ncodec = NaiveUnaryCodec('Results/NaiveUnaryCodec/Encoded/Goldhill_Gray.enc');
[~, et32] = ncodec.decode('Results/NaiveUnaryCodec/Decoded/Goldhill_Gray_Decoded.png');
save("Results/NaiveUnaryCodec/Saved Vars/Goldhill_Summary.mat", "cr3", "et31", "cdsize3", "tsize3", "dsize3", "et32");
disp('Results saved under Results/NaiveUnaryCodec.');
% testing proposed method (UnaryCodec)
disp('Testing UnaryCodec ...');
disp('Encoding Baboon_Gray.png ...');
codec = UnaryCodec('Inputs/Baboon_Gray.png');
[~, cr4, et41, cdsize4, tsize4, dsize4] = codec.encode('Results/UnaryCodec/Encoded/Baboon_Gray.enc');
disp('Decoding Baboon_Gray.png ...');
codec = UnaryCodec('Results/UnaryCodec/Encoded/Baboon_Gray.enc');
[~, et42] = codec.decode('Results/UnaryCodec/Decoded/Baboon_Gray_Decoded.png');
save("Results/UnaryCodec/Saved Vars/Baboon_Summary.mat", "cr4", "et41", "cdsize4", "tsize4", "dsize4", "et42");

disp('Encoding Boat_Gray.png ...');
codec = UnaryCodec('Inputs/Boat_Gray.png');
[~, cr5, et51, cdsize5, tsize5, dsize5] = codec.encode('Results/UnaryCodec/Encoded/Boat_Gray.enc');
disp('Decoding Boat_Gray.png ...');
codec = UnaryCodec('Results/UnaryCodec/Encoded/Boat_Gray.enc');
[~, et52] = codec.decode('Results/UnaryCodec/Decoded/Boat_Gray_Decoded.png');
save("Results/UnaryCodec/Saved Vars/Boat_Summary.mat", "cr5", "et51", "cdsize5", "tsize5", "dsize5", "et52");

disp('Encoding Goldhill_Gray.png ...');
codec = UnaryCodec('Inputs/Goldhill_Gray.png');
[~, cr6, et61, cdsize6, tsize6, dsize6] = codec.encode('Results/UnaryCodec/Encoded/Goldhill_Gray.enc');
disp('Decoding Goldhill_Gray.png ...');
codec = UnaryCodec('Results/UnaryCodec/Encoded/Goldhill_Gray.enc');
[~, et62] = codec.decode('Results/UnaryCodec/Decoded/Goldhill_Gray_Decoded.png');
save("Results/UnaryCodec/Saved Vars/Goldhill_Summary.mat", "cr6", "et61", "cdsize6", "tsize6", "dsize6", "et62");
disp('Results saved under Results/UnaryCodec.');

disp('Done!');
