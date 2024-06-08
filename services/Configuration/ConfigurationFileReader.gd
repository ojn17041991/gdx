class_name ConfigurationFileReader extends BaseConfigurationFileReader

var APPSETTINGS_URL: String
var APPSETTINGS_DEBUG_URL: String
var APPSETTINGS_RELEASE_URL: String
const USERSETTINGS_DIRECTORY: String = "user://gdx"
const USERSETTINGS_URL: String = USERSETTINGS_DIRECTORY + "/usersettings.json"
const USERSETTINGS_DEBUG_URL: String = USERSETTINGS_DIRECTORY + "/usersettings.debug.json"
const USERSETTINGS_RELEASE_URL: String = USERSETTINGS_DIRECTORY + "/usersettings.release.json"

func Read() -> Result:
	# Set up the app config references.
	var appConfigReferencesInitialized: bool = _initializeAppConfigReferences()
	if (appConfigReferencesInitialized == false):
		return Result.new(ResultType.Error, [])
	
	# Set up the user configs.
	var userConfigsInitialized: bool = _initializeUserConfigs()
	if (userConfigsInitialized == false):
		return Result.new(ResultType.Error, [])
	
	# Determine which of the environment-specific configuration files should be used.
	var environmentAppSettingsUrl: String = _getEnvironmentAppSettingsUrl()
	var environmentUserSettingsUrl: String = _getEnvironmentUserSettingsUrl()
	
	# Make sure all required files are available.
	if (_fileExists(APPSETTINGS_URL) == false ||
		_fileExists(environmentAppSettingsUrl) == false ||
		_fileExists(USERSETTINGS_URL) == false ||
		_fileExists(environmentUserSettingsUrl) == false):
		return Result.new(ResultType.NotFound, [])
	
	# Open all required files and make sure there were no errors.
	var appSettingsFile: FileAccess = _openFile(APPSETTINGS_URL)
	if (appSettingsFile == null):
		return Result.new(ResultType.Error, [])
	
	var environmentAppSettingsFile: FileAccess = _openFile(environmentAppSettingsUrl)
	if (environmentAppSettingsFile == null):
		return Result.new(ResultType.Error, [])
	
	var userSettingsFile: FileAccess = _openFile(USERSETTINGS_URL)
	if (userSettingsFile == null):
		return Result.new(ResultType.Error, [])
	
	var environmentUserSettingsFile: FileAccess = _openFile(environmentUserSettingsUrl)
	if (environmentUserSettingsFile == null):
		return Result.new(ResultType.Error, [])
	
	# Parse the JSON from all files and make sure there were no errors.
	var appSettings: Result = _parseJson(APPSETTINGS_URL, appSettingsFile)
	if (appSettings.ResultType != ResultType.Ok):
		return Result.new(appSettings.ResultType, [])
	
	var environmentAppSettings: Result = _parseJson(environmentAppSettingsUrl, environmentAppSettingsFile)
	if (environmentAppSettings.ResultType != ResultType.Ok):
		return Result.new(environmentAppSettings.ResultType, [])
	
	var userSettings: Result = _parseJson(USERSETTINGS_URL, userSettingsFile)
	if (userSettings.ResultType != ResultType.Ok):
		return Result.new(userSettings.ResultType, [])
	
	var environmentUserSettings: Result = _parseJson(environmentUserSettingsUrl, environmentUserSettingsFile)
	if (environmentUserSettings.ResultType != ResultType.Ok):
		return Result.new(environmentUserSettings.ResultType, [])
	
	# Put the app settings data into the main settings as a base, then merge in the remaining settings.
	var settings: Dictionary = appSettings.Data
	_merge(settings, userSettings.Data)
	_merge(settings, environmentAppSettings.Data)
	_merge(settings, environmentUserSettings.Data)
	return Result.new(ResultType.Ok, settings)

