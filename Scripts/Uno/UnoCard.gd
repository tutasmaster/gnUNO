class_name Card

var gcolor = GColor.ANY
var value = Value.ZERO
var actions = []
var object : Node3D = null

func _init(c = GColor.ANY, v = Value.ZERO, a = []):
	gcolor = c
	value = v
	actions = a
	

enum GColor{
	RED,
	GREEN,
	BLUE,
	YELLOW,
	ANY
}

enum Value{
	ZERO,
	ONE,
	TWO,
	THREE,
	FOUR,
	FIVE,
	SIX,
	SEVEN,
	EIGHT,
	NINE,
	PLUS_TWO,
	PLUS_FOUR,
	COLOR,
	STOP,
	REVERSE,
	UNKNOWN
}

enum Action{
	STOP,
	REVERSE,
	ADD_TWO,
	ADD_FOUR,
	STEAL,
	COLOR,
	SET_COLOR,
	ROTATE,
	NEXT
}

func has_action(action):
	for a in actions:
		if a == action:
			return true
	return false
