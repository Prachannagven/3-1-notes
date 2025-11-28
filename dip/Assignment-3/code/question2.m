%%% Initial Images and Parameters
img1 = rgb2gray(imread("assignment1-image.png"));
img2 = uint8(imbinarize(img1) * 255);
img3 = rgb2gray(imread("assignment2-image.png"));
img4 = uint8(imbinarize(img3) * 255);

patch_size = 16;
Q = 5;

images = {img1, img2, img3, img4};
names  = ["Image 1 Grayscale","Image 1 Binary","Image 2 Grayscale","Image 2 Binary"];

results_BTC = struct;
results_DPCM = struct;
results_DWT = struct;

BTC_rec_images = cell(1,4);
DPCM_rec_images = cell(1,4);
DWT_rec_images = cell(1,4);

%% ========================= MAIN LOOP =============================
for i = 1:4
    img = double(images{i});

    fprintf("\n====================== Processing %s ======================\n", names(i));

    og_bits = numel(img) * 8;

    %% --- BTC ---
    [btc_bits,btc_rec] = block_transform_coding(img,patch_size,Q);
    btc_cr = og_bits / btc_bits;

    results_BTC(i).cr = btc_cr;
    results_BTC(i).mse = immse(img, btc_rec);
    results_BTC(i).psnr = psnr(uint8(btc_rec), uint8(img));
    BTC_rec_images{i} = uint8(btc_rec);

    %% --- DPCM ---
    [dpcm_bits,dpcm_rec] = predictive_coding(img, Q);
    dpcm_cr = og_bits / dpcm_bits;

    results_DPCM(i).cr = dpcm_cr;
    results_DPCM(i).mse = immse(img, dpcm_rec);
    results_DPCM(i).psnr = psnr(uint8(dpcm_rec), uint8(img));
    DPCM_rec_images{i} = uint8(dpcm_rec);

    %% --- DWT (LL only, quantized) ---
    [dwt_bits,dwt_rec] = wavelet_LL_only_quantized(img, Q);
    dwt_cr = og_bits / max(dwt_bits,1);   % protect against 0

    results_DWT(i).cr = dwt_cr;
    results_DWT(i).mse = immse(img, dwt_rec);
    results_DWT(i).psnr = psnr(uint8(dwt_rec), uint8(img));
    DWT_rec_images{i} = uint8(dwt_rec);

    %% Print summary
    fprintf("BTC     CR = %.3f | MSE = %.2f | PSNR = %.2f dB\n", results_BTC(i).cr, results_BTC(i).mse, results_BTC(i).psnr);
    fprintf("DPCM    CR = %.3f | MSE = %.2f | PSNR = %.2f dB\n", results_DPCM(i).cr, results_DPCM(i).mse, results_DPCM(i).psnr);
    fprintf("DWT     CR = %.3f | MSE = %.2f | PSNR = %.2f dB\n", results_DWT(i).cr, results_DWT(i).mse, results_DWT(i).psnr);
end

%% ========================= DISPLAY 4×4 GRID =============================
figure;
for i = 1:4
    % Original
    subplot(4,4,4*(i-1)+1);
    imshow(uint8(images{i}));
    title(names(i));

    % BTC
    subplot(4,4,4*(i-1)+2);
    imshow(BTC_rec_images{i});
    title("BTC");

    % DPCM
    subplot(4,4,4*(i-1)+3);
    imshow(DPCM_rec_images{i});
    title("DPCM");

    % DWT
    subplot(4,4,4*(i-1)+4);
    imshow(DWT_rec_images{i});
    title("DWT (LL-only)");
end

%% ========================= SUMMARY TABLE =============================
fprintf("\n====================== FINAL SUMMARY TABLE ======================\n");
fprintf("%-22s | %-8s | %-8s | %-8s | %-8s | %-8s | %-8s\n", ...
    "Image", "BTC_CR", "BTC_PSNR", "DPCM_CR", "DPCM_PSNR", "DWT_CR", "DWT_PSNR");
fprintf(repmat('-',1,90)); fprintf("\n");

for i = 1:4
    fprintf("%-22s | %8.3f | %8.2f | %8.3f | %8.2f | %8.3f | %8.2f\n", ...
        names(i), ...
        results_BTC(i).cr,  results_BTC(i).psnr, ...
        results_DPCM(i).cr, results_DPCM(i).psnr, ...
        results_DWT(i).cr,  results_DWT(i).psnr);
end
fprintf("=================================================================\n");

%% ========================= SAVE ALL OUTPUT IMAGES =============================
outdir = "compressed_outputs";
if ~exist(outdir, "dir")
    mkdir(outdir);
end

for i = 1:4
    base = sprintf("Image%02d_", i);

    % Save original
    imwrite(uint8(images{i}), fullfile(outdir, base + "Original.png"));

    % Save BTC reconstruction
    imwrite(BTC_rec_images{i}, fullfile(outdir, base + "BTC.png"));

    % Save DPCM reconstruction
    imwrite(DPCM_rec_images{i}, fullfile(outdir, base + "DPCM.png"));

    % Save DWT reconstruction
    imwrite(DWT_rec_images{i}, fullfile(outdir, base + "DWT.png"));
end

fprintf("\nSaved all output images to folder: %s\n", outdir);


%% ========================= FUNCTIONS ==================================

function [bits, rec] = block_transform_coding(img, blk, Q)
% BLOCK_TRANSFORM_CODING  Block DCT + quantization + entropy bit estimate
%   [bits, rec] = block_transform_coding(img, blk, Q)
%   - img: double image (0..255)
%   - blk: block size (e.g. 16)
%   - Q:   scalar quantizer step
%
% The function returns:
%  - bits : estimated compressed bit count (entropy-coded estimate)
%  - rec  : reconstructed image after dequantize + idct

