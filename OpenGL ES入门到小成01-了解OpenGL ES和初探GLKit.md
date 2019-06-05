### 前言

OpenGL ES (OpenGL for Embedded Systems) 是以手持和嵌入式为目标的高级3D图形应
用程序编程接口(API). OpenGL ES 是⽬前智能手机中占据统治地位的图形API.⽀持的平
台: iOS, Andriod , BlackBerry ,bada ,Linux ,Windows。iOS 允许OpenGL ES通过底层图形处理的强大功能，可以绘制复杂的2D、3D图形，进行复杂着色的计算。

其中安卓主要还是采用OpenGL ES，而iOS在iOS 12开始被废弃，但是仍然可用，官方主推Metal，但是有很多应用还是基于OpenGL ES写的，还没那么快直接迁移至Metal，就像Swift和OC一样。而且Metal的也是采取了OpenGL ES的思想和做法自己开发的一个图形接口集合，因为高度封装所以使用很方便，但是想要熟悉了解还得深入底层，那么了解和学习OpenGL ES是很有必要的，毕竟这也是iOS12之前的做法。



### 渲染流程

![渲染流程图](https://github.com/oymuzi/OpenGLDocs/raw/master/Resources/OpenGL%20ES%E5%9B%BE%E5%BD%A2%E7%AE%A1%E7%BA%BF.png)

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



### GLkit

![](https://github.com/oymuzi/OpenGLDocs/raw/master/Resources/OpenGLES通过GLKit渲染过程.png)

> **GLKit** 框架的设计目标是为了简化基于**OpenGL / OpenGL ES** 的应⽤用开发。它的出现加快**OpenGL ES**或**OpenGL**应用程序开发。 使⽤数学库，背景纹理加载，预先创建的着色器器效果，以及标准视图和视图控制器来实现渲染循环。
>
> **GLKit**框架提供了功能和类，可以减少创建新的基于着⾊器的应用程序所需的工作量，或者⽀持依赖早期版本的**OpenGL ES**或**OpenGL**提供的固定函数顶点或⽚片段处理理的现有 应⽤用程序
>
> **GLKView**提供绘制场所，GLKViewController扩展于标准的UIKit设计模式，用于绘制视图内容的管理与呈现。 可参考[官方文档](<https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/DrawingWithOpenGLES/DrawingWithOpenGLES.html#//apple_ref/doc/uid/TP40008793-CH503-SW1>)说明。

**GLKit主要的功能是：①加载纹理 ②提供高性能的数学运算 ③提供常见的着色器 ④提供视图以及视图控制器。**



#### 几个常见的对象

###### EAGLContext

> EAGLContext对象管理OpenGL ES渲染上下文 - 使用OpenGL ES绘制所需的状态信息，命令和资源。要执行OpenGL ES命令，就需要一个当前的渲染上下文。



###### GLKView

> 一个继承自UIView而且默认使用OpenGL ES渲染的视图。GLKView类通过直接代表管理帧缓冲对象，简化了创建OpenGL ES应用程序所需的工作量;当需要更新内容时，您的应用程序只需要绘制到帧缓冲区中。



###### EAGLSharegroup

> EAGLSharegroup对象是管理一个或多个EAGLContext对象关联的OpenGL ES资源，它是在初始化EAGLContext对象时创建的，并在释放引用它的最后一个EAGLContext对象时进行处理。改对象。该对象没有提供任何接口给开发者。



###### GLKTextureLoader

> GLKTextureLoader类可以加载Image I/O框架支持的大多数图像格式的二维或立方体贴图纹理。在iOS中，它还可以加载以PVRTC格式压缩的纹理。它可以同步或异步加载数据。



###### GLKTextureInfo

> 当您的应用使用GLKTextureLoader类加载纹理时，纹理加载器会使用GLKTextureInfo对象返回有关纹理的信息。您的应用永远不会直接创建GLKTextureInfo对象。



###### GLKBaseEffect

> GLKBaseEffect类提供的着色器模仿OpenGL ES 1.1照明和着色模型提供的许多行为，包括材质，光照和纹理。基本效果允许将最多三个灯光和两个纹理应用于场景。



#### 使用GLKit加载图片

我们知道使用UIImageView加载图片很简单，但是加载图片的底层用到了OpenGL ES，而GLKView也是封装在OpenGL ES之上的，可以看看如何使用GLKView加载一张图片。

![](https://github.com/oymuzi/OpenGLDocs/raw/master/Resources/GLKit加载图片的过程.png)

**案例一：使用GLKit加载图片[OC](https://github.com/oymuzi/OpenGLDocs/tree/master/OpenGL%20ES%20Demo/OC/OpenGL%20ES%20GLKit%E5%8A%A0%E8%BD%BD%E5%9B%BE%E7%89%87)、[Swift](https://github.com/oymuzi/OpenGLDocs/tree/master/OpenGL%20ES%20Demo/Swift/OpenGL%20ES%20GLKit%E5%8A%A0%E8%BD%BD%E5%9B%BE%E7%89%87)**



##### 几个常见对象的方法、属性

###### EAGLContext

 ```swift
// 通过指定OpenGL ES版本初始化
public convenience init?(api: EAGLRenderingAPI)

// 通过指定OpenGL ES版本、OpenGL ES管理对象进行初始化
public init?(api: EAGLRenderingAPI, sharegroup: EAGLSharegroup)

// 设置当前的上下文    
open class func setCurrent(_ context: EAGLContext?) -> Bool

// 获得当前的上下文
open class func current() -> EAGLContext?

// 获取当前上下文的OpenGL ES版本    
open var api: EAGLRenderingAPI { get }

// 获取OpenGL ES管理对象
open var sharegroup: EAGLSharegroup { get }

// 标签说明上下文的用途
open var debugLabel: String?

// 是否开启多线程
open var isMultiThreaded: Bool
 ```



###### GLKView


```swift
//通过frame和上下文来进行初始化
public init(frame: CGRect, context: EAGLContext)

// 代理    
@IBOutlet unowned(unsafe) open var delegate: GLKViewDelegate?

// 上下文    
open var context: EAGLContext

//   获取帧缓冲的宽、高 
open var drawableWidth: Int { get }
open var drawableHeight: Int { get }

//渲染颜色缓冲区格式  
open var drawableColorFormat: GLKViewDrawableColorFormat
//渲染深度缓冲区格式
open var drawableDepthFormat: GLKViewDrawableDepthFormat
//渲染模板缓冲区格式
open var drawableStencilFormat: GLKViewDrawableStencilFormat
//多重采样格式
open var drawableMultisample: GLKViewDrawableMultisample

// 将帧缓冲区对象绑定到OpenGL ES
open func bindDrawable()

// 删除帧缓冲区对象
open func deleteDrawable()

// 获得绘制的一张快照，不应该在绘制时获取
open var snapshot: UIImage { get }

//控制视图是否响应setNeedsDisplay。如果为true，则视图与UIView类似。当视图已标记为响应时，将在下一个绘制周期中调用draw方法。如果是不响应时，在下一个绘图周期中永远不会调用视图的绘制方法。默认为true，但是在GLKViewController默认为false。
open var enableSetNeedsDisplay: Bool

//当enableSetNeedsDisplay值为false时，则需要使用此方法进行更新绘制内容
open func display()

// 代理方法。所有的绘制都需要在这里进行
protocol func glkView(_ view: GLKView, drawIn rect: CGRect)
```



###### GLKTextureLoader

```swift
// 通过管理对象来进行初始化
public init(sharegroup: EAGLSharegroup)

/*******以下纹理加载方法为类方法都为同步、实例方法都为异步加载*******************/

// 同步从本地文件路径加载纹理
open class func texture(withContentsOfFile path: String, options: [String : NSNumber]? = nil) throws -> GLKTextureInfo

// 同步从指定URL加载纹理
open class func texture(withContentsOf url: URL, options: [String : NSNumber]? = nil) throws -> GLKTextureInfo

// 同步从指定Assets下的图片名称来加载纹理
open class func texture(withName name: String, scaleFactor: CGFloat, bundle: Bundle?, options: [String : NSNumber]? = nil) throws -> GLKTextureInfo

// 同步从数据中加载纹理 
open class func texture(withContentsOf data: Data, options: [String : NSNumber]? = nil) throws -> GLKTextureInfo

// 同步从位图中加载纹理
open class func texture(with cgImage: CGImage, options: [String : NSNumber]? = nil) throws -> GLKTextureInfo

// 同步从本地路径加载六张图片作为立方体的纹理 右、左、上、下、前、后的顺序加载
open class func cubeMap(withContentsOfFiles paths: [Any], options: [String : NSNumber]? = nil) throws -> GLKTextureInfo

// 同步从本地路径加载一张图片宽高均乘以6后作为立方体六个面的纹理
open class func cubeMap(withContentsOfFile path: String, options: [String : NSNumber]? = nil) throws -> GLKTextureInfo 

// 同步从指定URL加载一张图片宽高均乘以6后作为立方体六个面的纹理
open class func cubeMap(withContentsOf url: URL, options: [String : NSNumber]? = nil) throws -> GLKTextureInfo
```



###### GLKTextureInfo

```swift
// 纹理的名称
open var name: GLuint { get }
// 纹理的对象
open var target: GLenum { get }
// 纹理的宽、高
open var width: GLuint { get }
open var height: GLuint { get }
// 纹理的深度
open var depth: GLuint { get }
// 纹理的透明度状态
open var alphaState: GLKTextureInfoAlphaState { get }
// 纹理的原点
open var textureOrigin: GLKTextureInfoOrigin { get }
// 是否包含mip贴图
open var containsMipmaps: Bool { get }

open var mimapLevelCount: GLuint { get }
open var arrayLength: GLuint { get }
```



###### GLKBaseEffect

```swift
// 三个光照。默认是关闭的，需要手动开启 
open var light0: GLKEffectPropertyLight { get } 
open var light1: GLKEffectPropertyLight { get }
open var light2: GLKEffectPropertyLight { get }
// 光源类型从
open var lightingType: GLKLightingType // GLKLightingTypePerVertex
// 环境颜色
open var lightModelAmbientColor: GLKVector4 // { 0.2, 0.2, 0.2, 1.0 }
// 图元材质属性
open var material: GLKEffectPropertyMaterial { get } // Default material state

// 两个纹理，默认是关闭，需要手动开启
open var texture2d0: GLKEffectPropertyTexture { get } // Disabled
open var texture2d1: GLKEffectPropertyTexture { get }
// 纹理顺序
open var textureOrder: [GLKEffectPropertyTexture]? // texture2d0, texture2d1

// 不提供顶点颜色时使用这个常量颜色
open var constantColor: GLKVector4 // { 1.0, 1.0, 1.0, 1.0 }
//雾化效果
open var fog: GLKEffectPropertyFog { get } // Disabled
// 标签
open var label: String? // @"GLKBaseEffect"

// 是否使用计算灯光与材质后的颜色
open var colorMaterialEnabled: GLboolean // GL_FALSE
// 是否是两面光照
open var lightModelTwoSided: GLboolean // GL_FALSE
// 是否使用常量颜色
open var useConstantColor: GLboolean // GL_TRUE

//准备渲染效果
open func prepareToDraw()
```





#### 常用的API

##### 上下文初始化

```swift
// 参数api是个枚举值，有openGLES1、openGLES2、openGLES3
let context = EAGLContext.init(api: .openGLES3)

// 还需要设置EAGLContext的上下文
EAGLContext.setCurrent(context)
```

##### 设置GLKView

```swift
// 初始化GLKView
glKitView = GLKView.init(frame: CGRect.init(x: 0, y: 200, width:self.view.frame.width, height: self.view.frame.width))
// 设置view的代理
glKitView.delegate = self
// 设置view的上下文
glKitView.context = context
// 设置颜色缓冲区格式
glKitView.drawableColorFormat = .RGBA8888
// 设置深度缓冲区格式
glKitView.drawableDepthFormat = .format24
// 设置多重采用格式
glKitView.drawableMultisample = .multisample4X
// 设置模板缓冲区格式
glKitView.drawableStencilFormat = .format8
self.view.addSubview(glKitView)
```



##### 创建VBO

```swift
var bufferID: GLuint = 0
glGenBuffers(1, &bufferID);
```



##### 绑定顶点缓冲区

```swift
glBindBuffer(GLenum(GL_ARRAY_BUFFER), bufferID);
```



##### 将顶点坐标、纹理坐标拷贝至缓冲区

```swift
glBufferData(GLenum(GL_ARRAY_BUFFER), GLsizeiptr(MemoryLayout<VertexBuffer>.size * vertexData.count), vertexData, GLenum(GL_STATIC_DRAW));
```

> 参数一：目标
>
> 参数二：坐标数据的大小
>
> 参数三：坐标数据
>
> 参数四：用途



##### 开启Attribute通道并传递顶点数据到缓冲区

在iOS中，苹果为了提高性能所有的通道都是默认关闭的，如需使用需要手动开启。

```
glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue))
```

在OC中获取占用字节数大小是使用函数**sizeof**来获取，在swift中使用**MemoryLayout<GLfloat>.size**。

```swift
let pointerPtr = UnsafeRawPointer.init(bitPattern: MemoryLayout<GLfloat>.size * 0)

glVertexAttribPointer(GLuint(GLKVertexAttrib.position.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<VertexBuffer>.size), pointerPtr)
```

> glVertexAttribPointer方法参数说明
>
> 参数一：传递顶点坐标的类型有五种类型：**position**[顶点]、**normal**[法线]、**color**[颜色]、**texCoord0**[纹理一]、**texCoord1**[纹理二]，这里用的是顶点类型。
>
> 参数二：每次从数据取**多少个**顶点或其他类型数据
>
> 参数三：取值得类型是啥。**GL_BYTE, GL_UNSIGNED_BYTE, GL_SHORT,GL_UNSIGNED_SHORT, GL_FIXED, 和 GL_FLOAT，初始值为GL_FLOAT。**
>
> 参数四：是否需要归一化(NDC)
>
> 参数五：步长，取完一次数据需要跨越多少步长去读取下一个数据，单位是字节数。
>
> 参数六：偏移量。每次取得数据需要偏移多少位置开始读取数据，单位是字节数。



##### 开启纹理一通道并传递纹理坐标

```swift
glEnableVertexAttribArray(GLuint(GLKVertexAttrib.texCoord0.rawValue))

let texturePtr = UnsafeRawPointer.init(bitPattern: MemoryLayout<GLfloat>.size * 3)
glVertexAttribPointer(GLuint(GLKVertexAttrib.texCoord0.rawValue), 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<VertexBuffer>.size), texturePtr)
```



##### 加载纹理

我们都知道iOS的坐标计算是从左上角[0, 0]开始，到右下角[1, 1]。**但是在纹理中的原点不是左上角而是左下角，右上角为[1, 1]**，所以如果需要图片被正确方向的加载那么需要设置纹理的原点为左下角，否则得到的图片是一张倒立的图片。我们知道GLKit只有两个纹理通道，需要三种及以上的纹理只能通过GLSL来实现。

```swift
/// 加载纹理的可选项
let options = [GLKTextureLoaderOriginBottomLeft: NSNumber.init(value: 1)];

let textureInfo = try? GLKTextureLoader.texture(withContentsOfFile: texturePath, options: options)
```



##### GLKBaseEffect

我们知道GLKView就是为了开发者更好的完成OpenGL ES的开发，所以GLKView的的着色器工作是由GLKBaseEffect来完成的。

```swift
// 初始化
let glkEffect = ELKBaseEffect()
// 设置纹理通道1可用
glEffect.texture2d0.enabled = 1
// 设置纹理名称，获取纹理名称可通过glGenTextures()
glEffect.texture2d0.name = textureInfo.name
// 设置纹理通道的目标
glEffect.texture2d0.target = GLKTextureTarget(rawValue: textureInfo.target)!
```



##### 执行绘制

执行绘制是在GLKView的代理方法**glkView(_ view: GLKView, drawIn rect: CGRect)**中

```swift
// 清除颜色缓冲区
glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
// 准备开始绘制
glEffect.prepareToDraw()
        
/** 开始绘制
 参数一：绘制的类型
 参数二：从那个点开始绘制
 参数三：总共有几个点
*/
glDrawArrays(GLenum(GL_TRIANGLES), 0, 6);
```



### 参考

参考文章：[sizeof与MemoryLayout](http://willwei.me/2017/06/30/Swift%20sizeof%E4%B8%8EMemoryLayout/)