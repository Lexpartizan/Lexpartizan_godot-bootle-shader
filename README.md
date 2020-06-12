# Godot_bottle_shader
This project for simple shader fake simulation liquid in bottle.
 It is based on https://github.com/CaptainProton42/LiquidContainerDemo

https://youtu.be/KsbmwZwHbZI


# Known Issues:

* We have problem with transparent for liquid for use ALPHA or SCREEN_UV if render_mode cull_disable.
So, we have 2 materials - for transparent liquid (simple, without some surfaces and simple normals) and for non transparent (more complex).

* This work better for symmetrical objects.