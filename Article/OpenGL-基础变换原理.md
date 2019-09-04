### 前言

[上篇文章]()我们了解了在OpenGL中的渲染以及一些常见的问题，我们渲染图形有时可能需要进行变换操作来完成一些需求，我们知道这些都是建立在3D数学的基础上实现的，那么我们有必要去了解一些一些3D数学的基本知识，如果还需要在3D图形编程中深究，还需要去读《计算机图形学》这本书。所以在图形编程中，3D数学是非常重要的。



### 向量与矩阵

#### 向量

![](http://cloud.minder.mypup.cn/blog/OpenGL%E5%90%91%E9%87%8F.png)

从 *图一* 我们知道在三维坐标系有个点的位置为(x, y, z)，那么从原点指向这个点可被视为一个向量。我们知道向量有方向和数量，并且我们把长度为1的向量称为单位向量。长度的计算方式为**图四**。

在**math3d**库中有两个数据类型来表示三维向量或四维向量，其中三维向量我们都知道是(x, y, z)的形式，四维向量中是用(x, y, z, w)的形式来表示，其中w是缩放因子，正常情况为1.

```
// 三维向量
M3DVector3f mVector3 = {0.0f, 1.0f, 0.7f};
// 四维向量
M4DVector4f mVector4 = {0.5f, 1.0f, 0.3f, 1.0f};
```



##### 向量与标量运算

标量(Scalar)只是一个数字（或者说是仅有一个分量的向量）。当把一个向量加/减/乘/除一个标量，我们可以简单的把向量的每个分量分别进行该运算。下面只有向量与标量相加的例子，**值得注意的是：在除法和减法的操作符中，只能向量在前，标量在后，因为反过来没有定义运算，加减两者位置随意。**

```
M3DVector3f mVector = {0.0f, 0.2f, 3.3f};

假若标量3.0f与mVector的相加结果为 {3.0f + 0.0f, 3.0f + 0.2f, 3.0f + 3.3f};
```



##### 向量取反

对一个向量取反(Negate)会将其方向逆转。一个指向东北的向量取反后就指向西南方向了。我们在一个向量的每个分量前加负号就可以实现取反了（或者说用-1数乘该向量)。



##### 向量加减

向量的加法可以被定义为是分量的(Component-wise)相加，即将一个向量中的每一个分量加上另一个向量的对应分量。*向量V1={2.0f, 3.0f, 4.0f }, V2={3.0f, 4.5f, 1.9f}, 那么V1 + V2 = {5.0f, 7.5f, 5.9f}*



> 两个向量相乘是一种很奇怪的情况。普通的乘法在向量上是没有定义的，因为它在视觉上是没有意义的。但是在相乘的时候我们有两种特定情况可以选择：一个是点乘(Dot Product)，记作v¯⋅k¯，另一个是叉乘(Cross Product)，记作v¯ × k¯。

##### 点乘

**两个向量的点乘等于它们的数乘结果乘以两个向量之间夹角的余弦值**。上图二有两个向量，可以利用点乘求得这个夹角的余弦值。在**math3D**库中也有函数进行点乘操作：

```
// 可以利用此函数获得点乘结果
float m3DotProduct3(const M3DVector3f u, const M3DVector3f v);

// 获取向量夹角的弧度值
float m3dGetAngleBetweenVectors3(const M3DVector3f u, const M3DVector3f v);
```



##### 叉乘

叉乘只在3D空间中有定义，它需要两个不平行向量作为输入，生成一个正交于两个输入向量的第三个向量。 我们可以从 **图三**中看到向量V1和V2的叉乘将会得到向量V3。在**math3D**库中也有函数进行叉乘操作：

```
// 此函数的结果将会在result中，u和v为向量
void m3dCrossProduct3(M3DVector3f result, const M3DVector3f u, const M3DVector3f v);
```



#### 矩阵

