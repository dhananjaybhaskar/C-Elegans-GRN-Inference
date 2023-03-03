# SLURM: srun --pty -t 6:00:00 --cpus-per-task 16 --mem=24G --partition interactive zsh
# Preprocess: cat 021821_stringent_threshold4.csv | cut -d, -f3- > stringent_cell_expr.csv
# Usage: ~/gibbs/dbhaskar/julia-1.8.5/bin/julia -p 16 build_network.jl

using NetworkInference
using LightGraphs
using GraphPlot
using NPZ

dataset = "data/stringent_cell_expr.csv"

algorithm = PIDCNetworkInference()

# Set threshold for edge inclusion (top 15% edges are kept)
threshold = 0.15

print("Building node list")
genes = get_nodes(dataset, delim=',')

print("Inferring network")
inferred_network = InferredNetwork(algorithm, genes)

print("Writing to file")
write_network_file("data/stringent_network.csv", inferred_network)

adjacency_matrix, labels_to_ids, ids_to_labels = get_adjacency_matrix(network, threshold)
number_of_nodes = size(adjacency_matrix)[1]

npzwrite("data/stringent_network_threshold.npz", Dict("adj_mat" => adjacency_matrix, 
						      "label2id" => labels_to_ids),
	 					      "id2label" => ids_to_labels
						      )
	)

graph = LightGraphs.SimpleGraphs.SimpleGraph(adjacency_matrix)
