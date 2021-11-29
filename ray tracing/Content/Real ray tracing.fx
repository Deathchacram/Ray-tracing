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
float3 _Rand;
float _Samples;

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

float random(float2 st)
{
    return frac(sin(dot(st.xy, float2(12.9898, 78.233))) * 43758.5453123);
}

float4 BoxInt(float3 origin, float3 dir, float4 pos)
{
    float3 ro = origin - pos.xyz;
    float3 m = 1 / dir;
    float3 r = pos.w;
    
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
    float3 pos = (0, 0, -1);
    float t = -(dot(origin, norm) + 1) / dot(dir, norm);
    if (t > 0)
        return float4(norm, t);
    return float4(0, 0, 0, 99999);

}

float4 SphereInt(float3 origin, float3 dir, float3 pos, float rad)
{
    float3 sPos = pos;
    float r = rad;
	
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
        if (t > 0)
            return float4(normalize(tResult), t);
    }
    return float4(0, 0, 0, 99999);
}


float4 CastRay(float3 origin, float3 dir, out float t, out float3 norm)
{
    float2x4 qubes[7];
    
    qubes[0][0] = float4(7, 7, 1.5, 3);
    qubes[1][0] = float4(7, -7, 1.5, 3);
    qubes[2][0] = float4(-7, 7, 1.5, 3);
    qubes[3][0] = float4(-7, -7, 1.5, 3);
    qubes[4][0] = float4(0, 0, -2, 3);
    qubes[5][0] = float4(1, 0, 1.3, 0.3);
    qubes[6][0] = float4(-0.7, -1.5, 1.3, 0.5);
    
    qubes[0][1] = float4(0.25, 0.28, 0.33, 0);
    qubes[1][1] = float4(0.45, 0.45, 0.45, 0.8);
    qubes[2][1] = float4(0.6, 0.7, 0.7, 0.95);
    qubes[3][1] = float4(0.85, 0.95, 0.95, 1);
    qubes[4][1] = float4(0.17, 0.4, 0.82, 0.2);
    qubes[5][1] = float4(0.30, 0.70, 0.90, 0.2);
    qubes[6][1] = float4(0.17, 0.4, 0.82, 0.2);
    
    float4 col = 1;
    float4 min = float4(0, 0, 0, 99999);
    t = 99999;
    norm = 0;
    
    float4 inf = SphereInt(origin, dir, float3(0, 1.5, 1.5), 0.5);
    if (inf.w < min.w)
    {
        min = inf;
        t = min.w;
        norm = min.xyz;
        col = float4(0.75, 0.25, 0.1, 0.8);
    }
    inf = SphereInt(origin, dir, float3(-2, 1.7, 1.5), 0.5);
    if (inf.w < min.w)
    {
        min = inf;
        t = min.w;
        norm = min.xyz;
        col = float4(1, 1, 1, 1);
    }
    inf = SphereInt(origin, dir, float3(100000, 100000, 100000), 1);
    if (inf.w < min.w)
    {
        min = inf;
        t = min.w;
        norm = min.xyz;
        col = float4(1, 1, 1, 4);
    }
    inf = SphereInt(origin, dir, float3(0, 0, 1.5), 0.5);
    if (inf.w < min.w)
    {
        min = inf;
        t = min.w;
        norm = min.xyz;
        col = float4(1, 1, 1, 4);
    }
    for (int i = 0; i < 7; i++)
    {
        inf = BoxInt(origin, dir, qubes[i][0]);
        if (inf.w < min.w)
        {
            min = inf;
            t = min.w;
            norm = min.xyz;
            col = qubes[i][1];
        }
    }
    /*inf = BoxInt(origin, dir, float3(4, 3, 0.3));
    if (inf.w < min.w)
    {
        min = inf;
        t = min.w;
        norm = min.xyz;
        col = float4(0.17, 0.4, 0.82, 0);
    }
    inf = BoxInt(origin, dir, float3(4, 6, 0));
    if (inf.w < min.w)
    {
        min = inf;
        t = min.w;
        norm = min.xyz;
        col = float4(0.17, 0.4, 0.82, 1);
    }*/
        inf = PlaneInt(origin, dir);
    if (inf.w < min.w && inf.w > 0)
    {
        min = inf;
        t = min.w;
        norm = min.xyz;
        //float c = saturate(dot(normalize(min.xyz + 0.001), normalize(_Light)));
        col = float4(0.7, 0.7, 0.7, 0.1);
    }
    if (min.w == 99999)
        return float4(0.4, 0.71, 0.87, 0.7);
    
    return float4(col);
}
float4 TraceRay(float3 origin, float3 dir, float s)
{
    float samples = 5;
    float4 col = 0;
    float t = 99999;
    float3 norm = 0;
    float m = 1;
    
    for (int i = 1; i < samples; i++)
    {
        float4 col1 = CastRay(origin, dir, t, norm) * m;
        if (t != 99999)
            m *= 0.75;
        else
            return (col + col1 * m) * col1.a / i;
        if(col1.a > 1)
            return (col + col1 * m) * col1.a;
        origin = origin + dir * (t - 0.001);
        float3 rand = float3(random(_Rand.xy * dir.yz / s) * 2 - 1, random(_Rand.zx * dir.yx / s) * 2 - 1, random(_Rand.zy * dir.xz / s) * 2 - 1);
        dir = lerp(reflect(dir, norm), rand, 1 - col1.a);
        if(dot(dir, norm) < 0)
            dir = -dir;
        col += col1 * m;
    }
    return col * 0;
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
    
    float samples = _Samples;
    for (int i = 0; i < samples; i++)
    {
        col += TraceRay(origin, dir, i);
    }
    col /= samples;
    
    //float4 tex = tex2D(SpriteTextureSampler, input.TextureCoordinates.xy);
    //return lerp(tex, col, 0.5);
    return col;
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