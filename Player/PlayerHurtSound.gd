extends AudioStreamPlayer2D

func _ready():
	connect("finished" ,self,"queue_free")
