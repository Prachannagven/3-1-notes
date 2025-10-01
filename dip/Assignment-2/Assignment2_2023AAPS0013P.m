%%% Preamble
close all
clc

%%% Loading the two new images and modifying for accuracy
img1 = imread("image1.png");
img1 = rgb2gray(img1); % convert to grayscale if RGB
img_1 = double(img1);

img2 = imread("image2.png");
img2 = rgb2gray(img2); % convert to grayscale if RGB
img2 = imresize(img2, size(img1));
img_2 = double(img2);

% Sizes of Images
[M_1, N_1] = size(img_1);
[M_2, N_2] = size(img_2);

%2023AAPS0013P -> A = 3, B = 3
A = 3;
B = 3;



%%% Task 1
% Part 1
fft_1 = fft2(img_1);
fftshift_1 = fftshift(fft_1);
mag_1 = log(1 + abs(fftshift_1));
phase_1 = angle(fftshift_1);

fft_2 = fft2(img_2);
fftshift_2 = fftshift(fft_2);
mag_2 = log(1 + abs(fftshift_2));
phase_2 = angle(fftshift_2);

figure();
subplot(2, 3, 1); imshow(img1); title("Greyscale Image 1")
subplot(2, 3, 2); imshow(mag_1, []); title("Log Magnitude Plot of Image 1")
subplot(2, 3, 3); imshow(phase_1, []); title("Phase Plot of Image 1")
subplot(2, 3, 4); imshow(img2); title("Greyscale Image 2");
subplot(2, 3, 5); imshow(mag_2, []); title("Log Magnitude Plot of Image 2")
subplot(2, 3, 6); imshow(phase_2, []); title("Phase Plot of Image 2")


% Part 3 - Swapping the magnitude and phase
mixed_1 = mag_1 .* exp(1i * phase_2);   
mixed_1 = ifft2(ifftshift(mixed_1));    
mixed_1 = mat2gray(real(mixed_1));

mixed_2 = mag_2 .* exp(1i * phase_1);
mixed_2 = ifft2(ifftshift(mixed_2));
mixed_2 = mat2gray(real(mixed_2));

figure();
subplot(1, 2, 1); imshow(mixed_1); title("Magnitude of 1 + Phase of 2");
subplot(1, 2, 2); imshow(mixed_2); title("Magnitude of 2 + Phase of 1");

% Part 4 - Shifting
shift_x = A * 10 + 5;
shift_y = B * 10 + 5;

img_1_shifted = circshift(img_1, [shift_y, shift_x]);
img_2_shifted = circshift(img_2, [shift_y, shift_x]);

fft_shifted_1 = fftshift(fft2(img_1));
mag_shifted_1 = log(1 + abs(fft_shifted_1));
phase_shifted_1 = angle(fft_shifted_1);
fft_shifted_2 = fftshift(fft2(img_2));
mag_shifted_2 = log(1 + abs(fft_shifted_2));
phase_shifted_2 = angle(fft_shifted_2);

figure ();
subplot(2, 3, 1); imshow(img1); title("Greyscale Image 1")
subplot(2, 3, 2); imshow(mag_1, []); title("Log Magnitude Plot of Image 1")
subplot(2, 3, 3); imshow(phase_1, []); title("Phase Plot of Image 1")
subplot(2, 3, 4); imshow(mat2gray(img_1_shifted)); title("Greyscale Shifted Image 1");
subplot(2, 3, 5); imshow(mag_shifted_1, []); title("Log Magnitude Plot of Shifted Image 1")
subplot(2, 3, 6); imshow(phase_shifted_1, []); title("Phase Plot Shifted of Image 1")

figure ();
subplot(2, 3, 1); imshow(img2); title("Greyscale Image 2")
subplot(2, 3, 2); imshow(mag_2, []); title("Log Magnitude Plot of Image 2")
subplot(2, 3, 3); imshow(phase_2, []); title("Phase Plot of Image 2")
subplot(2, 3, 4); imshow(mat2gray(img_2_shifted)); title("Greyscale Shifted Image 2");
subplot(2, 3, 5); imshow(mag_shifted_2, []); title("Log Magnitude Plot of Shifted Image 2")
subplot(2, 3, 6); imshow(phase_shifted_2, []); title("Phase Plot Shifted of Image 2")

