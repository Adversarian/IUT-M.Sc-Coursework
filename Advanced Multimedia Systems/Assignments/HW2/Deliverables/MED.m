% Mean Edge Detector
classdef MED
    properties
        image
        error
    end
    methods
        function obj = MED(input)
            if nargin > 0
                obj.image = imread(input);
            end
        end
        function obj = encPredict(obj)
            % Calculates an error map from a given input image using MED.
            [H, W] = size(obj.image);
            pred = int16(zeros([H, W]));
            obj.error = int16(zeros([H, W]));
            % Pad one above and one to the left with 0
            padded = int16(padarray(obj.image, [1, 1], 0, 'pre'));
            % A = W, B = N, C = NW
            for i = 2:H+1
                for j = 2:W+1
                    % MED
                    A = padded(i, j-1);
                    B = padded(i-1, j);
                    C = padded(i-1, j-1);
                    if C >= max(A, B)
                        pred(i-1, j-1) = min(A, B);
                    elseif C <= min(A,B)
                        pred(i-1, j-1) = max(A, B);
                    else
                        pred(i-1, j-1) = A + B - C;
                    end
                    obj.error(i-1, j-1) = int16(obj.image(i-1, j-1)) - pred(i-1, j-1);
                end
            end
        end
        function rec = decPredict(obj)
            % Counterpart of encPredict. Performs MED prediction on
            % using only the error map as reference. Operations are
            % symmetric to encPredict. Returns the reconstructed image.
            [H, W] = size(obj.error);
            pred = int16(zeros([H+1, W+1]));
            rec = uint8(zeros([H, W]));
            for i = 2:H+1
                for j = 2:W+1
                    A = pred(i, j-1);
                    B = pred(i-1, j);
                    C = pred(i-1, j-1);
                    if C >= max(A, B)
                        pred(i, j) = min(A, B);
                    elseif C <= min(A,B)
                        pred(i, j) = max(A, B);
                    else
                        pred(i, j) = A + B - C;
                    end
                    pred(i, j) = pred(i, j) + obj.error(i-1, j-1);
                    rec(i-1, j-1) = uint8(pred(i, j));
                end
            end
        end
    end
end