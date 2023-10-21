module SSKit

using DataFrames, DataFramesMeta, Formatting

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
export freq, get_lagged_values, get_rowsum, @ndrop


end
