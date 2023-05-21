function [bnw, psnr] = GetBestBNW(img_dir)
    % Converts an RGB picture to the best possible binary image w.r.t. PSNR.
    img = imread(img_dir);
    % flatten the original image by taking mean of each channel
    flattened_img = mean(img, 3);
    % threshold at 127.5
    bnw = 255 * (uint8(flattened_img / 255));
    % broadcast B&W image to 3 channels
    broadcast_bnw = repmat(bnw, [1, 1, 3]);
    psnr = PSNR(broadcast_bnw, img);
    % save results to file
    [~,filename,extension] = fileparts(img_dir);
    imwrite(bnw, join(["Results/BnW/" filename "_bnw" extension], ""));
    save(join(["Results/BnW/" filename "_psnr.mat"], ""),"psnr");
end