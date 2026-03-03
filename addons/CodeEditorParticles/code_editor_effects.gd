@tool
class_name EditorParticleEffects extends EditorPlugin

var typing_particles_scene: PackedScene = load("res://addons/CodeEditorParticles/typing_particles.tscn")
var current_code_edit: CodeEdit
var code_edit_hash: String
var typing_particles_inst: GPUParticles2D

@export var enable_shake: bool = true
@export var RANDOM_SHAKE_STRENGTH: float = 20.0
# Multiplier for lerping the shake strength to zero
var SHAKE_DECAY_RATE: float = 40.0

var shake_strength: float = 0.0

func _enter_tree() -> void:
	EditorInterface.get_script_editor().editor_script_changed.connect(current_script_changed)
	
	current_script_changed(EditorInterface.get_script_editor().get_current_script())


func _process(delta: float) -> void:
	if !Engine.is_editor_hint(): return
	if enable_shake:
		if current_code_edit and current_code_edit.has_focus():
			shake_strength = lerp(shake_strength,0.0, SHAKE_DECAY_RATE * delta)
			
			var random_offset: = get_random_offset()
			if is_finite(random_offset.y) and is_finite(random_offset.x):
				current_code_edit.position = random_offset


func get_random_offset() -> Vector2:
	return Vector2( randf_range(-shake_strength, shake_strength), randf_range(-shake_strength, shake_strength))

func apply_shake() -> void:
	shake_strength = RANDOM_SHAKE_STRENGTH


func current_script_changed(scriptObj: Script) -> void:
	if EditorInterface.get_script_editor().get_current_editor():
		current_code_edit  = EditorInterface.get_script_editor().get_current_editor().get_base_editor()
		
		if current_code_edit.has_node("TypingParticles"):
			typing_particles_inst = current_code_edit.get_node("TypingParticles")
		else:
			typing_particles_inst = typing_particles_scene.instantiate()
			current_code_edit.add_child(typing_particles_inst)
		if current_code_edit:
			if !current_code_edit.gui_input.is_connected(handle_code_edit_input):
				current_code_edit.gui_input.connect(handle_code_edit_input)


func handle_code_edit_input(event: InputEvent) -> void:
	if event is InputEventKey && typing_particles_inst:
		var new_hash: = current_code_edit.text.sha256_text()
		if new_hash != code_edit_hash:
			code_edit_hash = new_hash
			event = event as  InputEventKey
			match event.keycode:
				KEY_BACKSPACE:
					typing_particles_inst.process_material.color = Color(0.91, 0.471, 0)
					typing_particles_inst.process_material.gravity.y = 500
				KEY_ENTER:
					return
				KEY_SHIFT:
					return
				KEY_ALT:
					return
				KEY_CTRL:
					return
				_:
					typing_particles_inst.process_material.color = Color("44dfec")
					typing_particles_inst.process_material.gravity.y = 0
					apply_shake()
			
			var caret_pos = current_code_edit.get_caret_draw_pos(0)
			if is_finite(caret_pos.x) and is_finite(caret_pos.y):
				if caret_pos > Vector2.ZERO and caret_pos < current_code_edit.size:
					typing_particles_inst.position = caret_pos
					typing_particles_inst.emitting = true
			else:
				printerr("caret_pos not valid, !is_finite(caret_pos) == true")


func _exit_tree() -> void:
	for editor in get_editor_interface().get_script_editor().get_open_script_editors():
		if editor.gui_input.is_connected(handle_code_edit_input):
			editor.get_base_editor().disconnect("gui_input", handle_code_edit_input)
		if editor.has_node("TypingParticles"):
			editor.get_node("TypingParticles").queue_free()
