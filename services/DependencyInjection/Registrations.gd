class_name _registrations extends Node

func _init() -> void:
	var router: Router = Router.new()
	var baseConfigurationFileReaderPath: String = router.BuildPath(
		"services/Configuration/Abstract/BaseConfigurationFileReader.gd"
	)
	var configurationFileReaderPath: String = router.BuildPath(
		"services/Configuration/ConfigurationFileReader.gd"
	)
	DependencyInjection.Register(
		baseConfigurationFileReaderPath,
		configurationFileReaderPath,
		DependencyInjectionLifetime.Scoped
	)
	
	# Register your dependencies here.
