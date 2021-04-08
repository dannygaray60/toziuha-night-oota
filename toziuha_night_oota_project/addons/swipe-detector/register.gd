tool
extends EditorPlugin

func _enter_tree():
    # Initialization of the plugin goes here
    # Add the new type with a name, a parent type, a script and an icon
    add_custom_type('SwipeDetector', 'Node', preload('swipe_detector.gd'), preload('icon.png'))
    print('Registered SwipeDetector')

func _exit_tree():
    # Clean-up of the plugin goes here
    # Always remember to remove it from the engine when deactivated
    remove_custom_type('SwipeDetector')
