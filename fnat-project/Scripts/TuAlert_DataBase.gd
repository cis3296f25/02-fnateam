extends Node

# Database of troll messages for the game
const messages = {
	0: {
		"Text": "TUalertEMER: Shooting reported at N Broad St/ Cecil B Moore St.",
		"Category": "Security"
	},
	1: {
		"Text": "TUalertEMER: Water main break at 9th and Berks. Avoid the area. Mascot on site.",
		"Category": "Mascot"
	},
	2: {
		"Text": "TUalertEMER: Temple University Siren Test. No action needed.",
		"Category": "Utility"
	},
	3: {
		"Text": "TUalertEMER: Mascot activaty reported near the Library. Exercise caution.",
		"Category": "Mascot"
	},
	4: {
		"Text": "TUalertEMER: Large crowd gathering near the Student Center. Expect delays.",
		"Category": "Security"
	},
	5: {
		"Text": "TUalertEMER: Power outage reported in the Morgan Hall.",
		"Category": "Utility"
	},
	6: {
		"Text": "TUalertEMER: Suspicious package found near the Tech Center. Follow safety protocols.",
		"Category": "Security"
	},
	7: {
		"Text": "TUalertEMER: Severe weather warning in effect for the area. Seek shelter if necessary.",
		"Category": "Safety"
	},
	8: {
		"Text": "TUalertEMER: Construction work causing noise disturbances near the campus gym.",
		"Category": "Mascot"
	},
	9: {
		"Text": "TUalertEMER: City wide Blackout.",
		"Category": "Safety"
	}
}

# Get a random troll message
static func get_random_message() -> String:
	var keys = messages.keys()
	var random_key = keys[randi() % keys.size()]
	return messages[random_key]["Text"]

# Get a specific message by ID
static func get_message(id: int) -> String:
	if messages.has(id):
		return messages[id]["Text"]
	else:
		push_error("Invalid message ID: " + str(id))
		return ""

# Get a specific message with all data
static func get_message_data(id: int) -> Dictionary:
	if messages.has(id):
		return messages[id]
	else:
		push_error("Invalid message ID: " + str(id))
		return {}

# Get all message texts as an array
static func get_all_messages() -> Array:
	var all_messages = []
	for id in messages.keys():
		all_messages.append(messages[id]["Text"])
	return all_messages

# Get messages by category
static func get_messages_by_category(category: String) -> Array:
	var filtered_messages = []
	for id in messages.keys():
		if messages[id]["Category"] == category:
			filtered_messages.append(messages[id]["Text"])
	return filtered_messages

# Get message count
static func get_message_count() -> int:
	return messages.size()

# Get all message IDs
static func get_all_ids() -> Array:
	return messages.keys()
