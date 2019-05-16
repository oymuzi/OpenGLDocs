### 前言

之前可知固定管道着色器的含义，即使用同一个函数不同参数调用着色器程序，虽然在OpenGL ES中我们已经不会用到固定管道编程，但是我们还是可以通过这个来了解大概的效果和需要的参数，对以后学习OpenGL ES都是有帮助的。



### 初始化着色器管理者

```
GLShaderManager shaderManager; 

shaderManager.InitializeStockShaders(); 

// 下文都会使用这个函数来执行不同的着色器
GLShaderManager::UserStockShader(xxx, ...);

参数1：存储着色器种类
...
```



### 单元着色器

```
GLShaderManager::UserStockShader(GLT_SHADER_IDENTITY,GLfloat vColor[4]);

参数1：单元着色器
参数2：颜色

使用场景：在默认OpenGL绘制坐标系[-1，1]中，所有只以单一颜色进行填充。
```



### 平面着色器

```
GLShaderManager::UserStockShader(GLT_SHADER_FLAT,GLfloat mvp[16],GLfloat vColor[4]);

参数1：平面着色器
参数2：4x4矩阵
参数3：颜色

使用场景：在绘制图形时，可以应用模型/投影变换
```



### 上色着色器

```
GLShaderManager::UserStockShader(GLT_SHADER_SHADED,GLfloat mvp[16]);

参数1：上色着色器
参数2：允许变化的4x4矩阵

使用场景：在绘制图形时，可以应用模型/投影变换，颜色将会平滑的插入到顶点中，称为平滑着色。
```



### 默认光源着色器

```
GLShaderManager::UserStockShader(GLT_SHADER_DEFAULT_LIGHT,GLfloat mvMatrix[16],GLfloat pMatrix[16],GLfloat vColor[4]);

参数1：默认光源着色器
参数2：模型4x4矩阵
参数3：投影4x4矩阵
参数4：颜色

使用场景：在绘制图形时，可以应用模型/投影变换，这种绘制会让图形产生光照和阴影的效果。
```



### 点光源着色器

```
GLShaderManager::UserStockShader(GLT_SHADER_POINT_LIGHT_DIEF,GLfloat mvMatrix[16],GLfloat pMatrix[16],GLfloat vLightPos[3],GLfloat vColor[4]);

参数1：点光源着色器
参数2：模型4x4矩阵
参数3：投影4x4矩阵
参数4：点光源位置
参数5：漫反射颜色

使用场景：在绘制图形时，可以应用模型/投影变换，这种绘制会让图形产生光照和阴影的效果，和默认光源着色器很相似，但是光源的位置是固定的。
```



### 纹理替换矩阵着色器

```
GLShaderManager::UserStockShader(GLT_SHADER_TEXTURE_REPLACE,GLfloat mvMatrix[16],GLint nTextureUnit);

参数1：纹理替换矩阵着色器
参数2：模型4x4矩阵
参数3：纹理单元

使用场景：在绘制图形时，可以应用模型/投影变换，这种着色器通过给定的模型矩阵和纹理，将从纹理每个点中渲染到图形上对应的每个像素。
```



### 纹理调整着色器

```
GLShaderManager::UserStockShader(GLT_SHADER_TEXTURE_MODULATE,GLfloat mvMatrix[16],GLfloat vColor[4],GLint nTextureUnit);

参数1：纹理调整矩阵
参数2：模型4x4矩阵
参数3：颜色值
参数4：纹理单元

使用场景：在绘制图形时，可以应用模型/投影变换，这种着色器通过给定的模型矩阵和纹理，将颜色和纹理混合后填充到片段里。
```





### 纹理光源着色器

```
GLShaderManager::UserStockShader(GLT_SHADER_TEXTURE_POINT_LIGHT_DIEF,G Lfloat mvMatrix[16],GLfloat pMatrix[16],GLfloat vLightPos[3],GLfloat vBaseColor[4],GLint nTextureUnit);

参数1：纹理光源着色器
参数2：模型4x4矩阵
参数3：投影4x4矩阵
参数4：光源位置
参数5：颜色值
参数6：纹理单元

使用场景：在绘制图形时，可以应用模型/投影变换，通过给定的模型矩阵和投影，将纹理通过漫反射照明计算后进行调整。
```

