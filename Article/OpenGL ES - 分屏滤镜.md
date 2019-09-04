### 前言

我的上篇文章写了了解GLSL和简单的使用GLSL来加载一张纹理图片，还讲到过默认绘制的纹理是翻转以及相关解决办法，这篇讲的是分屏滤镜，我们玩过抖音都知道有个分屏滤镜的特效，我们今天实现一下简易版。图片渲染流程是一致的，只是GLSL代码不一样，不熟悉流程的可以查看之前文章。本篇文章主要讲述的是分屏的GLSL和思路。



### 原始图片

![](http://cloud.minder.mypup.cn/blog/OpenGL%20ES%20%E5%88%86%E5%B1%8F%E6%BB%A4%E9%95%9C1.jpg)

这张是我们加载图片，**有点模糊不是加载的问题是我找的这张图质量不咋地，但是不影响我玩它**，其中图片显示区域就是我们设置的绘制区域。下面的都是在这个区域内进行绘制的。

### 二屏滤镜

我们看到原始图片要如何才会变成上面的二屏滤镜呢，之前也说过纹理加载就是根据顶点数据和纹理顶点映射过去的，所以在我们只要控制好映射就能无限的分屏。

需要怎么控制呢？肯定不是在流程里，因为都是同样的编译链接程序；肯定也不是在顶点着色里控制，因为和顶点没有关系的，答案就在片段着色器中。

我们看看着色器的代码：

```c
varying lowp vec2 textureCoord;
uniform sampler2D sampler;

void main(){
    lowp vec2 uv = vec2(0.0, 0.0);
    if (textureCoord.x < 0.5) {
        uv.x = textureCoord.x + 0.25;
        uv.y = textureCoord.y;
    } else {
        uv.x = textureCoord.x - 0.25;
        uv.y = textureCoord.y;
    }
    gl_FragColor = texture2D(sampler, uv);
}
```

是不是很纳闷，这样就可以达到二分屏的效果，因为分成了左右两屏，那么每屏的高度是一致的，而宽度则是原来的一半。那么为啥需要`textureCoord.x + 0.25;`呢，这是因为我们分屏的时候你总不想别人总是看你的纹理的左边一半吧，更倾向于是看中间的，你也可以直接显示的区域是中心的一部分，看自己心情😃。

![](http://cloud.minder.mypup.cn/blog/OpenGL%20ES%20%E5%88%86%E5%B1%8F%E6%BB%A4%E9%95%9C%E6%80%9D%E8%B7%AF.png)

### 三屏滤镜

![](http://cloud.minder.mypup.cn/blog/OpenGL%20ES%20%E5%88%86%E5%B1%8F%E6%BB%A4%E9%95%9C3.png)

通过上面的二屏我们可以知道三屏的实现，其实也很简单，抖音的三屏是竖向的，我们下面也实现竖向的三屏。

```c
varying lowp vec2 textureCoord;
uniform sampler2D sampler;

void main(){
    lowp vec2 uv = vec2(0.0, 0.0);
    if (textureCoord.y < 1.0/3.0) {
        uv.x = textureCoord.x;
        uv.y = textureCoord.y + 1.0/3.0;
    } else if (textureCoord.y > 2.0/3.0){
        uv.x = textureCoord.x;
        uv.y = textureCoord.y - 1.0/3.0;
    } else {
        uv.x = textureCoord.x;
        uv.y = textureCoord.y;
    }
    gl_FragColor = texture2D(sampler, uv);
}

```





### 四屏滤镜

知道二屏、三屏了，四屏你还会远嘛？

```c
varying lowp vec2 textureCoord;
uniform sampler2D sampler;
void main(){
    lowp vec2 uv = vec2(0.0, 0.0);
    if (textureCoord.x < 0.5) {
        if (textureCoord.y < 0.5) {
            uv.x = textureCoord.x * 2.0;
            uv.y = textureCoord.y * 2.0;
        } else {
            uv.x = textureCoord.x * 2.0;
            uv.y = (textureCoord.y - 0.5) * 2.0;
        }
    } else {
        if (textureCoord.y < 0.5) {
            uv.x = (textureCoord.x - 0.5) * 2.0;
            uv.y = textureCoord.y * 2.0;
        } else {
            uv.x = (textureCoord.x - 0.5) * 2.0;
            uv.y = (textureCoord.y - 0.5) * 2.0;
        }
    }
    gl_FragColor = texture2D(sampler, uv);
}

```

![](http://cloud.minder.mypup.cn/blog/OpenGL%20ES%20%E5%88%86%E5%B1%8F%E6%BB%A4%E9%95%9C4.jpg)

### 六屏、九屏滤镜

当你知道如何划分的时候你知道任何屏数该如何解决问题了，上面是六屏和九屏。代码的话也是差不多的。

![](http://cloud.minder.mypup.cn/blog/OpenGL%20ES%20%E5%88%86%E5%B1%8F%E6%BB%A4%E9%95%9C6.jpg)

![](http://cloud.minder.mypup.cn/blog/OpenGL%20ES%20%E5%88%86%E5%B1%8F%E6%BB%A4%E9%95%9C9.jpg)



### 总结

我们从上面了解了分屏滤镜的原理后可以自定义写n屏滤镜，主要还是利用映射的关系。**有兴趣的同学可以再这里获取demo: [传送门](https://github.com/oymuzi/OpenGLDocs)**， 如果对你有帮助，帮忙点个star✨，谢谢。