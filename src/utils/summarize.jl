# function returns a dataframe where each columns is a summary of the
# variable; summary stats include nobs, n_missing, mean, std, min, p01,
# p10, p25, p50, p75, p90, p99, max
function summarize(df::DataFrame, var::Symbol)

    # intiailize empty dataframe
    df_stats = DataFrame(
        var = Symbol[],
        nobs = Int[],
        n_missing = Int[],
        shr_missing = Float64[],
        x_mean = Float64[],
        x_std = Float64[],
        x_min = Float64[],
        p01 = Float64[],
        p10 = Float64[],
        p50 = Float64[],
        p90 = Float64[],
        p99 = Float64[],
        x_max = Float64[],
    )

    # get series
    x0 = df[:, var]

    # drop missing, potential NaN values, and Inf/-Inf values
    xm = collect(filter(x -> !isnan(x) && !isinf(x), skipmissing(x0)))

    # if all missing, return empty dataframe
    if isempty(xm)
        push!(
            df_stats,
            [
                var,
                length(x0),
                length(x0),
                1.0,
                missing,
                missing,
                missing,
                missing,
                missing,
                missing,
                missing,
                missing,
                missing,
                missing,
            ],
        )
        return df_stats
    end

    # compute statistics
    n_missing = length(x0) - length(xm)
    data_row = [
        var,
        length(x0),
        n_missing,
        n_missing / length(x0),
        mean(xm),
        std(xm),
        minimum(xm),
        quantile(xm, 0.01),
        quantile(xm, 0.1),
        quantile(xm, 0.5),
        quantile(xm, 0.9),
        quantile(xm, 0.99),
        maximum(xm),
    ]
    push!(df_stats, data_row)

    return df_stats
end

function summarize(df::DataFrame, varlist::Vector{Symbol})
    dfs = []
    for var in varlist
        df_stats = summarize(df, var)
        push!(dfs, df_stats)
    end

    df_stats = vcat(dfs...)

    return df_stats
end
