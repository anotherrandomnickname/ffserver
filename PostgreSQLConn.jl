using LibPQ
conn = LibPQ.Connection("host=localhost port=8030 dbname=fairy user=postgres password=127822")

UNIQUE_IDENTIFY = "SnHuLP5he6dnw36k"

if !isdefined(Base, :NamedTuple)
    using NamedTuples
end