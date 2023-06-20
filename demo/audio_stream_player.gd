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
	var data = file.get_buffer(file.get_length())
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
	elif file_name.ends_with(".wav"):
		var wav_formatting : Array = _check_wav_format(data)  # Format of returned array is format code, sample rate, channel number
		var wav_stream = AudioStreamWAV.new()
		wav_stream.data = data
		wav_stream.format = wav_formatting[0]#AudioStreamWAV.FORMAT_16_BITS
		wav_stream.mix_rate = wav_formatting[1]#22050
		if wav_formatting[2] == 2:
			wav_stream.stereo = true
		else:
			wav_stream.stereo = false
		wav_stream.loop_mode = AudioStreamWAV.LOOP_DISABLED
		_play_stream(wav_stream, false)

func _play_stream(audio_stream: AudioStream, mute_bus: bool):
	# Stop any current playback
	stop()

	# Set the stream and bus mute
	stream = audio_stream
	AudioServer.set_bus_mute(LipSyncGlobals.speech_bus, mute_bus)
	
	# Play the stream
	play()

# Code to check .wav file formatting; code is adapted from https://github.com/Gianclgar/GDScriptAudioImport/blob/master/GDScriptAudioImport.gd
func _check_wav_format(data):
	var bits_per_sample = 0
	var format_code
	var format_name
	var sample_rate
	var channel_num

	for i in range(0, 100):
		var those4bytes = str(char(data[i])+char(data[i+1])+char(data[i+2])+char(data[i+3]))
		
		if those4bytes == "RIFF": 
			print ("RIFF OK at bytes " + str(i) + "-" + str(i+3))
			#RIP bytes 4-7 integer for now
		if those4bytes == "WAVE": 
			print ("WAVE OK at bytes " + str(i) + "-" + str(i+3))

		if those4bytes == "fmt ":
			print ("fmt OK at bytes " + str(i) + "-" + str(i+3))
			
			#get format subchunk size, 4 bytes next to "fmt " are an int32
			var formatsubchunksize = data[i+4] + (data[i+5] << 8) + (data[i+6] << 16) + (data[i+7] << 24)
			print ("Format subchunk size: " + str(formatsubchunksize))
			
			#using formatsubchunk index so it's easier to understand what's going on
			var fsc0 = i+8 #fsc0 is byte 8 after start of "fmt "

			#get format code [Bytes 0-1]
			format_code = data[fsc0] + (data[fsc0+1] << 8)
			if format_code == 0: format_name = "8_BITS"
			elif format_code == 1: format_name = "16_BITS"
			elif format_code == 2: format_name = "IMA_ADPCM"
			else: 
				format_name = "UNKNOWN (trying to interpret as 16_BITS)"
				format_code = 1
			print ("Format: " + str(format_code) + " " + format_name)

			
			#get channel num [Bytes 2-3]
			channel_num = data[fsc0+2] + (data[fsc0+3] << 8)
			print ("Number of channels: " + str(channel_num))
			
			#get sample rate [Bytes 4-7]
			sample_rate = data[fsc0+4] + (data[fsc0+5] << 8) + (data[fsc0+6] << 16) + (data[fsc0+7] << 24)
			print ("Sample rate: " + str(sample_rate))

			
	return [format_code, sample_rate, channel_num]
