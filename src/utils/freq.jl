"""
Get frequency of values in a column of a dataframe
    - df: dataframe
    - col: symbol
"""
function freq(df::DataFrame, col::Symbol)
    t = @by(df, col, :count = length($col))
    sort!(t, :count, rev=true)
    return t
end

"""
Get frequency of values in a column of a dataframe
    - df: dataframe
    - col: vector of symbols
"""
function freq(df::DataFrame, col::Vector{Symbol})

    var1 = col[1]
    t = @by(df, col, :count = length($var1))
    sort!(t, :count, rev=true)
    return t
end