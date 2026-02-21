shader_type canvas_item;

// --- Lens Distortion Uniforms ---
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform sampler2D normal_map : hint_normal;
uniform float distortion_strength : hint_range(0.0, 0.2) = 0.02;

// --- Film Grain Uniforms ---
uniform float grain_amount : hint_range(0.0, 1.0) = 0.05;
uniform float grain_size : hint_range(0.1, 10.0) = 1.0;

// A standard pseudorandom number generator for GLSL
float random(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
    // 1. Lens Distortion
    vec4 normal_color = texture(normal_map, SCREEN_UV);
    vec2 normal_dir = normal_color.rg * 2.0 - 1.0;
    vec2 distorted_uv = SCREEN_UV + (normal_dir * distortion_strength);
    
    // Sample the screen using the distorted UVs
    vec4 final_color = texture(screen_texture, distorted_uv);
    
    // 2. Film Grain
    // Create a constantly shifting coordinate based on screen position, size, and time
    vec2 noise_seed = SCREEN_UV * grain_size + fract(TIME);
    
    // Generate a random float between 0.0 and 1.0
    float noise = random(noise_seed);
    
    // Shift the noise to range between -0.5 and 0.5 so it both lightens and darkens the image
    // Then multiply by your grain_amount slider
    final_color.rgb += (noise - 0.5) * grain_amount;
    
    COLOR = final_color;
}