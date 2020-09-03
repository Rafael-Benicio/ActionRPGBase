extends KinematicBody2D

const EnemieDeathEffect=preload("res://Effects/EnemieDeathEffect.tscn")

var velocity=Vector2.ZERO
var knockBack= Vector2.ZERO

onready var stats=$Stats
onready var sprites=$animatedBat
onready var playerDZ=$PlayerDetectionZone
onready var hurtbox=$Hurtbox
onready var softCollision=$SoftCollision
onready var wanderController=$WanderController
onready var animationPlayer=$AnimationPlayer
export(int) var ACCELERATION=300
export(int) var MAX_SPEED=50
export(int) var FRICTION=200
export(int) var WANDER_TARGET_RANGE=4

enum{
	IDLE,
	WANDER,
	CHASE
}

var state=CHASE

func _ready():
	state=pick_random_state([IDLE,WANDER])
	
func _physics_process(delta):
	knockBack=knockBack.move_toward(Vector2.ZERO, FRICTION*delta)
	knockBack=move_and_slide(knockBack)


	match state:
		IDLE:
			velocity=velocity.move_toward(Vector2.ZERO,FRICTION*delta)
			seek_player()
			if wanderController.get_time_left() ==0:
				update_wander()
		WANDER:
			seek_player()
			if wanderController.get_time_left() ==0:
				update_wander()
				
			acceleration_toward_poit(wanderController.target_position,delta)
			
			if global_position.distance_to(wanderController.target_position) <= WANDER_TARGET_RANGE:
				update_wander()
				
		CHASE:
			var player=playerDZ.player
			if player !=null:
				acceleration_toward_poit(player.global_position,delta)

			else:
				state=IDLE
			
	if softCollision.is_colliding():
		velocity+=softCollision.get_push_vector() *delta*400
	velocity=move_and_slide(velocity)

func acceleration_toward_poit(point,delta):		
	var direction =global_position.direction_to(point)
	velocity=velocity.move_toward(MAX_SPEED * direction,ACCELERATION* delta)
	sprites.flip_h=velocity.x<0

func update_wander():
	state=pick_random_state([IDLE,WANDER])
	wanderController.start_wander_timer(rand_range(1,3))

func seek_player():
	if playerDZ.can_see_player():
		state=CHASE
		
func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()
func _on_Hurtbox_area_entered(area):
	stats.health-=area.damege
	knockBack= area.knockBack_vector * 200
	hurtbox.create_hit_effect()
	hurtbox.started_invincibility(0.4)

func _on_Stats_no_health():
	queue_free()
	var enemieDeathEffect=EnemieDeathEffect.instance()
	get_parent().add_child(enemieDeathEffect)
	enemieDeathEffect.global_position=global_position



func _on_Hurtbox_invincibility_started():
	animationPlayer.play("Start")


func _on_Hurtbox_invincibility_ended():
	animationPlayer.play("Stop")
