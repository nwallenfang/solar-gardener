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

func switch_to_tool(new_tool: int):
	current_tool = new_tool
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