func _initializeUserConfigs() -> bool:
	var userConfigDirectoryInitialized: bool = _initializeUserConfigDirectory()
	if (userConfigDirectoryInitialized == false):
		Logger.LogError("Failed to initialize user config directory.")
		return false
	
	var userConfigInitialized: bool = _initializeUserConfig(USERSETTINGS_URL)
	if (userConfigInitialized == false):
		Logger.LogError("Failed to initialize " + USERSETTINGS_URL + ".")
		return false
	
	var userDebugConfigInitialized: bool = _initializeUserConfig(USERSETTINGS_DEBUG_URL)
	if (userConfigInitialized == false):
		Logger.LogError("Failed to initialize " + USERSETTINGS_DEBUG_URL + ".")
		return false
	
	var userReleaseConfigInitialized: bool = _initializeUserConfig(USERSETTINGS_RELEASE_URL)
	if (userConfigInitialized == false):
		Logger.LogError("Failed to initialize " + USERSETTINGS_RELEASE_URL + ".")
		return false
	
	return true

func _initializeUserConfigDirectory() -> bool:
	if (_directoryExists(USERSETTINGS_DIRECTORY) == false):
		var result: Error = DirAccess.make_dir_absolute(USERSETTINGS_DIRECTORY)
		
		if (result != Error.OK):
			return false
	
	return true

func _initializeUserConfig(userConfigDirectory: String) -> bool:
	if (_fileExists(userConfigDirectory) == false):
		var file: FileAccess = FileAccess.open(userConfigDirectory, FileAccess.WRITE_READ)
		file.store_string("{}")
		file.close()
	
	return true

func _initializeAppConfigReferences() -> bool:
	var router: Router = Router.new()
	var configBasePath: String = router.BuildPath("config")
	
	APPSETTINGS_URL = configBasePath + "/appsettings.json"
	APPSETTINGS_DEBUG_URL = configBasePath + "/appsettings.debug.json"
	APPSETTINGS_RELEASE_URL = configBasePath + "/appsettings.release.json"
	return true

func _getEnvironmentAppSettingsUrl() -> String:
	if (OS.is_debug_build()):
		return APPSETTINGS_DEBUG_URL
	else:
		return APPSETTINGS_RELEASE_URL

func _getEnvironmentUserSettingsUrl() -> String:
	if (OS.is_debug_build()):
		return USERSETTINGS_DEBUG_URL
	else:
		return USERSETTINGS_RELEASE_URL

func _directoryExists(directoryUrl: String) -> bool:
	var dirExists: bool = DirAccess.dir_exists_absolute(directoryUrl)
	
	if (dirExists == false):
		Logger.LogInformation("Failed to locate " + directoryUrl + ".")
		
	return dirExists

func _fileExists(fileUrl: String) -> bool:
	var fileExists: bool = FileAccess.file_exists(fileUrl)
	
	if (fileExists == false):
		Logger.LogInformation("Failed to locate " + fileUrl + ".")
		
	return fileExists

func _openFile(fileUrl: String) -> FileAccess:
	var file: FileAccess = FileAccess.open(fileUrl, FileAccess.READ)
	
	if (file == null):
		Logger.LogError("Failed to open " + fileUrl + ".")
		
	return file

func _parseJson(fileName: String, file: FileAccess) -> Result:
	var jsonReader = JSON.new()
	var fileText = file.get_as_text(false)
	var parseResult = jsonReader.parse(fileText)
	
	if parseResult == OK:
		return Result.new(ResultType.Ok, jsonReader.data)
	else:
		Logger.LogError("Failed to parse JSON from " + fileName + ".")
		return Result.new(ResultType.Error, {})

func _merge(fileParent, environmentParent) -> void:
	if (environmentParent is Dictionary):
		for key in environmentParent:
			var environmentChild = environmentParent[key]
			
			if (fileParent.has(key) == false):
				fileParent[key] = environmentChild
			else:
				if (environmentChild is Dictionary || environmentChild is Array):
					_merge(fileParent[key], environmentChild)
				else:
					fileParent[key] = environmentChild
	elif (environmentParent is Array):
		for value in environmentParent:
			fileParent.push_back(value)
