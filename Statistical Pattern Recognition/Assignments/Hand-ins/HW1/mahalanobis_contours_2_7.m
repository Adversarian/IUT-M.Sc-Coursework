x = linspace(-100, 100);
y = linspace(-100, 100);
z = zeros([100 100]);
for i=1:100
    for j=1:100
        z(i, j) = sqrt([x(i)-2.1 y(j)-1.9]*[0.9 -0.2;-0.2 0.6]*[x(i)-2.1;y(j)-1.9]);
    end
end
contour(z);