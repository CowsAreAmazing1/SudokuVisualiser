
using DelimitedFiles, GLMakie


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

add_once!(dict::Dict{T, Any}, key::T, value) where T = !haskey(dict, key) && (dict[key] = value)



begin
f = Figure(size = (600,300))

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


f[1,2] = buttongrid = GridLayout(tellwidth = false, tellheight = false)

labels = [ string(i) for i in 1:9 ]
buttons = buttongrid[1:3, 1:3] = [Button(f, label = l, width = 100, height = 100) for l in labels]


color_grid = Observable([ (:black, 0.0) for _ in 1:9, _ in 1:9])
highlight_plots = [ polyer(grid, CartesianIndex(x, y), @lift($(color_grid)[x,y])) for x in 1:9, y in 1:9 ]

for i in 1:9
    on(buttons[i].clicks) do _
        num[] = i
    end
end

num = Observable(0)

on(num) do n
    to_highlight = Dict{CartesianIndex, Any}()
    
    foreach(pos -> add_once!(to_highlight, pos, (:black, 0.3)), findall(x -> x != 0 && x != n, board))
    
    match_positions = findall(==(n), board)
    foreach(pos -> add_once!(to_highlight, pos, (:red, 0.5)), match_positions)
    
    for pos in match_positions
        foreach(y -> add_once!(to_highlight, CartesianIndex(pos[1], y), (:cyan, 0.7)), 1:9)
        foreach(x -> add_once!(to_highlight, CartesianIndex(x, pos[2]), (:cyan, 0.7)), 1:9)
        
        foreach(x -> begin
        foreach(y -> begin
            add_once!(to_highlight, CartesianIndex( (pos[1] - (pos[1]-1) % 3, pos[2] - (pos[2]-1) % 3) .+ (x,y) ), (:cyan, 0.7))
        end, 0:2)
    end, 0:2)

    # Add secondary line detection here!!!!!!!!!!!!!
            
    # square_offsets = CartesianIndices((-1:1, -1:1))
    # # Loop through each 3x3 square
    # for x in 2:3:8, y in 2:3:8 
        
    # end


end

color_grid[] .= Ref((:black, 0.0))

for (pos, col) in to_highlight
    color_grid[][pos] = col
end
notify(color_grid)
end

f
end
