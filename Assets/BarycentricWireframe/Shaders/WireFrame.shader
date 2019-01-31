Shader "Custom/Wire Frame"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Gain ("Gain", Float) = 1.5
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma target 3.0
			#pragma glsl
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2g
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			struct g2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 bary : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Gain;

			v2g vert (appdata v)
			{
				v2g o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			[maxvertexcount(3)]
            void geom(triangle v2g input[3], inout TriangleStream<g2f> outStream)
            {
				[unroll]
				for (int i = 0; i < 3; i++)
				{
					v2g v = input[i];
					g2f o;
					o.vertex = v.vertex;
					o.uv = v.uv;
					o.bary = float3((i == 0), (i == 1), (i == 2));

					outStream.Append(o);
				}

				outStream.RestartStrip();
			}

			float edgeFactor(float3 bary)
			{
				float3 d = fwidth(bary);
				float3 a3 = smoothstep(float3(0, 0, 0), _Gain * d, bary);
				return min(min(a3.x, a3.y), a3.z);
			}

			fixed4 frag (g2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				float t = edgeFactor(i.bary);
				
				return col * t;
			}
			ENDCG
		}
	}
}
