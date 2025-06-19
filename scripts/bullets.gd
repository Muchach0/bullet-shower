extends Node2D
# This demo is an example of controling a high number of 2D objects with logic
# and collision without using nodes in the scene. This technique is a lot more
# efficient than using instancing and nodes, but requires more programming and
# is less visual. Bullets are managed together in the `bullets.gd` script.

const BULLET_COUNT = 200
const SPEED_MIN = 20
const SPEED_MAX = 80

# Test drawing circle by hand
const BASE_LINE_WIDTH: float = 3.0
const DRAW_COLOR = Color.WHITE * Color(1, 0, 0, 0.5)

# const bullet_image := preload("res://assets/bullet2.png")

var init_bullet_count = BULLET_COUNT
var bullets := []
var shape := RID()



class Bullet:
    var position := Vector2()
    var speed := 1.0
    # The body is stored as a RID, which is an "opaque" way to access resources.
    # With large amounts of objects (thousands or more), it can be significantly
    # faster to use RIDs compared to a high-level approach.
    var body := RID()

func _ready() -> void:
    # EventBus.connect("player_respawned", init_game)
    init_game()

func init_game() -> void:
    print("bullets.gd - initiating the game")
    shape = PhysicsServer2D.circle_shape_create()
    # Set the collision shape's radius for each bullet in pixels.
    PhysicsServer2D.shape_set_data(shape, 8)
    bullets = []
    print("bullets.gd - creating %d bullets" % init_bullet_count)
    for _i in init_bullet_count:
        var bullet := Bullet.new()
        # Give each bullet its own random speed.
        bullet.speed = randf_range(SPEED_MIN, SPEED_MAX)
        bullet.body = PhysicsServer2D.body_create()

        PhysicsServer2D.body_set_space(bullet.body, get_world_2d().get_space())
        PhysicsServer2D.body_add_shape(bullet.body, shape)
        # Don't make bullets check collision with other bullets to improve performance.
        PhysicsServer2D.body_set_collision_mask(bullet.body, 0)

        # Place bullets randomly on the viewport and move bullets outside the
        # play area so that they fade in nicely.
        bullet.position = Vector2(
            randf_range(0, get_viewport_rect().size.x),
            randf_range(0, get_viewport_rect().size.y) - get_viewport_rect().size.y
        )
        var transform2d := Transform2D()
        transform2d.origin = bullet.position
        PhysicsServer2D.body_set_state(bullet.body, PhysicsServer2D.BODY_STATE_TRANSFORM, transform2d)

        bullets.push_back(bullet)




func _process(_delta: float) -> void:
    # Order the CanvasItem to update every frame.
    queue_redraw()


func _physics_process(delta: float) -> void:
    var transform2d := Transform2D()
    var offset := - 16
    for bullet: Bullet in bullets:
        bullet.position.y += bullet.speed * delta

        if bullet.position.y >  get_viewport_rect().size.y:
            # Move the bullet back to the right when it left the screen.
            bullet.position.y = offset

        transform2d.origin = bullet.position
        PhysicsServer2D.body_set_state(bullet.body, PhysicsServer2D.BODY_STATE_TRANSFORM, transform2d)


# Instead of drawing each bullet individually in a script attached to each bullet,
# we are drawing *all* the bullets at once here.
func _draw() -> void:
    # var offset := -bullet_image.get_size() * 0.5
    var offset := Vector2(BASE_LINE_WIDTH * 0.5, BASE_LINE_WIDTH * 0.5)

    for bullet: Bullet in bullets:
        # draw_texture(bullet_image, bullet.position + offset)
        draw_circle(bullet.position + offset, BASE_LINE_WIDTH * 2.0, DRAW_COLOR)


# Perform cleanup operations (required to exit without error messages in the console).
func _exit_tree() -> void:
    for bullet: Bullet in bullets:
        PhysicsServer2D.free_rid(bullet.body)

    PhysicsServer2D.free_rid(shape)
    bullets.clear()
