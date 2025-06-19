extends Node2D
# This demo is an example of controling a high number of 2D objects with logic
# and collision without using nodes in the scene. This technique is a lot more
# efficient than using instancing and nodes, but requires more programming and
# is less visual. Bullets are managed together in the `bullets.gd` script.


@export var INIT_NUMBER_OF_LIFE := 1
## The number of bullets currently touched by the player.
var touching := 0


var speed: float = 200.0

@onready var sprite_size: Vector2 = ($Sprite2D.texture.get_size() * scale) / 2

var number_of_life := INIT_NUMBER_OF_LIFE
var is_invincible: bool = false

var init_position = position
# @onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
    material.set_shader_parameter("enable_effect", false)
    # EventBus.connect("player_respawned", _on_player_respawned)
    # The player follows the mouse cursor automatically, so there's no point
    # in displaying the mouse cursor.
    # Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func _process(delta) -> void:
    # Getting the movement of the mouse so the sprite can follow its position.
    # if event is InputEventMouseMotion:
    #     position = event.position - Vector2(0, 16)

    # Get input from the joystick
    var x_input = Input.get_axis("ui_left", "ui_right")
    var y_input = Input.get_axis("ui_up", "ui_down")

    # Move the player according to the inputs
    var direction = Vector2(x_input, y_input).normalized()
    position += direction * speed * delta

    # Clamp the player's position to stay within the screen bounds
    var screen_size = get_viewport_rect().size
    position.x = clamp(position.x, 0 + sprite_size.x , screen_size.x - sprite_size.x)
    position.y = clamp(position.y, 0 + sprite_size.y, screen_size.y - sprite_size.y)




func _on_body_shape_entered(_body_id: RID, _body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:

    # Player got touched by a bullet so sprite changes to sad face.
    touching += 1

    # print("player.gd - player touched by: %s" % _body_id)

    if !is_invincible:
        print("Player got touched by a bullet")
        number_of_life -= 1
        EventBus.emit_signal("player_hit", number_of_life)


    if touching >= 1:
        material.set_shader_parameter("enable_effect", true)
        # sprite.frame = 1


func _on_body_shape_exited(_body_id: RID, _body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
    touching -= 1
    # When non of the bullets are touching the player,
    # sprite changes to happy face.
    if touching == 0:
        material.set_shader_parameter("enable_effect", false)
        # sprite.frame = 0


func _on_star_area_entered(area:Area2D) -> void:
    print("The star is touched")
    pass # Replace with function body.


func _on_area_entered(area: Area2D) -> void:
    print("The star is touched 2 - area group: ", area.get_groups())
    if "star" in area.get_groups():
        print("The star is touched 3")
        EventBus.emit_signal("star_touched")
    pass # Replace with function body.
