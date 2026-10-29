clc
clear all

close all;

lenna=rgb2gray(imread('lena512color.tiff'));
l_size=[size(lenna,1) size(lenna,2)];
lenna=double(lenna);

%% Part 1

%1)
l_fft=fftshift(fft2(lenna));    %F(u,v)
%a.)
l_lmag=log10(1+abs(l_fft));
l_ang=angle(l_fft);
%b.)
l_ifft=log10(1+abs(fftshift(ifft2(lenna))));
%c.)
figure; set(gcf,'NumberTitle','off','Name','1.Lenna FFT'); %Figure 1
subplot(2,2,1);
imagesc(lenna);
axis image;
colormap(gray);
title('(a) Original Image');

subplot(2,2,2);
imagesc(l_lmag);
axis image;
colormap(gray);
title('(b) Log Magnitude');

subplot(2,2,3);
imagesc(l_ifft);
axis image;
colormap(gray);
title('(c) Inverse Transformed');

subplot(2,2,4);
imagesc(l_ang);
axis image;
colormap(gray);
title('(d) Log Phase');

%% Part 2: Lowpass Filter Design

%a.)
glpf=fspecial('gaussian',11,1.3);
%b.)
glpf_fft=fftshift(fft2(glpf,l_size(1),l_size(2)));  %H(u,v)
%c.)
glpf_lmag=log10(1+abs(glpf_fft));
glpf_ang=angle(glpf_fft);

figure; set(gcf,'NumberTitle','off','Name','2.Gaussin LPF Kernel'); %Figure 2
subplot(1,2,1);
imagesc(glpf_lmag);
axis image;
colormap(gray);
title('(a) Log Magnitude of Gaussian LPF Kernel');

subplot(1,2,2);
imagesc(glpf_ang);
axis image;
colormap(gray);
title('(b) Phase of Gaussian LPF Kernel');

%d.)
l_lpf_fft=glpf_fft.*l_fft;  %G(u,v)
l_lpf_lmag=log10(1+abs(l_lpf_fft));
l_lpf_ang=angle(l_lpf_fft);

figure; set(gcf,'NumberTitle','off','Name','3.LP Filtered Image Spectrum'); %Figure 3
subplot(1,2,1);
imagesc(l_lpf_lmag);
axis image;
colormap(gray);
title('(a) Log Magnitude of LP Filtered Image');

subplot(1,2,2);
imagesc(l_lpf_ang);
axis image;
colormap(gray);
title('(b) Phase of LP Filtered Image');

%e.)
l_lpf=ifft2(l_lpf_fft);

figure; set(gcf,'NumberTitle','off','Name','4.LP Filtered Image'); %Figure 4
imagesc(l_lpf);
axis image;
colormap(gray);
title('Gaussian Lowpass Filtered Image');

%% Part 3: Highpass Filter Design

%a.)
lhpf=fspecial('laplacian');
%b.)
lhpf_fft=fftshift(fft2(lhpf,l_size(1),l_size(2)));  %H(u,v)
%c.)
lhpf_lmag=log10(1+abs(lhpf_fft));
lhpf_ang=angle(lhpf_fft);

figure; set(gcf,'NumberTitle','off','Name','5.Laplacian HPF Kernel'); %Figure 5
subplot(1,2,1);
imagesc(lhpf_lmag);
axis image;
colormap(gray);
title('(a) Log Magnitude of Laplacian HPF Kernel');

subplot(1,2,2);
imagesc(lhpf_ang);
axis image;
colormap(gray);
title('(b) Phase of Laplacian HPF Kernel');

%d.)
l_hpf_fft=lhpf_fft.*l_fft;   %G(u,v)
l_hpf_lmag=log10(1+abs(l_hpf_fft));
l_hpf_ang=angle(l_hpf_fft);

figure; set(gcf,'NumberTitle','off','Name','6.HP Filtered Image Spectrum'); %Figure 6
subplot(1,2,1);
imagesc(l_hpf_lmag);
axis image;
colormap(gray);
title('(a) Log Magnitude of HP Filtered Image');

subplot(1,2,2);
imagesc(l_hpf_ang);
axis image;
colormap(gray);
title('(b) Phase of HP Filtered Image');

%e.)
l_hpf=ifft2(l_hpf_fft);

