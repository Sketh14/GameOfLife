class_name MainGameplayManager
extends Control

# @export var _pauseTxt: Label

# Buttons
# @export var _pauseButton: Button
@export var _startBt: Button

#Textures
@export var _pauseTex: CanvasItem
@export var _playTex: CanvasItem

# Tile Controls
# @export var _gridDimensions: Vector2i
@export var _gridColumns = _DEFAULT_GRID_COLUMNS
@export var _tileContainer: GridContainer
@export var _infoTxt: RichTextLabel
# @export var _tilePrefab: Node

var _pauseStatus: bool
var _tilesArr: Array[Button]

var _tilesState: Array[int]
var _tilesStateNext: Array[int]
var _pressedStyleBox: StyleBoxFlat

# Info
@export var _solveSpeed = 1.0
var _generation: int
var _population: int
var _simulationStarted: bool
# var _awaitTimer: SceneTreeTimer
# var _debugStr: String

#Constants
const _TILE_STARTING_POS = Vector2(280, -16)
const _TILE_PREFAB_PATH = "res://Scenes/BaseTile.tscn"
const _DEFAULT_GRID_COLUMNS = 10
const _PRESSED_COLOR = Color(0, 0, 0, 1)
const _RATIO_DIFF = 7

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_pauseStatus = false
	# _tileContainer.columns = _gridDimensions.y
	_tileContainer.columns = _gridColumns
	_simulationStarted = false
	_generation = 0
	_population = 0
	_infoTxt.text = "Generation: 0\nPopulation: 0"

	_pressedStyleBox = StyleBoxFlat.new()
	_pressedStyleBox.bg_color = _PRESSED_COLOR
	# _awaitTimer = get_tree().create_timer(_solveSpeed)
	
	InitializeTiles()

	# GameLogic()
	_startBt.connect("pressed",
		func():
			_simulationStarted = !_simulationStarted
			if _simulationStarted:
				GameLogic())

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

	for i in (_gridColumns - _RATIO_DIFF): # Rows | 9:16 ratio
		for j in _gridColumns: # Columns
			var initializedTile = (tilePrefab.instantiate() as Button)
			initializedTile.connect("pressed", func(): TilePressed((i * _gridColumns) + j))

			# tilePos.x = 0.0
			# tilePos.y = 0.0
			# initializedTile.position = tilePos

			_tileContainer.add_child(initializedTile)
			_tilesArr.append(initializedTile)
			_tilesState.append(0)
			_tilesStateNext.append(0)
	# print("Total Tiles Added: " + str(_tilesArr.size()))

func TilePressed(tileIndex: int):
	if (_tilesState[tileIndex] == 1):
		_tilesState[tileIndex] = 0
		_population -= 1
	else:
		_tilesState[tileIndex] = 1
		_population += 1

	_infoTxt.text = "Generation: " + str(_generation) + "\nPopulation: " + str(_population)
	UpdateTile(tileIndex)

func UpdateTile(tileIndex: int):
	# ("Pressed Tile: ")            #<------------ Why does this compile? WTF
	# print("Pressed Tile: " + str(tileIndex) + " | Has stylebox: " + str(_tilesArr[tileIndex].get_theme_stylebox("normal", "Button")))
	# _tilesArr[tileIndex].get_theme_stylebox("normal").bg_color = _PRESSED_COLOR
	if _tilesState[tileIndex] == 0:
		_tilesArr[tileIndex].remove_theme_stylebox_override("normal")
		# _tilesState[tileIndex] = 1
	else:
		_tilesArr[tileIndex].add_theme_stylebox_override("normal", _pressedStyleBox)
		# _tilesState[tileIndex] = 0

func PrintTileStates(tilesArr: Array[int]):
	var debugTiles = ""
	var currIndex = -1;
	for i in (_gridColumns - _RATIO_DIFF): # Rows | 9:16 ratio
	# for i in _gridColumns:
		for j in _gridColumns: # Columns
			currIndex = (i * _gridColumns) + j
			debugTiles += str(currIndex) + "[" + str(tilesArr[currIndex]) + "] | "
		debugTiles += "\n"
	
	print("debug Tiles: \n" + str(debugTiles))

