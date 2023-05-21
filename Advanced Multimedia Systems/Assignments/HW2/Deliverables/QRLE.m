% Quantized RLE
function [output_img, hx, psnr] = QRLE(img, d)
    if isstring(img)
        img = imread(img);
    end
    [R, C, CFV, RFV] = GRLOQ(img, d);
    % run RLE on both vectors from GRLOQ.
    % output the one with the least entropy.
    CFRLE = RLE(CFV);
    RFRLE = RLE(RFV);
    hx_c = (numel(CFRLE{1})*Entropy_Array(CFRLE{1}) + ...
        numel(CFRLE{2})*Entropy_Array(CFRLE{2}))/numel(img);
    hx_r = (numel(RFRLE{1})*Entropy_Array(RFRLE{1}) + ...
        numel(RFRLE{2})*Entropy_Array(RFRLE{2}))/numel(img);
    if hx_c >= hx_r
        output_img = uint8(reshape(RFV, R, C)');
        hx = hx_r;
    else
        output_img = uint8(reshape(CFV, R, C));
        hx = hx_c;
    end
    psnr = PSNR(img, output_img);
end