简单来说矩阵就是一个矩形的数字、符号或表达式数组。矩阵中每一项叫做矩阵的元素(Element)。我们在做图形变换时，例如旋转一个图形，那么知道一开始的位置以及旋转的角度，通过math3D库计算函数来获得旋转后的图形位置。在3D程序中我们常用到的两种矩阵是3x3矩阵和4x4矩阵。在math3D库中有两种类型来表示这两种矩阵。

```
typedef float M3DMatrix33f[9];   // 3x3矩阵
typedef float M3DMatrix44f[16];  // 4x4矩阵
```



##### 矩阵加减

矩阵与标量之间的加减法也是矩阵的每一个元素分别加或减该标量，矩阵与矩阵的加减法也是对应矩阵的加减法运算。

矩阵与标量相加：$\begin{bmatrix} 1 & 2 \\ 3 & 4 \end{bmatrix} + \color{green}3 = \begin{bmatrix} 1 + \color{green}3 & 2 + \color{green}3 \\ 3 + \color{green}3 & 4 + \color{green}3 \end{bmatrix} = \begin{bmatrix} 4 & 5 \\ 6 & 7 \end{bmatrix}$

矩阵与标量相减：$\begin{bmatrix} 1 & 2 \\ 3 & 4 \end{bmatrix} - \color{green}3 = \begin{bmatrix} 1 - \color{green}3 & 2 - \color{green}3 \\ 3 - \color{green}3 & 4 - \color{green}3 \end{bmatrix} = \begin{bmatrix} -2 & -1 \\ 0 & 1 \end{bmatrix}$

矩阵与矩阵相加：$\begin{bmatrix} \color{red}1 & \color{red}2 \\ \color{green}3 & \color{green}4 \end{bmatrix} + \begin{bmatrix} \color{red}5 & \color{red}6 \\ \color{green}7 & \color{green}8 \end{bmatrix} = \begin{bmatrix} \color{red}1 + \color{red}5 & \color{red}2 + \color{red}6 \\ \color{green}3 + \color{green}7 & \color{green}4 + \color{green}8 \end{bmatrix} = \begin{bmatrix} \color{red}6 & \color{red}8 \\ \color{green}{10} & \color{green}{12} \end{bmatrix}$

矩阵与矩阵相减：$\begin{bmatrix} \color{red}4 & \color{red}2 \\ \color{green}1 & \color{green}6 \end{bmatrix} - \begin{bmatrix} \color{red}2 & \color{red}4 \\ \color{green}0 & \color{green}1 \end{bmatrix} = \begin{bmatrix} \color{red}4 - \color{red}2 & \color{red}2  - \color{red}4 \\ \color{green}1 - \color{green}0 & \color{green}6 - \color{green}1 \end{bmatrix} = \begin{bmatrix} \color{red}2 & -\color{red}2 \\ \color{green}1 & \color{green}5 \end{bmatrix}$



##### 矩阵数乘

和矩阵与标量的加减一样，矩阵与标量之间的乘法也是矩阵的每一个元素分别乘以该标量。就如下个例子：

$\color{green}2 \cdot \begin{bmatrix} 1 & 2 \\ 3 & 4 \end{bmatrix} = \begin{bmatrix} \color{green}2 \cdot 1 & \color{green}2 \cdot 2 \\ \color{green}2 \cdot 3 & \color{green}2 \cdot 4 \end{bmatrix} = \begin{bmatrix} 2 & 4 \\ 6 & 8 \end{bmatrix}$



##### 矩阵相乘

矩阵乘法基本上意味着遵照规定好的法则进行相乘。但有一些限制：

- *只有当左侧矩阵的列数与右侧矩阵的行数相等，两个矩阵才能相乘。*
- *矩阵相乘不遵守交换律(Commutative)，也就是说A⋅B≠B⋅AA⋅B≠B⋅A。*

