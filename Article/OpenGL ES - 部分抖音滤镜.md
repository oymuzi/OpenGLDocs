### 前言

在学习完灰度、翻转、旋涡、马赛克滤镜后是不是觉得滤镜也就这么回事，今天学习抖音部分滤镜：缩放、灵魂出窍、抖动、闪白、毛刺，其中那个灵魂出窍我最喜欢。



### 缩放滤镜

![](http://cloud.minder.mypup.cn/blog/OpenGL%20ES%E6%8A%96%E9%9F%B3%E6%BB%A4%E9%95%9C-%E7%BC%A9%E6%94%BE.gif)

还记得那段时间嘛，满屏都是小姐姐就这样搞了我头晕，这个滤镜的原理以及实现就是改变顶点数据来达到这样的变化，顶点着色器的代码如下：

```c

attribute vec4 position;
attribute vec2 textureCoordinate;
varying lowp vec2 textureCoord;

uniform float time;
const float PI = 3.1415926;

void main(){
    
    // 缩放市场
    float duration = 0.6;
    // 缩放幅度
    float amplitude = 0.25;
    // 周期
    float period = mod(time, duration);
    // 当前幅度 [1, 1.25]
    float currentAmplitude = 1.0 + amplitude * (sin(time * (PI / duration)));
    // 纹理坐标
    textureCoord = textureCoordinate;
    gl_Position = vec4(position.x * currentAmplitude, position.y * currentAmplitude, position.z, position.w);
}
```



### 灵魂出窍滤镜

![](http://cloud.minder.mypup.cn/blog/OpenGL%20ES%20%E6%8A%96%E9%9F%B3%E6%BB%A4%E9%95%9C-%E7%81%B5%E9%AD%82%E5%87%BA%E7%AA%8D.gif)

是不是这个镜头让你趴在抖音里看然后天天被打，我们仔细观看可以知道有一层透明的图像放大，然后消失，再根据我们传时间以及开启定时器让他无限循环就完成了这个效果。这个是改变纹理数据，所以我们需要片段着色器中实现：

````c
precision highp float;
varying lowp vec2 textureCoord;
uniform sampler2D sampler;
uniform float time;

void main(){
    
    float duration = 0.7;
    float maxAlpha = 0.4;
    float maxScale = 1.8;
    
    float progress = mod(time, duration) / duration;
    float alpha = maxAlpha * (1.0 - progress);
    float scale = 1.0 + progress * (maxScale - 1.0);
    
    float sx = 0.5 + (textureCoord.x - 0.5) / scale;
    float sy = 0.5 + (textureCoord.y - 0.5) / scale;
    
    vec2 coord = vec2(sx, sy);
    vec4 mask = texture2D(sampler, coord);
    vec4 origin = texture2D(sampler, textureCoord);
    
    
    gl_FragColor = origin * (1.0 - alpha) + mask * alpha;
}
````



### 抖动滤镜

![](http://cloud.minder.mypup.cn/blog/OpenGL%20ES%E6%8A%96%E9%9F%B3%E6%BB%A4%E9%95%9C-%E6%8A%96%E5%8A%A8.gif)

同学喜欢不喜欢我不知道，反正我不喜欢这个滤镜，看着头晕一点感觉都没得，但是有点刺激的感觉豁，像极了蹦迪时候的你吧😑。仔细观看可以发现有偏移和放大以及蓝色和红色两种颜色闪动，实现这个滤镜也就是这关键的两点以及时间：

```c
precision highp float;
varying lowp vec2 textureCoord;
uniform sampler2D sampler;

uniform float time;

void main(){
    float duration = 0.75;
    float maxScale = 1.2;
    float offset = 0.04;
    
    float progress = mod(time, duration) / duration;
    vec2 offsetCoord = vec2(offset, offset) * progress;
    float scale = 1.0 + (maxScale - 1.0) * progress;
    
    vec2 shakeCoord = vec2(0.5, 0.5) + (textureCoord - vec2(0.5, 0.5)) / scale;
    
    vec4 maskR = texture2D(sampler, shakeCoord - offsetCoord);
    vec4 maskB = texture2D(sampler, shakeCoord + offsetCoord);
    vec4 mask = texture2D(sampler, shakeCoord);
    
    gl_FragColor = vec4(maskR.r, mask.g, maskB.b, mask.a);
    
}
```



### 闪白滤镜

![](http://cloud.minder.mypup.cn/blog/OpenGL%20ES%20%E6%8A%96%E9%9F%B3%E6%BB%A4%E9%95%9C-%E9%97%AA%E7%99%BD.gif)

呃呃，就不说这个滤镜了，这个滤镜实现很简单，我们观察就能知道有一层白色透明度随时间变化，所以看下代码就行啦：

```c
precision highp float;
varying lowp vec2 textureCoord;
uniform sampler2D sampler;

uniform float time;
const float PI = 3.1415926;

void main(){
    
    float duration = 0.75;
    float currentTime = mod(time, duration);
    
    vec4 whiteMask = vec4(1.0, 1.0, 1.0, 1.0);
    float amplitude = abs(currentTime * sin(PI / duration));
    
    vec4 mask = texture2D(sampler, textureCoord);
    
    
    gl_FragColor = mask * (1.0 - amplitude) + whiteMask *amplitude;
}
```



### 毛刺滤镜

![](http://cloud.minder.mypup.cn/blog/OpenGL%20ES%20%E6%8A%96%E9%9F%B3%E6%BB%A4%E9%95%9C-%E6%AF%9B%E5%88%BA.gif)

是不是快看腻了，这个滤镜也是女的用的多，男的少。这个滤镜原理在于随机偏移1像素是否小于设置的最大偏移阈值与幅度的乘积时来撕裂，所以我们看到图像只有一些撕裂的，其他的则是偏移。

```c
precision highp float;
varying lowp vec2 textureCoord;
uniform sampler2D sampler;

uniform float time;
const float PI = 3.1415926;

float rand(float n) {
    // fract(x) 返回x的小数部分数值
    return fract(sin(n) * 50000.0);
}

void main(){
    
    float maxJitter = 0.06;
    float duration = 0.35;
    float colorROffset = 0.03;
    float colorBOffset = -0.03;
    
    float currentTime = mod(time, duration * 2.0);
    float amplitude = max(sin(currentTime * (PI / duration)), 0.0);
    
    float jitter = rand(textureCoord.y) * 2.0 - 1.0;
    bool needOffset = abs(jitter) < maxJitter * amplitude;
    
    float textureX = textureCoord.x + (needOffset ? jitter : (jitter * amplitude * 0.006));
    vec2 textureCoords = vec2(textureX, textureCoord.y);
    
    vec4 mask = texture2D(sampler, textureCoords);
    vec4 maskR = texture2D(sampler, textureCoords + vec2(colorROffset * amplitude, 0.0));
    vec4 maskB = texture2D(sampler, textureCoords + vec2(colorBOffset * amplitude, 0.0));
    
    gl_FragColor = vec4(maskR.r, mask.g, maskB.b, mask.a);
}
```



### 总结

感觉以后都看几次抖音后，可以试着去尝试他的思路把模仿出来🤔。**有兴趣的同学可以再这里获取demo: [传送门](https://github.com/oymuzi/OpenGLDocs)**， 如果对你有帮助，帮忙点个star✨，谢谢。

