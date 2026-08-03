#pragma header

uniform float intensity;
uniform int sides[3];

void main()
{

    vec2 uv = openfl_TextureCoordv.xy;
    vec2 center = vec2(0.5,0.5);

    vec2 dir = uv - center;
    float dist = length(dir) ;

    //vec2 offset_h = vec2(intensity, 0.0);
    vec2 offset_h = dir * intensity * dist;
    vec2 offset_v = vec2(0.0, intensity);

    vec2 warpedUV = center + dir * (1.0 - intensity);

    float r = flixel_texture2D(bitmap, warpedUV + offset_h).r;
    float b = flixel_texture2D(bitmap, warpedUV + offset_h * (3)).b;
    float g = flixel_texture2D(bitmap, warpedUV + offset_h * (5)).g;

    float a = flixel_texture2D(bitmap, warpedUV).a;

    gl_FragColor = vec4(r,g,b,a);
}