### 了解纹理

从专业名词释义这篇文章我们知道纹理其实就是在绘制图形的时候把颜色填充替换成了图片进行填充，因为不可能所有的场景都是使用纯色来渲染，有时需要一些图片来渲染达到更加逼真的效果。在OpenGL中纹理一般采用.tga格式文件，这种格式文件是一种特殊格式文件，在OpenGL ES中还可以采用位图png、jpg等格式文件。

### 浅谈像素

我们知道电脑、计算机等彩色显示屏都是使用三原色光加色技术，以RGB三原色作为子像素构成一像素，由多个像素构成整个画面。早期的彩色显示屏主要以阴极射线管(CRT)为主，后来是液晶显示器(LCD)。在RGB中每像素由24位比特组成，即三个8位无符号二进制整数（0-255）表示红色、绿色、蓝色的强度。用于真彩色和JPEG或者TIFF等图像格式里的通用颜色交换，可以产生1600多万种颜色，但是我们人眼最多只能识别1000万种颜色。可以查看[这篇文章](https://juejin.im/post/5d29987c51882568f83c8afe)关于图片的编码。



### 纹理像素

##### 像素相关函数

```c
// 改变像素存储方式
void glPixelStorei(GLenum pname, GLint param);

// 恢复像素存储方式
void glPixelStoref(GLenum pname, GLfloat param);

// 参数一：指定OpenGL如何从数据缓存区中解包图像。GL_UNPACK_ALIGNMENT 指内存中每个像素行起点的排列请求
// 参数二：表示参数设置的值。1：byte排列  2： 排列为偶数byte的行  3：字word排列  8：行从双字节边界开始
glPixelStorei(GL_UNPACK_ALIGMENT, 1);
```



像素格式表：

|      像素格式      | 描述                                                         |
| :----------------: | ------------------------------------------------------------ |
|       GL_RGB       | 红、绿、蓝顺序排列的颜色                                     |
|      GL_RGBA       | 红、绿、蓝、透明度顺序排列的颜色                             |
|       GL_BGR       | 蓝、绿、红顺序排列颜色                                       |
|      GL_BGRA       | 蓝、绿、红、透明度顺序排列颜色                               |
|       GL_RED       | 每个像素只包含了一个红色分量                                 |
|      GL_GREEN      | 每个像素只包含了一个绿色分量                                 |
|      GL_BLUE       | 每个像素只包含了一个蓝色分量                                 |
|       GL_RG        | 每个像素分别包含了一个红色、绿色分量                         |
|   GL_RED_INTEGER   | 每个像素包含了一个整数形式的红色分量                         |
|  GL_GREEN_INTEGER  | 每个像素包含了一个整数形式的绿色分量                         |
|  GL_BLUE_INTEGER   | 每个像素包含了一个整数形式的蓝色分量                         |
|   GL_RG_INTEGER    | 每个像素分别包含了一个整数形式的红色、绿色分量               |
|   GL_RGB_INTEGER   | 每个像素分别包含了一个整数形式的红色、蓝色、绿色分量         |
|  GL_RGBA_INTEGER   | 每个像素分别包含了一个整数形式的红色、蓝色、绿色、透明度分量 |
|   GL_BGR_INTEGER   | 每个像素分别包含了一个整数形式的蓝色、绿色、红色分量         |
|  GL_BGRA_INTEGER   | 每个像素分别包含了一个整数形式的蓝色、绿色、红色、透明度分量 |
|  GL_STENCIL_INDEX  | 每个像素只包含了一个模板值                                   |
| GL_DEPTH_COMPONENT | 每个像素包含了一个深度值                                     |
|  GL_DEPTH_STENCIL  | 每个像素分别包含了一份深度值、模板值                         |



像素数据类型表：

|           像素数据类型            | 描述                                                         |
| :-------------------------------: | ------------------------------------------------------------ |
|         GL_UNSIGNED_BYTE          | 每种颜色分量都是一个8位无符号的整数   1字节                  |
|              GL_BYTE              | 每种颜色分量都是一个8位有符号的整数      1字节               |
|         GL_UNSIGNED_SHORT         | 每种颜色分量都是一个16位无符号的整数    2字节                |
|             GL_SHORT              | 每种颜色分量都是一个16位有符号的整数    2字节                |
|          GL_USIGNED_INT           | 每种颜色分量都是一个32位无符号的整数    4字节                |
|              GL_INT               | 每种颜色分量都是一个32位有符号的整数    4字节                |
|             GL_FLOAT              | 单精度浮点值                                                   4字节 |
|           GL_HALF_FLOAT           | 半精度浮点数                                                   2字节 |
|      GL_UNSIGNED_BYTE_3_2_2       | 包装的RGB值                                                  |
|    GL_UNSIGNED_BYTE_2_3_3_REV     | 包装的RGB值                                                  |
|      GL_UNSIGNED_SHORT_5_6_5      | 包装的RGB值                                                  |
|    GL_UNSIGNED_SHORT_5_6_5_REV    | 包装的RGB值                                                  |
|      GL_UNSIGNED_SHORT_4_4_4      | 包装的RGB值                                                  |
|    GL_UNSIGNED_SHORT_4_4_4_REV    | 包装的RGB值                                                  |
|     GL_UNSIGNED_SHORT_5_5_5_1     | 包装的RGB值                                                  |
|   GL_UNSIGNED_SHORT_1_5_5_5_REV   | 包装的RGB值                                                  |
|      GL_UNSIGNED_INT_8_8_8_8      | 包装的RGB值                                                  |
|    GL_UNSIGNED_INT_8_8_8_8_REV    | 包装的RGB值                                                  |
|    GL_UNSIGNED_INT_10_10_10_2     | 包装的RGB值                                                  |
|  GL_UNSIGNED_INT_2_10_10_10_REV   | 包装的RGB值                                                  |
|       GL_UNSIGNED_INT_24_8        | 包装的RGB值                                                  |
|    GL_UNSIGNED_INT_10F_11F_REV    | 包装的RGB值                                                  |
| GL_FLOAT_24_UNSIGNED_INT_24_8_REV | 包装的RGB值                                                  |



##### 纹理API

###### 从颜色缓冲区内容作为像素图直接读取

> 参数x：矩形左下角的窗口坐标
>
> 参数y：矩形左下角的窗口坐标
>
> 参数width：矩形的宽
>
> 参数height：矩形的高
>
> 参数 format：OpenGL的像素格式，参考下面的像素格式表
>
> 参数 type：结束参数pixels指向的数据类型，参考下面的像素数据类型表

```c
void glReadPixels(GLint x, GLint y, GLSizei width, GLSizei height, GLenum format, GLenum type, const void * pixels);
```



###### 载入纹理(一维、二维、三维纹理)

> 参数 target：`GL_TEXTURE_1D`、`GL_TEXTURE_2D`、`GL_TEXTURE_3D`
>
> 参数 level：指定所加载的mip贴图纹理层次，一般都是设置0
>
> 参数 internalformat：每个纹理单元中存储多少颜色成分
>
> 参数 width：纹理宽度
>
> 参数 height：纹理高度
>
> 参数 depth：纹理深度
>
> 注：宽度、高度、深度三者的值在OpenGL/OpenGL ES的老版本中必须为2的整数次幂，现在没有这个限制

```c
void glTexImage1D(GLenum target, GLint level, GLint internalformat, GLsizei width, GLint border, GLenum format, GLenum type, void *data);

void glTexImage2D(GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, void *data);

void glTexImage3D(GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLsizei depth, GLint border, GLenum format, GLenum type, void *data);
```



###### 更新纹理

> 参数 target：`GL_TEXTURE_1D`、`GL_TEXTURE_2D`、`GL_TEXTURE_3D`
>
> 参数 level：指定所加载的mip贴图纹理层次，一般都是设置0
>
> 参数 xOffset：需要更新纹理的起点偏移起点的位置x值
>
> 参数 yOffset：需要更新纹理的起点偏移起点的位置y值
>
> 参数 width：纹理宽度
>
> 参数 height：纹理高度
>
> 参数 depth：纹理深度

```c
void glTexSubImage1D(GLenum target, GLint level, 
                    GLint xOffset, 
                    GLsizei width, 
                    GLenum format, GLenum type, const GLvoid *data);
                    
void glTexSubImage2D(GLenum target, GLint level, 
                    GLint xOffset, GLint yOffset, 
                    GLsizei width, GLsizei height,
                    GLenum format, GLenum type, const GLvoid *data);
                    
void glTexSubImage3D(GLenum target, GLint level, 
                    GLint xOffset, GLint yOffset, GLint zOffset,
                    GLsizei width, GLsizei height, GLsizei depth,
                    GLenum format, GLenum type, const GLvoid *data);
```



###### 插入纹理

```c
void glCopyTexSubImage1D(GLenum target, GLint level, 
                    GLint xOffset, 
                    GLint x, GLint y, 
                    GLsizei width);
                    
void glCopyTexSubImage2D(GLenum target, GLint level, 
                    GLint xOffset, GLint yOffset
                    GLint x, GLint y, 
                    GLsizei width, GLsizei height);
                    
void glCopyTexSubImage1D(GLenum target, GLint level, 
                    GLint xOffset, GLint yOffset, GLint zOffset,
                    GLint x, GLint y, 
                    GLsizei width, GLsizei height);
```



###### 生成纹理

其中参数x、y在颜色缓存区中指定了开始读取纹理数据的位置，是源缓存区通过glReadBuffer设置的。还有点与其他纹理函数不同的是不存在**glCopyTexImage3D**，因为我们无法从2D颜色缓存区中获取深度数据。

```c
void glCopyTexImage1D(GLenum target, GLint level, GLenum internalformat, GLint x, GLint y, GLSizei width, GLint border);

void glCopyTexImage2D(GLenum target, GLint level, GLenum internalformat, GLint x, GLint y, GLsizei width, GLsizei height, GLint border);
```



###### 纹理对象



使用函数分配纹理对象

> 指定纹理对象的数量和指针

```c
void glGenTextures(GLsizei n, GLuint *textures);
```



绑定纹理状态

> 其中target和上面API中target是一样的，texture为需要绑定的纹理对象

```c
void glBindTexture(GLenum target, GLuint texture);
```



删除绑定纹理对象

> 纹理对象以及纹理对象指针

```c
void glDeleteTextures(GLSizei m, GLuint *textures);
```



测试纹理对象

> 如果该纹理对象有效将会返回 GL_TRUE，反之返回GL_FALSE

```c
GLboolean glISTexure(GLuint texture);
```



### 纹理参数

> 下面四个函数的区别主要在于纹理数据类型
>
> 参数 target：纹理维度，GL_TEXTURE_1D、GL_TEXTURE_2D、GL_TEXTURE_3D。
>
> 参数 pname：纹理参数
>
> 参数 param：纹理参数的值

```c
glTexParameterf(GLenum target, GLenum pname, GLFloat param);
glTexParameteri(GLenum target, GLenum pname, GLint param);
glTexParameterfv(GLenum target, GLenum pname, GLFloat *param);
glTexParameteriv(GLenum target, GLenum pname, GLint *param);
```

##### 纹理过滤

###### 基本过滤

纹理填充时需要进行拉伸缩放时的过程叫做纹理过滤。在OpenGL 中可以同时设置放大过滤器以及缩小过滤器。在OpenGL或OpenGL ES中常用的就有两种纹理过滤器算法：邻近过滤算法和线性过滤算法。其中邻近过滤算法的特征是图片拉大时会有斑驳块的像素，而线性过滤算法的特征在图片拉大的时候会出现我们知道的失真现象，则更接近现实。

![](http://cloud.minder.mypup.cn/blog/OpenGL-%E7%BA%B9%E7%90%86%E8%BF%87%E6%BB%A4%E6%96%B9%E5%BC%8F.png)

> 参数一：纹理维度
>
> 参数二：**放大**(GL_TEXTURE_MAG_FILTER)/**缩小**(GL_TEXTURE_MIN_FILTER) **过滤器**
>
> 参数三：设置过滤器的算法    **邻近过滤**：GL_NEARST   **线性过滤**：GL_LINEAR

```
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEARST);
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
```



###### 多行渐远过滤

在使用多个纹理时有些物体会比较远，如果使用和近处的纹理同样大小的话明显不符合现实，OpenGL有一个**多行渐远纹理(Mipmap)**功能，原理是利用距观察者的距离超过一定的阈值，OpenGL会使用不同的多级渐远纹理，即最适合物体的距离的那个。由于距离远，解析度不高也不会被用户注意到。简单来说就是一系列的纹理图形，后一个纹理图像是前一个的二分之一。手工创建一个多行渐远纹理很麻烦，在OpenGL中有一个glGenerateMipmaps函数来简单的创建。

> 在渲染中切换多级渐远纹理级别(Level)时，OpenGL在两个不同级别的多级渐远纹理层之间会产生不真实的生硬边界。就像普通的纹理过滤一样，切换多级渐远纹理级别时你也可以在两个不同多级渐远纹理级别之间使用NEAREST和LINEAR过滤。为了指定不同多级渐远纹理级别之间的过滤方式，你可以使用下面四个选项中的一个代替原有的过滤方式。

|   多行渐远纹理过滤方式    | 描述                                                         |
| :-----------------------: | :----------------------------------------------------------- |
| GL_NEAREST_MIPMAP_NEAREST | 使用最邻近的多级渐远纹理来匹配像素大小，并使用邻近插值进行纹理采样 |
| GL_LINEAR_MIPMAP_NEAREST  | 使用最邻近的多级渐远纹理级别，并使用线性插值进行采样         |
| GL_NEAREST_MIPMAP_LINEAR  | 在两个最匹配像素大小的多级渐远纹理之间进行线性插值，使用邻近插值进行采样 |
|  GL_LINEAR_MIPMAP_LINEAR  | 在两个邻近的多级渐远纹理之间使用线性插值，并使用线性插值进行采样 |





##### 纹理环绕

我们知道纹理都和与其对应的纹理坐标的映射关系来对指定区域进行填充，这个值都在[0.0, 1.0]之间。但是如果不在此范围内将会使用纹理环绕模式来处理。设置纹理环绕时的坐标用的是GL_TEXTURE_WRAP_S、GL_TEXTURE_WRAP_T（三维贴图时还会用到GL_TEXTURE_WRAP_R）。

![](http://cloud.minder.mypup.cn/blog/OpenGL-%E7%BA%B9%E7%90%86%E7%8E%AF%E7%BB%95%E6%96%B9%E5%BC%8F.png)

> 参数一：纹理维度
>
> 参数二：纹理坐标，上面的三个值
>
> 参数三：纹理环绕模式，详细的可以参考下表。

```c
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
```



|    纹理环绕模式    |                           描述                           |
| :----------------: | :------------------------------------------------------: |
|     GL_REPEAT      |                       重复纹理图像                       |
| GL_MIRRORED_REPEAT |                    重复纹理图像的镜像                    |
|  GL_CLAMP_TO_EDGE  | 超出区域外的部分会一直重复纹理边缘的图像，类似于边缘拉伸 |
| GL_CLAMP_TO_BORDER |            超出区域的部分为指定的颜色进行填充            |



### 参考

[OpenGL中使用纹理](https://learnopengl-cn.readthedocs.io/zh/latest/01%20Getting%20started/06%20Textures/)