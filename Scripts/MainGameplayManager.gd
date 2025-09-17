extends Control

# @export var _pauseTxt: Label

# Buttons
# @export var _pauseButton: Button

#Textures
@export var _pauseTex: CanvasItem
@export var _playTex: CanvasItem

# Tile Controls
@export var _gridDimensions: Vector2i
@export var _tileContainer: GridContainer
# @export var _tilePrefab: Node

var _pauseStatus: bool
# var _debugStr: String

#Constants
const _TILE_STARTING_POS = Vector2(280, -16)
const _TILE_PREFAB_PATH = "res://Scenes/BaseTile.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    _pauseStatus = false
    _tileContainer.columns = _gridDimensions.y
    InitializeTiles()

func OnPauseButtonPressed():
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

func InitializeTiles():
    var tilePos = _TILE_STARTING_POS
    var tilePrefab = load(_TILE_PREFAB_PATH)
    var initializedTile
    # print("_gridDimensions : " + str(_gridDimensions))
    for i in _gridDimensions.x:
        for j in _gridDimensions.y:
            initializedTile = tilePrefab.instantiate()

            # tilePos.x = 0.0
            # tilePos.y = 0.0
            initializedTile.position = tilePos

            _tileContainer.add_child(initializedTile)