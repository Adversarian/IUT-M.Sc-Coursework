%% Distribution Initialization
N = 100;
mu1 = [1.0, 1.0];
mu2 = [1.5, 1.5];
s = 0.2;
sigma = eye([2 2]) * s;
fprintf('Number of Samples: %d\nmu1: [%f, %f], mu2: [%f, %f]\nsigma: %f\n',...
    N, mu1(1), mu1(2), mu2(1), mu2(2), s);
%% Sample Generation
c1_samples = mvnrnd(mu1, sigma, N);
c2_samples = mvnrnd(mu2, sigma, N);
labels = [ones([N 1]); 2*ones([N 1])];
all_samples = [c1_samples; c2_samples];
%% BME Classification
predictions = zeros([2*N 1]);
threshold = mu1'*mu1 - mu2'*mu2;
for i=1:2*N
    x = [all_samples(i, 1) all_samples(i, 2)];
    A = x'*(mu1 - mu2);
    if A + A' > threshold
        predictions(i) = 1;
    elseif A + A' < threshold
        predictions(i) = 2;
    else
        predictions(i) = randi([1, 2], 1);
    end
end
%% BME Error
e = sum(predictions ~= labels)/(2*N);
fprintf('BME Classification Error: %f\n', e);
%% BMR Classification
predictions = zeros([2*N 1]);
threshold = mu1'*mu1 - mu2'*mu2 + 2*(0.2^2)*(log(2));
for i=1:2*N
    x = [all_samples(i, 1) all_samples(i, 2)];
    A = x'*(mu1 - mu2);
    if A + A' > threshold
        predictions(i) = 1;
    elseif A + A' < threshold
        predictions(i) = 2;
    else
        predictions(i) = randi([1, 2], 1);
    end
end
%% BMR (Weighted) Error
e = (predictions ~= labels);
e = (0.5*sum(e(1:N)) + sum(e(N+1:2*N)))/(2*N);
fprintf('BMR Classification Error: %f\n', e);
%% Repeating the experiment for a different mu2
% Because in the second experiment the difference between mu1 and mu2 is
% more tangible, the classifier has less trouble drawing the line between
% the two classes and therefore we have less error both for BME and BMR
N = 100;
mu1 = [1.0, 1.0];
mu2 = [3.0, 3.0];
s = 0.2;
sigma = eye([2 2]) * s;
fprintf('Number of Samples: %d\nmu1: [%f, %f], mu2: [%f, %f]\nsigma: %f\n',...
    N, mu1(1), mu1(2), mu2(1), mu2(2), s);
c1_samples = mvnrnd(mu1, sigma, N);
c2_samples = mvnrnd(mu2, sigma, N);
labels = [ones([N 1]); 2*ones([N 1])];
all_samples = [c1_samples; c2_samples];
predictions = zeros([2*N 1]);
threshold = mu1'*mu1 - mu2'*mu2;
for i=1:2*N
    x = [all_samples(i, 1) all_samples(i, 2)];
    A = x'*(mu1 - mu2);
    if A + A' > threshold
        predictions(i) = 1;
    elseif A + A' < threshold
        predictions(i) = 2;
    else
        predictions(i) = randi([1, 2], 1);
    end
end
e = sum(predictions ~= labels)/(2*N);
fprintf('BME Classification Error: %f\n', e);
predictions = zeros([2*N 1]);
threshold = mu1'*mu1 - mu2'*mu2 + 2*(0.2^2)*(log(2));
for i=1:2*N
    x = [all_samples(i, 1) all_samples(i, 2)];
    A = x'*(mu1 - mu2);
    if A + A' > threshold
        predictions(i) = 1;
    elseif A + A' < threshold
        predictions(i) = 2;
    else
        predictions(i) = randi([1, 2], 1);
    end
end
e = (predictions ~= labels);
e = (0.5*sum(e(1:N)) + sum(e(N+1:2*N)))/(2*N);
fprintf('BMR Classification Error: %f\n', e);
