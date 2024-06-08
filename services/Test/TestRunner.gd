class_name _testRunner extends Node

const GDSCRIPT_EXTENSION: String = ".gd"

var _scenePaths: Array = []

func _ready() -> void:
	_findTests()
	_runTests()

func _findTests() -> void:
	var router: Router = Router.new()
	var testPath: String = router.BuildPath("tests")
	_recurse(testPath)

func _recurse(directoryPath: String) -> void:
	var directory: DirAccess = DirAccess.open(directoryPath)
	
	var childDirectories: PackedStringArray = directory.get_directories()
	for childDirectory in childDirectories:
		_recurse(directoryPath + "/" + childDirectory)
	
	var childFiles: PackedStringArray = directory.get_files()
	for childFile in childFiles:
		if childFile.ends_with(GDSCRIPT_EXTENSION):
			_scenePaths.push_back(directoryPath + "/" + childFile)

func _runTests() -> void:
	for scenePath in _scenePaths:
		# Clear down dependencies from previous test.
		DependencyInjection.Clear()
		
		# Initialize the test scene.
		var sceneBuilder: Resource = load(scenePath)
		var scene: Node = sceneBuilder.new()
		
		# Skip any scenes that are not test scenes.
		if (scene is TestClass == false):
			continue
		
		# Convert the scene to a TestClass.
		var testScene: TestClass = scene
		
		# Check if there is any Configuration File Reader registered for the test.
		var router: Router = Router.new()
		var baseConfigurationFileReaderPath: String = router.BuildPath(
			"services/Configuration/Abstract/BaseConfigurationFileReader.gd"
		)
		if (DependencyInjection.Has(baseConfigurationFileReaderPath)):
			# Refresh the configuration using the settings defined in the test.
			Configuration.Refresh()
		
		# Add the test scene to the scene tree to run the tests.
		var results: Array[TestResult] = testScene.Run()
		
		# Print the results to the console.
		_printResult(results)
	
	# Tester has finished, so exit tree.
	get_tree().quit()

func _printResult(results: Array[TestResult]) -> void:
	for result: TestResult in results:
		Logger.LogInformation(
			result.Name + " test " +
			(
				"passed." if result.Passed
				else "failed."
			)
		)
