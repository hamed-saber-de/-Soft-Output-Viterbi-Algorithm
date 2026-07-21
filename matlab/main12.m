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

detectedPath = beststate;

%%

% Plot Survivor and Concurrent Paths with LLRs for Simple Rule
figure;
hold on;
xlim([1, L]);
ylim([0, M]);

% Highlight Survivor Paths
currentState = detectedPath(L);
for t = L:-1:2
    prevState = survivorPath(currentState + 1, t);
    plot([t-1, t], [prevState+1, currentState+1], 'r', 'LineWidth', 2); % Survivor path
    currentState = prevState;
end

% Highlight Concurrent Paths
for t = L:-1:2
    for state = 0:M-1
        if state ~= survivorPath(detectedPath(t)+1, t) % Non-survivor states
            plot([t-1, t], [state+1, detectedPath(t)+1], 'b--');
        end
    end
end

% Annotate States with LLRs 
METRIC = 'F';
for t = 1:L
    for state = 0:M-1
        llr_simple = calculateLLR(e, t, h, 'simple',METRIC);
        text(t, state+1, sprintf('S:%.2f', llr_simple), 'FontSize', 8, 'HorizontalAlignment', 'center');
    end
end

% Highlight Initial and Final States
scatter(1, detectedPath(1)+1, 100, 'g', 'filled', 'DisplayName', 'Initial State');
scatter(L, detectedPath(L)+1, 100, 'r', 'filled', 'DisplayName', 'Final State');
xlabel('Time Index'); ylabel('State');
title('Survivor and Concurrent Paths with LLR Annotations (SIMPLE RULE)');
grid on;
hold off;

%%

% Plot Survivor and Concurrent Paths with LLRs for Huber Rule
figure;
hold on;
xlim([1, L]);
ylim([0, M]);

% Highlight Survivor Paths
currentState = detectedPath(L);
for t = L:-1:2
    prevState = survivorPath(currentState + 1, t);
    plot([t-1, t], [prevState+1, currentState+1], 'r', 'LineWidth', 2); % Survivor path
    currentState = prevState;
end

% Highlight Concurrent Paths
for t = L:-1:2
    for state = 0:M-1
        if state ~= survivorPath(detectedPath(t)+1, t) % Non-survivor states
            plot([t-1, t], [state+1, detectedPath(t)+1], 'b--');
        end
    end
end

% Annotate States with LLRs 
METRIC = 'F';
for t = 1:L
    for state = 0:M-1
        llr_huber = calculateLLR(e, t, h, 'huber',METRIC);
        text(t, state+1, sprintf('H:%.2f', llr_huber), 'FontSize', 8, 'HorizontalAlignment', 'center');
    end
end

% Highlight Initial and Final States
scatter(1, detectedPath(1)+1, 100, 'g', 'filled', 'DisplayName', 'Initial State');
scatter(L, detectedPath(L)+1, 100, 'r', 'filled', 'DisplayName', 'Final State');
xlabel('Time Index'); ylabel('State');
title('Survivor and Concurrent Paths with LLR Annotations (HUBER RULE)');
grid on;
hold off;

%%

% Plot Survivor and Concurrent Paths with LLRs for Battail Rule
figure;
hold on;
xlim([1, L]);
ylim([0, M]);

% Highlight Survivor Paths
currentState = detectedPath(L);
for t = L:-1:2
    prevState = survivorPath(currentState + 1, t);
    plot([t-1, t], [prevState+1, currentState+1], 'r', 'LineWidth', 2); % Survivor path
    currentState = prevState;
end

% Highlight Concurrent Paths
for t = L:-1:2
    for state = 0:M-1
        if state ~= survivorPath(detectedPath(t)+1, t) % Non-survivor states
            plot([t-1, t], [state+1, detectedPath(t)+1], 'b--');
        end
    end
end

% Annotate States with LLRs 
METRIC = 'F';
for t = 1:L
    for state = 0:M-1
        llr_battail = calculateLLR(e, t, h, 'battail',METRIC);
        text(t, state+1, sprintf('B:%.2f', llr_battail), 'FontSize', 8, 'HorizontalAlignment', 'center');
    end
end

% Highlight Initial and Final States
scatter(1, detectedPath(1)+1, 100, 'g', 'filled', 'DisplayName', 'Initial State');
scatter(L, detectedPath(L)+1, 100, 'r', 'filled', 'DisplayName', 'Final State');
xlabel('Time Index'); ylabel('State');
title('Survivor and Concurrent Paths with LLR Annotations (BATTAIL RULE)');
grid on;
hold off;


%%


% LLR Calculation using Forney Metric
llr_simple = zeros(1, L);
llr_huber = zeros(1, L);
llr_battail = zeros(1, L);

for t = 1:L
    % Compute LLR using Simple Rule
    llr_simple(t) = calculateLLR(e, t, h, 'simple',METRIC);
    
    % Compute LLR using Huber Rule
    llr_huber(t) = calculateLLR(e, t, h, 'huber',METRIC);

    % Compute LLR using Battail Rule
    llr_battail(t) = calculateLLR(e, t, h, 'battail',METRIC);
end

% Display LLRs
figure;
subplot(311)
plot(1:L, llr_simple, '-o');
title('Simple LLR');ylabel('LLR Value');
subplot(312)
plot(1:L, llr_huber, '-x');
title('Huber LLR');ylabel('LLR Value');
subplot(313)
plot(1:L, llr_battail, '-s');
title('Battail LLR')
xlabel('Time Index'); ylabel('LLR Value');
title('LLR Comparison');
grid on;

