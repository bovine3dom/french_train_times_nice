#!/bin/julia
using Dates, StatsPlots, DataFrames
plotly() # lets us hover over stuff
lines = readlines("timetables_converted/timetable_new.txt")
lines = map.(x -> isascii(x) ? x : '?',  lines) # not perfect but probably good enough. will mess up station names etc
lines = rpad.(lines, maximum(length.(lines)))
# length.(lines)
# hcat(split.(lines, "")...)

# new times
# each page is a collection of times (worked out by looking at line/col numbers in vim, :set cursorcolumn is handy)
# todo: add conditions is the row containing e.g. TLJ for each page, and columns for station names
stationstoventimiglia = getindex.(lines[12:41], Ref(1:27)) .|> strip
stationstomandelieu = getindex.(lines[280:309], Ref(1:27)) .|> strip
toventimiglia = [12:41, 64:93, 115:144, 166:195, 223:252]
notestoventimiglia = [9, 61, 112, 163, 220]
tomandelieu = [280:309, 332:361, 383:412, 434:463, 491:520]
notestomandelieu = [277, 329, 380, 431, 488]

# all except last page of each timetable
t = [46:51, 58:65, 70:76, 82:88, 94:100, 104:112, 119:124, 131:136, 143:149, 154:162, 165:173, 179:186, 190:200, 205:213, 215:225, 227:237, 241:250, 254:263, 266:274, 279:287, 292:298]
vent = [51:55, 63:67, 78:82, 95:99, 111:115, 128:132, 145:149, 161:165, 177:181, 192:196, 207:211, 224:228, 239:243, 254:257, 269:272, 284:287, 300:303]

# plot(df.station, eachcol(df[!, Not(:station)])|>collect, yformatter=nsToTimeStr, legend=:none)
# function nsToTimeHack(ns)
#     hours = floor(ns / 3600000000000)
#     minutes = floor((ns - hours * 3600000000000) / 60000000000)
#     string(Time(hours, minutes) + Hour(4))
# end

function cellToTime(cell)
    try
        Time(strip(cell), dateformat"HH.MM")# - Hour(4)
    catch(e)
        missing
    end
    # todo: work out how to deal with +1 day gracefully ... for now can just subtract four hours
end

function getstationman(i)
    try
        stationstomandelieu[Int(floor(i))]
    catch(e)
        ""
    end
end

function getstationven(i)
    try
        stationstoventimiglia[Int(floor(i))]
    catch(e)
        ""
    end
end


df = DataFrame(hcat(
    vcat([[getindex.(lines[v], Ref(c)) .|> cellToTime for c in t] for v in toventimiglia[1:4]]...)...,
    vcat([[getindex.(lines[v], Ref(c)) .|> cellToTime for c in vent] for v in toventimiglia[5:5]]...)...,
), :auto)
notes2v = Dict("x$k" => v for (k, v) in enumerate(hcat(
    vcat([[getindex.(lines[v], Ref(c)) .|> strip for c in t] for v in notestoventimiglia[1:4]]...)...,
    vcat([[getindex.(lines[v], Ref(c)) .|> strip for c in vent] for v in notestoventimiglia[5:5]]...)...,
)))
df_RAW = DataFrame(hcat(vcat([[getindex.(lines[v], Ref(c)) for c in t] for v in toventimiglia[1:4]]...)..., vcat([[getindex.(lines[v], Ref(c)) for c in vent] for v in toventimiglia[5:5]]...)...), :auto)
df.station = 1:size(df, 1)
df2 = DataFrame(hcat(
    vcat([[getindex.(lines[v], Ref(c)) .|> cellToTime for c in t] for v in tomandelieu[1:4]]...)...,
    vcat([[getindex.(lines[v], Ref(c)) .|> cellToTime for c in vent] for v in tomandelieu[5:5]]...)...,
), :auto)
notes2v2 = Dict("x$k" => v for (k, v) in enumerate(hcat(
    vcat([[getindex.(lines[v], Ref(c)) .|> strip for c in t] for v in notestomandelieu[1:4]]...)...,
    vcat([[getindex.(lines[v], Ref(c)) .|> strip for c in vent] for v in notestomandelieu[5:5]]...)...,
)))
df2.station = size(df, 1):-1:1
# df = DataFrame(hcat(vcat([[getindex.(lines[v], Ref(c)) .|> cellToTime for c in t] for v in toventimiglia[1:4]]...)...), :auto)
# dropmissing!(df)
plot(legend=:none, yformatter=getstationven,xticks=Time(5):Hour(2):Time(23), xrot=45);#xformatter=nsToTimeHack)#, xticks=Hour(1):Hour(1):Hour(24))
for n in names(eachcol(df[!, Not(:station)]))
    # weekday, see values with below
    # unique(values(notes2v))
    !(notes2v[n] in (["TLJ", "L?V", "sf VS", "L?J", "sf sam"])) && continue
    mini_df = dropmissing(df[!, [:station, Symbol(n)]])
    plot!(mini_df[!, Symbol(n)], mini_df.station, label=n)
end
# for n in names(eachcol(df2[!, Not(:station)]))
#     # weekday, see values with below
#     # unique(values(notes2v))
#     !(notes2v2[n] in (["TLJ", "L?V", "sf VS", "L?J", "sf sam"])) && continue
#     mini_df = dropmissing(df2[!, [:station, Symbol(n)]])
#     plot!(mini_df[!, Symbol(n)], mini_df.station, label=n)
# end
plot!()