% Part 5 - Scaling and Resizing Image
img_1_compressed = imresize(img_1, 1/A);
img_1_expanded = imresize(img_1, B);

fft_compressed_1 = fftshift(fft2(img_1_compressed));
mag_compressed_1 = mat2gray(log(1 + abs(fft_compressed_1)));

fft_expanded_1 = fftshift(fft2(img_1_expanded));
mag_expanded_1 = mat2gray(log(1 + abs(fft_expanded_1)));

figure();
subplot(2, 3, 1); imshow(img1); title("Original Image");
subplot(2, 3, 2); imshow(mat2gray(img_1_compressed)); title("Compressed Image")
subplot(2, 3, 3); imshow(mat2gray(img_1_expanded)); title("Expanded Image");
subplot(2, 3, 4); imshow(mag_1, []); title("Magnitude Plot of Original")
subplot(2, 3, 5); imshow(mag_compressed_1, []); title("Magnitude Plot of Compressed");
subplot(2, 3, 6); imshow(mag_expanded_1, []); title("Magnitude Plot of Expanded");

% Part 6 - Rotation of Image
angles = [0, 30, 45, 60, 90];
figure();
for k = 1:length(angles)
    theta = angles(k);
    
    img_rot = imrotate(img2, theta, 'bilinear', 'crop'); 
    
    F = fftshift(fft2(img_rot));
    mag = log(1 + abs(F));
    
    subplot(2, 5, k);
    imshow((img_rot));
    title(['Image after ', num2str(theta), '° rotation']);
    subplot(2, 5, k+5);
    imshow(mag, []);
    title(['Magnitude at ', num2str(theta), '° rotation']);
end


%%% Task 2
% LPF
radii = [20, 50, 100];  
[x1, y1] = meshgrid(1:N_1, 1:M_1);
center1 = [ceil(N_1/2), ceil(M_1/2)];
dist1 = sqrt((x1-center1(1)).^2 + (y1-center1(2)).^2);

figure("Name","Image 1: Circular LPF");

imgs1 = {img1};
F1s   = {fft_1};

for k = 1:length(radii)
    H = dist1 <= radii(k); % circular mask
    F1_filt = fft_shifted_1 .* H;
    img1_filt = real(ifft2(ifftshift(F1_filt)));
    
    imgs1{end+1} = img1_filt;
    F1s{end+1}   = F1_filt;
end

for k = 1:length(imgs1)
    % Row 1: Images
    subplot(3, length(imgs1), k);
    imshow(imgs1{k}, []);
    if k==1, title("Original"); else, title(['r = ', num2str(radii(k-1))]); end
    
    % Row 2: Magnitude
    subplot(3, length(imgs1), length(imgs1)+k);
    imshow(log(1+abs(F1s{k})), []);
    title("Magnitude");
    
    % Row 3: Phase
    subplot(3, length(imgs1), 2*length(imgs1)+k);
    imshow(angle(F1s{k}), []);
    title("Phase");
end

rect_sizes = [20, 50, 100];
[x2, y2] = meshgrid(1:N_2, 1:M_2);
center2 = [ceil(N_2/2), ceil(M_2/2)];

figure("Name","Image 2: Rectangular LPF");

imgs2 = {img2};
F2s   = {fft_2};

for k = 1:length(rect_sizes)
    rx = rect_sizes(k);
    ry = rect_sizes(k); % square filter
    H = (abs(x2-center2(1)) <= rx) & (abs(y2-center2(2)) <= ry);
    
    F2_filt = fft_shifted_2 .* H;
    img2_filt = real(ifft2(ifftshift(F2_filt)));
    
    imgs2{end+1} = img2_filt;
    F2s{end+1}   = F2_filt;
end

for k = 1:length(imgs2)
    % Row 1: Images
    subplot(3, length(imgs2), k);
    imshow(imgs2{k}, []);
    if k==1, title("Original"); else, title(['size = ', num2str(rect_sizes(k-1))]); end
    
    % Row 2: Magnitude
    subplot(3, length(imgs2), length(imgs2)+k);
    imshow(log(1+abs(F2s{k})), []);
    title("Magnitude");
    
    % Row 3: Phase
    subplot(3, length(imgs2), 2*length(imgs2)+k);
    imshow(angle(F2s{k}), []);
    title("Phase");
end

