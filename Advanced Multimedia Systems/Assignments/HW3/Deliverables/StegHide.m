% Simple stegangraphy class
classdef StegHide
    properties
        % used both as a random seed and to determine the length of secret
        % message in bits
        internal_key
        cover_image
        stego_image
    end
    methods
        function obj = StegHide(cover, secret)
            % Embeds secret into cover
            if nargin > 0
                obj.cover_image = imread(cover);
                handle = fopen(secret);
                % bit-level read
                secret_bits = uint8(fread(handle, '*ubit1'));
                fclose(handle);
                % secret key is equal to the length of secret message
                obj.internal_key = numel(secret_bits);
                % construct lsb as a vector
                lsb = uint8(zeros([numel(obj.cover_image), 1]));
                % set the seed
                rng(obj.internal_key);
                % construct a random pattern
                random_pattern = (round(rand(size(lsb)))==1);
                % place the secret in the beginning of the lsb vector
                lsb(1:obj.internal_key) = secret_bits;
                % encode it with the random pattern
                randomized_lsb = xor(lsb, random_pattern);
                % reshape lsb into the size of cover image so we can
                % replace LSB(cover_image) with our constructed lsb
                % containing the secret message.
                randomized_lsb = reshape(randomized_lsb, size(obj.cover_image));
                % LSB replacement
                obj.stego_image = bitset(obj.cover_image, 1, randomized_lsb);
            end
        end
        function extracted = ExtractSecret(obj, save_to) 
            % Extracts secret from an stego image
            % extract lsb from stego_image
            lsb = (bitget(obj.stego_image, 1)==1);
            % reshape it into a vector
            lsb = uint8(reshape(lsb, [numel(obj.stego_image), 1]));
            % set the seed again
            rng(obj.internal_key);
            % reconstruct the same random pattern
            random_pattern = round(rand(size(lsb)));
            % xor twice to decode
            decoded_lsb = xor(lsb,random_pattern);
            % the key is the length of the secret message, read that much
            % from the decoded lsb
            message = decoded_lsb(1:obj.internal_key);
            % save it to a file in bit-level
            write = fopen(save_to, 'w');
            fwrite(write, message, '*ubit1');
            fclose(write);
            % return the imread of the saved file as output
            extracted = imread(save_to);
        end
    end
end