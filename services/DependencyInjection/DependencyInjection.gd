class_name _dependencyInjection extends Node

var _registrations: Dictionary = {}
var _singletons: Dictionary = {}

const UNSPECIFIED_IMPLEMENTATION: int = -1
const IMPLEMENTATION_DELIMITER: String = "/implementationId="
const SCENE_EXTENSION: String = ".tscn"
const GDSCRIPT_EXTENSION: String = ".gd"

const ERROR_FILE_NOT_FOUND: String = "There is no scene at the given URL."
const ERROR_DUPLICATE_INTERFACE: String = "This base scene has already been registered."
const ERROR_UNREGISTERED_INTERFACE: String = "This base scene has not been registered."

func _validate(interfaceUrl: String, dependencyUrl: String, implementationId: int) -> void:
	_scenesExist(interfaceUrl, dependencyUrl)
	_isKeyDuplicated(interfaceUrl, implementationId)
	_isDependencyResourceTypeValid(dependencyUrl)

func _scenesExist(interfaceUrl: String, dependencyUrl: String) -> void:
	assert(FileAccess.file_exists(interfaceUrl), ERROR_FILE_NOT_FOUND)
	assert(FileAccess.file_exists(dependencyUrl), ERROR_FILE_NOT_FOUND)

func _isKeyDuplicated(interfaceUrl: String, implementationId: int) -> void:
	var hasKey: bool = _registrationsHasKey(interfaceUrl, implementationId)
	assert(hasKey == false, ERROR_DUPLICATE_INTERFACE)

func _isDependencyResourceTypeValid(dependencyUrl: String) -> bool:
	var resourceType: int = _getDependencyResourceType(dependencyUrl)
	return resourceType != DependencyInjectionResourceType.Unknown

func _getDependencyResourceType(dependencyUrl: String) -> int:
	if (dependencyUrl.ends_with(SCENE_EXTENSION)):
		return DependencyInjectionResourceType.Scene
	elif (dependencyUrl.ends_with(GDSCRIPT_EXTENSION)):
		return DependencyInjectionResourceType.GdScript
	else:
		return DependencyInjectionResourceType.Unknown

func _buildKey(interfaceUrl: String, implementationId: int) -> String:
	return interfaceUrl + IMPLEMENTATION_DELIMITER + str(implementationId)

func _registrationsHasKey(interfaceUrl: String, implementationId: int) -> bool:
	return _registrations.keys().any(func(r: String):
		return r == _buildKey(interfaceUrl, implementationId)
	)

func _instantiateDependency(key: String) -> Node:
	var dependency: Dependency = _registrations[key]
	var dependencyBuilder: Resource = load(_registrations[key].DependencyUrl)
	
	if (dependency.ResourceType == DependencyInjectionResourceType.Scene):
		return dependencyBuilder.instantiate()
	elif (dependency.ResourceType == DependencyInjectionResourceType.GdScript):
		return dependencyBuilder.new()
	else:
		return null

func Register(
	interfaceUrl: String,
	dependencyUrl: String,
	lifetime: int,
	implementationId: int = UNSPECIFIED_IMPLEMENTATION) -> void:
	
	if (OS.is_debug_build()):
		_validate(interfaceUrl, dependencyUrl, implementationId)
	
	var key: String = _buildKey(interfaceUrl, implementationId)
	var resourceType: int = _getDependencyResourceType(dependencyUrl)
	var value: Dependency = Dependency.new(dependencyUrl, lifetime, resourceType)
	
	_registrations[key] = value
	
	Logger.LogInformation("Registering \"" + dependencyUrl + "\" as \"" + interfaceUrl + "\".")

func Create(
	interfaceUrl: String,
	implementationId: int = UNSPECIFIED_IMPLEMENTATION) -> Node:
	
	var key: String = _buildKey(interfaceUrl, implementationId)
	var hasKey: bool = _registrationsHasKey(interfaceUrl, implementationId)
	assert(hasKey == true, ERROR_UNREGISTERED_INTERFACE)
	
	var dependency: Dependency = _registrations[key]
	var instance: Node
	
	if (dependency.Lifetime == int(DependencyInjectionLifetime.Singleton)):
		if (_singletons.has(key)):
			instance = _singletons[key]
		else:
			instance = _instantiateDependency(key)
			_singletons[key] = instance
	else:
		instance = _instantiateDependency(key)
	
	return instance

func Clear() -> void:
	_registrations.clear()
	_singletons.clear()

func Has(
	interfaceUrl: String,
	implementationId: int = UNSPECIFIED_IMPLEMENTATION) -> bool:
	return _registrationsHasKey(interfaceUrl, UNSPECIFIED_IMPLEMENTATION)
