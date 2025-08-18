extends CharacterBody3D

var speed:int = 200
var direction:Vector3
@onready var label_name: Label3D = $Label3D
@onready var sync: MultiplayerSynchronizer = $MultiplayerSynchronizer


func _enter_tree():
	pass


func _ready() -> void:
	sync.set_multiplayer_authority(name.to_int())
	for player in GameManager.players.keys():
		if name == str(player):
			label_name.text = GameManager.players.get(player).get("name")
	#if sync.get_multiplayer_authority() == multiplayer.get_unique_id():
	#	print("im ",name)

	#label_name.text = GameManager.players.get(name)


func _physics_process(delta):
	if sync.get_multiplayer_authority() == multiplayer.get_unique_id():
		walk(delta)
		move_and_slide()

func _process(delta: float) -> void:
	pass

func walk(delta):
	direction = transform.basis * Vector3(Input.get_axis("left", "right"), 0, Input.get_axis("forward", "back")).normalized()
	velocity.x = direction.x * speed * delta
	velocity.z = direction.z * speed * delta
