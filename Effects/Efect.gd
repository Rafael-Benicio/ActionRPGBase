extends AnimatedSprite

func _ready():
	connect("animation_finished",self,"_on_AnimatedSprite_animation_finished")
	play("animate")
	

func _on_AnimatedSprite_animation_finished():
	queue_free()
