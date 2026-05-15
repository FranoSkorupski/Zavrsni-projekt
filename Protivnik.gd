extends Node
class_name Enemy

var hp:int = 20
var difficulty:String = "easy"
var deck:Array = []
var hand:Array = []

func draw_card():
	if deck.size() > 0:
		var card = deck.pop_front()
		hand.append(card)

func play_card():
	if hand.size() > 0:
		return hand.pop_front()

	return null
