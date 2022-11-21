extends Control


var journal_unlocked = false
var guide_tab_active = true setget set_guide_tab_active

export var modulate_disabled: Color = Color("828282")
export var self_modulate_disabled: Color = Color("5d5d5d")
export var mod_enabled: Color = Color.white


func show():
	self.visible = true
	if not guide_tab_active and journal_unlocked:
		$JournalUI.show()
	
	
func hide():
	self.visible = false
	$JournalUI.hide()


func unlock_journal():
	$JournalTabSelector.hint_tooltip = ""
	journal_unlocked = true
	self.guide_tab_active = false


func _on_JournalTabSelector_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		event = event as InputEventMouseButton
		if event.pressed and event.button_index == BUTTON_LEFT:
			if journal_unlocked:
				set_guide_tab_active(false)

func _on_GuideTabSelector_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		event = event as InputEventMouseButton
		if event.pressed and event.button_index == BUTTON_LEFT:
			set_guide_tab_active(true)

func set_guide_tab_active(guide_active):
	if not guide_active:
		$JournalUI.visible = true
		$Guide.visible = false
		$GuideTabSelector.modulate = modulate_disabled
		$GuideTabSelector.self_modulate = self_modulate_disabled
		$JournalTabSelector.modulate = mod_enabled
		$JournalTabSelector.self_modulate = mod_enabled
	else:
		print("guide click")
		$JournalUI.visible = false
		$Guide.visible = true
		$JournalTabSelector.modulate = modulate_disabled
		$JournalTabSelector.self_modulate = self_modulate_disabled
		$GuideTabSelector.modulate = mod_enabled
		$GuideTabSelector.self_modulate = mod_enabled

	guide_tab_active = guide_active
