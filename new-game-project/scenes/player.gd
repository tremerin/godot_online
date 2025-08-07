extends CharacterBody3D

var speed:int = 200
var direction:Vector3

func _enter_tree():
	set_multiplayer_authority(name.to_int())

func _physics_process(delta):
	if !is_multiplayer_authority(): return
	walk(delta)
	move_and_slide() 

func walk(delta):
	direction = transform.basis * Vector3(Input.get_axis("left", "right"), 0, Input.get_axis("forward", "back")).normalized()
	velocity.x = direction.x * speed * delta
	velocity.z = direction.z * speed * delta
