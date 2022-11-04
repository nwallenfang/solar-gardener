extends Spatial

enum TOOL {NONE, PLANT, MOVE, ANALYSIS, BUILD}
var current_tool := 0

func _physics_process(delta):
	if Input.is_action_just_pressed("tool1") and not current_tool == TOOL.PLANT:
		switch_to_tool(TOOL.PLANT)
	if Input.is_action_just_pressed("tool2") and not current_tool == TOOL.MOVE:
		switch_to_tool(TOOL.MOVE)
	if Input.is_action_just_pressed("tool3") and not current_tool == TOOL.ANALYSIS:
		switch_to_tool(TOOL.ANALYSIS)
	if Input.is_action_just_pressed("tool4") and not current_tool == TOOL.BUILD:
		switch_to_tool(TOOL.BUILD)
	if Input.is_action_just_pressed("first_action"):
		process_first_action()
	if Input.is_action_just_pressed("second_action"):
		process_first_action()
	check_on_hover()

# Collision masks
# 0 - Collision
# 1 - Gravity
# 2 - Analysis
# 3 - Bad Planting
# 4 - Moveable

func switch_to_tool(new_tool: int):
	current_tool = new_tool
	match current_tool:
		TOOL.NONE:
			pass
		TOOL.PLANT:
			Game.player_raycast.set_collision_mask_bit(0, true)
			Game.player_raycast.set_collision_mask_bit(1, false)
			Game.player_raycast.set_collision_mask_bit(2, false)
			Game.player_raycast.set_collision_mask_bit(3, false)
			Game.player_raycast.set_collision_mask_bit(4, false)
		TOOL.MOVE:
			Game.player_raycast.set_collision_mask_bit(0, false)
			Game.player_raycast.set_collision_mask_bit(1, false)
			Game.player_raycast.set_collision_mask_bit(2, false)
			Game.player_raycast.set_collision_mask_bit(3, false)
			Game.player_raycast.set_collision_mask_bit(4, true)
		TOOL.ANALYSIS:
			Game.player_raycast.set_collision_mask_bit(0, false)
			Game.player_raycast.set_collision_mask_bit(1, false)
			Game.player_raycast.set_collision_mask_bit(2, true)
			Game.player_raycast.set_collision_mask_bit(3, false)
			Game.player_raycast.set_collision_mask_bit(4, false)
		TOOL.BUILD:
			pass

func process_first_action():
	match current_tool:
		TOOL.NONE:
			pass
		TOOL.PLANT:
			pass
		TOOL.MOVE:
			pass
		TOOL.ANALYSIS:
			pass
		TOOL.BUILD:
			pass

func process_second_action():
	match current_tool:
		TOOL.NONE:
			pass
		TOOL.PLANT:
			pass
		TOOL.MOVE:
			pass
		TOOL.ANALYSIS:
			pass
		TOOL.BUILD:
			pass

func check_on_hover():
	Game.player_raycast
	match current_tool:
		TOOL.NONE:
			pass
		TOOL.PLANT:
			pass
		TOOL.MOVE:
			pass
		TOOL.ANALYSIS:
			pass
		TOOL.BUILD:
			pass

func show_plantable(b: bool):
	print(b)
