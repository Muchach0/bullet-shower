extends Label


func _process(delta):
    text = """FPS: %d
Memory (Static): %.2f MB
Objects: %d
Draw Calls: %d
Used Texture Memory: %.2f MB
""" % [
        Engine.get_frames_per_second(),
        Performance.get_monitor(Performance.MEMORY_STATIC) / (1024.0 * 1024.0),
        Performance.get_monitor(Performance.OBJECT_COUNT),
        Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
        Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / (1024.0 * 1024.0),
    ]