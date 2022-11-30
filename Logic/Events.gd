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
#		print("popped ", popped_event)
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
	events.append(Event.new("gear_scanned", self, "gear_scanned", true))
	events.append(Event.new("tutorial_completed", self, "tutorial_completed", true))
	events.append(Event.new("soil_unlocked", self, "soil_unlocked", true))
	events.append(Event.new("remove_unlocked", self, "remove_unlocked", true))
	events.append(Event.new("jetpack_unlocked", self, "jetpack_unlocked", true))
	events.append(Event.new("too_many_seeds", self, "too_many_seeds", true))
	events.append(Event.new("no_seeds", self, "no_seeds", false))
	events.append(Event.new("planet_hopped", self, "planet_hopped", false))


###########
# TRIGGER FUNCTIONS
###########

var duration := 13.0
var repeat_time := 30.0  # later smth like 45 seconds
var repeat_this: String
# doesn't get called from an event, but in the beginning from MainScene
func tutorial_beginning():
	# show amber tutorial box 
	if Game.number_of_ambers > 0:
		return  # player has already done this before tutorial even began
	Game.UI.add_tutorial_message("Find Seed", "Use the scanner on an Amber relic to unlock a new seed.", duration)
	$RepeatTimer.start(repeat_time)
	repeat_this = "tutorial_beginning"


func _on_RepeatTimer_timeout() -> void:
	$RepeatTimer.stop()
	if repeat_this != null or repeat_this == "":
		call(repeat_this)

# Tutorials:
func tutorial_amber_collected():
	# unlock next tool 
	# show next tutorial box
	Game.multitool.activate_tool(Game.multitool.TOOL.PLANT)
	Game.UI.add_tutorial_message("Plant Seed", "Use the planting tool (2) to plant the seed.", duration)
	
	# when repeating, next will be called multiple times, but maybe it's no problem
	# should just keep it in mind
	next()
	
	$RepeatTimer.start(repeat_time)
	repeat_this = "tutorial_amber_collected"
	

func tutorial_seed_planted():
	if not $RepeatTimer.is_stopped():
		$RepeatTimer.stop()
	# unlock next tool 
	Game.UI.add_tutorial_message("Speed up growth", "Use the growth tool (3) to speed up growing.", duration)
	Game.multitool.activate_tool(Game.multitool.TOOL.GROW)

	next()

func seed_planted():
#	check_for_tutorial_completed()
	next()

func tutorial_plant_reached_stage1():
	if not $RepeatTimer.is_stopped():
		$RepeatTimer.stop()
	Game.UI.add_tutorial_message("Scan plants", "Use the scanner (1) to unlock plant information.", duration)

	next()
	
	$RepeatTimer.start(repeat_time)
	repeat_this = "tutorial_plant_reached_stage1"

var first_plant
func tutorial_plant_reached_stage2():
#	check_for_tutorial_completed()
	next()

func tutorial_plant_scanned():

	$RepeatTimer.stop()
	repeat_this = ""
	yield(get_tree().create_timer(2.5), "timeout")
	Game.UI.add_tutorial_message("Open the journal", "Use the Journal (TAB) to see plant information.", duration)
	Game.UI.get_node("JournalAndGuideUI").unlock_journal()

	next()

func tutorial_growth_reached():
	Game.UI.add_tutorial_message("Plant needs", "Plants grow taller the more of their needs are met.", duration)
	next()
	yield(get_tree().create_timer(16.0), "timeout")
	# TODO show this getting seeds message once more when player has no seeds
	Game.UI.add_tutorial_message("Getting seeds", "Use the grow-tool on grown plants to harvest seeds.", duration)


	
func no_seeds():  # TODO not connected yet
	Game.UI.add_tutorial_message("Getting seeds", "Use the grow-tool on grown plants to harvest seeds.", duration)	
	

#func check_for_tutorial_completed():
#	pass
#	if Game.planet.plant_list.size() > 6 and get_event_from_key("tutorial_plant_reached_stage2").execute_count > 0 and \
#			get_event_from_key("tutorial_plant_scanned").execute_count > 0:
#		Events.trigger("tutorial_completed")

func tutorial_completed():
	Game.multitool.activate_tool(Game.multitool.TOOL.HOPPER)
	yield(get_tree().create_timer(4.0), "timeout")
	Game.UI.add_tutorial_message("Traveling", "Point to a planet and click to travel.", duration)

	next()
	
	$RepeatTimer.start(repeat_time)
	repeat_this = "tutorial_completed"

func soil_unlocked():
	Game.multitool.soil_unlocked = true
	yield(get_tree().create_timer(4.0), "timeout")
	Game.UI.add_tutorial_message("Soil Analysis", "Scan the soil to get more information on the planet.", duration)
	next()

func remove_unlocked():
	Game.multitool.death_beam_unlocked = true
	yield(get_tree().create_timer(4.0), "timeout")
	Game.UI.add_tutorial_message("Removing Plants", "Use right click with the grow tool to remove plants.", duration)

	# TODO Show Remove Tooltip now!
	next()

func jetpack_unlocked():
	Game.player.unlocked_jetpack = true
	yield(get_tree().create_timer(4.0), "timeout")
	Game.UI.add_tutorial_message("Jetpack", "Press space after jumping to use your jetpack.", duration)

	next()

func gear_scanned():
	Game.UI.add_tutorial_message("Tool Upgrades", "Go to the shed to upgrade the Yardintool.", duration)
	next()

var first_hop := true
func planet_hopped():
	if first_hop:
		first_hop = false
		$RepeatTimer.stop()
	next()

func too_many_seeds():
	Game.UI.add_tutorial_message("Seed hoarding detected", "The Yardin-AI is wondering what to do with so many seeds.", duration)
	next()
