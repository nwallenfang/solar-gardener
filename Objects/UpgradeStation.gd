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
	$Tween.interpolate_method(self, "interpolate_to_slot", 0.0, 1.0, 1.7)
	$Tween.start()
	Audio.play("upgrade")
	yield($Tween,"tween_all_completed")
	$ModelUstation.ring_whirl()
	yield(get_tree().create_timer(.6),"timeout")
	play_upgrade_flash()
	yield(get_tree().create_timer(1.4),"timeout")
	$Tween.interpolate_method(self, "interpolate_to_slot", 1.0, 0.0, 1.7)
	$Tween.start()
	yield($Tween,"tween_all_completed")
	Upgrades.ugrade_once()
	Game.game_state = Game.State.INGAME
	shed.set_upgrade_screen(Upgrades.get_upgrades_screen_text())
	if not Upgrades.is_upgrade_available():
		yield(get_tree().create_timer(1),"timeout")
		set_open(false)
	else:
		$Area/CollisionShape.disabled = true
		yield(get_tree().create_timer(1.2),"timeout")
		$Area/CollisionShape.disabled = false

const GROW_POP_PARTICLES = preload("res://Effects/GrowPopParticles.tscn")
const FLASH_OVERLAY = preload("res://Assets/Materials/FlashAlphaOverlay.tres")
func play_upgrade_flash():
	var meshes : Array = Utility.get_all_mesh_instance_children(target)
	for mi in meshes:
		mi.material_overlay = FLASH_OVERLAY
	$FlashTween.interpolate_property(FLASH_OVERLAY, "albedo_color:a", 0.0, 0.5, .3, Tween.TRANS_QUAD, Tween.EASE_IN)
	$FlashTween.start()
	yield($FlashTween,"tween_all_completed")
	var grow_pop_part := GROW_POP_PARTICLES.instance()
	add_child(grow_pop_part)
	grow_pop_part.global_translation = target.global_translation
	grow_pop_part.scale = Vector3.ONE * .4
	$FlashTween.interpolate_property(FLASH_OVERLAY, "albedo_color:a", 0.5, 0.0, .5, Tween.TRANS_QUAD, Tween.EASE_IN)
	$FlashTween.start()
	yield($FlashTween,"tween_all_completed")
	for mi in meshes:
		mi.material_overlay = null

func _ready():
	yield(get_tree().create_timer(.5),"timeout")
	Game.multitool.upgrade_station = self
	shed = get_parent()

func set_open(open: bool):
	$ModelUstation.set_open(open)
