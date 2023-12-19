class_name UnoDeck

var card_arr : Array[Card] = []
func _init(fill = false, cardZeroEnabled = false):
	if(!fill):
		return
	for j in range(4):
		for i in range(2):
			var color = Card.GColor.RED
			match j:
				0:
					color = Card.GColor.RED
				1:
					color = Card.GColor.BLUE
				2:
					color = Card.GColor.YELLOW
				3:
					color = Card.GColor.GREEN
			if(cardZeroEnabled):
				card_arr.push_back(Card.new(color,Card.Value.ZERO,[Card.Action.SET_COLOR, Card.Action.ROTATE, Card.Action.NEXT]))
			var actions = [Card.Action.SET_COLOR, Card.Action.NEXT]
			card_arr.push_back(Card.new(color,Card.Value.ONE,actions))
			card_arr.push_back(Card.new(color,Card.Value.TWO,actions))
			card_arr.push_back(Card.new(color,Card.Value.THREE,actions))
			card_arr.push_back(Card.new(color,Card.Value.FOUR,actions))
			card_arr.push_back(Card.new(color,Card.Value.FIVE,actions))
			card_arr.push_back(Card.new(color,Card.Value.SIX,actions))
			card_arr.push_back(Card.new(color,Card.Value.SEVEN,actions))
			card_arr.push_back(Card.new(color,Card.Value.EIGHT,actions))
			card_arr.push_back(Card.new(color,Card.Value.NINE,actions))
			actions = [Card.Action.SET_COLOR,Card.Action.ADD_TWO, Card.Action.NEXT]
			card_arr.push_back(Card.new(color,Card.Value.PLUS_TWO,actions))
			actions = [Card.Action.SET_COLOR,Card.Action.NEXT, Card.Action.NEXT]
			card_arr.push_back(Card.new(color,Card.Value.STOP,actions))
			actions = [Card.Action.SET_COLOR,Card.Action.REVERSE, Card.Action.NEXT]
			card_arr.push_back(Card.new(color,Card.Value.REVERSE,actions))
	for i in range(8):
		card_arr.push_back(Card.new(Card.GColor.ANY,Card.Value.PLUS_FOUR,[Card.Action.COLOR,Card.Action.NEXT,Card.Action.ADD_FOUR]))
	for i in range(8):
		var actions = [Card.Action.COLOR, Card.Action.NEXT]
		card_arr.push_back(Card.new(Card.GColor.ANY,Card.Value.COLOR,actions))

func top():
	return card_arr.front()

func insert(card):
	card_arr.push_front(card)	

func draw():
	return card_arr.pop_front()
	
func remove_card(card):
	var i = 0
	for c in card_arr:
		if c == card:
			card_arr.remove_at(i)
			break
		i+=1
	
func shuffle():
	randomize()
	card_arr.shuffle()
