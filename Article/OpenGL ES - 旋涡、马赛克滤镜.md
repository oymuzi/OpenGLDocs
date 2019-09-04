### 前言

上篇文章已经学习了分屏滤镜的实现，本篇文章主要讲的是旋涡和马赛克滤镜，当然也包括了一些常见的滤镜-灰度滤镜、翻转滤镜。还是从简单的说起吧。



### 简单滤镜

![](http://cloud.minder.mypup.cn/blog/OpenGL%20ES%20%E7%AE%80%E5%8D%95%E7%9A%84%E6%BB%A4%E9%95%9C%E6%95%88%E6%9E%9C.png)

#### 灰度滤镜

我们使用苹果手机拍照的时候有个特效是黑白的，在一些常见的App上都有灰度滤镜效果。在我们了解图片的色彩后会知道灰度滤镜会是非常的简单。这里有篇文章可以看下颜色编码：[YUV的那些事](https://juejin.im/post/5d29987c51882568f83c8afe)。图片灰度最简单的办法就是颜色中的RGB分量都是用G的值，该图片就是灰度图片。下面有五种方法进行灰度计算：

> **浮点算法**                  Gray = Gray = R * 0.3 + G * 0.59 + B * 0.11

> **整数算法**                  Gray = (R * 30 + G * 59 + B * 11) / 100

> **移位算法**                  Gray = (R * 76 + G * 151 + B * 28) >> 8

> **平均值法**                  Gray = (R + G + B) / 3;

> **取G值法**                   Gray = G;



下面我们使用平均值方法来做灰度滤镜的处理

```c
precision highp float;
varying vec2 textureCoord;
uniform sampler2D sampler;

void main(){
    vec4 mask = texture2D(sampler, textureCoord);
    float color = (mask.r + mask.g + mask.b) / 3.0;
    gl_FragColor = vec4(color, color, color, 1.0);
}
```



#### 翻转滤镜

我最开始的念头就是在矫正纹理的时候不矫正不就得到了一张翻转图嘛😃，但是理性告诉我不能这样，不然其他滤镜咋整。这个滤镜和上面的那个滤镜可以说一样的简单。

```c
varying lowp vec2 textureCoord;
uniform sampler2D sampler;

void main(){
    gl_FragColor = texture2D(sampler, vec2(textureCoord.x, 1.0 - textureCoord.y));
}
```



### 旋涡滤镜

旋涡滤镜在我们的抖音也有，旋涡这个滤镜有点复杂，甚至比蜂型的马赛克还难理解。我们先看一张效果图。看完了这张惨不忍睹的图片后我们在来看看旋涡滤镜的原理。

![](http://cloud.minder.mypup.cn/blog/OpenGL%20ES%20%E6%97%8B%E6%B6%A1%E6%BB%A4%E9%95%9C.png)

> 利用了一个抛物线衰减公式：**(1.0 - (r / Radius) * (r / Radius))** 。假设我们在一块区域内旋转采样点，这块区域都会有旋转的效果，如果我们在旋转的过程中加入这个衰减的因子，那么就会造成我们看到的这张图片的模样。

```c

precision highp float;
varying vec2 textureCoord;
uniform sampler2D sampler;

const float PI = 3.1415926;
const float angle = 80.0;
const float radius = 0.3;

void main(){
    
    // 旋转正方形范围
    vec2 rectSize = vec2(0.5, 0.5);
    // 旋转区域的内切圆直径
    float votexDiameter = rectSize.s;
    // 纹理坐标
    vec2 st = textureCoord;
    // 旋涡的半径
    float votexRadius = votexDiameter * radius;
    vec2 textureCoordinate = st * votexDiameter;
    vec2 textureCoordinateHalf = textureCoordinate - vec2(votexDiameter / 2.0, votexDiameter / 2.0);
    float r = length(textureCoordinateHalf);
    float factor = atan(textureCoordinateHalf.y, textureCoordinateHalf.x) + radians(angle) * 2.0 * (1.0 - (r / votexRadius) * (r / votexRadius));
    
    // 在旋涡内的图像进行旋转
    if (r < votexRadius){
        textureCoordinate = votexDiameter * 0.5 + r * vec2(cos(factor), sin(factor));
    }
    
    st = textureCoordinate / votexDiameter;
    vec3 irgb = texture2D(sampler, st).rgb;
    
    
    
    gl_FragColor = vec4(irgb, 1.0);
}
```





### 马赛克滤镜

说起马赛克我们都知道且应用的非常广泛，挡住了许多同学的幻想和渴望，哈哈，国家为了保护个人隐私和避免一些血腥的场景产生影响都会使用马赛克。马赛克不止我们常见的那种，还有少见的蜂型马赛克和三角形马赛克。下面是三种马赛克的实例。

![](http://cloud.minder.mypup.cn/blog/OpenGL%20ES%20%E9%A9%AC%E8%B5%9B%E5%85%8B%E6%BB%A4%E9%95%9C.png)



#### 一般马赛克

一般马赛克的叫法是我取的名字，为了区分后两者马赛克，别见怪。一般马赛克的原理非常简单，就是一定区域内的颜色为同一种颜色，这样就隐藏了图片的细节，所以就达到了遮掩的效果。相信看到这里的同学就该知道去除马赛克不靠谱了，就别惦记着了。**用到了floor函数也是马赛克的关键，相信聪明的同学应该知道啥意思和用途了吧。**

```c
precision highp float;
varying lowp vec2 textureCoord;
uniform sampler2D sampler;

vec2 imageSize = vec2(400.0, 400.0); // 图片大小
vec2 mosaicSize = vec2(8.0, 8.0);    // 马赛克大小

void main(){
    // 计算图像实际位置
    vec2 position = vec2(textureCoord.x * imageSize.x, textureCoord.y * imageSize.y);
    // 计算一个小马赛克的位置并使用了floor函数，该函数是马赛克的重要关键
    vec2 mosaicPosition = vec2(floor(position.x / mosaicSize.x) * mosaicSize.x, floor(position.y / mosaicSize.y) * mosaicSize.y);
    // 换算纹理坐标
    vec2 texPosition = vec2(mosaicPosition.x / imageSize.x, mosaicPosition.y / imageSize.y);
    vec4 color = texture2D(sampler, texPosition);
    
    gl_FragColor = color;
}
```



#### 蜂型马赛克

蜂型马赛克我只见过一两次，第一次见得时候觉得很不错，至少让我看马赛克也舒服点。但是蜂型马赛克有点复杂。我们在宽高比为**3:√3**的矩形中看这些正六边形。只要这些每个六边形的颜色一致就会变成蜂型马赛克，也就是类似于降低了图片的分辨率。

![](http://cloud.minder.mypup.cn/blog/OpenGL%20ES%20%E8%9C%82%E5%9E%8B%E9%A9%AC%E8%B5%9B%E5%85%8B%E7%9F%A9%E5%BD%A2%E5%88%86%E6%9E%90.png)

我们知道这些后就需要对矩形内的点进行计算后使用不同的颜色进行着色就能实现。仔细看能发现是有规律的，有两种矩形，再根据当前点离哪个六边形的中心点近就使用该矩形的中心点颜色进行渲染。![](http://cloud.minder.mypup.cn/blog/OpenGL%20ES%20%E8%9C%82%E5%9E%8B%E9%A9%AC%E8%B5%9B%E5%85%8B%E4%B8%A4%E7%A7%8D%E7%9F%A9%E5%BD%A2%E5%88%86%E6%9E%90.png)

也就是说有左上右下、左下右上这两种情况，然后再根据坐标来进行计算



```c
precision highp float;
varying lowp vec2 textureCoord;
uniform sampler2D sampler;

// 马赛克大小
const float mosaicSize = 0.03;

void main(){
    
    float length = mosaicSize;
    // 矩形长度
    float TX = 3.0 / 2.0;
    // 矩形高度
    float TY = sqrt(3.0) / 2.0;
    
    float x = textureCoord.x;
    float y = textureCoord.y;
    // 计算出当前矩形在竖向的第几个
    int wx = int(x / TX / length);
    // 计算出当前矩形在横向的第几个
    int wy = int(y / TY / length);
    // 用于记录
    vec2 v1, v2, vn;
    
    // 判断是否为偶数行。不能使用取余来计算会出现错误，当前的作用类似于: wx % 2 == 0
    if (wy / 2 * 2 == wy) {
        if (wx / 2 * 2 == wx){
            // 左下和右上
            v1 = vec2(length * TX * float(wx), length * TY * float(wy));
            v2 = vec2(length * TX * float(wx + 1), length * TY * float(wy + 1));
        } else {
            // 左上和右下
            v1 = vec2(length * TX * float(wx), length * TY * float(wy + 1));
            v2 = vec2(length * TX * float(wx + 1), length * TY * float(wy));
        }
    }
    else {
        if (wx / 2 * 2 == wx){
            // 左上和右下
            v1 = vec2(length * TX * float(wx), length * TY * float(wy + 1));
            v2 = vec2(length * TX * float(wx + 1), length * TY * float(wy));
        } else {
            // 左下和右上
            v1 = vec2(length * TX * float(wx), length * TY * float(wy));
            v2 = vec2(length * TX * float(wx + 1), length * TY * float(wy + 1));
        }
    }

    // 判断当前点离哪个六边形近，就用近的颜色
    float s1 = sqrt(pow(v1.x - x, 2.0) + pow(v1.y - y, 2.0));
    float s2 = sqrt(pow(v2.x - x, 2.0) + pow(v2.y - y, 2.0));

    if (s1 < s2){
        vn = v1;
    } else {
        vn = v2;
    }

    vec4 color = texture2D(sampler, vn);
    
    gl_FragColor = color;
}
```



#### 三角形马赛克

三角形马赛克在上面的蜂型马赛克在进一步分解，一个正六边形里分解成六个三角形，然后在进行计算颜色值。

```c
precision highp float;
varying lowp vec2 textureCoord;
uniform sampler2D sampler;

const float mosaicSize = 0.03;
const float PI6 = 0.62831852;

void main(){
    
    float length = mosaicSize;
    float TX = 3.0 / 2.0;
    float TY = sqrt(3.0) / 2.0;
    
    float x = textureCoord.x;
    float y = textureCoord.y;
    
    int wx = int(x / TX / length);
    int wy = int(y / TY / length);
    
    vec2 v1, v2, vn;
    
    if (wx / 2 * 2 == wx) {
        if (wy / 2 * 2 == wy){
            v1 = vec2(length * TX * float(wx + 1), length * TY * float(wy));
            v2 = vec2(length * TX * float(wx), length * TY * float(wy + 1));
        } else {
            v1 = vec2(length * TX * float(wx + 1), length * TY * float(wy + 1));
            v2 = vec2(length * TX * float(wx), length * TY * float(wy));
        }
    }
    else {
        if (wy / 2 * 2 == wy){
            v1 = vec2(length * TX * float(wx + 1), length * TY * float(wy + 1));
            v2 = vec2(length * TX * float(wx), length * TY * float(wy));
        } else {
            v1 = vec2(length * TX * float(wx + 1), length * TY * float(wy));
            v2 = vec2(length * TX * float(wx), length * TY * float(wy + 1));
        }
    }
    
    float s1 = sqrt(pow(v1.x - x, 2.0) + pow(v1.y - y, 2.0));
    float s2 = sqrt(pow(v2.x - x, 2.0) + pow(v2.y - y, 2.0));
    
    if (s1 < s2){
        vn = v1;
    } else {
        vn = v2;
    }
    
    vec4 midColor = texture2D(sampler, vn);
    
    float a = atan((x - vn.x) / (y - vn.y));
    vec2 area1 = vec2(vn.x, vn.y - mosaicSize * TY / 2.0);
    vec2 area2 = vec2(vn.x + mosaicSize / 2.0, vn.y - mosaicSize * TY / 2.0);
    vec2 area3 = vec2(vn.x + mosaicSize / 2.0, vn.y + mosaicSize * TY / 2.0);
    vec2 area4 = vec2(vn.x, vn.y + mosaicSize * TY / 2.0);
    vec2 area5 = vec2(vn.x - mosaicSize / 2.0, vn.y + mosaicSize * TY / 2.0);
    vec2 area6 = vec2(vn.x - mosaicSize / 2.0, vn.y - mosaicSize * TY / 2.0);

    if (a >= PI6 && a < PI6 * 3.0) {
        vn = area1;
    } else if (a >= PI6 * 3.0 && a < PI6 * 5.0) {
        vn = area2;
    } else if ((a >= PI6 * 5.0 && a <= PI6 * 6.0) || (a < -PI6 * 5.0 && a > -PI6 * 6.0)) {
        vn = area3;
    } else if (a < -PI6 * 3.0 && a >= -PI6 * 5.0) {
        vn = area4;
    } else if(a <= -PI6 && a> -PI6 * 3.0) {
        vn = area5;
    } else if (a > -PI6 && a < PI6) {
        vn = area6;
    }
    
    vec4 color = texture2D(sampler, vn);
    
    gl_FragColor = color;
}
```



### 总结

马赛克滤镜利用的就是一块区域内展示一种颜色，这样就隐藏了图片中细节图像，达到马赛克的效果。同时文中也说过，知道怎么做马赛克，就别想着去马赛克了。**有兴趣的同学可以再这里获取demo: [传送门](https://github.com/oymuzi/OpenGLDocs)**， 如果对你有帮助，帮忙点个star✨，谢谢。