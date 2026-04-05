extends Control

var save = SaveManager.new()
var graph = LineGraph.new()

var graph_lookup: String
var graph_filter: Array

var content: String

func _update_graph():
	var loaded = save.load_json(graph_lookup + ".json")
	
	graph.clear_datasets()

	if loaded:
		# Failures dataset
		if graph_filter.has("Failures"):
			var data: Array = []
			for i in loaded["Rounds Completed"]:
				# Example: assuming deck info is stored somewhere in loaded
				var deck_name = loaded.get(str(int(i), "deck"), "") 
				data.append({
					"pos": Vector2(i, loaded[str(int(i), "failures")]),
					"deck": deck_name
				})
			graph.add_dataset(data, Color(0.9, 0.2, 0.1), "Failures")
			graph.set_range(0, loaded["Rounds Completed"], 0, 15)
			graph.set_divisions(loaded["Rounds Completed"], 3)
		
		# QPM dataset
		if graph_filter.has("QPM"):
			var data: Array = []
			for i in loaded["Rounds Completed"]:
				var deck_name = loaded.get(str(int(i), "deck"), "")
				data.append({
					"pos": Vector2(i, loaded[str(int(i), "qpm")]),
					"deck": deck_name
				})
			graph.add_dataset(data, Color(0.3, 0.8, 0.1), "QPM")
			graph.set_range(0, loaded["Rounds Completed"], 0, 50)
			graph.set_divisions(loaded["Rounds Completed"], 10)
	else:
		graph.clear_datasets()
		graph.set_range(0,10,0,50)
		graph.set_divisions(10,10)
