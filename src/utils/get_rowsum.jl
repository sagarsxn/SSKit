# function takes in a dataframe, a list of columns, and the name for a
# new column that equals the rowsum of the list of columns; it also
# skips missing values in any of the columns
function get_rowsum(df_raw, new_var, columns)
    return transform(df_raw, AsTable(columns) => ByRow(sum ∘ skipmissing) => new_var)
end