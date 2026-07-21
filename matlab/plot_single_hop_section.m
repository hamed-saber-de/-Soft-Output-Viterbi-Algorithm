function plot_single_hop_section(t, survivorPath, pathMetric, M, e, h)
    % plot_single_hop_section

    figure;
    hold on;
    title(sprintf('Single-Hop Section from Time %d to Time %d', t, t+1));
    xlabel('States at Time n+1');
    ylabel('States at Time n');
    xlim([0, M]);
    ylim([0, M]);
    
    % Labels for states at time n
    for state_n = 0:M-1
        text(t-1, state_n + 1, sprintf('State: %d\nMetric: %.2f', state_n, pathMetric(state_n + 1, t)), ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
    end

    % Labels for states at time n+1
    for state_n1 = 0:M-1
        prevState = survivorPath(state_n1 + 1, t + 1);
        newSymbol = (state_n1 - mod(prevState, 2^(length(h)-1))) / 2^(length(h)-2);  % Decoding the symbol input
        transitionMetric = pathMetric(state_n1 + 1, t + 1) - pathMetric(prevState + 1, t);

        text(t, state_n1 + 1, sprintf('State: %d\nMetric: %.2f\nPred: %d\nInput: %.1f', ...
            state_n1, pathMetric(state_n1 + 1, t + 1), prevState, newSymbol), ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
    end

    % Plot the transitions
    for state_n = 0:M-1
        for state_n1 = 0:M-1
            % Only plot transitions that are valid
            if survivorPath(state_n1 + 1, t + 1) == state_n
                plot([t-1, t], [state_n + 1, state_n1 + 1], 'b', 'LineWidth', 1.5);  % Transition line
                transitionMetric = pathMetric(state_n1 + 1, t + 1) - pathMetric(state_n + 1, t);
                midPoint = [(2*(t-1)+1) / 2, (state_n + 1 + state_n1 + 1) / 2];
                text(midPoint(1), midPoint(2), sprintf('Metric: %.2f', transitionMetric), ...
                    'FontSize', 8, 'HorizontalAlignment', 'center');
            end
        end
    end
    
    % Label the plot with the received sample value
    text(0.5, M + 0.5, sprintf('Received Sample: %.2f', e(t)), ...
        'HorizontalAlignment', 'center', 'FontSize', 10, 'FontWeight', 'bold');
    
    grid on;
    hold off;
end