%% 2. Butterworth LPF (orders 1, 2, 4)
orders = [1,2,4];
D0 = 50; % cutoff radius
[x1,y1] = meshgrid(1:N_1, 1:M_1);
center1 = [ceil(N_1/2), ceil(M_1/2)];
D = sqrt((x1-center1(1)).^2 + (y1-center1(2)).^2);

figure("Name","Image 1: Butterworth LPF");

imgs1 = {img1};
F1s   = {fft_1};

for n = orders
    H = 1 ./ (1 + (D./D0).^(2*n));
    F_filt = fft_shifted_1 .* H;
    img_filt = real(ifft2(ifftshift(F_filt)));

    imgs1{end+1} = img_filt;
    F1s{end+1}   = F_filt;
end

for k = 1:length(imgs1)
    subplot(3,length(imgs1),k), imshow(imgs1{k},[]);
    if k==1, title("Original"); else, title(['n = ',num2str(orders(k-1))]); end
    subplot(3,length(imgs1),length(imgs1)+k), imshow(log(1+abs(F1s{k})),[]), title("Magnitude");
    subplot(3,length(imgs1),2*length(imgs1)+k), imshow(angle(F1s{k}),[]), title("Phase");
end


%% 3. Gaussian LPF (D0=25,50,100)
cutoffs = [25,50,100];
figure("Name","Image 1: Gaussian LPF");

imgs1 = {img1};
F1s   = {fft_1};

for D0 = cutoffs
    H = exp(-(D.^2)./(2*(D0^2)));
    F_filt = fft_shifted_1 .* H;
    img_filt = real(ifft2(ifftshift(F_filt)));

    imgs1{end+1} = img_filt;
    F1s{end+1}   = F_filt;
end

for k = 1:length(imgs1)
    subplot(3,length(imgs1),k), imshow(imgs1{k},[]);
    if k==1, title("Original"); else, title(['D0 = ',num2str(cutoffs(k-1))]); end
    subplot(3,length(imgs1),length(imgs1)+k), imshow(log(1+abs(F1s{k})),[]), title("Magnitude");
    subplot(3,length(imgs1),2*length(imgs1)+k), imshow(angle(F1s{k}),[]), title("Phase");
end


%% 4. Ideal HPF (Disk + Rectangle)
radii = [20,50,100];
rect_sizes = [20,50,100];

% Circular HPF
figure("Name","Image 2: Ideal Circular HPF");
imgs1 = {img2}; F1s = {fft_2};
for r = radii
    H = double(D > r);
    F_filt = fft_shifted_2 .* H;
    img_filt = real(ifft2(ifftshift(F_filt)));
    imgs1{end+1} = img_filt; F1s{end+1} = F_filt;
end
for k=1:length(imgs1)
    subplot(3,length(imgs1),k), imshow(imgs1{k},[]);
    if k==1, title("Original"); else, title(['r = ',num2str(radii(k-1))]); end
    subplot(3,length(imgs1),length(imgs1)+k), imshow(log(1+abs(F1s{k})),[]), title("Magnitude");
    subplot(3,length(imgs1),2*length(imgs1)+k), imshow(angle(F1s{k}),[]), title("Phase");
end

% Rectangular HPF
[x2,y2] = meshgrid(1:N_2, 1:M_2);
center2 = [ceil(N_2/2), ceil(M_2/2)];
figure("Name","Image 2: Ideal Rectangular HPF");

imgs2 = {img2}; F2s = {fft_2};
for s = rect_sizes
    H = ~((abs(x2-center2(1))<=s) & (abs(y2-center2(2))<=s));
    F_filt = fft_shifted_2 .* H;
    img_filt = real(ifft2(ifftshift(F_filt)));
    imgs2{end+1} = img_filt; F2s{end+1} = F_filt;
end
for k=1:length(imgs2)
    subplot(3,length(imgs2),k), imshow(imgs2{k},[]);
    if k==1, title("Original"); else, title(['size = ',num2str(rect_sizes(k-1))]); end
    subplot(3,length(imgs2),length(imgs2)+k), imshow(log(1+abs(F2s{k})),[]), title("Magnitude");
    subplot(3,length(imgs2),2*length(imgs2)+k), imshow(angle(F2s{k}),[]), title("Phase");
end


