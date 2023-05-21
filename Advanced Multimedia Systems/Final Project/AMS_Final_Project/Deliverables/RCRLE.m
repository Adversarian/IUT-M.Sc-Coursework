% Get row-major and column-major RLE, return the one with the least entropy
function [rec, h_best] = RCRLE(img)
    [R, C] = size(img);
    CF_Vector = reshape(img, 1, []);
    RF_Vector = reshape(img', 1, []);
    CFRLE = RLE(CF_Vector);
    RFRLE = RLE(RF_Vector);
    hx_c = (numel(CFRLE{1})*Entropy_Array(CFRLE{1}) + ...
        numel(CFRLE{2})*Entropy_Array(CFRLE{2}))/numel(img);
    hx_r = (numel(RFRLE{1})*Entropy_Array(RFRLE{1}) + ...
        numel(RFRLE{2})*Entropy_Array(RFRLE{2}))/numel(img);
    if hx_c >= hx_r
        rec = reshape(RF_Vector, C, R)';
        h_best = hx_r;
    else
        rec = reshape(CF_Vector, R, C);
        h_best = hx_c;
    end
end