func GameLogic():
	_generation = 0
	# while (_simulationStarted && _generation < 100):
	while (_simulationStarted):
		# PrintTileStates(_tilesState)
		var currIndex = -1;

		# Copy Data for Current Calculation
		# for i in (_gridColumns - _RATIO_DIFF): # Rows | 9:16 ratio
		# 	for j in _gridColumns: # Columns
		# 		currIndex = (i * (_gridColumns - _RATIO_DIFF)) + j
		# 		_tilesStateNext[currIndex] = _tilesState[currIndex]

		# Update All Tiles
		for i in (_gridColumns - _RATIO_DIFF): # Rows | 9:16 ratio
			for j in _gridColumns: # Columns
				currIndex = (i * _gridColumns) + j
				UpdateTile(currIndex)

		var sum = 0
		for i in (_gridColumns - _RATIO_DIFF): # Rows | 9:16 ratio
			for j in _gridColumns: # Columns
				currIndex = (i * _gridColumns) + j

				# Ignore Edges
				# if (i == 0 || i == (_gridColumns - _RATIO_DIFF - 1) || j == 0 || j == _gridColumns - 1):
				# 	_tilesStateNext[currIndex] = _tilesState[currIndex]
				# 	continue

				# Count live neighbours
				sum = CountNeighbours(currIndex)
				# print(str(currIndex) + "[" + str(sum) + "]")

				# Set Tile value
				if (_tilesState[currIndex] == 0 && sum == 3):
					_tilesStateNext[currIndex] = 1
					_population += 1
				elif (_tilesState[currIndex] == 1 && (sum < 2 || sum > 3)):
					_tilesStateNext[currIndex] = 0
					_population -= 1
				else:
					_tilesStateNext[currIndex] = _tilesState[currIndex]

		# PrintTileStates(_tilesStateNext)
		# PrintTileStates(_tilesState)
		# _tilesState = _tilesStateNext
		
		# Update Array
		for i in (_gridColumns - _RATIO_DIFF): # Rows | 9:16 ratio
			for j in _gridColumns: # Columns
				currIndex = (i * _gridColumns) + j
				_tilesState[currIndex] = _tilesStateNext[currIndex]

		_generation += 1

		# await Engine.get_main_loop().process_frame
		
		# _awaitTimer.time_left = _solveSpeed
		# await _awaitTimer.timeout

		await get_tree().create_timer(_solveSpeed).timeout
		_infoTxt.text = "Generation: " + str(_generation) + "\nPopulation: " + str(_population)
		# print("Curr _generation" + str(_generation))

	# print("Final _generation" + str(_generation))

# Check Tile value within 1 block radius
func CountNeighbours(tileIndex: int) -> int:
	# print("Checking for index: " + str(tileIndex))
	var sum = 0
	# var tileRow = tileIndex / _gridColumns
	# var tileCol = tileIndex % _gridColumns
	# var offset = -1
	
	var finalIndex = -1
	for i in range(-1, 2):
		for j in range(-1, 2):
			# Calculate Row
			# tileRow = ((tileIndex / _gridColumns) + i + _gridColumns) % _gridColumns
			finalIndex = ((tileIndex / _gridColumns) + i + _gridColumns - _RATIO_DIFF) % (_gridColumns - _RATIO_DIFF)
			finalIndex *= _gridColumns

			# Calculate Column
			# tileCol = ((tileIndex % _gridColumns) + j + _gridColumns) % _gridColumns
			finalIndex += ((tileIndex % _gridColumns) + j + _gridColumns) % _gridColumns

			# offset = (i * _gridColumns) + j
			# sum += _tilesState[tileIndex + offset]

			sum += _tilesState[finalIndex]
			# print("Offset: " + str(offset) + "Sum: " + str(sum))

	sum -= _tilesState[tileIndex]

	return sum
