# macro prints the number of observations dropped in a @subset statement
# and also custom drop functions where the first argumenet is df
macro ndrop(msg, func)
    quote
        # ---------- main ----------
        local n_old = 0
        if typeof($(esc(func.args[2]))) == DataFrame
            local n_old = nrow($(esc(func.args[2])))
        else
            local n_old = nrow($(esc(func.args[3])))
        end
        local df_new = $(esc(func))
        local n_new = nrow(df_new)
        local n_diff = n_old - n_new

        # ---------- printing ----------
        printstyled("\n" * "-"^15 * " ", $(msg), " " * "-"^15 * "\n"; color=:bold)
        printstyled("\nOrig: "; bold=true, color=:blue)
        print(format(n_old, commas=true))
        printstyled("\tRemain: "; bold=true, color=:green)
        print(format(n_new, commas=true))
        printstyled("\tDropped: "; bold=true, color=:red)
        print(format(n_diff, commas=true))
        printstyled("\tShare Dropped: "; bold=true, color=:red)
        print(format(n_diff / n_old, precision=4), "\n\n")
        df_new
    end
end