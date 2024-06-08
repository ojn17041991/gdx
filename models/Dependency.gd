class_name Dependency extends Node

var DependencyUrl: String
var Lifetime: int
var ResourceType: int

func _init(dependencyUrl: String, lifetime: int, resourceType: int) -> void:
	DependencyUrl = dependencyUrl
	Lifetime = lifetime
	ResourceType = resourceType
