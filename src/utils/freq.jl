function freq(df::DataFrame, col::Symbol)
    """
    Get frequency of values in a column of a dataframe
    """
    t = @by(df, col, :count = length($col))
    sort!(t, :count, rev = true)
    return t
end