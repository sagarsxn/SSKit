# function gives binned statistics for a vector of y variables and a
# given x variable
function get_binned_stats(
    df_raw::DataFrame,
    xvar::Symbol,
    yvars::Vector{Symbol};
    nbins::Int=100,
    stat::Symbol=:mean,
)

    # get relevant vars
    df = select(df_raw, xvar, yvars...)

    # get bins
    df.bin = levelcode.(cut(df[:, xvar], nbins; allowempty=true))

    # get binned stats
    if stat == :mean
        df_stats = combine(groupby(df, :bin), [xvar, yvars...] .=> mean ∘ skipmissing; renamecols=false)
    elseif stat == :median
        df_stats = combine(groupby(df, :bin), [xvar, yvars...] .=> median ∘ skipmissing; renamecols=false)
    end

    # get percentiles
    df_stats.pctile = df_stats.bin .* (100 / nbins)

    return df_stats
end


# function computes binned stats for a scatter plot
function get_simple_binned_stats(
    df_raw::DataFrame,
    xvar::Symbol,
    yvar::Symbol;
    nbins::Int=10,
    stat::Symbol=:mean,
)

    # get relevant vars
    df = select(df_raw, xvar, yvar)

    # dropmissing values
    dropmissing!(df, [xvar, yvar])

    # drop inf and nan
    filter!(row -> !isnan(row[xvar]) && !isinf(row[xvar]), df)
    filter!(row -> !isnan(row[yvar]) && !isinf(row[yvar]), df)

    # drop outliers in xvar
    p99 = quantile(df[:, xvar], 0.99)
    @subset!(df, $xvar .< p99)

    # get linear and quadratic fits
    fit_linear = Polynomials.fit(df[:, xvar], df[:, yvar], 1)
    fit_quad = Polynomials.fit(df[:, xvar], df[:, yvar], 2)

    # get bins
    df.bin = levelcode.(cut(df[:, xvar], nbins; allowempty=true))

    # get binned stats
    if stat == :mean
        df_stats = @by(
            df,
            :bin,
            $xvar = mean(skipmissing($xvar)),
            $yvar = mean(skipmissing($yvar))
        )
    elseif stat == :median
        df_stats = @by(
            df,
            :bin,
            $xvar = median(skipmissing($xvar)),
            $yvar = median(skipmissing($yvar))
        )
    end

    # add fitted values to dataframe
    x_vals = range(
        minimum(df_stats[:, xvar]),
        maximum(df_stats[:, xvar]),
        length=100,
    )
    df_fitted = DataFrame()
    df_fitted[!, xvar] = collect(x_vals)
    df_fitted[!, "$(yvar)_linear"] = fit_linear.(x_vals)
    df_fitted[!, "$(yvar)_quad"] = fit_quad.(x_vals)

    return df_stats, df_fitted, df
end

function plot_simple_binned_stats(
    df_raw::DataFrame,
    xvar::Symbol,
    yvar::Symbol;
    nbins::Int=10,
    stat::Symbol=:mean,
)

    # get binned stats
    df_stats, df_fitted, df =
        get_simple_binned_stats(df_raw, xvar, yvar; nbins=nbins, stat=stat)

    # variable names
    yvar_linear = "$(yvar)_linear"
    yvar_quad = "$(yvar)_quad"

    # plot
    f = Figure()
    ax = Axis(f[1, 1])

    # scatter plot
    CairoMakie.scatter!(df_stats[:, xvar], df_stats[:, yvar], ax=ax)

    # linear fit
    CairoMakie.lines!(
        df_fitted[:, xvar],
        df_fitted[:, yvar_linear],
        linestyle=:dash
    )

    # quadratic fit
    CairoMakie.lines!(
        df_fitted[:, xvar],
        df_fitted[:, yvar_quad],
        linestyle=:dot
    )

    # add title
    ax.title = string(yvar)

    # add xlabel
    ax.xlabel = string(xvar)

    display(f)

    return f
end


# function residualizes y and x using other variables in formula y ~ x +
# other 
function get_residualized_xy(df_raw, formula, add_mean=true)
    lhs = formula.lhs
    rhs = formula.rhs

    local df
    if rhs isa Tuple
        # residualize if there are other controls
        res_formula = formula.lhs + formula.rhs[1] ~ formula.rhs[2:end]
        df, _ = partial_out(df_raw, res_formula, align=false, add_mean=add_mean)
    else
        # otherwise return just those two variables
        yvar = string(lhs)
        xvar = string(rhs)
        df = df_raw[:, [yvar, xvar]]
    end

    return df
end

function plot_binned_stats(
    df_raw::DataFrame,
    formula;
    nbins::Int=10,
    stat::Symbol=:mean,
    add_mean::Bool=true,
)

    # get residuals
    df = get_residualized_xy(df_raw, formula, add_mean)
    yvar, xvar = propertynames(df)

    # get binned stats
    df_stats, df_fitted, df =
        get_simple_binned_stats(df_raw, xvar, yvar; nbins=nbins, stat=stat)

    # variable names
    yvar_linear = "$(yvar)_linear"
    yvar_quad = "$(yvar)_quad"

    # plot
    f = Figure()
    ax = Axis(f[1, 1])

    # scatter plot
    CairoMakie.scatter!(df_stats[:, xvar], df_stats[:, yvar], ax=ax)

    # linear fit
    CairoMakie.lines!(
        df_fitted[:, xvar],
        df_fitted[:, yvar_linear],
        linestyle=:dash
    )

    # quadratic fit
    CairoMakie.lines!(
        df_fitted[:, xvar],
        df_fitted[:, yvar_quad],
        linestyle=:dot
    )

    # add title
    ax.title = string(yvar)

    # add xlabel
    ax.xlabel = string(xvar)

    display(f)

    return f
end