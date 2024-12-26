extends Area3D

const ROT_SPEED = 2 # Number of Degrees the coin rotates
@export var hud : CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotate_y(deg_to_rad(ROT_SPEED))



func _on_body_entered(body: Node3D) -> void:
	# Modify collision layer/mask correctly for interaction
	Global.coins += 1
	hud.get_node("CoinsLabel").text = str(Global.coins)
	if Global.coins >= Global.NUM_COINS:
		get_tree().change_scene_to_file("res://level_1.tscn")
		
	set_collision_layer_value(2, true)
	set_collision_mask_value(1, true) 

	# Play the animation and queue the coin to be freed once the animation finishes
	$AnimationPlayer.play("coinbounce")

	#

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()  # Free the coin when the animation finishes
