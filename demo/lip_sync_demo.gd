extends Control


## UI actions needing user confirmation
enum CONFIRM_ACTION {
	None,		# None
	New,		# Current file modified, and user selects file/new
	Open,		# Current file modified, and user selects file/open
	Exit		# Current file modified, and user selects file/exit
}




## File action (after confirmation)
var confirm_action: int = CONFIRM_ACTION.None


# Called when the node enters the scene tree for the first time.
func _ready():
	# Disable default quit (so we can warn about data loss)
	get_tree().set_auto_accept_quit(false)

	# Connect file state changed
	LipSyncGlobals.connect("file_state_changed", Callable(self, "_on_file_state_changed"))

	# Connect main menu signals
	$MainMenuBar.connect("menu_file_new", Callable(self, "_on_file_new"))
	$MainMenuBar.connect("menu_file_open", Callable(self, "_on_file_open"))
	$MainMenuBar.connect("menu_file_save", Callable(self, "_on_file_save"))
	$MainMenuBar.connect("menu_file_save_as", Callable(self, "_on_file_save_as"))
	$MainMenuBar.connect("menu_file_exit", Callable(self, "_on_file_exit"))
	$MainMenuBar.connect("menu_audio_microphone", Callable(self, "_on_audio_microphone"))
	$MainMenuBar.connect("menu_audio_microphone_loop", Callable(self, "_on_audio_microphone_loop"))
	$MainMenuBar.connect("menu_audio_play_resource", Callable(self, "_on_audio_play_resource"))
	$MainMenuBar.connect("menu_audio_play_file", Callable(self, "_on_audio_play_file"))
	$MainMenuBar.connect("menu_audio_stop", Callable(self, "_on_audio_stop"))
	$MainMenuBar.connect("menu_help_about", Callable(self, "_on_help_about"))

	# Update the window title
	_on_file_state_changed()


## Handle for user trying to close application
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_on_file_exit()


## Handler for user selecting file/new menu item
func _on_file_new():
	if LipSyncGlobals.file_modified:
		# Confirm data-loss before proceeding
		confirm_action = CONFIRM_ACTION.New
		$ConfirmProceedDialog.popup()
	else:
		# Create new file
		LipSyncGlobals.new_file()


## Handler for user selecting file/open menu item
func _on_file_open():
	if LipSyncGlobals.file_modified:
		# Confirm data-loss before proceeding
		confirm_action = CONFIRM_ACTION.Open
		$ConfirmProceedDialog.popup()
	else:
		# Show the load dialog
		$LoadTrainingFileDialog.popup()


## Handler for user selecting file/save menu item
func _on_file_save():
	if LipSyncGlobals.file_name == "":
		# No file-name - Show save-as popup
		$SaveAsTrainingFileDialog.popup()
	else:
		# Save the file
		LipSyncGlobals.save_file()


## Handler for user selecting file/save-as menu item
func _on_file_save_as():
	# Show save-as popup
	$SaveAsTrainingFileDialog.popup()


## Handler for user selecting file/exit menu item
func _on_file_exit():
	if LipSyncGlobals.file_modified:
		# Confirm data-loss before proceeding
		confirm_action = CONFIRM_ACTION.Exit
		$ConfirmProceedDialog.popup()
	else:
		# Quit the application
		get_tree().quit()


## Handler for user selecting audio/microphone/listen menu item
func _on_audio_microphone():
	$AudioStreamPlayer.play_microphone()


## Handler for user selecting audio/microphone/loop-back menu item
func _on_audio_microphone_loop():
	$AudioStreamPlayer.play_microphone_loop()


## Handler for user selecting audio/play/<embedded-resource> menu item
func _on_audio_play_resource(name: String):
	$AudioStreamPlayer.play_resource(name)


## Handler for user selecting audio/play/file menu item
func _on_audio_play_file():
	$AudioFileDialog.popup()


## Handler for user selecting audio/stop menu item
func _on_audio_stop():
	$AudioStreamPlayer.stop()


## Handler for user selecting help/about
func _on_help_about():
	$AboutDialog.popup()


## User has confirmed pending action
func _on_ConfirmProceedDialog_confirmed():
	match confirm_action:
		CONFIRM_ACTION.New:
			# User confirms new - do new file
			LipSyncGlobals.new_file()
		
		CONFIRM_ACTION.Open:
			# User confirms open - show load dialog
			$LoadTrainingFileDialog.popup()
		
		CONFIRM_ACTION.Exit:
			# User confirms exit - quit application
			get_tree().quit()


## User has confirmed file in load dialog
func _on_LoadTrainingFileDialog_file_selected(path):
	LipSyncGlobals.load_file(path)


## User has confirmed file in save dialog
func _on_SaveAsTrainingFileDialog_file_selected(path):
	LipSyncGlobals.save_file_as(path)


## User has selected file in audio file dialog
func _on_AudioFileDialog_file_selected(path):
	$AudioStreamPlayer.play_file(path)


## Handle file state changed
func _on_file_state_changed():
	DisplayServer.window_set_title("Godot LipSync Training: " + LipSyncGlobals.file_display_name())
