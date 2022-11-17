extends Node

class Event:
	var key: String
	var object: Node
	var function_name: String
	var just_once: bool
	var skip_immediately: bool
	var execute_count := 0
	
	func _init(_key: String, _object: Node, _function_name: String, _just_once: bool = true, _skip: bool = false):
		key = _key
		object = _object
		function_name = _function_name
		just_once = _just_once
		skip_immediately = _skip

var events := []
func get_event_from_key(key: String) -> Event:
	for e in events:
		if e.key == key:
			return e
	printerr("Event not found " + key)
	return null

var event_queue := []
func trigger(key: String):
	var event = get_event_from_key(key)
	if event == null:
		return
	if event.skip_immediately:
		execute_event(event)
		return
	if not key in event_queue:  # so multiple triggers don't mess this whole system up
		event_queue.append(key)
	if event_queue.size() == 1:
		execute_event(event_queue[0])

func execute_event(key: String):
	var event := get_event_from_key(key)
	if event.execute_count == 0 or (not event.just_once):
		event.execute_count += 1
		event.object.call(event.function_name)
		if event.skip_immediately:
			next()
	else:
		next()

func next():
	if event_queue.size() > 0:
		var popped_event = event_queue.pop_front()
		print("popped ", popped_event)
	if not event_queue.empty():
		execute_event(event_queue[0])

###########
# SETUP
###########

func setup():
	events.append(Event.new("test", self, "test"))
	# just once: amber_collected_tutorial
	events.append(Event.new("tutorial_seed_planted", self, "tutorial_seed_planted", true))
	events.append(Event.new("tutorial_amber_collected", self, "tutorial_amber_collected", true))
	events.append(Event.new("tutorial_plant_reached_stage1", self, "tutorial_plant_reached_stage1", true))
	events.append(Event.new("tutorial_plant_scanned", self, "tutorial_plant_scanned", true))
	events.append(Event.new("tutorial_growth_reached", self, "tutorial_growth_reached", true))
###########
# TRIGGER FUNCTIONS
###########

var duration := 5.5

# doesn't get called from an event, but in the beginning from MainScene
func tutorial_beginning():
	# show amber tutorial box
	Game.UI.add_tutorial_message("Scan Amber", "Scan an Amber relict to find a new seed.", duration)

# Tutorials:
func tutorial_amber_collected():
	# unlock next tool 
	# show next tutorial box
	Game.multitool.activate_tool(Game.multitool.TOOL.PLANT)
	Game.UI.add_tutorial_message("Plant Seed", "Use the planting tool by clicking on the soil.", duration)

	print("next from amber")
	next()

func tutorial_seed_planted():
	# unlock next tool 
	Game.UI.add_tutorial_message("Speed up growth", "Use the growth tool to speed up growing.", duration)
	Game.multitool.activate_tool(Game.multitool.TOOL.GROW)


	print("next from seed planted")
	next()

func tutorial_plant_reached_stage1():
	Game.UI.add_tutorial_message("Scan plants", "Scan a plant to unlock information on its type.", duration)

	print("next from reached stage 1")
	next()

func tutorial_plant_scanned():
	Game.UI.add_tutorial_message("Open the journal", "You can look at the Plant Journal to see information on scanned plants.", duration)
	# TODO unlock journal

	print("next plant scanned")
	next()

func tutorial_growth_reached():
	Game.UI.add_tutorial_message("Plant needs", "Plants grow taller the more of their needs are met.", duration)
	yield(get_tree().create_timer(10.0), "timeout")
	# TODO show this getting seeds message once more when player has no seeds
	Game.UI.add_tutorial_message("Getting seeds", "Use the grow-tool on grown plants to harvest seeds.", duration)

	print("next growth reached")
	next()
	
	
func tutorial_completed():
	Game.UI.add_tutorial_message("Tutorial completed", "That's it, have fun exploring!")
	Game.multitool.activate_tool(Game.multitool.TOOL.HOPPER)
	yield(get_tree().create_timer(duration), "timeout")
	next()
