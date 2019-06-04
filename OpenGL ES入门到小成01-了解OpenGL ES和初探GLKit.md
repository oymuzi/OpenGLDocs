### 前言

OpenGL ES (OpenGL for Embedded Systems) 是以手持和嵌入式为目标的高级3D图形应
用程序编程接口(API). OpenGL ES 是⽬前智能手机中占据统治地位的图形API.⽀持的平
台: iOS, Andriod , BlackBerry ,bada ,Linux ,Windows。iOS 允许OpenGL ES通过底层图形处理的强大功能，可以绘制复杂的2D、3D图形，进行复杂着色的计算。

其中安卓主要还是采用OpenGL ES，而iOS在iOS 12开始被废弃，但是仍然可用，官方主推Metal，但是有很多应用还是基于OpenGL ES写的，还没那么快直接迁移至Metal，就像Swift和OC一样。而且Metal的也是采取了OpenGL ES的思想和做法自己开发的一个图形接口集合，因为高度封装所以使用很方便，但是想要熟悉了解还得深入底层，那么了解和学习OpenGL ES是很有必要的，毕竟这也是iOS12之前的做法。



### 渲染流程

![渲染流程图](https://github.com/oymuzi/OpenGLDocs/raw/master/Resources/OpenGL ES图形管线.png)

#### 顶点着色器

> 着色器程序是执行顶点操作的顶点着色器程序源代码/可执行文件。

> 可接收数据有：
>
> Attribute：接收顶点数组数据
>
> Uniform：接收顶点/片元着色器使用的不变化的数据
>
> 采样器：接收纹理的特殊统一变量



**顶点着色器的主要任务是：①计算矩形变换位置  ②根据光照公式计算颜色  ③ 生成/变换纹理。顶点着色器可以执行自定义计算进行变换，以及实现光照效果等传统不能实现的功能。**



#### 图元装配

> 根据图元类型和顶点数据计算生成一个个的图元，裁剪、透视分割和视口变换操作都是在这个阶段进行，之后进入光栅化阶段。



#### 光栅化

> 在这个阶段将会把图元装配后的图元(点、线、三角形等)转化成一组二维片段的过程。二维片段有屏幕坐标、颜色属性、纹理坐标等数据，也就是屏幕上可绘制的像素，像素含有以上属性、数据，转化的片段将有片元着色器进行处理。



#### 片元着色器

> 可接受的数据：
>
> 图元变量：接收光栅化后的片元
>
> Uniform：接收顶点/片元着色器使用的不变化的数据
>
> 采样器：接收纹理的特殊统一变量



**片元着色器的主要任务：①计算颜色  ②获取纹理值  ③往像素填充颜色(颜色值/纹理值)。可以将图片/视频中的每帧的每像素中颜色进行修改，常见的有添加滤镜、美化图片等操作。**



#### 逐片段操作

![](https://github.com/oymuzi/OpenGLDocs/raw/master/Resources/OpenGLES逐片段操作.png)



### EGL(Embedded Graphics Library)

**OpenGL ES**规范没有定义窗口层，托管操作系统必须提供函数来创建一个**OpenGL ES** 渲染上下文和一个帧缓冲区，写入任何绘图命令的结果 。

**OpenGL ES 命令需要渲染上下文和绘制表面才能完成图形图像的绘制。但是OpenGL ES API并没有提供如何渲染上下文或者上下文如何连接到原生窗口系统，EGL是Khronos渲染API(OpenGL ES)和原生窗口的之间的接口，iOS是唯一支持OpenGL ES却不支持EGL的平台，因为Apple提供自己的EGL API实现——  EAGL。**

> **渲染上下文**：存储相关OpenGL ES的状态。
>
> **绘制表面**：用于绘制图元的表面，指定渲染所需的缓存区类型，例如颜色缓存区、深度缓存区和模板缓冲区。
>
> **EGLDisplay**：因为每个窗口系统都有不同的定义，所以EGL提供基本不透明的类型：EGLDisplay，这个人类型封装了所有的系统相关性，用于和原生窗口系统接口。



### 动画

我们知道动画有两种：帧动画和关键帧动画；如果需要细分的话：显性动画和隐性动画。

#### 动画循环



### GLkit

![](https://github.com/oymuzi/OpenGLDocs/raw/master/Resources/OpenGLES通过GLKit渲染过程.png)

> **GLKit** 框架的设计目标是为了简化基于**OpenGL / OpenGL ES** 的应⽤用开发。它的出现加快**OpenGL ES**或**OpenGL**应用程序开发。 使⽤数学库，背景纹理加载，预先创建的着色器器效果，以及标准视图和视图控制器来实现渲染循环。
>
> **GLKit**框架提供了功能和类，可以减少创建新的基于着⾊器的应用程序所需的工作量，或者⽀持依赖早期版本的**OpenGL ES**或**OpenGL**提供的固定函数顶点或⽚片段处理理的现有 应⽤用程序
>
> **GLKView**提供绘制场所，GLKViewController扩展于标准的UIKit设计模式，用于绘制视图内容的管理与呈现。 可参考[官方文档](<https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/DrawingWithOpenGLES/DrawingWithOpenGLES.html#//apple_ref/doc/uid/TP40008793-CH503-SW1>)说明。

**GLKit主要的功能是：①加载纹理 ②提供高性能的数学运算 ③提供常见的着色器 ④提供视图以及视图控制器。**



