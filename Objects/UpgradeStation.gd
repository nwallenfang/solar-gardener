extends Spatial
class_name UpgradeStation

var shed: Spatial

var target: Spatial
var temp_placeholder: Spatial
func setup_slot_interpolation(_target: Spatial):
	target = _target
	if temp_placeholder == null:
		temp_placeholder = Spatial.new()
		target.get_parent().add_child(temp_placeholder)
	temp_placeholder.global_transform = target.global_transform

func interpolate_to_slot(x: float):
	if is_instance_valid(target) and is_instance_valid(temp_placeholder):
		target.global_transform.basis = temp_placeholder.global_transform.basis.slerp($Slot.global_transform.basis, x)

func upgrade():
	shed.set_upgrade_screen("Upgrading the\nYardintool...")
	Game.game_state = Game.State.INTRO_FLIGHT
	$Tween.interpolate_method(self, "interpolate_to_slot", 0.0, 1.0, 1.0)
	$Tween.start()
	yield($Tween,"tween_all_completed")
	# TODO Animation Particles
	$Tween.interpolate_method(self, "interpolate_to_slot", 1.0, 0.0, 1.0)
	$Tween.start()
	yield($Tween,"tween_all_completed")
	Upgrades.ugrade_once()
	Game.game_state = Game.State.INGAME
	shed.set_upgrade_screen(Upgrades.get_upgrades_screen_text())

func _ready():
	yield(get_tree().create_timer(.5),"timeout")
	Game.multitool.upgrade_station = self
	shed = get_parent()
