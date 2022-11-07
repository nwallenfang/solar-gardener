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

####

