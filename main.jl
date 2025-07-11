
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

add_once!(dict::Dict{T, Any}, key::T, value) where T = dict[key] = value # !haskey(dict, key) && (dict[key] = value)



begin
f = Figure(size = (800,400))

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

# Clear any existing listeners to prevent multiple registrations
for i in 1:9
    empty!(buttons[i].clicks.listeners)
end
for i in 1:9
    on(buttons[i].clicks) do _
        println("Button $i clicked, setting num to $i")
        num[] = i
    end
end

num = Observable(0)

# Clear any existing listeners on num to prevent multiple registrations
empty!(num.listeners)

on(num) do n
    to_highlight = Dict{CartesianIndex, Any}()
    
    foreach(pos -> add_once!(to_highlight, pos, (:black, 0.3)), findall(x -> x != 0 && x != n, board))
    
    match_positions = findall(==(n), board)
    foreach(pos -> add_once!(to_highlight, pos, (:red, 0.5)), match_positions)
    
    for (idx, pos) in enumerate(match_positions)

        foreach(y -> add_once!(to_highlight, CartesianIndex(pos[1], y), (:cyan, 0.7)), 1:9)
        foreach(x -> add_once!(to_highlight, CartesianIndex(x, pos[2]), (:cyan, 0.7)), 1:9)
        
        foreach(x -> begin
        foreach(y -> begin
            add_once!(to_highlight, CartesianIndex( (pos[1] - (pos[1]-1) % 3, pos[2] - (pos[2]-1) % 3) .+ (x,y) ), (:cyan, 0.7))
        end, 0:2)
    end, 0:2)

    end
    
    # Move debugging code outside the loop so it only runs once
    # Add secondary line detection here!!!!!!!!!!!!!
            
    # More efficient generation - vertical slices then horizontal slices
    detect_indices(base_r, base_c) = [
        [CartesianIndex.(base_r .+ (-1:1), base_c + c) for c in -1:1];  # vertical slices
        [CartesianIndex.(base_r + r,       base_c .+ (-1:1)) for r in -1:1]   # horizontal slices
    ]

    # Function to check if all possible positions are contained in a single valid slice
    function has_valid_slice_constraint(slice_array)
        # Count total false positions across all slices
        total_false_positions = sum(slice -> count(x -> x == false, slice), slice_array)
        
        # Debug: print the slice pattern
        println("Slice pattern:")
        for (i, slice) in enumerate(slice_array)
            false_positions = findall(x -> x == false, slice)
            println("  Slice $i: $slice (false at positions: $false_positions)")
        end
        println("  Total false positions: $total_false_positions")
        
        # Find slices that have contiguous false values
        valid_slices = []
        for (i, slice) in enumerate(slice_array)
            false_indices = findall(x -> x == false, slice)
            if length(false_indices) >= 2
                # Check if all false indices are consecutive
                is_contiguous = true
                for j in eachindex(false_indices)[2:end]
                    if false_indices[j] - false_indices[j-1] != 1
                        is_contiguous = false
                        break
                    end
                end
                if is_contiguous
                    println("  Found contiguous slice $i with $false_indices")
                    push!(valid_slices, (i, length(false_indices)))
                end
            end
        end
        
        println("  Valid contiguous slices: $valid_slices")
        
        # A valid slice constraint exists if:
        # 1. There's exactly one slice with contiguous false values of length >= 2
        # 2. OR multiple slices but we want the most restrictive one
        if length(valid_slices) >= 1
            # If multiple valid slices, prefer the one with fewer positions (more restrictive)
            slice_index, false_count = minimum(valid_slices, by = x -> x[2])
            println("  Selected slice $slice_index with $false_count positions")
            return slice_index
        end
        
        return nothing
    end

    # Loop through each 3x3 square
    for r in 2:3:8, c in 2:3:8 
        q = map(row_col -> map(pos -> haskey(to_highlight, pos), row_col), detect_indices(r, c))

        println("Checking 3x3 box at ($r, $c)")
        # Check if there's a valid slice constraint
        valid_slice_index = has_valid_slice_constraint(q)

        if valid_slice_index !== nothing
            println("Valid slice constraint found at ($r, $c): slice $valid_slice_index")
            row_slice_index = valid_slice_index

            indices_to_add = []
            for highlight_i in 2:3:8
                if row_slice_index <= 3
                    highlight_i == r && continue
                    append!(indices_to_add, detect_indices(highlight_i, c)[row_slice_index])
                else
                    highlight_i == c && continue
                    append!(indices_to_add, detect_indices(r, highlight_i)[row_slice_index])
                end
            end
            foreach(pos -> add_once!(to_highlight, pos, (:purple, 0.5)), indices_to_add)
        end
    end

    



    foreach(pos -> add_once!(to_highlight, pos, (:red, 0.5)), match_positions)



    # Update the color grid inside the listener
    color_grid[] .= Ref((:black, 0.0))
    
    for (pos, col) in to_highlight
        color_grid[][pos] = col
    end
    notify(color_grid)
end

f
end