figure; set(gcf,'NumberTitle','off','Name','7.HP Filtered Image'); %Figure 7
imagesc(l_hpf);
axis image;
colormap(gray);
title('Laplacian Highpass Filtered Image');

%% Part 4: Two Dimensional Filter Design

%1.)
[f1,f2]=freqspace(21,'meshgrid');
%2.)
r=sqrt(f1.^2+f2.^2);

%a.)
bp=ones(size(f1));
bp((r<0.1)|(r>0.6))=0;

lp=ones(size(f1));
lp(r>0.6)=0;

hp=ones(size(f1));
hp(r<0.6)=0;

%b.) 1.) - 2.)
%fsamp2
fs2bp=fsamp2(bp); fs2bp_fft=fftshift(fft2(fs2bp,l_size(1),l_size(2)));
fs2bp_lmag=log10(1+abs(fs2bp_fft)); fs2bp_ang=angle(fs2bp_fft);

fs2lp=fsamp2(lp); fs2lp_fft=fftshift(fft2(fs2lp,l_size(1),l_size(2)));
fs2lp_lmag=log10(1+abs(fs2lp_fft)); fs2lp_ang=angle(fs2lp_fft);

fs2hp=fsamp2(hp); fs2hp_fft=fftshift(fft2(fs2hp,l_size(1),l_size(2)));
fs2hp_lmag=log10(1+abs(fs2hp_fft)); fs2hp_ang=angle(fs2hp_fft);

%fwind1
fw1bp=fwind1(bp,hamming(21)); fw1bp_fft=fftshift(fft2(fw1bp,l_size(1),l_size(2)));
fw1bp_lmag=log10(1+abs(fw1bp_fft)); fw1bp_ang=angle(fw1bp_fft);

fw1lp=fwind1(lp,hamming(21)); fw1lp_fft=fftshift(fft2(fw1lp,l_size(1),l_size(2)));
fw1lp_lmag=log10(1+abs(fw1lp_fft)); fw1lp_ang=angle(fw1lp_fft);

fw1hp=fwind1(hp,hamming(21)); fw1hp_fft=fftshift(fft2(fw1hp,l_size(1),l_size(2)));
fw1hp_lmag=log10(1+abs(fw1hp_fft)); fw1hp_ang=angle(fw1hp_fft);

%fwind2
win=fspecial('gaussian',11,1.3);
win=win./max(win(:));
fw2bp=fwind2(bp,win); fw2bp_fft=fftshift(fft2(fw2bp,l_size(1),l_size(2)));
fw2bp_lmag=log10(1+abs(fw2bp_fft)); fw2bp_ang=angle(fw2bp_fft);

fw2lp=fwind2(lp,win); fw2lp_fft=fftshift(fft2(fw2lp,l_size(1),l_size(2)));
fw2lp_lmag=log10(1+abs(fw2lp_fft)); fw2lp_ang=angle(fw2lp_fft);

fw2hp=fwind2(hp,win); fw2hp_fft=fftshift(fft2(fw2hp,l_size(1),l_size(2)));
fw2hp_lmag=log10(1+abs(fw2hp_fft)); fw2hp_ang=angle(fw2hp_fft);

%b.) 3.)
figure; set(gcf,'NumberTitle','off','Name','8.FSAMP2 Filters'); %Figure 8
subplot(2,3,1); imagesc(fs2bp_lmag); axis image; colormap(gray);
title('(a) Log Magnitude of BP Filter');
subplot(2,3,4); imagesc(fs2bp_ang); axis image; colormap(gray);
title('(b) Phase of  BP Filter');
subplot(2,3,2);imagesc(fs2lp_lmag); axis image; colormap(gray);
title('(c) Log Magnitude of LP Filter');
subplot(2,3,5); imagesc(fs2lp_ang); axis image; colormap(gray);
title('(d) Phase of LP Filter');
subplot(2,3,3); imagesc(fs2hp_lmag); axis image; colormap(gray);
title('(e) Log Magnitude of HP Filter');
subplot(2,3,6); imagesc(fs2hp_ang); axis image; colormap(gray);
title('(f) Phase of HP Filter');

