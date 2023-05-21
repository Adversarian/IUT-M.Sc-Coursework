% Greedy Run Length Optimized Quantizer
function [R, C, CF_Vector, RF_Vector] = GRLOQ(img, d)
    % return R and C so that the original image is reconstructable
    [R, C] = size(img);
    % return both the row-first and column-first vectors
    CF_Vector = int16(reshape(img, 1, []));
    RF_Vector = int16(reshape(img', 1, []));
    % greedily append any pixel to the previous one if it doesn't violate
    % the "d" near-lossless constraint.
    for i=2:length(CF_Vector)
        if abs(CF_Vector(i-1) - CF_Vector(i)) <= d
            CF_Vector(i) = CF_Vector(i-1);
        end
        if abs(RF_Vector(i-1) - RF_Vector(i)) <= d
            RF_Vector(i) = RF_Vector(i-1);
        end
    end
    CF_Vector = uint8(CF_Vector);
    RF_Vector = uint8(RF_Vector);
end