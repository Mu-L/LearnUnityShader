// create by 长生但酒狂
// create time 2020-1-2
#include "Lighting.cginc"
// ------------------------------【计算兰伯特光照模型 - compute Lambert】-----------------------------
inline fixed3 ComputeLambertLighting (float3 worldNormal,float4 DiffuseCol = float4(1,1,1,1)) {
    // 环境光
    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
    //法线
    fixed3 normalDir = normalize(worldNormal);
    //灯光
    fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
    //漫反射计算
    fixed3 diffuse = _LightColor0.rgb * max(dot(normalDir,lightDir),0);
    fixed3 resultColor = (diffuse+ambient) * DiffuseCol.rgb;
    return resultColor;
}

// ------------------------------【计算半兰伯特光照模型 - compute half Lambert】-----------------------------
inline fixed3 ComputeHalfLambertLighting (float3 worldNormal,float4 DiffuseCol = float4(1,1,1,1)) {
    // 环境光
    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
    //法线
    fixed3 normalDir = normalize(worldNormal);
    //灯光
    fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
    //半兰伯特漫反射  值范围0-1
    fixed3 halfLambert = dot(normalDir,lightDir)*0.5+0.5;	
    fixed3 diffuse = _LightColor0.rgb * halfLambert;

    fixed3 resultColor = (diffuse+ambient) * DiffuseCol.rgb;
    return resultColor;
}

// ------------------------------【计算Phong光照模型 - compute Phong Lighting】-----------------------------
// worldNormal: 世界空间坐标系的法线
// worldVertex: 世界空间坐标系的顶点坐标
// gloss: 高光强度
// specularCol:高光颜色
// diffuseCol:漫反射颜色
inline fixed3 ComputePhongLighting (float3 worldNormal,float3 worldVertex , float gloss = 10.0, float specularCol = float4(1,1,1,1), float4 diffuseCol = float4(1,1,1,1)) {
    // 环境光
    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
    //法线
    fixed3 normalDir = normalize(worldNormal);
    // 灯光
    fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
    //漫反射
    fixed3 diffuse = _LightColor0.rgb * max(dot(normalDir,lightDir),0) * diffuseCol.rgb;
    //反射光
    fixed3 reflectDir = reflect(-lightDir,normalDir);//反射光
    //视角方向
    fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - worldVertex );
    //高光反射
    fixed3 specular = _LightColor0.rgb * pow(max(0,dot(viewDir,reflectDir)),gloss) * specularCol;
    fixed3 resultColor = diffuse+ambient+specular;
    return resultColor;
}


// ------------------------------【计算BlinnPhong光照模型 - compute BlinnPhong Lighting】-----------------------------
// worldNormal: 世界空间坐标系的法线
// worldVertex: 世界空间坐标系的顶点坐标
// gloss: 高光强度
// specularCol:高光颜色
// diffuseCol:漫反射颜色
inline fixed3 ComputeBlinnPhongLighting (float3 worldNormal,float3 worldVertex , float gloss = 10.0, float specularCol = float4(1,1,1,1), float4 diffuseCol = float4(1,1,1,1)) {
    // 环境光
    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
    //法线
    fixed3 normalDir = normalize(worldNormal);
    // 灯光
    fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
    //漫反射
    fixed3 diffuse = _LightColor0.rgb * max(dot(normalDir,lightDir),0) * diffuseCol.rgb;
    //反射光
    fixed3 reflectDir = reflect(-lightDir,normalDir);
    //视角方向
    fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - worldVertex );
    //光方向和视角方向平分线
    fixed3 halfDir = normalize(lightDir+viewDir);
    //BlinnPhong
	fixed3 specular = _LightColor0.rgb * pow(max(0,dot(normalDir,halfDir)),gloss) * specularCol;
    fixed3 resultColor = diffuse+ambient+specular;
    return resultColor;
}

// ------------------------------【计算法线贴图 - Compute Normal Map】-----------------------------
//BumpMap: 法线贴图
//uv: 法线纹理坐标
//lightDir: 切线空间下的光线方向, lightDir = mul(rotation, ObjSpaceLightDir(v.vertex));
//diffuseCol: 材质颜色
inline fixed3 ComputeNormalMap (sampler2D BumpMap,float2 uv,float3 lightDir, float4 diffuseCol = float4(1,1,1,1)) {
    //环境光
    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * diffuseCol.xyz;
    //求出切线空间下的法线
    float3 tangentNormal = UnpackNormal(tex2D(BumpMap, uv));
    //法线强度调整
    tangentNormal.xy *= _BumpScale;
    //normalize一下切线空间的光照方向
    float3 tangentLight = normalize(i.lightDir);
    //根据半兰伯特模型计算像素的光照信息
    fixed3 lambert = 0.5 * dot(tangentNormal, tangentLight) + 0.5;
    //最终输出颜色为lambert光强*材质diffuse颜色*光颜色
    fixed3 diffuse = lambert * diffuseCol.xyz * _LightColor0.xyz + ambient;
    //进行纹理采样
    fixed4 color = tex2D(_MainTex, i.uv);

	return diffuse * color.rgb;
}