figure; set(gcf,'NumberTitle','off','Name','9.FWIND1 Filters'); %Figure 9
subplot(2,3,1); imagesc(fw1bp_lmag); axis image; colormap(gray);
title('(a) Log Magnitude of BP Filter');
subplot(2,3,4); imagesc(fw1bp_ang); axis image; colormap(gray);
title('(b) Phase of  BP Filter');
subplot(2,3,2);imagesc(fw1lp_lmag); axis image; colormap(gray);
title('(c) Log Magnitude of LP Filter');
subplot(2,3,5); imagesc(fw1lp_ang); axis image; colormap(gray);
title('(d) Phase of LP Filter');
subplot(2,3,3); imagesc(fw1hp_lmag); axis image; colormap(gray);
title('(e) Log Magnitude of HP Filter');
subplot(2,3,6); imagesc(fw1hp_ang); axis image; colormap(gray);
title('(f) Phase of HP Filter');

figure; set(gcf,'NumberTitle','off','Name','10.FWIND2 Filters'); %Figure 10
subplot(2,3,1); imagesc(fw2bp_lmag); axis image; colormap(gray);
title('(a) Log Magnitude of BP Filter');
subplot(2,3,4); imagesc(fw2bp_ang); axis image; colormap(gray);
title('(b) Phase of  BP Filter');
subplot(2,3,2);imagesc(fw2lp_lmag); axis image; colormap(gray);
title('(c) Log Magnitude of LP Filter');
subplot(2,3,5); imagesc(fw2lp_ang); axis image; colormap(gray);
title('(d) Phase of LP Filter');
subplot(2,3,3); imagesc(fw2hp_lmag); axis image; colormap(gray);
title('(e) Log Magnitude of HP Filter');
subplot(2,3,6); imagesc(fw2hp_ang); axis image; colormap(gray);
title('(f) Phase of HP Filter');

%b.) 4.)
l_fs2bp_fft=fs2bp_fft.*l_fft;
l_fs2bp_lmag=log10(1+abs(l_fs2bp_fft)); l_fs2bp_ang=angle(l_fs2bp_fft);
l_fs2lp_fft=fs2lp_fft.*l_fft;
l_fs2lp_lmag=log10(1+abs(l_fs2lp_fft)); l_fs2lp_ang=angle(l_fs2lp_fft);
l_fs2hp_fft=fs2hp_fft.*l_fft;
l_fs2hp_lmag=log10(1+abs(l_fs2hp_fft)); l_fs2hp_ang=angle(l_fs2hp_fft);

l_fw1bp_fft=fw1bp_fft.*l_fft;
l_fw1bp_lmag=log10(1+abs(l_fw1bp_fft)); l_fw1bp_ang=angle(l_fw1bp_fft);
l_fw1lp_fft=fw1lp_fft.*l_fft;
l_fw1lp_lmag=log10(1+abs(l_fw1lp_fft)); l_fw1lp_ang=angle(l_fw1lp_fft);
l_fw1hp_fft=fw1hp_fft.*l_fft;
l_fw1hp_lmag=log10(1+abs(l_fw1hp_fft)); l_fw1hp_ang=angle(l_fw1hp_fft);

l_fw2bp_fft=fw2bp_fft.*l_fft;
l_fw2bp_lmag=log10(1+abs(l_fw2bp_fft)); l_fw2bp_ang=angle(l_fw2bp_fft);
l_fw2lp_fft=fw2lp_fft.*l_fft;
l_fw2lp_lmag=log10(1+abs(l_fw2lp_fft)); l_fw2lp_ang=angle(l_fw2lp_fft);
l_fw2hp_fft=fw2hp_fft.*l_fft;
l_fw2hp_lmag=log10(1+abs(l_fw2hp_fft)); l_fw2hp_ang=angle(l_fw2hp_fft);

figure; set(gcf,'NumberTitle','off','Name','11.FSAMP2 Image Spectrum'); %Figure 11
subplot(2,3,1); imagesc(l_fs2bp_lmag); axis image; colormap(gray);
title('(a) Log Magnitude of BP Filter');
subplot(2,3,4); imagesc(l_fs2bp_ang); axis image; colormap(gray);
title('(b) Phase of  BP Filter');
subplot(2,3,2);imagesc(l_fs2lp_lmag); axis image; colormap(gray);
title('(c) Log Magnitude of LP Filter');
subplot(2,3,5); imagesc(l_fs2lp_ang); axis image; colormap(gray);
title('(d) Phase of LP Filter');
subplot(2,3,3); imagesc(l_fs2hp_lmag); axis image; colormap(gray);
title('(e) Log Magnitude of HP Filter');
subplot(2,3,6); imagesc(l_fs2hp_ang); axis image; colormap(gray);
title('(f) Phase of HP Filter');

