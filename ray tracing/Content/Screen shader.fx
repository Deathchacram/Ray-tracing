#if OPENGL
	#define SV_POSITION POSITION
	#define VS_SHADERMODEL vs_3_0
	#define PS_SHADERMODEL ps_3_0
#else
	#define VS_SHADERMODEL vs_4_0_level_9_1
	#define PS_SHADERMODEL ps_4_0_level_9_1
#endif

Texture2D SpriteTexture;
float3 _Pos;
float3 _Light;
float2 _MouceRot;

sampler2D SpriteTextureSampler = sampler_state
{
	Texture = <SpriteTexture>;
};

struct VertexShaderOutput
{
	float4 Position : SV_POSITION;
	float4 Color : COLOR0;
	float2 TextureCoordinates : TEXCOORD0;
};

float4 BoxInt(float3 origin, float3 dir, float3 pos)
{
    float3 ro = origin - pos;
    float3 m = 1 / dir;
    float3 r = 1;
    
    float3 n = ro * m;
    float3 k = abs(m) * r;
    float3 t1 = -n - k;
    float3 t2 = -n + k;
    float tmin = max(max(t1.x, t1.y), t1.z);
    float tmax = min(min(t2.x, t2.y), t2.z);
    
    if (tmin < tmax && tmax > 0)
    {
        float3 norm = -sign(dir) * step(t1.yzx, t1.xyz) * step(t1.zxy, t1.xyz);
        return float4(normalize(norm), tmin);
    }
    return float4(0, 0, 0, 99999);
}

float4 PlaneInt(float3 origin, float3 dir)
{
    float3 norm = float3(0, 0, 1);
    norm = normalize(norm);
    float3 pos =  (0, 0, -1);
    float t = -(dot(origin, norm) + 1) / dot(dir, norm);
    if(t > 0)
        return float4(norm, t);
    return float4(0, 0, 0, 99999);

}

float4 SphereInt(float3 origin, float3 dir) 
{
	float3 sPos = float3(4, 0, 0);
	float r = 1;
	
	float3 k = origin - sPos;
	float b = dot(k, dir);
	float c = dot(k, k) - r * r;
	float d = b * b - c;
	if (d >= 0)
	{
		float sqrtfd = sqrt(d);
		float t1 = (-b + sqrtfd);
		float t2 = (-b - sqrtfd);
		
		float min_t = min(t1, t2);
		float max_t = max(t1, t2);
		
		float t = (min_t >= 0) ? min_t : max_t;
        float3 tResult = origin + dir * t - sPos;
        if(t > 0)
            return float4(normalize(tResult), t);
    }
    return float4(0, 0, 0, 99999);
}

float4 CastRay(float3 origin, float3 dir, out float t, out float3 norm)
{
    float4 col = 1;
    float4 min = float4(0, 0, 0, 99999);
    t = 99999;
    norm = 0;
    
    float4 inf = SphereInt(origin, dir);
    if (inf.w < min.w)
    {
        min = inf;
        t = min.w;
        norm = min.xyz;
        float c = saturate(dot(normalize(norm), normalize(_Light)));
        col = float4(0.75, 0.25, 0.1, 0.5);
    }
    inf = BoxInt(origin, dir, float3(4, 3, 0.2));
    if (inf.w < min.w)
    {
        min = inf;
        t = min.w;
        norm = min.xyz;
        float c = saturate(dot(normalize(norm), normalize(_Light)));
        col = float4(0.17, 0.4, 0.82, 1);
    }
    inf = BoxInt(origin, dir, float3(4, 6, 0));
    if (inf.w < min.w)
    {
        min = inf;
        t = min.w;
        norm = min.xyz;
        float c = saturate(dot(normalize(norm), normalize(_Light)));
        col = float4(0.17, 0.4, 0.82, 1);
    }
    inf = PlaneInt(origin, dir);
    if (inf.w < min.w && inf.w > 0)
    {
        min = inf;
        t = min.w;
        norm = min.xyz;
        //float c = saturate(dot(normalize(min.xyz + 0.001), normalize(_Light)));
        col = float4(0.5, 0.5, 0.5, 0);
    }
    if (min.w == 99999)
        return float4(0.4, 0.71, 0.87, 1);
    
    return float4(col);
}

float4 MainPS(VertexShaderOutput input) : COLOR
{
    float rotX = -radians(_MouceRot.x);
    float rotY = -radians(_MouceRot.y);
    float4 min = float4(0, 0, 0, 99999);
    float4 col = 0;
    float3 origin = _Pos;
    float3 dir = float3(1, (input.TextureCoordinates.x - 0.5f) * 1.66f, -input.TextureCoordinates.y + 0.5f);
    dir.zx = mul(dir.zx, float2x2(cos(rotY), -sin(rotY), sin(rotY), cos(rotY)));
    dir.xy = mul(dir.xy, float2x2(cos(rotX), -sin(rotX), sin(rotX), cos(rotX)));
    dir = normalize(dir);
    float t = 99999;
    float3 norm = 0;
    float m = 1;
    
    for (int i = 1; i < 16; i++)
    {
        col += CastRay(origin, dir, t, norm);
        if (t != 99999)
            m *= 0.8;
        else
            return col * m / i;
        origin = origin + dir * (t - 0.001);
        dir = reflect(dir, norm);
    }
    return col * m / 8;
    /*col = CastRay(origin, dir, t, norm);
    if (t != 99999)
    {
        float c = dot(normalize(norm), normalize(_Light));
        float3 or = origin + dir * (t - 0.001);
        dir = reflect(dir, norm);
        float3 norm1 = 0;
        float4 shd = CastRay(or, normalize(_Light), t, norm1);
        
        if (t != 99999)
            col.xyz *= 0.5;
        else if(col.w != 0)
            col.xyz *= max(0.5, c);
        //col.xyz = max(col.x, 0.2);
        return col * 1.1;
    }
    return float4(0.3, 0.61, 0.77, 1);*/
    
	//return tex2D(SpriteTextureSampler, input.TextureCoordinates) * input.Color;
	//return float4(input.TextureCoordinates, 0, 1);
}

technique SpriteDrawing
{
	pass P0
	{
		PixelShader = compile PS_SHADERMODEL MainPS();
	}
};