例子：$\begin{bmatrix} \color{red}1 & \color{red}2 \\ \color{green}3 & \color{green}4 \end{bmatrix} \cdot \begin{bmatrix} \color{blue}5 & \color{purple}6 \\ \color{blue}7 & \color{purple}8 \end{bmatrix} = \begin{bmatrix} \color{red}1 \cdot \color{blue}5 + \color{red}2 \cdot \color{blue}7 & \color{red}1 \cdot \color{purple}6 + \color{red}2 \cdot \color{purple}8 \\ \color{green}3 \cdot \color{blue}5 + \color{green}4 \cdot \color{blue}7 & \color{green}3 \cdot \color{purple}6 + \color{green}4 \cdot \color{purple}8 \end{bmatrix} = \begin{bmatrix} 19 & 22 \\ 43 & 50 \end{bmatrix}$

计算矩阵相乘的结果值的方式是先计算左侧矩阵对应行和右侧矩阵对应列的第一个元素之积，然后是第二个，第三个，第四个等等，然后把所有的乘积相加，这就是结果了。现在我们就能解释为什么左侧矩阵的列数必须和右侧矩阵的行数相等了，如果不相等这一步的运算就无法完成了！**结果矩阵的维度是(n, m)，n代表左侧矩阵的行数，m代表右侧矩阵的行数。**

三维矩阵例子：$\begin{bmatrix} \color{red}4 & \color{red}2 & \color{red}0 \\ \color{green}0 & \color{green}8 & \color{green}1 \\ \color{blue}0 & \color{blue}1 & \color{blue}0 \end{bmatrix} \cdot \begin{bmatrix} \color{red}4 & \color{green}2 & \color{blue}1 \\ \color{red}2 & \color{green}0 & \color{blue}4 \\ \color{red}9 & \color{green}4 & \color{blue}2 \end{bmatrix} = \begin{bmatrix} \color{red}4 \cdot \color{red}4 + \color{red}2 \cdot \color{red}2 + \color{red}0 \cdot \color{red}9 & \color{red}4 \cdot \color{green}2 + \color{red}2 \cdot \color{green}0 + \color{red}0 \cdot \color{green}4 & \color{red}4 \cdot \color{blue}1 + \color{red}2 \cdot \color{blue}4 + \color{red}0 \cdot \color{blue}2 \\ \color{green}0 \cdot \color{red}4 + \color{green}8 \cdot \color{red}2 + \color{green}1 \cdot \color{red}9 & \color{green}0 \cdot \color{green}2 + \color{green}8 \cdot \color{green}0 + \color{green}1 \cdot \color{green}4 & \color{green}0 \cdot \color{blue}1 + \color{green}8 \cdot \color{blue}4 + \color{green}1 \cdot \color{blue}2 \\ \color{blue}0 \cdot \color{red}4 + \color{blue}1 \cdot \color{red}2 + \color{blue}0 \cdot \color{red}9 & \color{blue}0 \cdot \color{green}2 + \color{blue}1 \cdot \color{green}0 + \color{blue}0 \cdot \color{green}4 & \color{blue}0 \cdot \color{blue}1 + \color{blue}1 \cdot \color{blue}4 + \color{blue}0 \cdot \color{blue}2 \end{bmatrix}   \\ = \begin{bmatrix} 20 & 8 & 12 \\ 25 & 4 & 34 \\ 2 & 0 & 4 \end{bmatrix}$



##### 矩阵与向量相乘

我们用向量来表示位置，表示颜色，甚至是纹理坐标。让我们更深入了解一下向量，它其实就是一个**N×1**矩阵，N表示向量分量的个数（也叫N维(N-dimensional)向量）。如果你仔细思考一下就会明白。向量和矩阵一样都是一个数字序列，但它只有1列。那么，这个新的定义对我们有什么帮助呢？如果我们有一个**M×N**矩阵，我们可以用这个矩阵乘以我们的**N×1**向量，因为这个矩阵的列数等于向量的行数，所以它们就能相乘。



##### 单位矩阵

