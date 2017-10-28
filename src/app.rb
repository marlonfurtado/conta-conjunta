require 'rgl/dot'
require 'rgl/adjacency'
require 'rgl/connected_components'
require_relative 'reader'

file = ARGV[0] || "caso00"
reader = Reader.new file
accounts = reader.data

accounts.shift  # Remove first
names_to_connect = accounts.pop.split(" ")  # Remove last and get names to connect

graph = RGL::AdjacencyGraph.new

accounts_hash = Hash.new

# Create graph
for i in 0...accounts.size
    nodei  = accounts[i].split(" ")[0]
    name_i1 = accounts[i].split(" ")[1]
    name_i2 = accounts[i].split(" ")[2]

    # Create a hash with account numbers and names
    accounts_hash.store(nodei, (name_i1 +" "+ name_i2))

    for j in i+1...accounts.size
        nodej  = accounts[j].split(" ")[0]
        name_j1 = accounts[j].split(" ")[1]
        name_j2 = accounts[j].split(" ")[2]

        if(name_i1 == name_j1 or name_i1 == name_j2 or name_i2 == name_j1 or name_i2 == name_j2)
            graph.add_edge(nodei, nodej)
        end

    end
end


initial_name = names_to_connect[0]
final_name = names_to_connect[1]

initial_node = []
final_node = []

accounts.each do |line|
    node = line.split(" ")[0]
    name1 = line.split(" ")[1]
    name2 = line.split(" ")[2]

    if name1 == initial_name or name2 == initial_name
        initial_node << node
    elsif name1 == final_name or name2 == final_name
        final_node << node
    end
end

shorter_distance = Float::INFINITY
final_path = nil
distance_paths = Hash.new

initial_node.each do |u|
    bfs = graph.bfs_iterator(u).attach_distance_map
    puts "Distance from #{u}, to: "

    bfs.each do |v|
        distance_to_root = bfs.distance_to_root(v) - 1
        print v, ': ', distance_to_root, "\n"
        distance_paths.store(v, distance_to_root)

        if final_node.include? v
            if distance_to_root <= shorter_distance
                shorter_distance = distance_to_root
                final_path = v
            end
        end
    end
end

shorter_path = []
distance_paths.sort_by{ |k, v| -v }.each do |node, distance|
    if distance_paths[node] < distance_paths[final_path] and graph.adjacent_vertices(final_path).include? node
        shorter_path << final_path
        final_path = node
        
        if initial_node.include? node
            @start_node = node
        end
    end
end
shorter_path << @start_node
shorter_path.reverse!

puts "\n\nFinal result:"
shorter_path.each do |node|
    puts "#{node} #{accounts_hash[node]}"
end