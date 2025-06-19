extends Node2D

@onready var game_over_screen: Control = $CanvasLayer/GameOverScreen
@onready var level_label: Control = $CanvasLayer/LevelLabel

@onready var star: Area2D = $Star

@onready var player: Area2D = $PlayerShip
@onready var init_player_position: Vector2 = player.position

@onready var bullets: Node2D = $Bullets
@onready var init_bullet_count: int = bullets.BULLET_COUNT
const INCREMENT_BULLET_COUNT = 50
var current_level := 1


func _ready() -> void:
    # Connect signals to the event bus
    EventBus.connect("player_hit", _on_player_hit)
    EventBus.connect("star_touched", finish_game)
    # EventBus.connect("player_respawned", self, "_on_player_respawned")


func _on_player_hit(number_of_life: int) -> void:
    print("game_logic - Player hit! Remaining lives: %d" % number_of_life)
    # Handle player hit logic here, e.g., update UI or play sound

    if number_of_life <= 0:
        finish_game(false)
    else:
        # Optionally, you can handle the case where the player still has lives left
        pass

# The button is restart is pressed, re-start the game.
func _on_button_restart_pressed() -> void:
    print("game_logic - Restart button pressed")
    EventBus.emit_signal("player_respawned")
    # player.visible = true
    
    # Update UI
    game_over_screen.visible = false
    level_label.text = "Level: " + str(current_level) + " - Bullets: " + str(init_bullet_count)
    star.visible = true

    # Freeing the bullets and re-instantiate it
    bullets.queue_free()

    # Spawning a new player
    player = preload("res://prefab/player_ship.tscn").instantiate()  # Create an instance of the food scene
    player.position = init_player_position
    add_child.call_deferred(player)

    # Spawning the bullets
    bullets = preload("res://prefab/bullets.tscn").instantiate()  # Create an instance of the bullets script
    bullets.position = Vector2.ZERO
    bullets.init_bullet_count = init_bullet_count
    add_child.call_deferred(bullets)


func finish_game(is_win:= true) -> void:
    print("Game finished.")
    # Handle game finish logic here, e.g., show a win screen or play a sound
    if is_win:
        star.visible = false
        game_over_screen.get_node("Label").text = "You Win!"
        game_over_screen.get_node("Button").text = "Next Level"
        init_bullet_count += INCREMENT_BULLET_COUNT
        current_level += 1
    else :
        game_over_screen.get_node("Label").text = "Game Over!"
        game_over_screen.get_node("Button").text = "Restart"
    game_over_screen.visible = true
    
    # Optionally, you can disable player controls or stop the game loop
    player.queue_free()
