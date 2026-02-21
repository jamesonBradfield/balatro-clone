shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

uniform sampler2D dissolve_texture : source_color;
uniform float dissolve_value : hint_range(0,1);

void fragment(){
    vec4 main_texture = texture(screen_texture, SCREEN_UV);
    vec4 noise_texture = texture(dissolve_texture, UV);
    main_texture.a *= floor(dissolve_value + min(1, noise_texture.x));
    COLOR = main_texture;
}