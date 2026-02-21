shader_type canvas_item;

/** 0 = Magic Matrix
 *  1 = Bayer Matrix
 *  2 = Random Threshold Dither
 */
uniform int dither_mode : hint_range(0, 2) = 0;
uniform bool enable_dither = true;
/** The random dither pattern can be animated over time
 *  or frozen if preferred
 */
uniform bool random_dither_animate = true;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, repeat_disable, filter_nearest;

const vec4 magic_matrix[4] = vec4[](
    vec4(0.0, 0.857, 0.143, 1.0),
    vec4(0.571, 0.286, 0.714, 0.429),
    vec4(0.429, 0.714, 0.286, 0.571),
    vec4(1.0, 0.143, 0.857, 0.0)
);

const vec4 bayer_matrix[4] = vec4[](
    vec4(0.0, 0.571, 0.143, 0.714),
    vec4(0.571, 0.0, 0.714, 0.143),
    vec4(0.429, 1.0, 0.286, 0.857),
    vec4(1.0, 0.429, 0.857, 0.286)
);

vec3 random_noise_vec3(vec2 pos) {
    float time_offset = random_dither_animate ? TIME : 0.0;
    return vec3(
        fract(sin(dot(pos, vec2(12.9898, 78.233)) + time_offset * 1.0) * 43758.5453),
        fract(sin(dot(pos, vec2(4.898, 63.233)) + time_offset * 1.2) * 23421.3453),
        fract(sin(dot(pos, vec2(9.298, 28.233)) + time_offset * 1.4) * 54325.5453)
    );
}

vec3 apply_dithering(vec3 color, vec2 screen_pos) {
    const float PALETTE_STEP = 8.0 / 255.0;
    vec3 color_scaled = color * 255.0;

    if (dither_mode == 2) {
        vec3 threshold = random_noise_vec3(screen_pos);
        vec3 error = fract(color_scaled / 8.0);
        return color + step(threshold, error) * PALETTE_STEP;
    } 
    else {
        float threshold = (dither_mode == 0) ? 
            magic_matrix[int(mod(screen_pos.y, 4.0))][int(mod(screen_pos.x, 4.0))] : 
            bayer_matrix[int(mod(screen_pos.y, 4.0))][int(mod(screen_pos.x, 4.0))];
        vec3 quantized = floor(color_scaled / 8.0) * 8.0;
        vec3 can_dither = step(quantized, vec3(247.0)) * step(vec3(1.0), color_scaled);
        return color + (step(threshold, fract(color_scaled / 8.0)) * PALETTE_STEP * can_dither);
    }
}

void fragment() {
    vec3 color = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
    if (enable_dither) {
        color = apply_dithering(color, FRAGCOORD.xy);
    }
    color = clamp(color, 0.0, 248.0 / 255.0);
    COLOR = vec4(floor(color * 255.0 / 8.0) * (8.0/255.0), 1.0);
}