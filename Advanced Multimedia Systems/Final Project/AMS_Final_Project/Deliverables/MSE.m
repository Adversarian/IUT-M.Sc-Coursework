function mse = MSE(img1, img2)
    % https://en.wikipedia.org/wiki/Mean_squared_error
    mse = mean((img1 - img2).^2, "all");
end