在OpenGL中，由于某些原因我们通常使用**4×4**的变换矩阵，而其中最重要的原因就是大部分的向量都是4分量的。我们能想到的最简单的变换矩阵就是单位矩阵(Identity Matrix)。单位矩阵是一个除了对角线以外都是0的**N×N**矩阵。在下式中可以看到，这种变换矩阵使一个向量完全不变：

$\begin{bmatrix} \color{red}1 & \color{red}0 & \color{red}0 & \color{red}0 \\ \color{green}0 & \color{green}1 & \color{green}0 & \color{green}0 \\ \color{blue}0 & \color{blue}0 & \color{blue}1 & \color{blue}0 \\ \color{purple}0 & \color{purple}0 & \color{purple}0 & \color{purple}1 \end{bmatrix} \cdot \begin{bmatrix} 1 \\ 2 \\ 3 \\ 4 \end{bmatrix} = \begin{bmatrix} \color{red}1 \cdot 1 \\ \color{green}1 \cdot 2 \\ \color{blue}1 \cdot 3 \\ \color{purple}1 \cdot 4 \end{bmatrix} = \begin{bmatrix} 1 \\ 2 \\ 3 \\ 4 \end{bmatrix}$

**也许会奇怪一个没变换的变换矩阵有什么用？单位矩阵通常是生成其他变换矩阵的起点，如果我们深挖线性代数，这还是一个对证明定理、解线性方程非常有用的矩阵。**在iOS使用**CGAffineTransform**动画中会用到一个**CGAffineTransformIdentity**用来表示原本模样，这也是单位矩阵的作用。在OpenGL中**math3D**库也有单位矩阵(也称单元矩阵)的函数：

```
void m3dLoadIdentity44(M3DMatrix44f m);
```



### 变换



##### 变换术语

| 变换术语 |                        应用                        |
| :------: | :------------------------------------------------: |
|   视图   |               指定观察者或相机的位置               |
|   模型   |                  在场景中移动物体                  |
| 模型视图 |               描述视图和模型的二元性               |
|   投影   |         改变视景体的大小和重新设置他的形状         |
|   视口   | 是一种伪变化，只是改变窗口上的最终输出进行一个缩放 |



##### 视觉坐标

视觉坐标是观察者角度来说的，就如我们之前说的相机坐标系一样，从不同的角度看到的物体的形态是不一致的。下图的图一表示的是观察者在Z轴的正上方的角度，而图二观察者的位置是从Z轴的负方向的角度，那么如果观看一个正方体，那么图一看到的是立方体的上面，图二则是立方体的下面。

