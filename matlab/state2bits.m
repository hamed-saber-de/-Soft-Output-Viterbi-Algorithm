function bits = state2bits(state, W)
    % Convert a state number to a vector of bits
    bits = mod(floor(state ./ 2.^(W-1:-1:0)), 2);
    bits = 2 * bits -1;
end