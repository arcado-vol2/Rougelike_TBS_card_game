extends Node

var file = File.new()
var dirs = Directory.new()

var saves_filenames = ["main_save.dat", "prefabs.dat", "settings.dat", "id_list.dat", "test.dat"]

func overwrite_file(content, filename_id):	
	file.open("user://" + saves_filenames[filename_id], File.WRITE)
	file.store_string(to_json(content))
	file.close()
	
func add_to_file(content, filename_id):	
	file.open("user://" + saves_filenames[filename_id], File.READ_WRITE)
	var old_content = parse_json(file.get_as_text())
	if old_content != null:
		old_content.append(content)
	else:
		old_content = [content]
	file.store_string(to_json(old_content))
	file.close()

func load_file(filename_id):
	file.open("user://" + saves_filenames[filename_id], File.READ)
	var content = file.get_as_text()
	file.close()
	if content:
		return parse_json(content)
	return null
	
func load_prefab():
	var content = load_file(1)
	var output = {}
	for i in content:
		if not i["size"]  in output:
			output[i["size"]] = [i["name"]]
		else:
			output[i["size"]].append(i["name"])
	return output
