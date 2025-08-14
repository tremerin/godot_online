extends CharacterBody3D

var speed:int = 200
var direction:Vector3
@onready var label_name: Label3D = $Label3D

func _enter_tree():
	pass
	
func _ready() -> void:
	label_name.text = "ID:" + name
	position.x = 0
	position.z = 0

func _physics_process(delta):
	walk(delta)
	move_and_slide()

func _process(delta: float) -> void:
	pass

func walk(delta):
	direction = transform.basis * Vector3(Input.get_axis("left", "right"), 0, Input.get_axis("forward", "back")).normalized()
	velocity.x = direction.x * speed * delta
	velocity.z = direction.z * speed * delta
