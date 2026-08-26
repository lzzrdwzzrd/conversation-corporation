shader_type canvas_item;

uniform float washout_intensity : hint_range(0.0, 1.0) = 0.3;
uniform float blur_amount : hint_range(0.0, 5.0) = 1.0;
uniform float blockiness : hint_range(50.0, 300.0) = 150.0;
uniform float color_steps : hint_range(8, 32) = 16.0;
uniform float grain_amount : hint_range(0.0, 0.1) = 0.02;

float rand(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

float chaotic_drift(float base_value, float range, float seed, vec2 block_region) {
    float slow = floor(TIME / 3.5 + seed * 1.3);
    float mid = floor(TIME / 0.6 + seed * 2.7);
    float fast = floor(TIME / 0.15 + seed * 0.9);

    float base = rand(vec2(slow + seed, seed * 3.1));
    float jump = rand(vec2(mid  + seed, block_region.x * 4.0 + seed));
    float spike = rand(vec2(fast + seed, block_region.y * 4.0 + seed));

    float spike_weight = step(0.82, rand(vec2(fast * 0.3 + seed, seed * 1.7)));

    float drift = base * 0.55 + jump * 0.35 + spike * spike_weight * 0.10;

    return base_value + (drift - 0.5) * range;
}

void fragment() {
    vec2 region = floor(UV * 6.0) / 6.0;

    float live_blur = clamp(chaotic_drift(blur_amount, blur_amount * 1.4, 0.0, region), 0.0, 8.0);
    float live_blockiness = clamp(chaotic_drift(blockiness, blockiness * 0.6, 5.31, region), 30.0, 400.0);
    float live_steps = clamp(chaotic_drift(color_steps, color_steps * 0.7, 11.7, region), 4.0, 48.0);

    vec2 block_uv = floor(UV * live_blockiness) / live_blockiness;
    vec2 texel_size = vec2(1.0) / vec2(textureSize(TEXTURE, 0));

    vec4 color = vec4(0.0);
    vec3 avg_color = vec3(0.0);
    int samples = 0;

    for (float x = -1.0; x <= 1.0; x++) {
        for (float y = -1.0; y <= 1.0; y++) {
            if (mod(x + y, 2.0) == 0.0) {
                color += texture(TEXTURE, block_uv + vec2(x, y) * texel_size * live_blur);
                avg_color += texture(TEXTURE, block_uv + vec2(x, y) * texel_size).rgb;
                samples++;
            }
        }
    }
    color /= float(samples);
    avg_color /= float(samples);

    float grayscale = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    color.rgb = mix(color.rgb, vec3(grayscale) + vec3(0.1), washout_intensity);
    color.rgb = floor(color.rgb * (live_steps * 1.5)) / (live_steps * 1.5);

    float noise = (rand(block_uv + fract(TIME * 0.1)) - 0.5) * 2.0;
    color.rgb += noise * (grain_amount * 0.5) * (1.0 - grayscale);

    COLOR = clamp(color, 0.0, 1.0);
}