extends AudioStreamPlayer



# Called when the node enters the scene tree for the first time.
func _ready():
	# Get the speech audio bus
	var bus := AudioServer.get_bus_index("Speech")
	LipSyncGlobals.speech_bus = bus

	# Get the speech spectrum analyzer
	for i in AudioServer.get_bus_effect_count(bus):
		var effect := AudioServer.get_bus_effect(bus, i) as AudioEffectSpectrumAnalyzer
		if effect:
			LipSyncGlobals.speech_spectrum = AudioServer.get_bus_effect_instance(bus, i)
			break


func play_microphone():
	_play_stream(AudioStreamMicrophone.new(), true)

func play_microphone_loop():
	_play_stream(AudioStreamMicrophone.new(), false)

func play_resource(name: String):
	_play_stream(load(name), false)

func play_file(file_name: String):
	# Load the file
	var file = FileAccess.open(file_name, FileAccess.READ)
	var data = file.get_buffer(file.get_len())
	file.close()

	# Play the stream
	if file_name.ends_with(".ogg"):
		var ogg_stream = AudioStreamOggVorbis.new()
		ogg_stream.data = data
		ogg_stream.loop = true
		_play_stream(ogg_stream, false)
	elif file_name.ends_with(".mp3"):
		var mp3_stream = AudioStreamMP3.new()
		mp3_stream.data = data
		mp3_stream.loop = true
		_play_stream(mp3_stream, false)

func _play_stream(audio_stream: AudioStream, mute_bus: bool):
	# Stop any current playback
	stop()

	# Set the stream and bus mute
	stream = audio_stream
	AudioServer.set_bus_mute(LipSyncGlobals.speech_bus, mute_bus)
	
	# Play the stream
	play()
