extends TabBar


## Last visemes matches
var _matches := []

## Last fingerprint
var _fingerprint := LipSyncFingerprint.new()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Populate the fingerprint
	_fingerprint.populate(LipSyncGlobals.speech_spectrum)

	# Calculate the matches
	LipSyncGlobals.file_data.match_visemes(_fingerprint, _matches)

	# Populate the bars
	for viseme in Visemes.VISEME.COUNT:
		var weight: float = _matches[viseme]
		var bar: TextureProgressBar = $GridContainer.get_child(viseme)
		bar.value = weight
