extends Spatial
class_name UpgradeStation

var shed: Spatial

var target: Spatial
var temp_placeholder: Spatial
var old_scale_factor: float
var new_scale_factor: float
func setup_slot_interpolation(_target: Spatial):
	target = _target
	if temp_placeholder == null:
		temp_placeholder = Spatial.new()
		target.get_parent().add_child(temp_placeholder)
	temp_placeholder.global_transform = target.global_transform
	old_scale_factor = temp_placeholder.scale.x
	new_scale_factor = $Slot.scale.x

func interpolate_to_slot(x: float):
	if is_instance_valid(target) and is_instance_valid(temp_placeholder):
		target.global_transform.basis = temp_placeholder.global_transform.basis.orthonormalized().slerp($Slot.global_transform.basis.orthonormalized(), x)
		target.global_translation = lerp(temp_placeholder.global_translation, $Slot.global_translation, x)
		target.scale = Vector3.ONE * lerp(old_scale_factor, new_scale_factor, x)

func upgrade():
	shed.set_upgrade_screen("Upgrading\nthe\nYardintool...")
	Game.game_state = Game.State.UPGRADING
	setup_slot_interpolation(Game.multitool.get_node("ModelMultitool"))
	$Tween.interpolate_method(self, "interpolate_to_slot", 0.0, 1.0, 2.0)
	$Tween.start()
	yield($Tween,"tween_all_completed")
	# TODO Animation Particles
	yield(get_tree().create_timer(1),"timeout")
	$Tween.interpolate_method(self, "interpolate_to_slot", 1.0, 0.0, 2.0)
	$Tween.start()
	yield($Tween,"tween_all_completed")
	Upgrades.ugrade_once()
	Game.game_state = Game.State.INGAME
	shed.set_upgrade_screen(Upgrades.get_upgrades_screen_text())

func _ready():
	yield(get_tree().create_timer(.5),"timeout")
	Game.multitool.upgrade_station = self
	shed = get_parent()
