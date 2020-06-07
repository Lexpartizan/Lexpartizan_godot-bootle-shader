# Godot_bottle_shader
This project for simple shader fake simulation liquid in bottle.
 It is based on https://www.reddit.com/r/godot/comments/guhtfm/my_wip_liquidinbottle_shader_since_this_stuff/

https://youtu.be/KsbmwZwHbZI


# Known Issues:

* We have problem with transparent for liquid for use ALPHA or SCREEN_UV if render_mode cull_disable.
So, we have 2 materials - for transparent liquid (simple, without some surfaces and simple normals) and for non transparent (more complex).

* I would like the fill variable to be in the range 0...1, but it depends on what coordinates the upper and lower points have. I'll think about it later.

* This work better for round objects.