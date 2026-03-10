# MIT License
# 
# Copyright (c) 2022 Lincoln Bryant
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

@tool
extends VBoxContainer

const LPCBuilder = preload("res://addons/lpc_to_godot/lpc_builder.gd")

var spritesheet_path: String
var output_file: String

# Signal handlers
func _on_FilePath_pressed():
	var dialog = $FileDialog
	dialog.popup_centered()


func _on_OutputDirPath_pressed():
	var dialog = $OutputDialog
	dialog.popup_centered()


func _on_GenerateFrames_pressed():
	spritesheet_path = $SpritePath/Value.text
	output_file = $OutputPath/Value.text
	new_sprite()


func _on_FileDialog_file_selected(path: String):
	$SpritePath/Value.text = path


func _on_OutputDialog_file_selected(path: String):
	$OutputPath/Value.text = path


func _on_OutputDialog_dir_selected(path: String):
	if output_file.is_empty():
		$OutputPath/Value.text = "%s/sprite_frames.tres" % path
	else:
		$OutputPath/Value.text = output_file


# Internal functions
func show_dialog(dialog_title: String, msg: String):
	var dialog = $WarnDialog
	dialog.title = dialog_title
	dialog.dialog_text = msg
	dialog.popup_centered()

func new_sprite():
	var frames := LPCBuilder.generate_sprite_frames(
		spritesheet_path,
		{
			"cast_frames": int($CastFrames/Value.value),
			"thrust_frames": int($ThrustFrames/Value.value),
			"idle_frames": int($IdleFrames/Value.value),
			"walk_frames": int($WalkFrames/Value.value),
			"slash_frames": int($SlashFrames/Value.value),
			"shoot_frames": int($ShootFrames/Value.value),
			"hurt_frames": int($HurtFrames/Value.value),
			"framerate": int($Framerate/Value.value),
		}
	)
	if frames == null:
		show_dialog("LTG Error", "Failed to load the selected spritesheet.")
		return

	if output_file.is_empty():
		show_dialog("LTG Output", "No output file selected. Generated SpriteFrames in memory only.")
		return

	var save_error := LPCBuilder.save_sprite_frames(output_file, frames)
	if save_error != OK:
		show_dialog("LTG Error", "Failed to save SpriteFrames: %s" % save_error)
