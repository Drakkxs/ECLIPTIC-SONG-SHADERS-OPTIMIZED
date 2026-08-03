#pragma header

uniform float glowStrength;
uniform float glowSize;
uniform vec3 glowColor;

void main()
{
    vec2 uv = openfl_TextureCoordv;
    vec4 base = flixel_texture2D(bitmap, uv);

    vec2 px = glowSize / openfl_TextureSize.xy;

    float glow = 1.0;

    glow += flixel_texture2D(bitmap, uv + vec2( px.x, 0.0)).a;
    glow += flixel_texture2D(bitmap, uv + vec2(-px.x, 0.0)).a;
    glow += flixel_texture2D(bitmap, uv + vec2(0.0,  px.y)).a;
    glow += flixel_texture2D(bitmap, uv + vec2(0.0, -px.y)).a;

    glow += flixel_texture2D(bitmap, uv + vec2( px.x,  px.y)).a;
    glow += flixel_texture2D(bitmap, uv + vec2(-px.x,  px.y)).a;
    glow += flixel_texture2D(bitmap, uv + vec2( px.x, -px.y)).a;
    glow += flixel_texture2D(bitmap, uv + vec2(-px.x, -px.y)).a;


    vec3 finalColor = base.rgb + glowColor * glow * glowStrength * (1.0 - base.a);

    gl_FragColor = vec4(finalColor, max(base.a, glow * glowStrength));
}