## part two: the old / current timetable













# nb: page four is broken. page three is a bit messed up as well... maybe i should have just done them all
using CSV

df2 = CSV.read("timetables_converted/timetable_new_page_2.csv", DataFrame, header=false, typemap=Dict(Float64 => String))
df3 = CSV.read("timetables_converted/timetable_new_page_3.csv", DataFrame, header=false, typemap=Dict(Float64 => String))
df4 = CSV.read("timetables_converted/timetable_new_page_4.csv", DataFrame, header=false, typemap=Dict(Float64 => String))
df = DataFrame(permutedims(vcat(
    hcat([Array(r) .|> cellToTime for r in eachrow(df2)]...,),
    hcat([Array(r) .|> cellToTime for r in eachrow(df3)]...,),
    hcat([Array(r) .|> cellToTime for r in eachrow(df4)]...,),
)), :auto)
df.station = 1:size(df, 1)


# todo: read the other pages the old fashioned way, and get "notes" for each train

rename!(x -> replace(x, "Column" => "x"), df2)

lines = readlines("timetables_converted/timetable_old.txt")
lines = map.(x -> isascii(x) ? x : '?',  lines) # not perfect but probably good enough. will mess up station names etc
lines = rpad.(lines, maximum(length.(lines)))
# length.(lines)
# hcat(split.(lines, "")...)

# new times
# each page is a collection of times (worked out by looking at line/col numbers in vim, :set cursorcolumn is handy)
# todo: add conditions is the row containing e.g. TLJ for each page, and columns for station names
stationstoventimiglia = getindex.(lines[12:41], Ref(1:27)) .|> strip
stationstomandelieu = getindex.(lines[280:309], Ref(1:27)) .|> strip
toventimiglia = [12:41, 64:93, 115:144, 166:195, 223:252]
notestoventimiglia = [9, 61, 112, 163, 220]
tomandelieu = [280:309, 332:361, 383:412, 434:463, 491:520]
notestomandelieu = [277, 329, 380, 431, 488]

# all except last page of each timetable
t = [46:51, 58:65, 70:76, 82:88, 94:100, 104:112, 119:124, 131:136, 143:149, 154:162, 165:173, 179:186, 190:200, 205:213, 215:225, 227:237, 241:250, 254:263, 266:274, 279:287, 292:298]
vent = [51:55, 63:67, 78:82, 95:99, 111:115, 128:132, 145:149, 161:165, 177:181, 192:196, 207:211, 224:228, 239:243, 254:257, 269:272, 284:287, 300:303]

# plot(df.station, eachcol(df[!, Not(:station)])|>collect, yformatter=nsToTimeStr, legend=:none)
# function nsToTimeHack(ns)
#     hours = floor(ns / 3600000000000)
#     minutes = floor((ns - hours * 3600000000000) / 60000000000)
#     string(Time(hours, minutes) + Hour(4))
# end

function cellToTime(cell)
    try
        Time(strip(cell), dateformat"HH.MM")# - Hour(4)
    catch(e)
        missing
    end
    # todo: work out how to deal with +1 day gracefully ... for now can just subtract four hours
end

function getstationman(i)
    try
        stationstomandelieu[Int(floor(i))]
    catch(e)
        ""
    end
end

function getstationven(i)
    try
        stationstoventimiglia[Int(floor(i))]
    catch(e)
        ""
    end
end


df = DataFrame(hcat(
    vcat([[getindex.(lines[v], Ref(c)) .|> cellToTime for c in t] for v in toventimiglia[1:4]]...)...,
    vcat([[getindex.(lines[v], Ref(c)) .|> cellToTime for c in vent] for v in toventimiglia[5:5]]...)...,
), :auto)
notes2v = Dict("x$k" => v for (k, v) in enumerate(hcat(
    vcat([[getindex.(lines[v], Ref(c)) .|> strip for c in t] for v in notestoventimiglia[1:4]]...)...,
    vcat([[getindex.(lines[v], Ref(c)) .|> strip for c in vent] for v in notestoventimiglia[5:5]]...)...,
)))
df_RAW = DataFrame(hcat(vcat([[getindex.(lines[v], Ref(c)) for c in t] for v in toventimiglia[1:4]]...)..., vcat([[getindex.(lines[v], Ref(c)) for c in vent] for v in toventimiglia[5:5]]...)...), :auto)
df.station = 1:size(df, 1)
# df = DataFrame(hcat(vcat([[getindex.(lines[v], Ref(c)) .|> cellToTime for c in t] for v in toventimiglia[1:4]]...)...), :auto)
# dropmissing!(df)
plot(legend=:none, yformatter=getstationven,)#xformatter=nsToTimeHack)#, xticks=Hour(1):Hour(1):Hour(24))
for n in names(eachcol(df[!, Not(:station)]))
    # weekday, see values with below
    # unique(values(notes2v))
    #!(notes2v[n] in (["TLJ", "L?V", "sf VS", "L?J", "sf sam"])) && continue
    mini_df = dropmissing(df[!, [:station, Symbol(n)]])
    plot!(mini_df[!, Symbol(n)], mini_df.station, label=n)
end
plot!()