![](http://cloud.minder.mypup.cn/blog/OpenGL%E8%A7%86%E8%A7%89%E5%9D%90%E6%A0%87.png)



##### 视图变换

视图变换是常用到的一种变换。在默认情况中，透视投影的的观察点的位置为(0， 0， 0)，并沿着Z轴的负方向进行观察。在正投影中，观察点被放在Z轴正方向的无穷远的位置，可以看到视景体内的一切物体。视图变换允许我们设置观察者的任意位置并指定方向来进行观察。



##### 模型变换

模型变换常见有平移、旋转、缩放。物体最后的形态取决于模型变换的顺序以及最后的变换，下图解释了物体的先平移后旋转和先旋转后平移两者最后得到的结果是不一样的。



##### 模型视图二元性

视图和模型变换在其内部的效果和展示的效果是一致的，为了开发人员方便才区分开来的。就比如向前移动物体k距离和向后移动坐标系k距离是一样的结果。**而模型视图矩阵则是模型和视图两者在编程管道中组成的一个矩阵。**



##### 投影变换

投影变换应用到将模型视图变换后的顶点上。在正投影中，物体按照其原本、轮廓的大小在屏幕上进行绘制；而在透视投影中，物体会根据观察者的位置来计算出来的结果在屏幕上绘制，就如你在一段很长很直的火车轨道上看远处的轨道会发现轨道越来越窄，但其实是一样的大小，这就透视投影比较符合我们生活中场景。



##### 视口变换

视口变换是最后一种伪变换，将绘制的图形映射到指定的窗口上，而窗口的大小是我们事先设置的，而这部分变换不用我们去操心，系统会根据指定的大小来进行变换。



### 模型视图矩阵

单元矩阵在上面已经介绍了，还有常见的几种变换如平移、旋转、缩放以及组合变换。



##### 平移

平移矩阵就是将物体沿着X、Y、Z轴的中一个或多个轴进行平移。

```
void m3dTranslationMatrix44(M3DMatrix44f result, float x, float y, float z);
```



旋转

旋转矩阵的作用是物体在沿着X、Y、Z轴中的某条轴或者任意轴进行旋转。

```
void m3dRotationMatrix44(M3DMatrix44f result, float x, float y, float z);
```



##### 缩放

缩放矩阵就是将物体中X、Y、Z的中一个或多个轴的值进行缩放处理。

```
void m3dScaleMatrix44(M3DMatrix44f result, float xScale, float yScale, float zScale);
```



##### 综合

很多时候物体的变换都不是单纯的平移、旋转、缩放，而是组合使用，那么不同矩阵的计算如果由开发人员计算将会是很长头痛的一点，那么math3D也有矩阵相乘的函数：

```
void m3dMatrixMultiply44(M3DMatrix44f product, const M3DMatrix44f a, const M3DMatrix44f b);
```



##### 仿射变换

**OpenGL**中**GLMatrixStack**类也内建了对创建旋转、平移和缩放矩阵的支持。

```
// 平移
void MatrixStack::Translate(GLfloat x, GLfloat y, GLfloat z);

// 旋转 其中angle为弧度
void MatrixStack::Rotate(GLfloat angle, GLfloat x, GLfloat y, GLfloat z);

// 缩放
void MatrixStack::Scale(GLfloat x, GLfloat y, GLfloat z);
```



### 矩阵堆栈

![](http://cloud.minder.mypup.cn/blog/OpenGL%E7%9F%A9%E9%98%B5%E5%A0%86%E6%A0%88%E5%8E%8B%E6%A0%88%E5%87%BA%E6%A0%88.png)

从上图我们知道矩阵堆栈在压栈的时候会拷贝栈的最上面的矩阵，拷贝矩阵与新矩阵进行矩阵相乘后得到新的矩阵压入栈，如果有其他矩阵的话也是这样的，出栈的时候会恢复之前的状态，这样我们在操作视图模型变换时就不会出现问题。矩形堆栈默认深度为64。



##### 初始化以及一些常用操作

```
GLMatrixStack::GLMatrixStack(int iStackDepth = 64);

// 压入一个单元矩阵
void GLMatrixStack::LoadIdentity(void);

// 压入矩阵
void GLMatrixStack::LoadMatrix(const M3DMatrix44f m);

// 矩阵相乘结果存储到堆栈的顶部
void GLMatrixStack::MultMatrix(const M3DMatrix44f);

// 获取矩阵堆栈顶部的值
const M3DMatrix44f & GLMatrixStack::GetMatrix(void);

// 获取顶部矩阵的最上面的矩阵的副本
void GLMatrixStack::GetMatrix(M3Datrix44f mMatrix);
```



##### 压栈、出栈

矩阵堆栈的存在就是为了存储矩阵的状态，出栈时可以恢复到之前的状态，具体的流程图可以通过上图。通过**GLMatrixStack**类进行的。压栈**PushMatrix**，出栈：**PopMatrix**。

```
// 拷贝栈顶矩阵后再压栈
void GLMatrixStack::PushMatrix(void);

// 将M3DMatrix44f矩阵对象压栈
void PushMatrix(const M3DMatrix44f mMatrix);

// 将GLFrame对象压栈
void PushMatrix(GLFrame &frame);

// 出栈
void GLMatrixStack::PopMatrix(void);
```

