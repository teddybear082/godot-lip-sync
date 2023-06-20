extends TabBar


## Last phoneme matches
var _matches := []

## Last fingerprint
var _fingerprint := LipSyncFingerprint.new()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Populate the fingerprint
	_fingerprint.populate(LipSyncGlobals.speech_spectrum)

	# Calculate the matches
	LipSyncGlobals.file_data.match_phonemes(_fingerprint, _matches)

	# Populate the bars
	for phoneme in Phonemes.PHONEME.COUNT:
		var deviation: float = _matches[phoneme]
		var value := 0.0 if deviation < 0.0 else 1.0 - deviation
		var bar: TextureProgressBar = $GridContainer.get_child(phoneme)
		bar.value = value
