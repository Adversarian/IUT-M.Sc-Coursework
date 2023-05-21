% Adaptive Gradient Adjusted Predictor
classdef AdaGAP
    properties
        image
        error
        threshold
        % Rate of Change
        roc
        % The first pixel of the image
        top_left
    end
    methods
        function obj = AdaGAP(input, roc)
            % if roc = 0, AdaGAP = GAP
            if nargin > 0
                if nargin < 2
                    roc = 1/128;
                end
                obj.roc = roc;
                obj.image = imread(input);
                obj.top_left = obj.image(1, 1);
                obj.threshold = 3;
            end
        end
        function [obj, et] = encPredict(obj)
            % Calculates error map from a given input image using an
            % Adaptive GAP. The idea is to combine the method used in ALCM
            % with GAP for a better estimation.
            tic;
            [R, C] = size(obj.image);
            img = double(obj.image);
            pred = zeros([R, C]);
            pred(1, 1) = img(1, 1);
            % Prediction for first column is the pixel above
            pred(2:R, 1) = img(2:R,1)-img(1:(R-1),1);
            % Prediction for the first row is the pixel to the left
            pred(1, 2:C) = img(1,2:C)-img(1,1:(C-1));
            obj.error = zeros([R, C]);
            obj.error(1, 1) = pred(1, 1);
            obj.error(2:R, 1) = pred(2:R, 1);
            obj.error(1, 2:C) = pred(1, 2:C);
            % Adaptively update these coefficients as we progress through
            % the image. Only W and N are considered because they affect
            % the result of the prediction the most.
            coeffs = containers.Map({'W', 'N'}, {1, 1});
            for i = 2:R
                for j = 2:C
                    % GAP
                    % No padding because we use a special encoding scheme for
                    % the first row and the first column, which means we
                    % have to handle the edge cases manually
                    W = img(i, j-1);
                    N = img(i-1, j);
                    NW = img(i-1, j-1);
                    % EDGE CASE: first scanned column has no WW
                    if j == 2
                        WW = W;
                    else
                        WW = img(i, j-2);
                    end
                    % EDGE CASE: first scanned row has no NN
                    if i == 2
                        NN = N;
                    else
                        NN = img(i-2, j);
                    end
                    % EDGE CASE: last scanned column has no NE or NNE
                    if j == C
                        NE = N;
                        NNE = NN;
                    else
                        NE = img(i-1, j+1);
                        % EDGE CASE: first scanned row has no NNE
                        if i == 2
                            NNE = NE;
                        else
                            NNE = img(i-2, j+1);
                        end
                    end
                    gradh = abs(W - WW) + abs(N - NW) + abs(N - NE);
                    gradv = abs(W - NW) + abs(N - NN) + abs(NE - NNE);
                    %% SHARP EDGES
                    if gradv - gradh > 80
                        pred(i, j) = min(coeffs('W')*W, 255.0);
                        obj.error(i, j) = img(i, j) - fix(pred(i, j));
                        % Adjust W with regard to the sign of error
                        if obj.error(i, j) > 0
                            coeffs('W') = coeffs('W') + obj.roc;
                        elseif obj.error(i, j) < 0
                            coeffs('W') = coeffs('W') - obj.roc;
                        end
                    elseif gradv - gradh < -80
                        pred(i, j) = min(coeffs('N')*N, 255.0);
                        obj.error(i, j) =img(i, j) - fix(pred(i, j));
                        % Adjust N with regard to the sign of error
                        if obj.error(i, j) > 0
                            coeffs('N') = coeffs('N') + obj.roc;
                        elseif obj.error(i, j) < 0
                            coeffs('N') = coeffs('N') - obj.roc;
                        end
                    else
                        pred(i, j) = min((coeffs('W')*W + coeffs('N')*N)/2 + (NE - NW)/4, 255.0);
                        %% WEAK EDGES
                        if gradv - gradh > 32
                            pred(i, j) = min((pred(i, j) + coeffs('W')*W)/2, 255.0);
                            obj.error(i, j) = img(i, j) - fix(pred(i, j));
                            % Adjust W with regard to the sign of error
                            if obj.error(i, j) > 0
                                coeffs('W') = coeffs('W') + obj.roc;
                            elseif obj.error(i, j) < 0
                                coeffs('W') = coeffs('W') - obj.roc;
                            end
                        elseif gradv - gradh > 8
                            pred(i, j) = min((3*pred(i, j) + coeffs('W')*W)/4, 255.0);
                            obj.error(i, j) = img(i, j) - fix(pred(i, j));
                            % Adjust W with regard to the sign of error
                            if obj.error(i, j) > 0
                                coeffs('W') = coeffs('W') + obj.roc;
                            elseif obj.error(i, j) < 0
                                coeffs('W') = coeffs('W') - obj.roc;
                            end
                        elseif gradv - gradh < -32
                            pred(i, j) = min((pred(i, j) + coeffs('N')*N)/2, 255.0);
                            obj.error(i, j) = img(i, j) - fix(pred(i, j));
                            % Adjust N with regard to the sign of error
                            if obj.error(i, j) > 0
                                coeffs('N') = coeffs('N') + obj.roc;
                            elseif obj.error(i, j) < 0
                                coeffs('N') = coeffs('N') - obj.roc;
                            end
                        elseif gradv - gradh < -8
                            pred(i, j) = min((3*pred(i, j) + coeffs('N')*N)/4, 255.0);
                            obj.error(i, j) = img(i, j) - fix(pred(i, j));
                            % Adjust N with regard to the sign of error
                            if obj.error(i, j) > 0
                                coeffs('N') = coeffs('N') + obj.roc;
                            elseif obj.error(i, j) < 0
                                coeffs('N') = coeffs('N') - obj.roc;
                            end
                        else
                            obj.error(i, j) = img(i, j) - fix(pred(i, j));
                        end
                    end
                    % reset if the error is too high
                    if abs(obj.error(i, j)) >= obj.threshold
                        coeffs('N') = 1.0;
                        coeffs('W') = 1.0;
                    end
                end
            end
            obj.error = int16(obj.error);
            et = toc;
        end
        function [rec, et] = decPredict(obj)
            % Counterpart of encPredict. Performs AdaGAP prediction on
            % using only the error map and the first row and column of the
            % original as reference. Operations are symmetric to encPredict.
            % Returns the reconstructed image.
            tic;
            [R, C] = size(obj.error);
            pred = zeros([R, C]);
            pred(1, 1) = obj.top_left;
            % pred(2:R, 1) = obj.first_column;
            % pred(1, 2:C) = obj.first_row;
            for i = 2:R
                pred(i, 1) = pred(i-1, 1) + obj.error(i, 1);
            end
            for i = 2:C
                pred(1, i) = pred(1, i-1) + obj.error(1, i);
            end            
            coeffs = containers.Map({'W', 'N'}, {1, 1});
            for i = 2:R
                for j = 2:C
                    W = pred(i, j-1);
                    N = pred(i-1, j);
                    NW = pred(i-1, j-1);
                    if j == 2
                        WW = W;
                    else
                        WW = pred(i, j-2);
                    end
                    if i == 2
                        NN = N;
                    else
                        NN = pred(i-2, j);
                    end
                    if j == C
                        NE = N;
                        NNE = NN;
                    else
                        NE = pred(i-1, j+1);
                        if i == 2
                            NNE = NE;
                        else
                            NNE = pred(i-2, j+1);
                        end
                    end
                    gradh = abs(W - WW) + abs(N - NW) + abs(N - NE);
                    gradv = abs(W - NW) + abs(N - NN) + abs(NE - NNE);
                    if gradv - gradh > 80
                        pred(i, j) = min(coeffs('W')*W, 255.0);
                        if obj.error(i, j) > 0
                            coeffs('W') = coeffs('W') + obj.roc;
                        elseif obj.error(i, j) < 0
                            coeffs('W') = coeffs('W') - obj.roc;
                        end
                    elseif gradv - gradh < -80
                        pred(i, j) = min(coeffs('N')*N, 255.0);
                        if obj.error(i, j) > 0
                            coeffs('N') = coeffs('N') + obj.roc;
                        elseif obj.error(i, j) < 0
                            coeffs('N') = coeffs('N') - obj.roc;
                        end
                    else
                        pred(i, j) = min((coeffs('W')*W + coeffs('N')*N)/2 + (NE - NW)/4, 255.0);
                        if gradv - gradh > 32
                            pred(i, j) = min((pred(i, j) + coeffs('W')*W)/2, 255.0);
                            if obj.error(i, j) > 0
                                coeffs('W') = coeffs('W') + obj.roc;
                            elseif obj.error(i, j) < 0
                                coeffs('W') = coeffs('W') - obj.roc;
                            end
                        elseif gradv - gradh > 8
                            pred(i, j) = min((3*pred(i, j) + coeffs('W')*W)/4, 255.0);
                            if obj.error(i, j) > 0
                                coeffs('W') = coeffs('W') + obj.roc;
                            elseif obj.error(i, j) < 0
                                coeffs('W') = coeffs('W') - obj.roc;
                            end
                        elseif gradv - gradh < -32
                            pred(i, j) = min((pred(i, j) + coeffs('N')*N)/2, 255.0);
                            if obj.error(i, j) > 0
                                coeffs('N') = coeffs('N') + obj.roc;
                            elseif obj.error(i, j) < 0
                                coeffs('N') = coeffs('N') - obj.roc;
                            end
                        elseif gradv - gradh < -8
                            pred(i, j) = min((3*pred(i, j) + coeffs('N')*N)/4, 255.0);
                            if obj.error(i, j) > 0
                                coeffs('N') = coeffs('N') + obj.roc;
                            elseif obj.error(i, j) < 0
                                coeffs('N') = coeffs('N') - obj.roc;
                            end
                        end
                    end
                    pred(i, j) = fix(pred(i, j)) + obj.error(i, j);
                    if abs(obj.error(i, j)) >= obj.threshold
                        coeffs('N') = 1.0;
                        coeffs('W') = 1.0;
                    end
                end
            end
            rec = uint8(pred);
            et = toc;
        end
    end
end