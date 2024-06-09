<div align=center>
  <img width="320" height="320" src="https://i.imgur.com/m4GIQSo.png">
</div>

# GDX v0.1.0

A Godot plugin that aims to bring industry standard tools and design patterns to the GDScript language.

## Setup

For now, the setup process is manual. The library is still in beta testing and is not available in Godot's AssetLib.

To use GDX in your Godot project, clone the **godot_v4** branch of this repository, then create a folder in your project called **gdx**, and paste in following folders:

* config

* enums

* models

* services

* tests

Then, create AutoLoads for the following classes, in the order given:

* Logger (*..services/Logger/Logger.gd*)

* DependencyInjection (*..services/DependencyInjection/DependencyInjection.gd*)

* Registrations (*..services/Registrations/Registrations.gd*)

* Configuration (*..services/Configuration/Configuration.gd*)

For a more detailed explanation of these features, please continue reading the additional sections below.

## Logging

The **Logger** class is a simple wrapper to the existing logging functions. It gives all logging methods a consistent naming convention for ease-of-use:

    Logger.LogError("Error message.")
    Logger.LogWarning("Warning message.")
    Logger.LogInformation("Information message.")

## Dependency Injection

The **DepenencyInjection** class allows you to register your dependencies at startup and to create instances of them during runtime.

First, you register your dependencies with the **Register** function, providing the path of the base class, the path of the dependency, and the dependency lifetime (Scoped or Singleton):

    DependencyInjection.Register(
        "res://BaseEnemy.tscn",
        "res://Enemy.tscn",
        DependencyInjectionLifetime.Scoped)

There is an optional parameter; ImplementationId, which allows you to register multiple dependencies of the same base type:

    DependencyInjection.Register(
        "res://BaseEnemy.tscn",
        "res://JumpingEnemy.tscn",
        DependencyInjectionLifetime.Scoped,
        EnemyType.JumpingEnemy)
    
    DependencyInjection.Register(
        "res://BaseEnemy.tscn",
        "res://ShootingEnemy.tscn",
        DependencyInjectionLifetime.Scoped,
        EnemyType.ShootingEnemy)

Note that while dependencies can be registered anywhere in your code, it is recommended to keep them all together in the **Registrations** class. All registrations defined here are automatically loaded at startup.

To instantiate a registered dependency, you can call the **Create** function, which takes the path of the base class, and an optional parameter for the implemention ID:

    var shootingEnemy: BaseEnemy = DependencyInjection.Create(
        "res://BaseEnemy.tscn",
        EnemyType.ShootingEnemy)

This returns a scene that can be added to the scene tree. Note that classes *without* scenes can also be registered and created using the method described above, replacing the scene paths with script paths.

## Unit Tester

The **TestRunner** class is responsible for running all unit tests defined within the scope of the project. This class relies heavily on mocking via the **DependencyInjection** class to acheive truly isolated unit tests.

To create a unit test, first you must create a new script in the **tests** folder that extends the **TestClass** class:

    class_name EnemySpawner_SpawnTests extends TestClass

Next, define your test functions in this new class:

    func SpawnedEnemyIsOfCorrectType() -> bool:
        # Arrange
        var enemySpawner: EnemySpawner = EnemySpawner.new()
    
        # Act
        var actual: BaseEnemy = enemySpawner.Spawn(EnemyType.ShootingEnemy)
    
        # Assert
        return actual is BaseEnemy && actual is MockShootingEnemy

Note that your test functions must return a bool to indicate the success or failure of the test to the runner.

Next, inside the constructor, you will need to register any dependencies required by your test functions:

    func _init() -> void:
        DependencyInjection.Register(
            "res://BaseEnemy.tscn",
            "res://MockShootingEnemy.tscn",
            DependencyInjectionLifetime.Scoped,
            EnemyType.ShootingEnemy)

Note that any dependencies registered in the **Registrations** class will <u>not be loaded</u> by the test runner. Instead you will need to create and register mock implementations for each of your dependencies.

Next, you will need to add your test functions to the Tests array inside the constructor:

    func _init() -> void:
        ...
        Tests = [
            SpawnedEnemyIsOfCorrectType
        ]

Once this is done, run the **TestRunner** scene directly. The results of the unit tests will be written to Godot's output terminal.

## Configuration

The **Configuration** class allows you to write application-level configuration files in JSON, and to access these settings during runtime.

To write configuration settings, navigate to the **config** folder and add your settings as key-value pairs in **appsettings.json**:

    {
        "MyNumber": 12345,
        "MyString": "Hello World",
        "MyDictionary": {
            "MyNestedArray": [
                0,
                1,
                2
            ]
        }
    }

Then use the various **Get** functions to access these settings, using a semi-colon to access nested properties:

    var myNumber: int = Configuration.GetInt("MyNumber")
    var myString: String = Configuration.GetString("MyString")
    var myArray: Array = Configuration.GetArray("MyDictionary:MyNestedArray")

You can also use the **appsettings.debug.json** and **appsettings.release.json** files if you want to add settings that only target debug or release mode respectively.

If you are wanting user-level configuration settings that are stored outside the project and are therefore invisible to the project's SCM/VCS, you can find a **usersettings.json** file, along with a debug and release equivalent, inside the user://{project}/gdx directory.
