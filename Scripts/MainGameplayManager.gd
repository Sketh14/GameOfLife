class_name MainGameplayManager
extends Control

# @export var _pauseTxt: Label

# Buttons
# @export var _pauseButton: Button

#Textures
@export var _pauseTex: CanvasItem
@export var _playTex: CanvasItem

# Tile Controls
# @export var _gridDimensions: Vector2i
@export var _gridColumns = _DEFAULT_GRID_COLUMNS
@export var _tileContainer: GridContainer
# @export var _tilePrefab: Node

var _pauseStatus: bool
var _tilesArr: Array[Helper.TileInfo]
var _pressedStyleBox: StyleBoxFlat
# var _debugStr: String

#Constants
const _TILE_STARTING_POS = Vector2(280, -16)
const _TILE_PREFAB_PATH = "res://Scenes/BaseTile.tscn"
const _DEFAULT_GRID_COLUMNS = 10
const _PRESSED_COLOR = Color(0, 0, 0, 1)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_pauseStatus = false
	# _tileContainer.columns = _gridDimensions.y
	_tileContainer.columns = _gridColumns

	_pressedStyleBox = StyleBoxFlat.new()
	_pressedStyleBox.bg_color = _PRESSED_COLOR

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
	# var tilePos = _TILE_STARTING_POS
	var tilePrefab = load(_TILE_PREFAB_PATH)
	# print("_gridDimensions : " + str(_gridDimensions))

	for i in (_gridColumns - 7): # Rows | 9:16 ratio
		for j in _gridColumns: # Columns
			var initializedTile = Helper.TileInfo.new()
			initializedTile.tileBt = (tilePrefab.instantiate() as Button)
			initializedTile.tileBt.connect("pressed",
				func():
					UpdateTile((i * _gridColumns) + j))

			# tilePos.x = 0.0
			# tilePos.y = 0.0
			# initializedTile.position = tilePos

			_tileContainer.add_child(initializedTile.tileBt)
			_tilesArr.append(initializedTile)
	# print("Total Tiles Added: " + str(_tilesArr.size()))

func GameLogic():
	pass
	
func UpdateTile(tileIndex: int):
	# ("Pressed Tile: ")            #<------------ Why does this compile? WTF
	# print("Pressed Tile: " + str(tileIndex) + " | Has stylebox: " + str(_tilesArr[tileIndex].get_theme_stylebox("normal", "Button")))
	# _tilesArr[tileIndex].get_theme_stylebox("normal").bg_color = _PRESSED_COLOR
	if _tilesArr[tileIndex].selected:
		_tilesArr[tileIndex].tileBt.remove_theme_stylebox_override("normal")
		_tilesArr[tileIndex].selected = false
	else:
		_tilesArr[tileIndex].tileBt.add_theme_stylebox_override("normal", _pressedStyleBox)
		_tilesArr[tileIndex].selected = true
