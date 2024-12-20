extends RigidBody3D

##How much vertical thrust to apply when moving
@export_range(750, 3000) var thrust: float = 1000.0

##How much force to apply to rotations
@export_range(50, 200) var torque_thrust: float = 100

var is_transitioning: bool = false; 

@onready var success_audio: AudioStreamPlayer = $SuccessAudio
@onready var explosion_audio: AudioStreamPlayer = $ExplosionAudio
@onready var rocket_audio: AudioStreamPlayer3D = $RocketAudio
@onready var booster_particles: GPUParticles3D = $BoosterParticles
@onready var booster_particles_left: GPUParticles3D = $BoosterParticles_left
@onready var booster_particles_right: GPUParticles3D = $BoosterParticles_right
@onready var explosion_particles: GPUParticles3D = $ExplosionParticles
@onready var success_particles: GPUParticles3D = $SuccessParticles

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("boost"):
		apply_central_force(basis.y * delta * thrust)
		booster_particles.emitting = true
		if !rocket_audio.playing:
			rocket_audio.play()
	else:
		rocket_audio.stop()
		booster_particles.emitting = false
	
	if Input.is_action_pressed("rotate_left"):
		apply_torque(Vector3(0.0, 0.0, torque_thrust) * delta)
		booster_particles_right.emitting = true
	else:
		booster_particles_right.emitting = false
	
	if Input.is_action_pressed("rotate_right"):
		apply_torque(Vector3(0.0, 0.0, -torque_thrust) * delta)
		booster_particles_left.emitting = true
	else:
		booster_particles_left.emitting = false


func _on_body_entered(body: Node) -> void:
	if(!is_transitioning):
		booster_particles_left.emitting = false
		booster_particles_right.emitting = false
		booster_particles.emitting = false
		rocket_audio.stop()
		if("Goal" in body.get_groups()):
			complete_level(body.file_path)
			
		if("Hazard" in body.get_groups()):
			crash_sequence()

func crash_sequence() -> void:
	print("KABOOM!")
	explosion_audio.play()
	explosion_particles.emitting = true
	set_process(false) #disables _process function
	is_transitioning = true
	var tween = create_tween()
	tween.tween_interval(2.5)
	tween.tween_callback(get_tree().reload_current_scene)
	
func complete_level(next_level_file: String) -> void:
	print("Yer a winner")
	success_audio.play()
	success_particles.emitting = true
	set_process(false) #disables _process function
	is_transitioning = true
	var tween = create_tween()
	tween.tween_interval(2.5)
	tween.tween_callback(get_tree().change_scene_to_file.bind(next_level_file))
	
