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

func next():
	if event_queue.size() > 0:
		events.pop_front()
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

###########
# TRIGGER FUNCTIONS
###########

# doesn't get called from an event, but in the beginning from MainScene
func tutorial_beginning():
	# show amber tutorial box
	Game.UI.show_tutorial_message("Find Amber", "Scan an Amber relict to find a new plant.")

# Tutorials:
func tutorial_amber_collected():
	# unlock next tool 
	# show next tutorial box
	Game.multitool.activate_tool(Game.multitool.TOOL.PLANT)
	Game.multitool.activate_tool(Game.multitool.TOOL.GROW)
	Game.UI.show_tutorial_message("Plant Seed", "(Stuff after this not implemented yet.)")

func tutorial_seed_planted():
	# unlock next tool 
	# show next tutorial box
	pass
