% Block Stereo Matching Predictor
function [error, disparity_vec, strip, LeftI, et] = BSMP(directory, block_size, window_size)
    t0 = tic;
    if nargin < 3
        % empirical values
        block_size = 20;
        window_size = 50;
    end
    paths = dir(directory);
    LeftI = imread([paths(3).folder '\' paths(3).name]);
    RightI = imread([paths(4).folder '\' paths(4).name]);
    [H, W, ~] = size(LeftI);
    x_max = fix(W/block_size) - 1;
    strip = [];
    % matching performed only on x-axis
    % left over in x direction not allowed, remainder is stripped and
    % returned as the "strip" output
    if rem(W, block_size) ~= 0
        x_begin = block_size*(x_max + 1) + 1;
        x_end = x_begin + rem(W, block_size) - 1;
        strip = RightI(1:end, x_begin:x_end, 1:end);
        disparity_vec = zeros([H W - rem(W, block_size)]);
    else
        disparity_vec = zeros([H W]);
    end
    % leftover in y direction is ok
    y_max = fix(H/block_size);
    if rem(H, block_size) == 0
        y_max = y_max - 1;
    end
    % construct starting indices for blocks
    x = zeros([1 x_max+1]);
    y = zeros([1 y_max+1]);
    for i=1:x_max+1
        x(i) = block_size*(i-1) + 1;
    end
    for i=1:y_max+1
        y(i) = block_size*(i-1) + 1;
    end
    % matching
    for i=1:length(x)
        for j=1:length(y)
            x_end = x(i) + block_size - 1;
            y_end = y(j) + block_size - 1;
            % edge case: if we don't have a perfect block on y-axis
            if j==length(y) && rem(H, block_size) ~= 0
                y_end = y(j) + rem(H, block_size) - 1;
            end
            curr_right_block = RightI(y(j):y_end, x(i):x_end, 1:end);
            best_SAD = Inf;
            available_window = min(window_size, x(length(x)) - x(i) + 1);
            for k=1:available_window
                x_blk_begin = x(i)+k-1;
                left_block = LeftI(y(j):y_end, x_blk_begin:x_blk_begin + block_size - 1, 1:end);
                curr_SAD = SAD(curr_right_block, left_block); % SAD over MSE because time efficiency
                if curr_SAD < best_SAD
                    best_SAD = curr_SAD;
                    disparity_vec(y(j):y_end, x(i):x_end) = k - 1;
                end
            end
        end
    end
    [H, W] = size(disparity_vec);
    right_prediction = zeros([H, W, 3]);
    % reconstruct the right image
    for x_pred=1:W
        for y_pred=1:H
            right_prediction(y_pred, x_pred, 1:end)=...
                LeftI(y_pred, x_pred+disparity_vec(y_pred, x_pred), 1:end);
        end
    end
    % calculate its error
    error = int16(RightI(1:end, 1:end-rem(end,block_size), 1:end)) - int16(right_prediction);
    et = toc(t0);
end