using DelimitedFiles, GLMakie
col = :black
board = rot180(readdlm("geet.csv", '\t', Int8, '\n'))

function polyer(ax::Axis, p::CartesianIndex)
    shifter(p) = (p[2], 10-p[1])

    poly!(ax, Point2.([
        shifter(p),
        shifter(p) .- (0,1), 
        shifter(p) .- (1,1),
        shifter(p) .- (1,0),
    ]), color = (:yellow, 0.3))
end





num = 5

begin
    f = Figure(size = (600,600))
    grid = Axis(f[1,1], aspect = DataAspect())
    hidedecorations!(grid); hidespines!(grid)

    lines!(grid, [
        Point2((0,0)),
        Point2((9,0)),
        Point2((9,9)),
        Point2((0,9)),
        Point2((0,0)),
    ], color = :black)

    foreach(x -> begin
        color = x % 3 == 0 ? :black : (:gray, 0.5)
        lw = x % 3 == 0 ? 3 : 1
        lines!(grid, [ (x, 0), (x, 9) ], color = color, linewidth = lw)
        lines!(grid, [ (0, x), (9, x) ], color = color, linewidth = lw)
    end, 1:8)


    texts = vec(map(x -> x == 0 ? " " : string(x), board))
    poses = [ Point2((x, y) .+ (0.5,0.5)) for y in 8:-1:0, x in 0:8 ]
    text!(
        grid, vec(poses), text = texts,
        align = (:center, :center), fontsize = 1, markerspace = :data
    )


    highlighters = CartesianIndex{2}[]
    append!(highlighters, findall(x -> x == num, board))

    temp = []
    for i in highlighters
        append!(temp, [ CartesianIndex(i[1], j) for j in 1:9] )
        append!(temp, [ CartesianIndex(j, i[2]) for j in 1:9] )
        append!(temp, [ CartesianIndex((i[1] - (i[1]-1) % 3, i[2] - (i[2]-1) % 3) .+ (x,y)) for x in 0:2, y in 0:2 ] )
    end
    append!(highlighters, temp)
    append!(highlighters,  findall(x -> x != 0 && x != num, board))
    unique!(highlighters)

    polyer.(grid, highlighters)

    f
end