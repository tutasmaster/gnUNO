extends Control

@export var playerCount : Label

@export var hiddenCards : CheckBox
@export var multiStacking : CheckBox
@export var dividedStacking : CheckBox
@export var drawOutOfTurn : CheckBox
@export var playOtherCards : CheckBox
@export var canTouchOtherCards : CheckBox
@export var cardZeroEnabled : CheckBox

func startGame():
	GameManager.game.isHiddenCards = hiddenCards.button_pressed
	GameManager.game.isMultiStackingEnabled = multiStacking.button_pressed
	GameManager.game.isDividedStacking = dividedStacking.button_pressed
	GameManager.game.isDrawOutOfTurn = drawOutOfTurn.button_pressed
	GameManager.game.isPlayOtherCards = !playOtherCards.button_pressed
	GameManager.game.canTouchOtherCards = canTouchOtherCards.button_pressed
	GameManager.game.cardZeroEnabled = cardZeroEnabled.button_pressed
	GameManager.startGame()

func setPlayerCount(pC):
	playerCount.text = str(pC) + " Players"

func explodePlayers():
	for p in GameManager.game.players:
		p.playerObject.explode.rpc()

func resetPlayers():
	GameManager.resetPlayers()
