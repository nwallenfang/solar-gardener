extends RayCast
class_name PlayerRayCast

#func cast_to_global_position(pos: Vector3):
#	cast_to = to_local(pos)
#	force_raycast_update()

var colliding: bool
var collider: Object# = ray.get_collider().get_parent()
var hit_point: Vector3# = ray.get_collision_point()
var hit_normal: Vector3# = ray.get_collision_normal()

func do_cast():
	cast_to = Vector3(0,0,-100000)
	force_raycast_update()
	colliding = is_colliding()
	collider = get_collider()
	if collider is Area:
		collider = collider.get_parent()
	hit_point = get_collision_point()
	hit_normal = get_collision_normal()
