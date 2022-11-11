extends Control

onready var current_toolbar_item: Node = $HBoxContainer/ToolbarItem1

func switch_to(new_tool: int):
	if new_tool == Game.multitool.TOOL.NONE or new_tool == Game.multitool.TOOL.HOPPER:
		# tools that aren't on the toolbar
		if current_toolbar_item != null:
			current_toolbar_item.active = false
			current_toolbar_item = null
		
		return
		
	var new_toolbar_item = get_node("HBoxContainer/ToolbarItem" + str(new_tool))
#	var prev_toolbar_item = get_node("HBoxContainer/ToolbarItem")
	
	if current_toolbar_item != null:
		current_toolbar_item.active = false
		
	new_toolbar_item.active = true
	current_toolbar_item = new_toolbar_item

func activate_tool(new_tool):
	if new_tool == Game.multitool.TOOL.NONE or new_tool == Game.multitool.TOOL.HOPPER:
		return
	var new_toolbar_item = get_node("HBoxContainer/ToolbarItem" + str(new_tool))
	new_toolbar_item.visible = true
