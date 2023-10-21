using SSKit
using Test

using DataFrames, DataFramesMeta

@testset "SSKit.jl" begin

    # test @ndrop with a DataFrame
    df = DataFrame(x=1:10, y=11:20)
    @ndrop "test" @subset!(df, :x .> 5)
    @test nrow(df) == 5

end
