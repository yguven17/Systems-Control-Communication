%% QPSK Modulator/Demodulator Example
% 
% 
%  TEXT
% 
%  TEXT
% 
% This documents describes/implements the QPSK modulation and
% demodulation of a song signal. 

%%
%      Prepared for ELEC 301

%%
%     by Alper T. Erdogan 

%%
%            *16.03.2020*    

%%

 

%% Program Initialization
%Clear Variables and Close All Figure Windows

% Clear all previous variables
clear
% Close all previous figure windows
close all

%% Read and Display an Example Image 
% *cameraman.tif* is an example gray-level image provided my matlab
% 

%%
% Load the Cameraman Image
Im = imread('cameraman.tif');
% Extract part of the image
Im=Im(51:100,101:150);

%%
% Display the image
imshow(Im);


%% Convert Image to  a Binary Vector
% We need to convert the image to a binary bit sequence

%%
% Convert 256x256 image matrix to an image (column) vector (of size 256^2x1) by concatenating columns
Imv=Im(:);

%%
% Convert each the number in each row to a binary vector
Imvb=de2bi(Imv);

%% 
% Note that *Imvb* has size 256^2x8

%%
% Now generate a row vector containing all bits
Imvbt=Imvb';
s=Imvbt(:)';



%% Generate Modulated Signal
% QPSK Modulated Signal
% 

%%
% From the single bit sequence generate a vector sequence
sv=[s(1:2:end);
    s(2:2:end)];


