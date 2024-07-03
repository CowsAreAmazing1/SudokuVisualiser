using DelimitedFiles, GLMakie
board = readdlm("geet.csv", '\t', Int8, '\n')




function display(b)
    f = Figure()
    grid = Axis(f[1,2])
    vb = string.(vec(b))



    f[1, 1] = buttongrid = GridLayout(tellwidth = false)
    buttonlabels = string.(1:9)
    buttons = buttongrid[1:3, 1:3] = [Button(f, label = l) for l in buttonlabels]



    spacing = 1.2; padding = spacing * 0.5
    a = vcat([0,1,2], spacing .+ [2,3,4], 2 * spacing .+ [4,5,6])
    low = minimum(a)-padding; high = maximum(a)+padding
    lines!(grid, Point2f.([
        (low,low),(low,high),(high,high),(high,low),(low,low)
    ]), color = :black)
    #grid.aspect = DataAspect(); 
    hidedecorations!(grid); hidespines!(grid)
    
    linegap = [(a[3] + a[4]) * 0.5, (a[6] + a[7]) * 0.5]
    lines!(grid, [Point2f(linegap[1],low),Point2f(linegap[1],high)], color = :black)
    lines!(grid, [Point2f(linegap[2],low),Point2f(linegap[2],high)], color = :black)
    lines!(grid, [Point2f(low,linegap[1]),Point2f(high,linegap[1])], color = :black)
    lines!(grid, [Point2f(low,linegap[2]),Point2f(high,linegap[2])], color = :black)
    
    textpos = vec([ Point2f(j,i)  for i in a, j in reverse(a)])
    foreach((p,t) -> if t != "0"; text!(grid, p, text = t, align = (:center, :center), fontsize = 1, markerspace = :data) end, textpos, vb)


    Box(f[1, 1], color = (:red, 0.2), strokewidth = 0)
    Box(f[1, 2], color = (:blue, 0.2), strokewidth = 0)
    #resize_to_layout!(f)
    #colsize!(f.layout, 1, Aspect(1,1))
    #colsize!(f.layout, 2, Aspect(1,1))
    f
end


display(board)