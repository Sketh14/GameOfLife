extends Control

# @export var _pauseTxt: Label

# Buttons
# @export var _pauseButton: Button

#Textures
@export var _pauseTex: CanvasItem
@export var _playTex: CanvasItem

var _pauseStatus: bool
# var _debugStr: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    _pauseStatus = false

func _on_pause_button_pressed():
    _pauseStatus = !_pauseStatus
    get_tree().paused = _pauseStatus

    if _pauseStatus:
        self.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
        _pauseTex.hide()
        _playTex.show()
        # _pauseTxt.show()
    else:
        self.process_mode = Node.PROCESS_MODE_ALWAYS
        _pauseTex.show()
        _playTex.hide()
        # _pauseTxt.hide()


    print("_pauseStatus : " + str(_pauseStatus))
    # self.process_mode = Node.PROCESS_MODE_DISABLED if _pauseStatus else Node.PROCESS_MODE_ALWAYS
