function [hx, redundancy] = ent(img_dir)
    % create a histogram from the input image
    hst = zeros([256, 1]);
    img = imread(img_dir);
    [M, N] = size(img);
    for i = 1:M
        for j = 1:N
            hst(img(i, j) + 1) = hst(img(i, j) + 1) + 1;
        end
    end
    % calculate entropy
    p = hst ./ (M*N);
    % remove 0 entries (because 0*log2(0) is NaN but is effectively 0 when
    % its limit is caluclated using l'hopital's rule.
    p(p==0) = [];
    hx = -sum(p.*log2(p));
    % calculate coding redundancy
    redundancy = 8 - hx;
end