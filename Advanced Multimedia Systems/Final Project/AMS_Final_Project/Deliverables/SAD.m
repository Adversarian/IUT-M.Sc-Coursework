function sad = SAD(img1, img2)
    % https://en.wikipedia.org/wiki/Sum_of_absolute_differences
    sad = sum(abs(img1 - img2), "all");
end