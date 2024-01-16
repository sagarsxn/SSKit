module SSKit

using CSV, DataFrames, DataFramesMeta, Formatting, Statistics, Polynomials, CategoricalArrays, CairoMakie, FixedEffectModels, Dates

# get directory
dir_utils = joinpath(dirname(@__FILE__), "utils")

# get all functions in the helper_functions directory
all_functions = readdir(dir_utils)

# functions to exclude
# to_exclude = ["to_tex.jl"]
to_exclude = []

# loop over all functions and include them
for f in all_functions
    if !(f ∈ to_exclude)
        include(joinpath(dir_utils, f))
        println(f)
    end
end

# exports
export freq, get_lagged_values, get_rowsum, @ndrop, summarize, get_simple_binned_stats, plot_simple_binned_stats, get_residualized_xy, plot_binned_stats, verbose_innerjoin, verbose_leftjoin, verbose_outerjoin, get_coeftable

end
