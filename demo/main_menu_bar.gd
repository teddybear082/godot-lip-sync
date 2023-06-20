extends HBoxContainer

# Menu signals
signal menu_file_new
signal menu_file_open
signal menu_file_save
signal menu_file_save_as
signal menu_file_exit
signal menu_audio_microphone
signal menu_audio_microphone_loop
signal menu_audio_play_resource(name)
signal menu_audio_play_file
signal menu_audio_stop
signal menu_help_about

# Menu IDs
const FILE_NEW_ID := 100
const FILE_OPEN_ID := 101
const FILE_SAVE_ID := 102
const FILE_SAVE_AS_ID := 103
const FILE_EXIT_ID := 104
const AUDIO_MICROPHONE_ID := 210
const AUDIO_MICROPHONE_LOOP_ID := 211
const AUDIO_PLAY_NORTHWIND := 220
const AUDIO_PLAY_ALONE := 221
const AUDIO_PLAY_JABBERWOCKY := 222
const AUDIO_PLAY_ROAD := 223
const AUDIO_PLAY_FILE := 224
const AUDIO_STOP := 230
const HELP_ABOUT := 300


# Called when the node enters the scene tree for the first time.
func _ready():
	# Populate file menu
	$FileMenu.get_popup().add_item("New", FILE_NEW_ID, KEY_N | KEY_MASK_CTRL)
	$FileMenu.get_popup().add_item("Open", FILE_OPEN_ID, KEY_O | KEY_MASK_CTRL)
	$FileMenu.get_popup().add_item("Save", FILE_SAVE_ID, KEY_S | KEY_MASK_CTRL)
	$FileMenu.get_popup().add_item("Save As", FILE_SAVE_AS_ID, KEY_S | KEY_MASK_CTRL | KEY_MASK_ALT)
	$FileMenu.get_popup().add_separator()
	$FileMenu.get_popup().add_item("Exit", FILE_EXIT_ID, KEY_F4 | KEY_MASK_ALT)
	$FileMenu.get_popup().connect("id_pressed", Callable(self, "_on_menu_id_pressed"))

	# Add microphone sub-menu to audio menu
	var microphone_menu = PopupMenu.new()
	microphone_menu.name = "microphone_menu"
	microphone_menu.add_item("Listen", AUDIO_MICROPHONE_ID, KEY_M | KEY_MASK_ALT)
	microphone_menu.add_item("Loop-back", AUDIO_MICROPHONE_LOOP_ID, KEY_M | KEY_MASK_ALT | KEY_MASK_SHIFT)
	microphone_menu.connect("id_pressed", Callable(self, "_on_menu_id_pressed"))
	$AudioMenu.get_popup().add_child(microphone_menu)
	$AudioMenu.get_popup().add_submenu_item("Microphone", "microphone_menu")
	
	# Add play sub-menu to audio menu
	var play_menu = PopupMenu.new()
	play_menu.name = "play_menu"
	play_menu.add_item("North Wind", AUDIO_PLAY_NORTHWIND, KEY_1 | KEY_MASK_ALT)
	play_menu.add_item("Alone", AUDIO_PLAY_ALONE, KEY_2 | KEY_MASK_ALT)
	play_menu.add_item("Jabberwocky", AUDIO_PLAY_JABBERWOCKY, KEY_3 | KEY_MASK_ALT)
	play_menu.add_item("Road", AUDIO_PLAY_ROAD, KEY_4 | KEY_MASK_ALT)
	play_menu.add_item("Custom File...", AUDIO_PLAY_FILE, KEY_F | KEY_MASK_ALT)
	play_menu.connect("id_pressed", Callable(self, "_on_menu_id_pressed"))
	$AudioMenu.get_popup().add_child(play_menu)
	$AudioMenu.get_popup().add_submenu_item("Play", "play_menu")
	$AudioMenu.get_popup().add_item("Stop", AUDIO_STOP, KEY_S | KEY_MASK_ALT)
	$AudioMenu.get_popup().connect("id_pressed", Callable(self, "_on_menu_id_pressed"))

	# Populate help menu
	$HelpMenu.get_popup().add_item("About", HELP_ABOUT, KEY_F1)
	$HelpMenu.get_popup().connect("id_pressed", Callable(self, "_on_menu_id_pressed"))


func _on_menu_id_pressed(id: int):
	match id:
		FILE_NEW_ID:
			emit_signal("menu_file_new")

		FILE_OPEN_ID:
			emit_signal("menu_file_open")

		FILE_SAVE_ID:
			emit_signal("menu_file_save")

		FILE_SAVE_AS_ID:
			emit_signal("menu_file_save_as")

		FILE_EXIT_ID:
			emit_signal("menu_file_exit")

		AUDIO_MICROPHONE_ID:
			emit_signal("menu_audio_microphone")

		AUDIO_MICROPHONE_LOOP_ID:
			emit_signal("menu_audio_microphone_loop")

		AUDIO_PLAY_NORTHWIND:
			emit_signal(
				"menu_audio_play_resource",
				"res://assets/speeches/North_Wind_and_the_Sun.ogg")

		AUDIO_PLAY_ALONE:
			emit_signal(
				"menu_audio_play_resource",
				"res://assets/speeches/Alone_by_Edgar_Allan_Poe.ogg")

		AUDIO_PLAY_JABBERWOCKY:
			emit_signal(
				"menu_audio_play_resource",
				"res://assets/speeches/Jabberwocky-UK.ogg")

		AUDIO_PLAY_ROAD:
			emit_signal(
				"menu_audio_play_resource",
				"res://assets/speeches/The_Road_Not_Taken.ogg")

		AUDIO_PLAY_FILE:
			emit_signal("menu_audio_play_file")

		AUDIO_STOP:
			emit_signal("menu_audio_stop")

		HELP_ABOUT:
			emit_signal("menu_help_about")
