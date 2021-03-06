### 前言

从上个章节我们学习了渲染的基础，可以绘制一些简单的图形，比如点、线、金字塔、三角形扇形、以及三角形圆环等图形，也感受到了绘制图形后兴奋感以及刺激感。但是在更多的场景会碰到一些问题，就比如绘制甜甜圈的时候会出现如下图的情况，简直惨不忍睹。

![](http://cloud.minder.mypup.cn/blog/OpenGL%E7%BB%98%E5%88%B6%E7%94%9C%E7%94%9C%E5%9C%88%E5%87%BA%E7%8E%B0%E7%9A%84%E9%97%AE%E9%A2%98.gif)



在绘制3D图形的场景中，我们需要指定哪些面可以被观察者看到，哪些面是需要隐藏的，就如上面的甜甜圈中，管壁都是不透明的，不应该绘制看不见的面，称为隐藏面消除(Hidden surface elimination)。

最早的做法是**油画算法**。我们知道在绘制油画时，先绘制的颜色，如果后面需要再绘制其他的颜色，那么将会覆盖之前的颜色，也就是我们只绘制最上面的图形就能解决这个隐藏面消除的问题。但是很快发现这中算法存在一种弊端，就是当三个三角形相互交叉的场景时就无法使用油画算法来解决问题。我们知道OpenGL绘制3D场景时不绘制隐藏面，那么OpenGL的性能瞬间提升了50%。



### 正背面剔除(Face Culling)

在了解正背面剔除前，我们先试想一下在一个正方形立体图形中， 最多可以看见几个页面？无论我们在那个视角，最多只能看见三个面。如果我们只绘制可以看到的面，那么那些看不见的面不绘制，反正我们也看不见，那么OpenGL的性能可以立即提升50%及以上。我们知道一个平面有两个面，正面/背面。同一时间我们只能看见一个面，那么我们只去绘制一个能看见的面，可以节省片段着色器的工作，这就是正背面剔除。了解了正背面剔除后，我们肯定会去想，既然只绘制正面，那么如何区分正背面呢？

答案是通过分析顶点数据的连接顺序。如下图所示：

![](http://cloud.minder.mypup.cn/blog/OpenGL%E9%A1%B6%E7%82%B9%E9%A1%BA%E5%BA%8F.png)

```
GLfloat vertices[] = {
    //顺时针
    vertices[0], // vertex 1
    vertices[1], // vertex 2
    vertices[2], // vertex 3
    // 逆时针
    vertices[0], // vertex 1
    vertices[2], // vertex 3
    vertices[1] // vertex 2
};
```

左侧三角形按照逆时针进行连线的，右侧则是顺时针，每个三角形都是按点顺序连线而成的三角形，**默认情况下，逆时针顺序的三角形被定义为正面，顺时针顺序的三角形定义为背面**。如果你能看见一个三角形，那么这个三角形应该是逆时针的(除了手动更改顺时针为正面)。**实际上的顶点连接顺序是在光栅化阶段计算的**，所以顶点着色器已经运行后，顶点就能在观察点被看到。

下图是一张在观察者位置看到三角形顶点的连接顺序，背面的三角形顶点的连接顺序将会反转，如果观察点在左边，那么左右边的三角形的顶点连接顺序也会反转，以便在绘制的时候来剔除背面。**正⾯和背⾯是由三⻆形的顶点定义顺序和观察者方向共同决定的.随着观察者的角度方向的改变,正面背面也会跟着改变**

![](http://cloud.minder.mypup.cn/blog/OpenGL%E8%A7%82%E5%AF%9F%E9%A1%B6%E7%82%B9%E8%BF%9E%E6%8E%A5%E9%A1%BA%E5%BA%8F.png)



讲完了是如何区分正背面，接下来说下如何使用正背面剔除。

```
//开启正背面剔除
glEnable(GL_CULL_FACE);
// 关闭正背面剔除
glDisable(GL_CULL_FACE);
// 指定正背面剔除模式 有三种形式， GL_FRONT  GL_BACK   GL_FRONT_AND_BACK 默认为GL_BACK
glCullFace(model);  

// 指定正面, 两种模式， 逆时针 GL_CCW   顺时针  GL_CW  默认为GL_CWW
glFrontFace(GL_CWW);
```

**在实际场景上，我们一般会开启正背面剔除，而且也不会去指定顺时针为正面，因为OpenGL是状态机，改的是整个正背面的状态，不利于团队开发，建议习惯逆时针为正面。**



我们开启正背面剔除后可以看到没有之前的那么不堪入目了，如下图所示。但是出现了一个新的问题，就是有的面没有绘制出来，这是为啥呢？那该怎么解决这个问题呢？

![](http://cloud.minder.mypup.cn/blog/OpenGL%E5%BC%80%E5%90%AF%E6%AD%A3%E8%83%8C%E9%9D%A2%E5%89%94%E9%99%A4%E7%9A%84%E6%95%88%E6%9E%9C.gif)



### 深度测试、Z-Buffer

上面我们看到开启正背面剔除后，还会出现以上的问题。这是因为绘制的时候，该像素被绘制到后面一点了，后面的点被正背面剔除干掉了，所以会出现这个缺口。所以解决以上问题的办法就是利用Z值来正确绘制，简称为**Z-Buffer**。

#### 深度

深度是在3D世界中的物体离摄像机的位置

#### 深度缓冲区

深度缓冲区是一块内存，存储着每个像素的深度(z值 0-1)，深度值越大，离摄像机越远，值越小，则离摄像机越近。

为什么需要深度缓冲区呢？我们再绘制的时候，先绘制了一个A图形，在绘制B图形，但是A图形的深度值比B大，但是因为最后绘制B，根据油画算法我们知道，最后显示的B，但是有了深度缓冲区后，绘制的先后顺序已经不那么重要了，根据深度值来绘制最上面的图形。实际上，只要存在深度缓冲区，那么就会往深度缓冲区写入像素的深度值，除非手动禁止写入深度值：**glDepthMask(GL_FALSE)**

#### 深度测试

深度缓冲区(DepthBuffer)和颜色缓冲区(ColorBuffer)是一一对应的。颜色缓冲区存储着每个像素的颜色，深度缓冲区存储着每个像素的深度值。在绘制物体表面的时候，会取出该表面的深度值和深度缓冲区的深度值进行比较，如果像素的深度值大于深度缓冲区的值，则丢弃这部分值，否则，则根据像素的颜色和深度更新颜色缓冲区和深度缓冲区的值，这个过程叫做深度测试。

#### 深度值计算

深度值一般由**16**位，**24**位或者**32**位值表示，通常是**24**位。位数越⾼高的话，深度的精确度越
好。深度值的范围在**[0,1]**之间，值越小表示越靠近观察者，值越大表示远离观察者。
深度缓冲主要是通过计算深度值来比较⼤小，从观察者看到其内容与场景中的所有对象的 **z** 值进⾏了比较。这些视图空间中的 **z** 值可以在投影平头截体的近平面和远平面之间的任何值。我们因此需要⼀一些⽅方法来转换这些视图空间 **z** 值到 **[0**，**1]** 的范围内**,**下⾯面的 **(**线性**)** ⽅方程把 **z** 值转换为 **0.0** 和 **1.0** 之间的值：

​						$F_{depth} = \cfrac {z - near}  {far - near}$

实际运用很少运用到上述的线程方程来计算深度值，采用非线性来计算：

​						$F_{depth} = \cfrac {1/z - 1/near}{1/far - 1/near}$

但是非线性计算也会有些问题，就是物体移动短距离就能感觉出来，还需要还原值计算处理，具体可以参考这篇[文章](https://learnopengl-cn.github.io/04%20Advanced%20OpenGL/01%20Depth%20testing/)的深度值计算部分。

#### 深度测试的应用

一般情况下，都会默认如正背面剔除一样开启。开启前清除颜色缓冲区和深度缓冲区

```
glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
glEnable(GL_DEPTH_TEST);
// 指定深度计算你的模式，模式如下，默认的模式为GL_GREATER
void glDepthFunc(GLEnum mode);
// 关闭写入深度缓冲区，开启 GL_TRUE
glDepthMask(GL_FALSE);
```

| GL_ALWAYS   | 总是通过                       |
| ----------- | ------------------------------ |
| GL_NEVER    | 总是不通过                     |
| GL_LESS     | 深度值小于缓存深度值时通过     |
| GL_EQUAL    | 深度值等于缓存深度值时通过     |
| GL_LEQUAL   | 深度值小于等于缓存深度值时通过 |
| GL_GREATER  | 深度值大于缓存深度值时通过     |
| GL_NOTEQUAL | 深度值不等于缓存深度值时通过   |
| GL_GRQUAL   | 深度值大于等于缓存深度值时通过 |

下图展示了开启和关闭深度测试的效果：

![](http://cloud.minder.mypup.cn/blog/OpenGL%E5%BC%80%E5%90%AF%E5%92%8C%E5%85%B3%E9%97%AD%E6%B7%B1%E5%BA%A6%E6%B5%8B%E8%AF%95%E7%9A%84%E6%95%88%E6%9E%9C.gif)



### ZFlighting问题

开启深度测试之后，OpenGL 就不不会再去绘制模型被遮挡的部分**.** 这样实现的显示更更加真实**.**但是由于深度缓冲区精度的限制对于深度相差非常小的情况下.(例如在同一平⾯上进行2次绘制),OpenGL 就可能出现不能正确判断两者的深度值**,**会导致深度测试的结果不不可预测**.**显示出来的现象时交错闪烁**.**的2个画⾯交错出现。

#### 解决ZFlighting方法

```
// 增加偏移量  
void glPolygonOffset(GLFloat factor, GLFloat uints);
```

使用**Polygon Offse**t来解决这个Z值冲突的问题。让深度值之间产生一个间隙，两个平面之间就不会交叉产生闪烁的问题，在图形深度测试前增加一点距离来让两个平面的深度值有所区分。使用**glPolygonOffset**增加偏移量会让每个Fragment的深度值都增加如下所示的偏移量。	

> ​					$Offset = m * factor + r * uints$
>
> m: 多边形的深度的斜率的最大值，当一个多边形越是与近裁切面平行，m就越趋于0。
>
> r： 能产生窗口坐标系的深度值由可分辨的差异最小值r，该值是由OpenGL指定的一个常量。
>
> 一个大于0的offset把物体退到远离摄像机位置的地方看起来远些；小于0的offset把物体往前拉靠近摄像机的位置看起来近些。

```
//启⽤用Polygon Offset ⽅方式
/* 参数列列表: 
 GL_POLYGON_OFFSET_POINT  对应光栅化模式: GL_POINT 
 GL_POLYGON_OFFSET_LINE   对应光栅化模式: GL_LINE
 GL_POLYGON_OFFSET_FILL   对应光栅化模式: GL_FILL
*/
glEnable(GL_POLYGON_OFFSET_FILL)

// 设置偏移值,通常这样设置即可达到解决闪烁的问题，-1.0是让物体从观察者看起来更近点
glPolygonOffset(-1.0f, -1.0f); 

// 关闭PolygonOffset, 和上面的模式相对应的三种
glDisable(GL_POLYGON_OFFSET_FILL);
```



#### 避免ZFlighting产生

1. 不要两个图形靠的太近，避免渲染时三角形叠加在一起。这种方式添加一个小量的偏移值即可，手动设置偏移值是需要付出代价的。
2. 尽可能将近裁剪面设置的离观察者远一些。在近裁剪面附近，深度值是很精确的，可以让裁剪面离观察者远一些会让整个裁剪范围的深度值更加精确，但同时也会让离观察者近的物体被裁切掉，所以需要调试好参数。
3. 使用更高位数的深度缓冲区可以提高精度，一般是用的是24位，有的会使用32位深度缓冲区。



### 裁剪区域

> 在OpenGL中提高渲染性能的一种方式是只更新更改的部分，并且可以在将要显示的缓冲区中制定一个裁剪区域。原理就是在OpenGL渲染时限制渲染区域，来帧缓冲区设置一个裁剪区域，在此裁剪区域内的物体才会被绘制，超出区域的物体将会被丢弃。
>
> 窗口：显示界面。
>
> 视口：在窗口里面的区域，可以等于窗口也可以小于窗口，在视口里面的物体才能看见，超出视口的部分是看不到的。
>
> 裁剪区域：视口矩形区域的最小最大x坐标和y坐标，通过glOrtho()函数设置最远的Z坐标，形成一个立体裁剪区域。

```
//开启裁剪测试
glEnable(GL_SCISSOR_TEST);

// 关闭裁剪测试
glDisable(GL_SCISSOR_TEST);

// 指定裁剪区域
void glScissor(Glint x,Glint y,GLSize width,GLSize height);
```



### 混合

在OpenGL渲染开启颜色缓冲区、深度缓冲区后，颜色存储在颜色缓冲区中，深度也存储在深度缓冲区。当关闭颜色缓冲区后，新的颜色片段将会简单的覆盖之前的颜色片段；当再度开启颜色缓冲区后，新的颜色片段更接近裁剪面的颜色片段时才会替换之前的颜色片段。

#### 组合颜色

> 开启颜色混合后，颜色的混合计算是根据混合方程式来计算，以下就是其中一种常用的方程式：
>
> ​			$C_f = C_s * S + C_d * D $
>
> $C_f$是混合颜色结果
>
> $C_s$是源颜色
>
> $C_d$是目标颜色
>
> $S$是源混合因子
>
> $D$是目标混合因子
>
> 还有如下混合方程式可供选择，使用设置方程式函数**glbBlendEquation(GLenum mode);**
>
> | 模式                     | 函数                          |
> | ------------------------ | ----------------------------- |
> | GL_FUNC_ADD              | $C_f$ = $C_s$ * S + $C_d$ * D |
> | GL_FUNS_SUBTRACT         | $C_f$ = $C_s$ * S - $C_d$ * D |
> | GL_FUNC_REVERSE_SUBTRACT | $C_f$ = $C_d$ * D - $C_s$ * S |
> | GL_MIN                   | $C_f$ = min($C_s$, $C_d$)     |
> | GL_MAX                   | $C_f$ = max($C_s$, $C_d$)     |

| 函数                        | RGB混合因子                         | Alpha混合因子 |
| --------------------------- | ----------------------------------- | ------------- |
| GL_ZERO                     | (0, 0, 0)                           | 0             |
| GL_ONE                      | (1, 1, 1)                           | 1             |
| GL_SRC_COLOR                | ($R_s$, $G_s$, $B_s$)               | $A_s$         |
| GL_ONE_MINUS_SRC_COLOR      | (1, 1, 1) - ($R_s$, $G_s$, $B_s$)   | 1 - $A_s$     |
| GL_DST_COLOR                | ($R_d$, $G_d$, $B_d$)               | $A_d$         |
| GL_ONE_MINUS_DST_COLOR      | (1, 1, 1) - ($R_d$, $G_d$, $B_d$)   | 1 - $A_d$     |
| GL_SRC_ALPHA                | ($A_s$, $A_s$, $A_s$ )              | $A_s$         |
| GL_ONE_MINUS_SRC_ALPHA      | (1, 1, 1) - ($A_s$, $A_s$, $A_s$ )  | 1 - $A_s$     |
| GL_DST_ALPHA                | ($A_d$, $A_d$, $A_d$)               | $A_d$         |
| GL_ONE_MINUS_DST_ALPHA      | (1, 1, 1) - ($A_d$, $A_d$, $A_d$)   | 1 - $A_d$     |
| GL_CONSTANT_COLOR           | ($R_c$, $G_c$, $B_c$)               | $A_c$         |
| GL_ONE_MINUS_CONSTANT_COLOR | (1, 1, 1) - ($R_c$, $G_c$, $B_c$)   | 1 - $A_c$     |
| GL_CONSTANT_ALPHA           | ($A_c$, $A_c$, $A_c$)               | $A_c$         |
| GL_ONE_MINUS_CONSTANT_ALPHA | (1, 1, 1) - ($A_c$, $A_c$, $A_c$)   | 1 - $A_c$     |
| GL_SRC_ALPHA_SATURATE       | (f, f, f) * f = min($A_s$, 1-$A_d$) | 1             |

表中R、G、B、A分代表红、绿、蓝、alpha。

表中下标S、D分别代表源、目标。C代表常量颜色。

```
//常用的颜色混合因子是下列函数：
glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
```

 **glBlendFunc** 指定 源和目标 RGBA值的混合函数;但是**glBlendFuncSeparate**函数则允许为RGB 和 Alpha 成分单独指定混合函数。在混合因子表中带有**CONSTANT**字符的常量混合因子，默认为黑色，可以进行更改。

```
//strRGB: 源颜色的混合因子
//dstRGB: ⽬标颜色的混合因子 
//strAlpha: 源颜色的Alpha因子 
//dstAlpha: ⽬标颜⾊的Alpha因⼦
void glBlendFuncSeparate(GLenum strRGB,GLenum dstRGB ,GLenum strAlpha,GLenum dstAlpha);
```

