#pragma header
uniform float iTime;
#define iChannel0 bitmap
#define texture flixel_texture2D
#define fragColor gl_FragColor
#define mainImage main

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void mainImage()
{
    vec2 uv = openfl_TextureCoordv.xy;
    vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
    vec2 iResolution = openfl_TextureSize;
    vec4 texColor = texture(iChannel0, uv);//Get the pixel at xy from iChannel0
    
    float gt = 30.0;// + rand(vec2(iTime, iTime)) * 3.0;
    float m = mod(iTime, 0.45);
    bool glitch = m < 0.5;
    float t = floor(iTime * gt) / gt;
    float r = rand(vec2(t, t));
    
    if(glitch) {
		
        vec2 uvGlitch = uv;
        uvGlitch.x -= r / 4.0;
        if(uv.y > r && uv.y < r + 0.1) {
    		texColor = texture(iChannel0, uvGlitch);
        }
    }
    
    fragColor = texColor;
	//fragColor = vec4(uv,0.5+0.5*sin(iTime),1.0);
}
