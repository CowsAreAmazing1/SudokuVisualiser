using DelimitedFiles, GLMakie
col = :black
board = rot180(readdlm("geet.csv", '\t', Int8, '\n'))



x1 = [0,1,1,0]
y1 = [1,1,0,0]
function boxvert(p #= really an index =#)
    edge = [low, linegap[1], linegap[2], high]
    d = linegap[2] - linegap[1]
    Point2f.(Ref(edge[p]) .+ [[0,0], [0,d], [d,d], [d,0]])
end



begin
    f = Figure(size=(600,600))
    grid = Axis(f[1,1])
    vb = string.(board)


    #f[1, 1] = buttongrid = GridLayout(tellwidth = false)
    #buttonlabels = string.(1:9)
    #buttons = buttongrid[1:3, 1:3] = [Button(f, label = l) for l in buttonlabels]


    spacing = 1; padding = spacing * 0.5; width = 6 + 2 * spacing
    a = vcat([0,1,2], spacing .+ [2,3,4], 2 * spacing .+ [4,5,6])
    low = minimum(a)-padding; high = maximum(a)+padding
    lines!(grid, Point2f.([
        (low,low),(low,high),(high,high),(high,low),(low,low)
    ]), color = :black)
    grid.aspect = DataAspect(); hidedecorations!(grid); hidespines!(grid)
    
    linegap = [(a[3] + a[4]) * 0.5, (a[6] + a[7]) * 0.5]
    lines!(grid, [Point2f(linegap[1],low),Point2f(linegap[1],high)], color = :black)
    lines!(grid, [Point2f(linegap[2],low),Point2f(linegap[2],high)], color = :black)
    lines!(grid, [Point2f(low,linegap[1]),Point2f(high,linegap[1])], color = :black)
    lines!(grid, [Point2f(low,linegap[2]),Point2f(high,linegap[2])], color = :black)
    
    textpos = [ Point2f(j,i)  for i in a, j in reverse(a)]
    foreach((p,t) -> if t != "0"; text!(grid, p, text = t, align = (:center, :center), fontsize = 1, markerspace = :data) end, textpos, vb)


    #Box(f[1, 1], color = (:red, 0.2), strokewidth = 0)
    #Box(f[1, 2], color = (:blue, 0.2), strokewidth = 0)
    #rowsize!(f.layout, 1, Aspect(1,1))
    f
end

num = 2

begin
    numindices = findall(x -> x == num, board)
    arc!.(grid, textpos[numindices], 0.5, 0, 2pi, linewidth = 3, color = col)

    r = textpos[numindices]
    foreach(x -> poly!(grid, boxvert(x), color = (col, 0.6)), map(y -> map(x -> Int(1+floor(x/(linegap[2] - linegap[1]))), y), r))

    foreach(t -> begin
        #=
            poly takes array of points which is made in map which stretches a square of 
            points made below by adding corners to the center of each selected number
        =#
        poly!(grid, map(((x,y),c) -> Point2f(c == 0 ? low : high, y), t, x1), color = (col, 0.6))
        poly!(grid, map(((x,y),c) -> Point2f(x, c == 0 ? low : high), t, y1), color = (col, 0.6))
    end, map(x -> Point2f.(Ref(x) .+ [[-0.5,0.5], [0.5,0.5], [0.5,-0.5], [-0.5,-0.5]]), r))

    foreach((p,t) -> if t == string(num); text!(grid, p, text = t, align = (:center, :center), fontsize = 1, markerspace = :data, color = :cyan) end, textpos, vb)

end