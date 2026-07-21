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


% Viterbi Algorithm for ML Detection
M = 2^(W-1);          % Number of states in trellis
trellis = zeros(M, length(d));
pathMetric = inf(M, L);  % Path metrics (initialize to inf)
pathMetric(:, 1) = 0;    % Start from state 0
survivorPath = zeros(M, L);
beststate    = zeros(1,L);
% Trellis computation
bestmetric = 0;
for t = 1:L-1
    for state = 0:M-1
        for input = [-1, 1]
            prevState = state  ; % bitshift(state, -1) + (input == 1) * 2^(W-2)
            temp = [state2bits(prevState, W-1), input];
            output = conv(temp, h, 'valid');
            branchMetric = (e(t+W-1) - output)^2;

            newMetric = bestmetric + branchMetric;
            if newMetric < pathMetric(state + 1, t+1)
                pathMetric(state + 1, t+1) = newMetric;
                pathMetric(state + 1, t+1,2) = input;
                survivorPath(state + 1, t+1) = prevState;
            end
        end
    end
    [bestmetric,beststate(t+1)] = min(pathMetric(:,t+1,1));
    beststate(t+1) = beststate(t+1)-1;
end
beststate(L+1) = 0;
beststate = beststate(2:end);
[~,b] = min(pathMetric(:,:,1));
for i = 1 : L-1
    det1(i) = pathMetric(b(i+1),i+1,2);
end
det1(L) = -1;

% Traceback to determine ML sequence
finalState = 0;
detected = det1;

for t = 1 : L
     survivorPath(:,t) = beststate(t);
end

% Plot the Channel Trellis Diagram
figure;
hold on;
xlim([1, L]);
ylim([0, M]);
for t = 1:L-1
    for state = 0:M-1
        for input = [-1, 1]
            prevState = bitshift(state, -1) + (input == 1) * 2^(W-2);
            plot([t, t+1], [prevState+1, state+1], 'b'); % Trellis branches
        end
    end
end

% Highlight the Path Associated with Detected Data
for t = 1:L-1
    plot([t, t+1], [beststate(t)+1, beststate(t+1)+1], 'r', 'LineWidth', 2);
end



% Highlight Initial and Final States
scatter(1, 1, 100, 'g', 'filled', 'DisplayName', 'Initial State');
scatter(L, finalState + 1, 100, 'r', 'filled', 'DisplayName', 'Final State');
xlabel('Time Index'); ylabel('State');
title('Channel Trellis Diagram');
grid on;
hold off;

% Plot the Trellis Diagram at Detector
detectedPath = beststate;
figure;
hold on;
xlim([1, L]);
ylim([0, M]);
for t = 1:L-1
    for state = 0:M-1
        for input = [-1, 1]
            prevState = bitshift(state, -1) + (input == 1) * 2^(W-2);
            plot([t, t+1], [prevState+1, state+1], 'b'); % Trellis branches
        end
    end
end
errors = find(d(W:end) ~= detected); % Find error locations
% Highlight the Path Associated with Detected Data
for t = 1:L-1
    temp = sum(double(t==errors));
    if temp>0
         plot([t, t+1], [detectedPath(t)+1, detectedPath(t+1)+1], 'r', 'LineWidth', 2);
    else
        plot([t, t+1], [detectedPath(t)+1, detectedPath(t+1)+1], 'g', 'LineWidth', 2);
    end
end

% Highlight Initial and Final States
scatter(1, detectedPath(1)+1, 100, 'g', 'filled', 'DisplayName', 'Initial State');
scatter(L, detectedPath(L)+1, 100, 'g', 'filled', 'DisplayName', 'Final State');
xlabel('Time Index'); ylabel('State');
title('Trellis Diagram with Detected Path');
grid on;
hold off;