[H,W] = size(img);

% pad to multiple of block size
padH = ceil(H / blk) * blk;
padW = ceil(W / blk) * blk;
padded = zeros(padH, padW);
padded(1:H,1:W) = img;

rec = zeros(padH, padW);

% We'll collect quantized coefficients (in zigzag order) from all blocks
all_coeffs = [];

for r = 1:blk:padH
    for c = 1:blk:padW
        block = padded(r:r+blk-1, c:c+blk-1);
        C = dct2(block);

        % Uniform scalar quantization
        Cq = round(C / Q);

        % Zig-zag scan the block to get a 1D vector (DC first)
        v = zigzag_scan(Cq);
        all_coeffs = [all_coeffs; v(:)];  %#ok<AGROW>

        % Reconstruct block into rec buffer
        rec(r:r+blk-1, c:c+blk-1) = idct2(Cq * Q);
    end
end

% Crop reconstructed image to original size
rec = rec(1:H,1:W);
rec(rec<0) = 0;
rec(rec>255) = 255;

% -------------------- Entropy bit estimate --------------------
% Build histogram of symbols (treat quantized coefficient values as symbols)
% Convert to integer keys (as strings aren't necessary here)
coeffs = all_coeffs(:);

% If all zeros, trivial case
if all(coeffs == 0)
    bits_entropy = 1;   % tiny cost (header)
else
    % compute occurrences
    [sym_vals, ~, idx_map] = unique(coeffs);
    counts = accumarray(idx_map, 1);
    total = sum(counts);

    p = counts ./ total;               % empirical probabilities
    bits_per_symbol = -log2(p);        % ideal bits per symbol
    bits_entropy = sum(counts .* bits_per_symbol);  % total entropy bits
end

% Add a small header overhead (e.g., to send image dims, Q, and codebook info)
header_bits = 64;  % tweakable; small fixed cost

bits = ceil(bits_entropy + header_bits);

end

%% -------------------- helper: zigzag_scan --------------------
function vec = zigzag_scan(A)
% produces a zig-zag scan (DC first) of a square block A (blk x blk)
[blk1, blk2] = size(A);
if blk1 ~= blk2
    error('zigzag_scan expects square blocks');
end
N = blk1;

vec = zeros(N*N,1);
k = 1;
for s = 0:(2*(N-1))
    if mod(s,2) == 0
        % even sum (go up)
        i_start = max(0, s-(N-1));
        i_end   = min(N-1, s);
        for i = i_start:i_end
            j = s - i;
            % i, j are 0-based; convert to 1-based indices:
            vec(k) = A(i+1, j+1);
            k = k + 1;
        end
    else
        % odd sum (go down)
        j_start = max(0, s-(N-1));
        j_end   = min(N-1, s);
        for j = j_start:j_end
            i = s - j;
            vec(k) = A(i+1, j+1);
            k = k + 1;
        end
    end
end
end

function [bits, rec] = predictive_coding(img, Q)

img = double(img);
[H, W] = size(img);

%% === Step 1: Quantize image ===
img_q = round(img / Q);   % quantized original

%% === Step 2: Predictor matrix ===
pred = zeros(H, W);

for i = 1:H
    for j = 1:W
        
        if i == 1 && j == 1
            pred(i,j) = 0;                          % Rule 1
        
        elseif j == 1
            pred(i,j) = img_q(i-1, j);              % Rule 2 (left column)
        
        elseif i == 1
            pred(i,j) = img_q(i, j-1);              % Rule 3 (top row)
        
        else
            pred(i,j) = (img_q(i-1, j) + img_q(i, j-1)) / 2;   % Rule 4
        end
        
    end
end

%% === Step 3: Compute error matrix ===
err = img_q - pred;

%% === Step 4: Quantize error ===
err_q = round(err / Q);

%% === Step 5: Bit estimate ===
maxErr = max(abs(err_q(:)));

if maxErr == 0
    bits_per_pixel = 1;   % minimal cost case
else
    bits_per_pixel = ceil(log2(2 * maxErr + 1));
end

bits = bits_per_pixel * H * W;

%% === Step 6: Reconstruct image ===
rec = pred + err_q * Q;

% restore valid grayscale range
rec = rec * Q;   % convert back to original scale
rec(rec < 0) = 0;
rec(rec > 255) = 255;

end

function [bits, rec] = wavelet_LL_only_quantized(img, Q)

img = double(img);
[H0,W0] = size(img);

% Fix odd sizes
if mod(H0,2)==1, img(end+1,:) = img(end,:); end
if mod(W0,2)==1, img(:,end+1) = img(:,end); end
[H,W] = size(img);

img_q = round(img / Q) * Q;

row_low = (img_q(:,1:2:end) + img_q(:,2:2:end)) / 2;
LL = (row_low(1:2:end,:) + row_low(2:2:end,:)) / 2;

% ---------------------- FIXED BIT MODEL -------------------------
nz = LL(LL~=0);
if isempty(nz)
    bits = 32;   % header only
else
    maxAbs = max(abs(nz));
    bits_per_coeff = ceil(log2(maxAbs+1));   % NOT 2*maxAbs
    bits = numel(nz) * bits_per_coeff + 32;  % include small header
end

% ---------------------- Reconstruction -------------------------
rec_low = repelem(LL,2,1);   % double rows
rec_full = repelem(rec_low,1,2); % double cols

rec = rec_full(1:H0, 1:W0);
rec(rec<0)=0; rec(rec>255)=255;

end
