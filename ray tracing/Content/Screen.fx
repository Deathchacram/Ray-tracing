#if OPENGL
	#define SV_POSITION POSITION
	#define VS_SHADERMODEL vs_3_0
	#define PS_SHADERMODEL ps_3_0
#else
	#define VS_SHADERMODEL vs_4_0_level_9_1
	#define PS_SHADERMODEL ps_4_0_level_9_1
#endif

Texture2D SpriteTexture;
Texture2D CurTexture;

sampler2D SpriteTextureSampler = sampler_state
{
    Texture = <CurTexture>;
};

struct VertexShaderOutput
{
	float4 Position : SV_POSITION;
	float4 Color : COLOR0;
	float2 TextureCoordinates : TEXCOORD0;
};

float4 MainPS(VertexShaderOutput input) : COLOR
{
    float4 col = tex2D(SpriteTextureSampler, input.TextureCoordinates + float2(-1 / 800, -1 / 480) / 2);
    col += tex2D(SpriteTextureSampler, input.TextureCoordinates + float2(-1 / 800, 0) / 2);
    col += tex2D(SpriteTextureSampler, input.TextureCoordinates + float2(-1 / 800, 1 / 480) / 2);
    col += tex2D(SpriteTextureSampler, input.TextureCoordinates + float2(0, -1 / 480) / 2);
    col += tex2D(SpriteTextureSampler, input.TextureCoordinates + float2(0, 0));
    col += tex2D(SpriteTextureSampler, input.TextureCoordinates + float2(0, 1 / 480) / 2);
    col += tex2D(SpriteTextureSampler, input.TextureCoordinates + float2(1 / 800, -1 / 480) / 2);
    col += tex2D(SpriteTextureSampler, input.TextureCoordinates + float2(1 / 800, 0) / 2);
    col += tex2D(SpriteTextureSampler, input.TextureCoordinates + float2(1 / 800, 1 / 480) / 2);
    col /= 9;
	
    return (col);

}

technique SpriteDrawing
{
	pass P0
	{
        PixelShader = compile PS_SHADERMODEL MainPS();
    }
};