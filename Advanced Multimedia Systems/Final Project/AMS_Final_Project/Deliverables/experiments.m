% Specifications of the system on which these tests were performed:
% OS: Windows 10
% RAM: 16 GB DDR4
% Processor: AMD Ryzen 9 5900HX
%% Sanity Check: Ensuring the losslessness of both RGBAdaGAP and BSMP
img_1 = imread("Stereo_Pairs\Alovera\Image_1.png");
img_2 = imread("Stereo_Pairs\Alovera\Image_2.png");
t0 = tic;
disp("Encoding with RGBAdaGAP ...");
gap_inst = RGBAdaGAP(img_1);
[gap_inst, ~, et_gap_enc] = gap_inst.encPredict();
fprintf("Done @ %f\n", et_gap_enc);
disp("Encoding with BSMP ...");
[error, dv, strip, LeftI, et_bsmp] = BSMP("Stereo_Pairs\Alovera");
[dv_rec, ~] = RCRLE(dv);
fprintf("Done @ %f\n", et_bsmp);
disp("Decoding with RGBAdaGAP ...");
[rec_adagap, et_gap_dec] = gap_inst.decPredict();
fprintf("Done @ %f\n", et_gap_dec);
disp("Decoding with IBSMP ...");
[rec_ibsmp, et_ibsmp] = IBSMP(LeftI, dv_rec, error, strip);
fprintf("Done @ %f\n", et_ibsmp);
fprintf("PSNR(LeftI, rec_adagap): %f\n", PSNR(img_1, rec_adagap));
fprintf("PSNR(RightI, rec_ibsmp): %f\n", PSNR(img_2, rec_ibsmp));
toc(t0);
clearvars
%% Performing Experiments
results = struct();
paths = dir("Stereo_Pairs/");
for i = 3:length(paths)
    t = tic;
    gap_inst = RGBAdaGAP([paths(i).folder '\' paths(i).name '\Image_1.png']);
    [error, dv, strip, LeftI, et_bsmp] = BSMP([paths(i).folder '\' paths(i).name]);
    % RLE is performed on dv here for entropy calculations
    % the bigger the block_size, the bigger the gains
    [dv_rec, hx_dv] = RCRLE(dv);
    [gap_inst, h_left, et_gap_enc] = gap_inst.encPredict();
    [rec_adagap, et_gap_dec] = gap_inst.decPredict();
    [rec_ibsmp, et_ibsmp] = IBSMP(LeftI, dv_rec, error, strip);
    et_total = toc(t);
    h_right = (Entropy_Array(error)*numel(error) + hx_dv*numel(dv) + ...
        Entropy_Array(strip)*numel(strip))/(numel(error) + numel(dv) + ...
        numel(strip));
    h_avg = mean([h_right, h_left]);
    h_left_orig = Entropy_Array(imread([paths(i).folder '\' paths(i).name '\Image_1.png']));
    h_right_orig = Entropy_Array(imread([paths(i).folder '\' paths(i).name '\Image_2.png']));
    h_avg_orig = mean([h_right_orig, h_left_orig]);
    results(i-2).stereo_pair = paths(i).name;
    results(i-2).h_left_orig = h_left_orig;
    results(i-2).h_right_orig = h_right_orig;
    results(i-2).h_avg_orig = h_avg_orig;
    results(i-2).h_left = h_left;
    results(i-2).h_right = h_right;
    results(i-2).h_avg = h_avg;
    results(i-2).improvement_percentage = 100*(h_avg_orig - h_avg)/h_avg_orig;
    results(i-2).et_bsmp = et_bsmp;
    results(i-2).et_ibsmp = et_ibsmp;
    results(i-2).et_adagap_enc = et_gap_enc;
    results(i-2).et_adagap_dec = et_gap_dec;
    results(i-2).et_total = et_total;
end
last = length(results) + 1;
results(last).stereo_pair = 'Average';
results(last).h_left_orig = mean([results(:).h_left_orig]);
results(last).h_right_orig = mean([results(:).h_right_orig]);
results(last).h_avg_orig = mean([results(:).h_avg_orig]);
results(last).h_left = mean([results(:).h_left]);
results(last).h_right = mean([results(:).h_right]);
results(last).h_avg = mean([results(:).h_avg]);
results(last).improvement_percentage = mean([results(:).improvement_percentage]);
results(last).et_bsmp = mean([results(:).et_bsmp]);
results(last).et_ibsmp = mean([results(:).et_ibsmp]);
results(last).et_adagap_enc = mean([results(:).et_adagap_enc]);
results(last).et_adagap_dec = mean([results(:).et_adagap_dec]);
results(last).et_total = mean([results(:).et_total]);
save('Results/experiment_results.mat', "results");
disp('Results saved to Results/experiment_results.mat !');
