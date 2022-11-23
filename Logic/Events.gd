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
	print("Executing Event: " + key)
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
	events.append(Event.new("seed_planted", self, "seed_planted", false))
	events.append(Event.new("tutorial_amber_collected", self, "tutorial_amber_collected", true))
	events.append(Event.new("tutorial_plant_reached_stage1", self, "tutorial_plant_reached_stage1", true))
	events.append(Event.new("tutorial_plant_reached_stage2", self, "tutorial_plant_reached_stage2", true))
	events.append(Event.new("tutorial_plant_scanned", self, "tutorial_plant_scanned", true))
	events.append(Event.new("tutorial_growth_reached", self, "tutorial_growth_reached", true))
	events.append(Event.new("tutorial_completed", self, "tutorial_completed", true))


###########
# TRIGGER FUNCTIONS
###########

var duration := 10.0

# doesn't get called from an event, but in the beginning from MainScene
func tutorial_beginning():
	# show amber tutorial box 
	Game.UI.add_tutorial_message("Scan Amber", "Click to scan an Amber relict to find a new seed.", duration)

# Tutorials:
func tutorial_amber_collected():
	# unlock next tool 
	# show next tutorial box
	Game.multitool.activate_tool(Game.multitool.TOOL.PLANT)
	Game.UI.add_tutorial_message("Plant Seed", "Use the planting tool (2) to plant the seed.", duration)

	next()

func tutorial_seed_planted():
	# unlock next tool 
	Game.UI.add_tutorial_message("Speed up growth", "Use the growth tool (3) to speed up growing.", duration)
	Game.multitool.activate_tool(Game.multitool.TOOL.GROW)

	next()

func seed_planted():
	check_for_tutorial_completed()
	next()

func tutorial_plant_reached_stage1():
	Game.UI.add_tutorial_message("Scan plants", "Use the scanner (1) to unlock plant information.", duration)

	next()

var first_plant
func tutorial_plant_reached_stage2():
	check_for_tutorial_completed()
	next()

func tutorial_plant_scanned():
	yield(get_tree().create_timer(2.5), "timeout")
	Game.UI.add_tutorial_message("Open the journal", "Press [TAB] to look at the Plant Journal to see information on scanned plants.", duration)
	Game.UI.get_node("JournalAndGuideUI").unlock_journal()

	next()

func tutorial_growth_reached():
	Game.UI.add_tutorial_message("Plant needs", "Plants grow taller the more of their needs are met.", duration)
#	yield(get_tree().create_timer(10.0), "timeout")
	# TODO show this getting seeds message once more when player has no seeds
	Game.UI.add_tutorial_message("Getting seeds", "Use the grow-tool on grown plants to harvest seeds.", duration)

	next()
	

func check_for_tutorial_completed():
	if Game.planet.plant_list.size() > 6 and get_event_from_key("tutorial_plant_reached_stage2").execute_count > 0:
		Events.trigger("tutorial_completed")

func tutorial_completed():
	Game.UI.add_tutorial_message("Traveling", "Point to a planet and click to travel.", duration)
	Game.multitool.activate_tool(Game.multitool.TOOL.HOPPER)
	next()
