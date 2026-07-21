%================================================

clc
clear 
close all

%===========================================================

% Parameters
N                =              20;                           % Length of input vector d
W                =              5;                            % Length of impulse response
L                =              N + W - 1;                    % Total length after adding tail bits
sigma            =              0.01;                         % Noise standard deviation
d                =              randi([0, 1], 1, N) * 2 - 1;  % Generate random bipolar input vector {-1, +1}
h                =              [1, 1/2, 1/4, 1/2, 1/4];
h                =              h / norm(h);                  % Normalize impulse response

% Add tail bits
d = [-ones(1, W-1), d, -ones(1, W-1)];

e_u = conv(d, h);  % Transmitted signal
n = sigma * randn(1, length(e_u));
e = e_u + n;  % Received signal

figure
subplot(311)
plot(e_u)
xlabel('Samples')
ylabel('Amplitude')
title('Unnoisy Channel Output')
subplot(312)
plot(n)
xlabel('Samples')
ylabel('Amplitude')
title('Noise')
subplot(313)
plot(e)
xlabel('Samples')
ylabel('Amplitude')
title('Noisy Channel Output')

