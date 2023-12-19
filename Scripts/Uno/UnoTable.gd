class_name UnoTable
enum DIRECTION{
	CLOCKWISE,
	COUNTER_CLOCKWISE
}
enum STATE{
	LOBBY,
	HOLD, #COMBINES MULTIPLE STATES
	STOP,
	PLAYING,
	END
}

enum HOLD_STATE{
	STACKING,
	COLORING
}

var stack = 0
var isHiddenCards = true
var isMultiStackingEnabled = true
var isDividedStacking = true #THIS DEFINES THE IDEA THAT YOU CAN STACK WHILE DRAWING
var isDrawOutOfTurn = false
var isPlayOtherCards = false
var canTouchOtherCards = false
var cardZeroEnabled = false

const GColorMap = {
	Card.GColor.RED: "R",
	Card.GColor.BLUE: "B",
	Card.GColor.YELLOW: "Y",
	Card.GColor.GREEN: "G",
	Card.GColor.ANY: "A"
}
const ValueMap = {
	Card.Value.ZERO: "0",
	Card.Value.ONE: "1",
	Card.Value.TWO:"2",
	Card.Value.THREE:"3",
	Card.Value.FOUR:"4",
	Card.Value.FIVE:"5",
	Card.Value.SIX:"6",
	Card.Value.SEVEN:"7",
	Card.Value.EIGHT:"8",
	Card.Value.NINE:"9",
	Card.Value.PLUS_TWO:"+",
	Card.Value.PLUS_FOUR:"*",
	Card.Value.COLOR:"?",
	Card.Value.STOP:"!",
	Card.Value.REVERSE:"/",
	Card.Value.UNKNOWN:"%"
}
const ActionMap = {
	Card.Action.STOP:"!",
	Card.Action.REVERSE:"/",
	Card.Action.ADD_TWO:"+",
	Card.Action.ADD_FOUR:"*",
	Card.Action.STEAL:"-",
	Card.Action.COLOR:"?",
	Card.Action.ROTATE:"(",
	Card.Action.SET_COLOR:"%",
	Card.Action.NEXT:"$"
}


static func encode_card(card):
	var result = ""
	if(GColorMap.has(card.gcolor)):
		result += GColorMap[card.gcolor]
	else:
		print("FAILED TO PARSE CARD COLOR " + str(card.color))
		return ""
		
	if(ValueMap.has(card.value)):
		result += ValueMap[card.value]
	else:
		print("FAILED TO PARSE CARD VALUE " + str(card.value))
		return ""
	
	for a in card.actions:
		if(ActionMap.has(a)):
			result += ActionMap[a]
		else:
			print("FAILED TO PARSE CARD ACTION " + str(a))
			return ""
	return result
					
static func decode_card(value):
	var card = Card.new()
	var step = 0
	for s in value:
		if(step == 0):
			var c = GColorMap.find_key(s)
			if(c != null):
				card.gcolor = c
			else:
				print("FAILED TO DECODE CARD COLOR " + str(s))
				return null
		elif(step == 1):
			var v = ValueMap.find_key(s)
			if(v != null):
				card.value = v
			else:
				print("FAILED TO DECODE CARD VALUE " + str(s))
				return null
		else:
			var v = ActionMap.find_key(s)
			if(v != null):
				card.actions.push_back(v)
			else:
				print("FAILED TO DECODE CARD ACTION " + str(s))
				return null
		step+=1
	return card

var players = []
var deck = UnoDeck.new(true, cardZeroEnabled)
var discard = UnoDeck.new(false)
var table_direction = DIRECTION.CLOCKWISE
var state = STATE.LOBBY
var current_player = 0
var current_player_old = 0



func _init():
	#startGame()
	#print(deck.card_arr.size())
	#print(encode_card(discard.top()))
	#print(encode_card(players[0].hand.top()))
	#play(players[0].hand.draw())
	pass

func sort_players(a,b):
	if(b.ready && !a.ready):
		return false
	elif(a.ready && !b.ready):
		return true
	return a.seat < b.seat

func startGame():
	state = STATE.PLAYING
	table_direction = DIRECTION.CLOCKWISE
	players.sort_custom(sort_players)
	current_player = 0
	
	
	deck = UnoDeck.new(true, cardZeroEnabled)
	deck.shuffle()
	for p in players:
		p.ready = true
		p.hand = UnoDeck.new(false)
		p.victory = false
		p.uno = false
		p.called_himself = false
		p.called_out = false
		p.force_update = false
		for i in range(7):
			p.hand.insert(drawCard())
	discard = UnoDeck.new(false)
	discard.insert(deck.draw())
	current_color = discard.top().gcolor
	
func play(card):
	current_player_old = current_player
	if(state == STATE.LOBBY || state == STATE.END):
		print("GAME STATE IS NOT AVAILABLE")
		return card
	var t = discard.top()
	if(state == STATE.PLAYING):
		if current_color == Card.GColor.ANY || card.gcolor == Card.GColor.ANY:
			discard.insert(card)
			startAction()
		elif current_color == card.gcolor || t.value == card.value:
			discard.insert(card)
			startAction()
		else:
			print("INVALID CARD")
			print(UnoTable.encode_card(card) + ":" + UnoTable.encode_card(t))
			return card
	elif(state == STATE.HOLD):
		if(isHold(HOLD_STATE.STACKING)):
			if(isMultiStackingEnabled):
				if(!has_drawn && !isDividedStacking):
					if card.has_action(Card.Action.ADD_TWO) || card.has_action(Card.Action.ADD_FOUR):
						discard.insert(card)
						startAction()
					else:
						return card
				elif(isDividedStacking):
					if card.has_action(Card.Action.ADD_TWO) || card.has_action(Card.Action.ADD_FOUR):
						discard.insert(card)
						startAction()
					else:
						return card
				else:
					return card
			else:
				if(card.value == discard.top().value):
					discard.insert(card)
					startAction()
				else:
					return card
	return null
	