%%
% QPSK Constellation Mapper
% [0;0]-> -1-i
% [0;1]-> -1+i
% [1;0]->  1-i
% [1;1]->  1+i
for k=1:size(sv,2)
    switch num2str(sv(:,k)')
       case '0  0'
            c(k)=-1-i;
        case '1  0'
            c(k)=1-i;
        case '0  1'
            c(k)=-1+i;
        otherwise 
            c(k)=1+i;
        end
end
% Normalize the power to 1
c=c/sqrt(2);


%%
% Rectangle Modulation

% Sample Rate
Fsampling=2^19;
% Sample Intervale
Tsampling=1/Fsampling;
% Symbol Rate
Fsymbol=2^13;
% Symbol Period
Tsymbol=1/Fsymbol;
% Number of Samples per Symbol Period
Ns=Tsymbol/Tsampling;

%%
% Baseband Signal (samples)
xb=kron(c,ones(1,Ns));

%% 
% Carrier frequency:

%%
% $f_c=60kHz$
fc=60e3; % 60 kHz;

%define Q
Q=(0:pi/10:2*pi);

%% Ber Arrays
BER10=(0:length(Q)-1);
BER1=(0:length(Q)-1);
%%


 for i=1:length(Q) 
     
% Carrier signal:  _

%%
% $c(t)=cos(2\pi f_c t)$
  
t=(0:1:(length(xb)-1))*Tsampling;
cost=cos(2*pi*fc*t);
sint=sin(2*pi*fc*t);

%%
% Transmitter output

%%
% $x(t)=Re(xb(t))cos(2\pi f_c t)-Im(xb(t))sin(2\pi f_c t)$

x=real(xb).*cost-imag(xb).*sint;


%% Channel Effect
% We add some noise

%%
% First calculate average signal energy (per sample)
sigpow=mean(x.^2);

%%
% Define SNR level in (dB)

 SNR=10;


%% 
% Noise Level
NoiseAmp=sqrt(10^(-SNR/10)*sigpow);

%%
% Generate Noise signal as Gaussian Noise
noise=NoiseAmp*randn(1,length(x));

%% 
% Noisy received signal

%% 
% $y(t)=x(t)+n(t)$
y=x+noise;

%% The QPSK Receiver Processing
% Coherent QPSK Receiver operation

%%
% First extract real component baseband signal

%%
% $u_r(t)=2x(t)cos(2\pi f_c t)$

ur=2*y.*cos((2*pi*fc*t)+Q(i));

%%
% Then low pass filter this signal

%%
% $z_r(t)=u_r(t)*h_{LP}(t)$

zr = lowpass(ur,30e3,Fsampling);



%%
% Then extract the imaginary component baseband signal

%%
% $u_i(t)=2x(t)sin(2 \pi f_c t)$

ui=-2*y.*sin((2*pi*fc*t)+Q(i));

%%
% Then low pass filter this signal

%%
% $z_i(t)=u_i(t)*h_{LP}(t)$

zi = lowpass(ui,30e3,Fsampling);

%%
% Basband signal
z=zr+i*zi;

%% Constellation Estimates
% We sample the baseband received signal to get noisy estimates of
% transmitted constellation point. This is not the best way though. Any
% other suggestions for improvement?

ce=z(ceil(Ns/2):Ns:length(z));


%% Bit Estimates
% We implement QPSK Demapper to extract bits from constellation estimates

%%
% Check which quadrant ce lies in
ser=real(ce)>0;
sei=imag(ce)>0;
se(1:2:(2*length(ser)))=ser;
se(2:2:(2*length(ser)))=sei;

%% 
% Calculate Bit Error Rate 


BER10(i)=sum(se~=s)/length(s)





 end

for i=1:length(Q) 
     
% Carrier signal:  _

%%
% $c(t)=cos(2\pi f_c t)$
  
t=(0:1:(length(xb)-1))*Tsampling;
cost=cos(2*pi*fc*t);
sint=sin(2*pi*fc*t);

%%
% Transmitter output

%%
% $x(t)=Re(xb(t))cos(2\pi f_c t)-Im(xb(t))sin(2\pi f_c t)$

x=real(xb).*cost-imag(xb).*sint;


%% Channel Effect
% We add some noise

%%
% First calculate average signal energy (per sample)
sigpow=mean(x.^2);

%%
% Define SNR level in (dB)

 SNR=1;


%% 
% Noise Level
NoiseAmp=sqrt(10^(-SNR/10)*sigpow);

%%
% Generate Noise signal as Gaussian Noise
noise=NoiseAmp*randn(1,length(x));

%% 
% Noisy received signal

%% 
% $y(t)=x(t)+n(t)$
y=x+noise;

%% The QPSK Receiver Processing
% Coherent QPSK Receiver operation

%%
% First extract real component baseband signal

%%
% $u_r(t)=2x(t)cos(2\pi f_c t)$

ur=2*y.*cos((2*pi*fc*t)+Q(i));

%%
% Then low pass filter this signal

%%
% $z_r(t)=u_r(t)*h_{LP}(t)$

zr = lowpass(ur,30e3,Fsampling);



%%
% Then extract the imaginary component baseband signal

%%
% $u_i(t)=2x(t)sin(2 \pi f_c t)$

ui=-2*y.*sin((2*pi*fc*t)+Q(i));

%%
% Then low pass filter this signal

%%
% $z_i(t)=u_i(t)*h_{LP}(t)$

zi = lowpass(ui,30e3,Fsampling);

%%
% Basband signal
z=zr+i*zi;

%% Constellation Estimates
% We sample the baseband received signal to get noisy estimates of
% transmitted constellation point. This is not the best way though. Any
% other suggestions for improvement?

ce=z(ceil(Ns/2):Ns:length(z));


%% Bit Estimates
% We implement QPSK Demapper to extract bits from constellation estimates

%%
% Check which quadrant ce lies in
ser=real(ce)>0;
sei=imag(ce)>0;
se(1:2:(2*length(ser)))=ser;
se(2:2:(2*length(ser)))=sei;

%% 
% Calculate Bit Error Rate 


BER1(i)=sum(se~=s)/length(s)





 end
%% disp Q vs ber graph



figure(2)
plot(Q, BER10)
title('Receivers Phase vs Ber, Snr=10')
xlabel('Receiver oscillator s phase')
ylabel('BER values')

grid

figure(3)
plot(Q, BER1)
title('Receivers phase vs Ber, SNR=1')
xlabel('Receiver oscillator s phase')
ylabel('BER values')

grid