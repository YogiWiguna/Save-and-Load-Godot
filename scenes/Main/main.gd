extends Node2D

const SAVE_DIR = "user://saves/"
const SAVE_FILE_NAME = "save.save"
# Dont Put the security key on the same place with
# your save and load functions 
const SECUITY_KEY = "09jja91A"

# Calling the PlayerData class (Resource) 
var player_data = PlayerData.new()

func _ready():
	verify_save_directory(SAVE_DIR)


func verify_save_directory(path : String):
	# make_dir_absolute : Static version of make_dir(). Supports only absolute paths.
	DirAccess.make_dir_absolute(path)

func save_data(path: String):
	var file = FileAccess.open_encrypted_with_pass(path, FileAccess.WRITE, SECUITY_KEY)
	if file == null:
		# Returns the result of the last open() call in the current thread.
		print(FileAccess.get_open_error())
		return
	
	var data = {
		"player_data" : {
			"health" : player_data.health,
			"global_position" : {
				# Using the x and y for the VECTOR 2
				'x' : player_data.global_position.x,
				'y' : player_data.global_position.y
			},
			"coins": player_data.coins
		}
	}
	
	# Convert "data" into string on JSON using the stringify
	# "\t" seperator Tab ( making a new line)
	var json_string = JSON.stringify(data, "\t")
	
	# Save the json_string into "file"
	file.store_string(json_string)
	file.close()
	

func load_data(path: String):
	if FileAccess.file_exists(path):
		var file = FileAccess.open_encrypted_with_pass(path, FileAccess.READ, SECUITY_KEY)
		# Checking if the file is null
		if file == null:
			print(FileAccess.get_open_error())
			return
		
		# Returns the whole file as a String with get_as_text()
		var content = file.get_as_text()
		file.close()
		
		# Attempts to parse the json_string provided and returns 
		# the parsed data. Returns null if parse failed 
		var data = JSON.parse_string(content)
		if data == null:
			printerr("Cannot parse %s as json_string: (%s)" % [path, content])
			return
		
		# Load the "data" string from save json file, make a new PlayerData to  
		# contain the data of player_data from the "data" json file
		player_data = PlayerData.new()
		player_data.health = data.player_data.health
		player_data.global_position = Vector2(data.player_data.global_position.x, data.player_data.global_position.y)
		player_data.coins = data.player_data.coins
		
	else:
		# Prints one or more arguments to strings in the best way possible to standard error line
		printerr("Cannot open non-existent file at %s" % [path])
	
	
	
func _on_save_pressed():
	save_data(SAVE_DIR + SAVE_FILE_NAME)

func _on_load_pressed():
	load_data(SAVE_DIR + SAVE_FILE_NAME)

