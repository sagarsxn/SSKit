# this function takes in an array, and returns an array shifted by the
# given number of lag periods; can be used with transform ∘ groupby
function get_lagged_values(x; lag=1)

    # length of vector
    n = length(x)

    # construct a new array of zeros that allows missing
    x_new = zeros(Union{Missing,eltype(x)}, n)

    # add missing values first
    for i = 1:lag
        x_new[i] = missing
    end

    # fill in lagged values
    for i = 1:(n-lag)
        x_new[i+lag] = x[i]
    end

    return x_new
end