var has_drawn = false
var draw_count = 0

var holdStates = []

func isHold(st):
	for s in holdStates:
		if s == st:
			return true
	return false

func getCurrentPlayer():
	if current_player > players.size() - 1:
		playerRotation()
	return players[current_player] 

func drawCard(playerId = null):
	if(playerId != null && !isDrawOutOfTurn):
		if getCurrentPlayer().networkId != playerId:
			return null
	var d = deck.draw()
	if(d == null):
		if discard.card_arr.size() <= 1:
			discard = UnoDeck.new(true, cardZeroEnabled)
		for c in discard.card_arr:
			deck.insert(c)
		
		discard = UnoDeck.new(false)
		discard.insert(deck.draw())
		deck.shuffle()
		d = deck.draw()
	return d

func checkWin():
	if (players[current_player_old].hand.card_arr.size() == 1):
		players[current_player_old].uno = true
		players[current_player_old].called_himself = false
	elif(players[current_player_old].hand.card_arr.size() > 1):
		players[current_player_old].uno = false
		players[current_player_old].called_himself = false
	elif(players[current_player_old].hand.card_arr.size() == 0):
		if players[current_player_old].called_himself == true:
			players[current_player_old].victory = true
			return true
		else:
			players[current_player_old].hand.insert(drawCard())
			players[current_player_old].hand.insert(drawCard())
			players[current_player_old].hand.insert(drawCard())
			players[current_player_old].hand.insert(drawCard())
			players[current_player_old].force_update = true
	return false

func callUno():
	players[current_player].called_himself = true

func draw(player):
	if(player == current_player):
		if(state == STATE.HOLD):
			if(isHold(HOLD_STATE.STACKING)):
				has_drawn = true
				draw_count+=1
				if(draw_count >= stack):
					state = STATE.PLAYING
					has_drawn = false
					draw_count = 0
					stack = 0
					playerRotation()

var current_color = Card.GColor.ANY
	

func pickColor(color,player):
	if(player == current_player):
		if(state == STATE.HOLD):
			if(isHold(HOLD_STATE.COLORING)):
				current_color = color
				state = STATE.PLAYING
				nextAction()
	

var current_action = 0

func rotateCards():
	var prevPlayer = null
	var firstPlayer = null
	var hand = null
	
	for i in players.size():
		if players[i].ready:
			if firstPlayer == null:
				firstPlayer = i
			if(prevPlayer != null):
				hand = players[i].hand
				players[i].hand = players[prevPlayer].hand
				players[i].force_update = true
				players[prevPlayer].hand = hand
				players[prevPlayer].force_update = true
			prevPlayer = i
	
	hand = players[firstPlayer].hand
	players[firstPlayer].hand = players[prevPlayer].hand
	players[prevPlayer].hand = hand
	players[firstPlayer].force_update = true
	players[prevPlayer].force_update = true
		

func startAction():
	current_action = 0
	executeAction()

func nextAction():
	current_action += 1
	executeAction()

func executeAction():
	var card = discard.top()
	if(current_action >= card.actions.size()):
		return
	var a = card.actions[current_action]
	if a == Card.Action.SET_COLOR:
		current_color = card.gcolor
		nextAction()
	elif a == Card.Action.REVERSE:
		table_direction = DIRECTION.COUNTER_CLOCKWISE if table_direction == DIRECTION.CLOCKWISE else DIRECTION.CLOCKWISE
		nextAction()
	elif a == Card.Action.ROTATE:
		rotateCards()
		nextAction()
	#elif a == Card.Action.STOP:
		#if table_direction == DIRECTION.CLOCKWISE:
			#current_player += 1
		#else:
			#current_player -= 1
		#nextAction()
	elif a == Card.Action.ADD_TWO:
		stack += 2
		state = STATE.HOLD
		holdStates = [HOLD_STATE.STACKING]
		has_drawn = false
		nextAction()
	elif a == Card.Action.ADD_FOUR:
		stack += 4
		state = STATE.HOLD
		holdStates = [HOLD_STATE.STACKING]
		has_drawn = false
		nextAction()
	elif a == Card.Action.COLOR:
		state = STATE.HOLD
		holdStates = [HOLD_STATE.COLORING]
	elif a == Card.Action.NEXT:
		playerRotation()
		while(!players[current_player].ready):
			playerRotation()
		nextAction()
	var w = checkWin()
	if(w):
		print("VICTORY ACHIEVED")
		state = STATE.END
		current_player = -1
	

func playerRotation():
	if table_direction == DIRECTION.CLOCKWISE:
		current_player += 1
	else:
		current_player -= 1
		
	if current_player > players.size() - 1:
		current_player = 0 + (current_player - players.size())
	elif current_player < 0:
		current_player = players.size() + current_player