figure; set(gcf,'NumberTitle','off','Name','12.FWIND1 Image Spectrum'); %Figure 12
subplot(2,3,1); imagesc(l_fw1bp_lmag); axis image; colormap(gray);
title('(a) Log Magnitude of BP Filter');
subplot(2,3,4); imagesc(l_fw1bp_ang); axis image; colormap(gray);
title('(b) Phase of  BP Filter');
subplot(2,3,2);imagesc(l_fw1lp_lmag); axis image; colormap(gray);
title('(c) Log Magnitude of LP Filter');
subplot(2,3,5); imagesc(l_fw1lp_ang); axis image; colormap(gray);
title('(d) Phase of LP Filter');
subplot(2,3,3); imagesc(l_fw1hp_lmag); axis image; colormap(gray);
title('(e) Log Magnitude of HP Filter');
subplot(2,3,6); imagesc(l_fw1hp_ang); axis image; colormap(gray);
title('(f) Phase of HP Filter');

figure; set(gcf,'NumberTitle','off','Name','13.FWIND2 Image Spectrum'); %Figure 13
subplot(2,3,1); imagesc(l_fw2bp_lmag); axis image; colormap(gray);
title('(a) Log Magnitude of BP Filter');
subplot(2,3,4); imagesc(l_fw2bp_ang); axis image; colormap(gray);
title('(b) Phase of  BP Filter');
subplot(2,3,2);imagesc(l_fw2lp_lmag); axis image; colormap(gray);
title('(c) Log Magnitude of LP Filter');
subplot(2,3,5); imagesc(l_fw2lp_ang); axis image; colormap(gray);
title('(d) Phase of LP Filter');
subplot(2,3,3); imagesc(l_fw2hp_lmag); axis image; colormap(gray);
title('(e) Log Magnitude of HP Filter');
subplot(2,3,6); imagesc(l_fw2hp_ang); axis image; colormap(gray);
title('(f) Phase of HP Filter');

%b.) 5.)
l_fs2bp=ifft2(l_fs2bp_fft);
l_fs2lp=ifft2(l_fs2lp_fft);
l_fs2hp=ifft2(l_fs2hp_fft);

l_fw1bp=ifft2(l_fw1bp_fft);
l_fw1lp=ifft2(l_fw1lp_fft);
l_fw1hp=ifft2(l_fw1hp_fft);

l_fw2bp=ifft2(l_fw2bp_fft);
l_fw2lp=ifft2(l_fw2lp_fft);
l_fw2hp=ifft2(l_fw2hp_fft);

figure; set(gcf,'NumberTitle','off','Name','14.FSAMP2 Image'); %Figure 14
subplot(1,3,1); imagesc(l_fs2bp); axis image; colormap(gray);
title('(a) FSAMP2 BP Filtered');
subplot(1,3,2); imagesc(l_fs2lp); axis image; colormap(gray);
title('(b) FSAMP2 LP Filtered');
subplot(1,3,3); imagesc(l_fs2hp); axis image; colormap(gray);
title('(c) FSAMP2 HP Filtered');

figure; set(gcf,'NumberTitle','off','Name','15.FWIND1 Image'); %Figure 15
subplot(1,3,1); imagesc(l_fw1bp); axis image; colormap(gray);
title('(a) FWIND1 BP Filtered');
subplot(1,3,2); imagesc(l_fw1lp); axis image; colormap(gray);
title('(b) FWIND1 LP Filtered');
subplot(1,3,3); imagesc(l_fw1hp); axis image; colormap(gray);
title('(c) FWIND1 HP Filtered');

figure; set(gcf,'NumberTitle','off','Name','16.FWIND2 Image'); %Figure 16
subplot(1,3,1); imagesc(l_fw2bp); axis image; colormap(gray);
title('(a) FWIND2 BP Filtered');
subplot(1,3,2); imagesc(l_fw2lp); axis image; colormap(gray);
title('(b) FWIND2 LP Filtered');
subplot(1,3,3); imagesc(l_fw2hp); axis image; colormap(gray);
title('(c) FWIND2 HP Filtered');
