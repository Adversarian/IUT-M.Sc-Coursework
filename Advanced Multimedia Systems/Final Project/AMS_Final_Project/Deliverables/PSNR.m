function psnr = PSNR(img1, img2)
    % https://en.wikipedia.org/wiki/Peak_signal-to-noise_ratio
    psnr = 10 * log10(255^2/MSE(img1, img2));
end