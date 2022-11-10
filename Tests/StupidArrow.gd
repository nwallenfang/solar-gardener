extends Spatial

func point(dir: Vector3):
	$Pointer.global_translation = $MeshInstance.global_translation + dir.normalized()
