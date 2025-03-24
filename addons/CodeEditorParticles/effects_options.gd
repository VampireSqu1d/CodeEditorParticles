class_name EffectsOptionsDock
extends Control

@export var typing_color: Color = Color.ROYAL_BLUE
@export var backspace_color: Color = Color.ORANGE_RED
@export var typing_color_gradient: GradientTexture1D

enum type_code {
	TYPING,
	BACKSPACE
}


func _process(delta: float) -> void:
	pass
