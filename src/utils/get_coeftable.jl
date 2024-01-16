# function converts a regression model into a dataframe containing all
# relevant estimates and statistics
# TODO: make robust to using GLM
function get_coeftable(model)
    df = DataFrame(coeftable(model))
    rename!(df, [:var, :estimate, :se, :tval, :pval, :conf_low, :conf_high])
    @transform! df @astable begin
        :nobs = nobs(model)
        :r2 = r2(model)
        :r2_adj = adjr2(model)
        :fstat = model.F
    end
    return df
end