extends Spatial

func set_text(text: String):
	$Screen/Screen2D.set_text(text)

func _ready():
	$AnalyseScreen/ScannerHoloNeedsMet.quad = $HoloQuad2
