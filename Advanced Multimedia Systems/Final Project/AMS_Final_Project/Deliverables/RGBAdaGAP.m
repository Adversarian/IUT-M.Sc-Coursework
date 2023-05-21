% Wrapper for using AdaGAP on RGB images
classdef RGBAdaGAP
    properties
        adagap_instance_R
        adagap_instance_G
        adagap_instance_B
    end
    methods
        function obj = RGBAdaGAP(input, roc)
            if nargin < 2
               roc = 1/128;
            end
            if isstring(input) || ischar(input)
                rgb_img = imread(input);
            else
                rgb_img = input;
            end
            % use three instances of AdaGAP, one for each color plane
            obj.adagap_instance_R = AdaGAP(rgb_img(:,:,1), roc);
            obj.adagap_instance_G = AdaGAP(rgb_img(:,:,2), roc);
            obj.adagap_instance_B = AdaGAP(rgb_img(:,:,3), roc);
        end
        function [obj, hx, et] = encPredict(obj)
            t0 = tic;
            [obj.adagap_instance_R, ~] = obj.adagap_instance_R.encPredict();
            [obj.adagap_instance_G, ~] = obj.adagap_instance_G.encPredict();
            [obj.adagap_instance_B, ~] = obj.adagap_instance_B.encPredict();
            et = toc(t0);
            hx = (Entropy_Array(obj.adagap_instance_R.error)*numel(obj.adagap_instance_R.error)+...
                Entropy_Array(obj.adagap_instance_G.error)*numel(obj.adagap_instance_G.error)+...
                Entropy_Array(obj.adagap_instance_B.error)*numel(obj.adagap_instance_B.error))/...
                (numel(obj.adagap_instance_R.error) + numel(obj.adagap_instance_G.error) + numel(obj.adagap_instance_B.error));
        end
        function [rec, et] = decPredict(obj)
            t0 = tic;
            [rec_R, ~] = obj.adagap_instance_R.decPredict();
            [rec_G, ~] = obj.adagap_instance_G.decPredict();
            [rec_B, ~] = obj.adagap_instance_B.decPredict();
            % reconstruct original RGB by concatenating the color planes
            rec = cat(3, rec_R, rec_G, rec_B);
            et = toc(t0);
        end

    end
end