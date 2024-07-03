using DelimitedFiles

board = zeros(Int8, 9, 9)
writedlm("geet.csv", board)
