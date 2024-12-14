#include <metal_stdlib>
using namespace metal;

// 定义顶点着色器输入
struct VertexIn {
    float4 position [[attribute(0)]];
    float2 texCoord [[attribute(1)]];
};

// 定义顶点着色器输出/片段着色器输入
struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

// 顶点着色器
vertex VertexOut vertexShader(const VertexIn vertex_in [[stage_in]]) {
    VertexOut out;
    out.position = vertex_in.position;
    out.texCoord = vertex_in.texCoord;
    return out;
}

// 片段着色器
fragment float4 fragmentShader(VertexOut in [[stage_in]],
                             constant float &time [[buffer(0)]]) {
    float2 uv = in.texCoord;
    
    // 创建多层干冰效果
    float3 color = float3(0.0);
    
    for(float i = 0.0; i < 3.0; i++) {
        // 移动和缩放UV坐标
        float2 pos = uv * (1.0 - i * 0.1);
        
        // 添加时间动画
        pos.y += time * (0.1 + i * 0.05);
        pos.x += sin(time * 0.3 + i) * 0.2;
        
        // 创建干冰形状
        float shape = sin(pos.x * 10.0 + time) * 0.5 + 0.5;
        shape *= sin(pos.y * 8.0 - time * 0.5) * 0.5 + 0.5;
        
        // 添加颜色
        float3 layerColor = float3(0.7, 0.9, 1.0) * (1.0 - i * 0.2);
        color += layerColor * shape * (0.7 - i * 0.2);
    }
    
    // 添加一些随机噪声
    float noise = fract(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
    color += noise * 0.05;
    
    return float4(color, 0.7);  // 设置透明度为0.7
} 