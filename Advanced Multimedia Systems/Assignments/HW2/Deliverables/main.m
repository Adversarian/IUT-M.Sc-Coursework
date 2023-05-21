% Specifications of the system on which these tests were performed:
% OS: Windows 10
% RAM: 16 GB DDR4
% Processor: AMD Ryzen 9 5900HX
%% Testing MED
orig_img = imread('Inputs/Baboon.tif');
med = MED('Inputs/Baboon.tif');
med = med.encPredict();
reconstructed = med.decPredict();
fprintf('PSNR: Original image VS. MED reconstruction: %f\n', PSNR(orig_img, reconstructed));
%% Testing AdaGAP
results_comparison = struct();
adagap = AdaGAP('Inputs/Baboon.tif');
[adagap, ~] = adagap.encPredict();
[reconstructed, ~] = adagap.decPredict();
fprintf('PSNR: Original image VS. AdaGAP reconstruction: %f\n', PSNR(orig_img, reconstructed));
paths = dir('Inputs/');
for i=3:length(paths)
    im_path = strcat("Inputs/", paths(i).name);
    img = imread(im_path);
    results_comparison(i-2).image_name = paths(i).name(1:length(paths(i).name)-4);
    results_comparison(i-2).image_entropy = Entropy_Array(img);
    med = MED(im_path);
    med = med.encPredict();
    results_comparison(i-2).med_error_entropy = Entropy_Array(med.error);
    adagap = AdaGAP(im_path);
    [adagap, et_enc] = adagap.encPredict();
    [~, et_dec] = adagap.decPredict();
    results_comparison(i-2).proposed_error_bpp = Entropy_Array(adagap.error) + 1/numel(img);
    results_comparison(i-2).proposed_runtime = et_enc + et_dec;
end
last = length(results_comparison)+1;
results_comparison(last).image_name = 'Average';
results_comparison(last).image_entropy = mean([results_comparison(:).image_entropy]);
results_comparison(last).med_error_entropy = mean([results_comparison(:).med_error_entropy]);
results_comparison(last).proposed_error_bpp = mean([results_comparison(:).proposed_error_bpp]);
results_comparison(last).proposed_runtime = mean([results_comparison(:).proposed_runtime]);
save('Results/predictor_comparison.mat', "results_comparison");
disp('Results saved to Results/predictor_comparison.mat !');
%% Testing QRLE
results_RLE = struct();
paths = dir('Inputs/');
d = [0, 1, 3, 5];
pos = 1;
running_sum_hx = containers.Map({0, 1, 3, 5}, {0, 0, 0, 0});
running_sum_psnr = containers.Map({0, 1, 3, 5}, {0, 0, 0, 0});
for i=3:length(paths)
    im_path = strcat("Inputs/", paths(i).name);
    for j=d
        results_RLE(pos).image_name = paths(i).name(1:length(paths(i).name)-4);
        [~, hx, psnr] = QRLE(im_path, j);
        results_RLE(pos).d = j;
        results_RLE(pos).best_RLE_entropy = hx;
        results_RLE(pos).best_RLE_PSNR = psnr;
        running_sum_hx(j) = running_sum_hx(j) + hx;
        running_sum_psnr(j) = running_sum_psnr(j) + psnr;
        pos = pos + 1;
    end
end
orig_length = length(results_RLE);
for i=d
    %running_sum_hx = 0;
    %running_sum_psnr = 0;
    %for j=1:orig_length
    %    if results_RLE(j).d == i
    %        running_sum_hx = running_sum_hx + results_RLE(j).best_RLE_entropy;
    %        running_sum_psnr = running_sum_psnr + results_RLE(j).best_RLE_PSNR;
    %    end
    %end
    avg_hx = running_sum_hx(i) / (length(paths)-2);
    avg_psnr = running_sum_psnr(i) / (length(paths)-2);
    results_RLE(pos).image_name = 'Average';
    results_RLE(pos).d = i;
    results_RLE(pos).best_RLE_entropy = avg_hx;
    results_RLE(pos).best_RLE_PSNR = avg_psnr;
    pos = pos + 1;
end
save('Results/RLE_comparison.mat', "results_RLE");
disp('Results saved to Results/RLE_comparison.mat !');