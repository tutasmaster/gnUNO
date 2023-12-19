class_name UnoPlayer

var name = ""
var hand = UnoDeck.new(false)
var victory = false
var playerObject : Node3D = null
var handObject : Node3D = null
var networkId : int = -1
var seat : int = -1
var ready = false
var uno = false
var called_himself = false
var called_out = false
var force_update = false
