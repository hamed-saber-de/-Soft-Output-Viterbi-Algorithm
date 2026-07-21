function llr = calculateLLR(e, t, h, rule,METRIC)
switch METRIC
    case 'F'
        % Compute LLR based on the given rule and forney metric
        alpha = 1; % Huber tuning parameter
        beta = 0.5; % Battail scaling factor
        W = length(h);
        switch rule
            case 'simple'
                P1 = 0;
                P0 = 0;
                for w = 1 : W
                    if (t - w + 1)>0
                        P1 = P1 + abs(e(t)-h(w))^2;
                        P0 = P0 + abs(e(t)+h(w))^2;
                    end
                end
                llr = log(P1/P0);
            case 'huber'
                P1 = 0;
                P0 = 0;
                for w = 1 : W
                    if (t - w + 1)>0
                        residual = (e(t)-h(w));
                        if abs(residual)<=alpha
                            P1 = P1 + 0.5*residual^2;
                        else
                            P1 = P1 + alpha*(abs(residual)-0.5*alpha);
                        end
                    end
                    if (t - w + 1)>0
                        residual = (e(t)+h(w));
                        if abs(residual)<=alpha
                            P0 = P0 + 0.5*residual^2;
                        else
                            P0 = P0 + alpha*(abs(residual)-0.5*alpha);
                        end
                    end
                end
                llr = log(P1/P0);
            case 'battail'
                P1 = 0;
                P0 = 0;
                for w = 1 : W
                    if (t - w + 1)>0
                        residual = (e(t)-h(w));
                        P1 = P1 + exp(-beta*(residual^2));
                    end
                    if (t - w + 1)>0
                        residual = (e(t)+h(w));
                        P0 = P0 + exp(-beta*(residual^2));
                    end
                end
                llr = log(P1/P0);
            otherwise
                error('Invalid LLR rule');
        end
    case 'U'
        % Compute LLR based on the given rule using Ungerboeck Metric
        alpha = 1; % Huber tuning parameter
        beta = 0.5; % Battail scaling factor
        W = length(h);
        switch rule
            case 'simple'
                llr = 0;
                for w = 1 : W
                    if (t - w + 1)>0
                        llr = llr + 2*e(t)*h(w);
                    end
                end
            case 'huber'
                llr = 0;
                for w = 1 : W
                    if (t - w + 1)>0
                        residual = e(t) - h(w);
                        if abs(residual) <= alpha
                            llr = llr + residual^2;
                        else
                            llr = llr + alpha * abs(residual) - 0.5 * alpha^2;
                        end
                    end
                end
                residual = e(t) - h(w);
                if abs(residual) <= alpha
                    llr = residual^2;
                else
                    llr = alpha * abs(residual) - 0.5 * alpha^2;
                end
            case 'battail'
                llr = 0;
                for w = 1 : W
                    if (t - w + 1)>0
                        residual = e(t) - h(w);
                        llr = llr + residual^2 / (1 + beta * abs(residual));
                    end
                end
            otherwise
                error('Invalid LLR rule');
        end
    otherwise
        error('Invalid Metric');
end
end