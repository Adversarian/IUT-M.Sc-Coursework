% Inverse Block Stereo Matching Predictor
function [reconstruction, et] = IBSMP(LeftI, dv, error_map, strip)
    t0 = tic;
    [H, W] = size(dv);
    % reconstruct the right image
    right_prediction = zeros([H, W, 3]);
    for x_pred=1:W
        for y_pred=1:H
            right_prediction(y_pred, x_pred, 1:end)=...
                int16(LeftI(y_pred, x_pred+dv(y_pred, x_pred), 1:end))+...
                error_map(y_pred, x_pred, 1:end);
        end
    end
    % append the stripped part to the right of it
    right_prediction = [right_prediction strip];
    reconstruction = uint8(right_prediction);
    et = toc(t0);
end