%% 5. Butterworth HPF (orders 1,2,4)
orders = [1,2,4]; D0 = 50;
figure("Name","Image 1: Butterworth HPF");
imgs1 = {img2}; F1s = {fft_2};
for n = orders
    H = 1 ./ (1 + (D0./D).^(2*n));
    H(D==0) = 0; % avoid div by 0
    F_filt = fft_shifted_2 .* H;
    img_filt = real(ifft2(ifftshift(F_filt)));
    imgs1{end+1} = img_filt; F1s{end+1} = F_filt;
end
for k=1:length(imgs1)
    subplot(3,length(imgs1),k), imshow(imgs1{k},[]);
    if k==1, title("Original"); else, title(['n = ',num2str(orders(k-1))]); end
    subplot(3,length(imgs1),length(imgs1)+k), imshow(log(1+abs(F1s{k})),[]), title("Magnitude");
    subplot(3,length(imgs1),2*length(imgs1)+k), imshow(angle(F1s{k}),[]), title("Phase");
end


%% 6. Gaussian HPF (D0=30,60,120)
cutoffs = [30,60,120];
figure("Name","Image 1: Gaussian HPF");
imgs1 = {img2}; F1s = {fft_2};
for D0 = cutoffs
    H = 1 - exp(-(D.^2)./(2*(D0^2)));
    F_filt = fft_shifted_2 .* H;
    img_filt = real(ifft2(ifftshift(F_filt)));
    imgs1{end+1} = img_filt; F1s{end+1} = F_filt;
end
for k=1:length(imgs1)
    subplot(3,length(imgs1),k), imshow(imgs1{k},[]);
    if k==1, title("Original"); else, title(['D0 = ',num2str(cutoffs(k-1))]); end
    subplot(3,length(imgs1),length(imgs1)+k), imshow(log(1+abs(F1s{k})),[]), title("Magnitude");
    subplot(3,length(imgs1),2*length(imgs1)+k), imshow(angle(F1s{k}),[]), title("Phase");
end


%% Part 7 & 8

f_noise = A*10 + 100;        
W = 10;                     
BW = 15;                   
n_butter = 2;             
noise_amp = 2000;        

I1 = double(img_1);   
I2 = double(img_2);  

images = {I1, I2};
names  = {'Image 1', 'Image 2'};

for idx = 1:2
    I = images{idx};
    [M, N] = size(I);

    [u, v] = meshgrid(1:N, 1:M);
    center = [ceil(N/2), ceil(M/2)];
    D = sqrt((u-center(1)).^2 + (v-center(2)).^2);
    
    [xgrid, ~] = meshgrid(1:N, 1:M);
    noise = noise_amp * sin(2*pi * f_noise * xgrid / N);
    I_noisy = I + noise;
    
    F_orig_shift  = fftshift(fft2(I));
    F_noisy_shift = fftshift(fft2(I_noisy));
    
    D0 = f_noise;                   
    H_ideal = ones(M, N);
    H_ideal(abs(D - D0) <= (W/2)) = 0;    
    F_ideal_shift = F_noisy_shift .* H_ideal;
    I_ideal = real(ifft2(ifftshift(F_ideal_shift)));
    
    arg = zeros(size(D));
    safeMask = denom ~= 0;
    arg(safeMask) = (D(safeMask) .* BW) ./ denom(safeMask);
    H_butt(~safeMask) = 0;
    F_butt_shift = F_noisy_shift .* H_butt;
    I_butt = real(ifft2(ifftshift(F_butt_shift)));
    imgs = {I, I_noisy, I_ideal, I_butt};
    Fshifts = {F_orig_shift, F_noisy_shift, F_ideal_shift, F_butt_shift};
    colTitles = {'Original', 'Noisy', 'Ideal BR', 'Butterworth BR'};
    
    figure('Name', [names{idx} ' — BR Comparison'], 'Position',[50 50 1300 600]);
    for c = 1:4
        subplot(3,4,c);
        imshow(mat2gray(imgs{c}), []);
        title(colTitles{c});
        subplot(3,4,4 + c);
        imagesc(log(1 + abs(Fshifts{c})));
        axis image off;
        title(['Magnitude — ' colTitles{c}]);
        colormap gray;
        ph = angle(Fshifts{c});
        imagesc(ph);
        axis image off;
        title(['Phase — ' colTitles{c}]);
        colormap gray;
    end
end




