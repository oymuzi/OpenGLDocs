### 认识OpenGL

**OpenGL**是Open Graphics Library 的缩写，是一组图形绘制的api集合，大约有350个函数左右，常用于CAD、虚拟现实、科学可视化程序和电子游戏开发以及图片和视频的滤镜处理等场景。OpenGL规范描述了绘制2D和3D图形的抽象API，虽然这些API完全可以通过软件实现，但它是为大部分或全部使用硬件加速而设计的。各种图形API的作用本质就是使用GPU芯片高速渲染图形，得益于GPU的计算能力。而图形API也是iOS唯一能够接近GPU的地方。



### 了解OpenGL相关平台

- OpenGL（Open Graphics Library）：用于渲染2D、3D矢量图形的跨平台、跨语言的编程程序的接口集合。
- OpenGL ES （OpenGL for Embedded Systems）：三维图形应用程序OpenGL的子集（去除了glBegin/glEnd，四边形、多边形等复杂图元以及非绝对必要的特性），用于手机、PDA、游戏机等嵌入式设备而设计的编程接口。
- DirectX（Direct eXtension）：由微软公司创建的多媒体、游戏开发的应用程序接口。广泛运用且仅支持在Windows、XBox电子游戏开发。不是跨平台语言，按性质分类为四部分：显示部分，声音部分，输入部分，网络部分。
- Metal：Apple为游戏开发者提供的新平台技术，可以为3D图像提高十倍渲染性能。









