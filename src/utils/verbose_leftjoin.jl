
# this function merges two datasets, reports how good the merge was,
# prints observations from left_only and right_only datasets, and then
# keeps the set of values: ["left_only", "both"]
function verbose_leftjoin(df_left, df_right, on_vars; print="")
    df = outerjoin(df_left, df_right, on=on_vars, source=:merge)

    # overall merge report
    if print != ""
        println("\n" * "="^50 * "\n\n", print, "\n\n" * "="^50 * "\n")
    end
    println("\n" * "-"^15 * " ", "LEFT-JOIN", " " * "-"^15 * "\n")
    println(freq(df, :merge), "\n")

    # observations which did not merge
    println("\nOnly in the left dataframe\n")
    println(first(df[df.merge.=="left_only", on_vars], 10), "\n")
    println("\nOnly in the right dataframe\n")
    println(first(df[df.merge.=="right_only", on_vars], 10))
    println("\n\n" * "-"^40 * "\n\n")

    # if left dataframe variables were not missing before, make sure
    # they are still not missing after the merge
    for var in names(df_left)
        if typeof(eltype(df_left[:, var])) != Union
            if eltype(df_left[:, var]) != Missing
                dropmissing!(df, var)
            end
        end
    end

    # keep relevant values
    @subset!(df, in.(:merge, Ref(["left_only", "both"])))
    return df[:, Not(:merge)]
end