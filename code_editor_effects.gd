@tool
extends EditorPlugin

var typing_particles_scene: PackedScene = load("res://addons/CodeEditorParticles/typing_particles.tscn")
var current_code_edit: CodeEdit
var typing_particles_inst: GPUParticles2D


func _enter_tree() -> void:
	EditorInterface.get_script_editor().editor_script_changed.connect(current_script_changed)
	
	current_script_changed(EditorInterface.get_script_editor().get_current_script())


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
		#else: 
			#printerr("was not able to get the code editor :c")


func handle_code_edit_input(event: InputEvent) -> void:
	if event is InputEventKey && typing_particles_inst:
		var caret_pos = current_code_edit.get_caret_draw_pos(0)
		typing_particles_inst.position = caret_pos
		typing_particles_inst.emitting = true


func material_color_change(new_color: Color, particle_type: EffectsOptionsDock.type_code) -> void:
	pass


func _exit_tree() -> void:
	for editor in get_editor_interface().get_script_editor().get_open_script_editors():
		if editor.gui_input.is_connected(handle_code_edit_input):
			editor.get_base_editor().disconnect("gui_input", handle_code_edit_input)
