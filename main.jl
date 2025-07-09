
using DelimitedFiles, GLMakie
using Makie.Colors

col = :black
board = readdlm("geet.csv", '\t', Int8, '\n')




function polyer(ax::Axis, p::CartesianIndex, color)
    shifter(p) = (p[2], 10-p[1])

    poly!(ax, Point2.([
        shifter(p),
        shifter(p) .- (0,1), 
        shifter(p) .- (1,1),
        shifter(p) .- (1,0),
    ]), color = color)
end



f = Figure(size = (800,800))

begin
grid = Axis(f[1,1], aspect = DataAspect())
hidedecorations!(grid); hidespines!(grid)
deregister_interaction!(grid, :rectanglezoom)
deregister_interaction!(grid, :scrollzoom)
deregister_interaction!(grid, :limitreset)
deregister_interaction!(grid, :dragpan)

lines!(grid, [
    Point2((0,0)),
    Point2((9,0)),
    Point2((9,9)),
    Point2((0,9)),
    Point2((0,0)),
], color = :black, depth_shift = - 1.0)

foreach(x -> begin
    color = x % 3 == 0 ? :black : (:gray, 0.5)
    lw = x % 3 == 0 ? 3 : 1
    lines!(grid, [ (x, 0), (x, 9) ], color = color, linewidth = lw, depth_shift = -1.0)
    lines!(grid, [ (0, x), (9, x) ], color = color, linewidth = lw, depth_shift = -1.0)
end, 1:8)

texts = vec(map(x -> x == 0 ? " " : string(x), board))
poses = [ Point2((x, y) .+ (0.5,0.5)) for y in 8:-1:0, x in 0:8 ]
text!(
    grid, vec(poses), text = texts,
    align = (:center, :center), fontsize = 0.7, markerspace = :data, depth_shift = -1.0,
)
end


f[1,2] = buttongrid = GridLayout(tellwidth = false, tellheight = false)

labels = [ string(i) for i in 1:9 ]
buttons = buttongrid[1:3, 1:3] = [Button(f, label = l) for l in labels]


color_grid = [ RGB ]

highlight_plots = [ polyer for x in 1:9, y in 1:9 ]

for i in 1:9
    on(buttons[i].clicks) do _
        num[] = i
    end
end

num = Observable(0)
to_highlight = Observable(Tuple{CartesianIndex, Any}[])

on(num) do n
    global highlight_plots
    delete!.(grid, highlight_plots)
    highlight_plots = []

    match_positions = findall(==(n), board)

    for pos in match_positions
        append!(to_highlight[], [ ( CartesianIndex(pos[1], y), (:cyan)) for y in 1:9] )
        append!(to_highlight[], [ ( CartesianIndex(x, pos[2]), (:cyan)) for x in 1:9] )
        append!(to_highlight[], [ ( CartesianIndex((
            pos[1] - (pos[1]-1) % 3, pos[2] - (pos[2]-1) % 3
        ) .+ (x,y)), (:cyan)) for x in 0:2, y in 0:2 ] )
    end


    unique!(first, to_highlight[])

    # for (pos, col) in to_highlight
    #     push!(highlight_plots, )
    # end
end


on(to_highlight) do (pos, col)
    global highlight_plots
    push!(highlight_plots, polyer(grid, pos, col))
end

