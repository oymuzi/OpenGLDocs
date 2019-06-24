//
//  OMView.m
//  OpenGL ES 入门GLSL
//
//  Created by 欧阳林 on 2019/6/23.
//  Copyright © 2019年 欧阳林. All rights reserved.
//

#import "OMView.h"
#import <OpenGLES/ES3/gl.h>

typedef struct{
    GLfloat x;
    GLfloat y;
    GLfloat z;
    GLfloat textureX;
    GLfloat textureY;
}OMVertex;


@interface OMView()

@property (strong, nonatomic) EAGLContext *myContext;
@property (strong, nonatomic) CAEAGLLayer *myLayer;
@property (assign, nonatomic) GLuint myRenderBuffer;
@property (assign, nonatomic) GLuint myFrameBuffer;
@property (assign, nonatomic) GLuint myProgram;

@end

@implementation OMView


- (void)layoutSubviews{
    [self setupLayer];
    [self setupContext];
    [self clearAllBuffers];
    [self setupRenderBuffer];
    [self setupFrameBuffer];
    [self renderLayer];
}


+ (Class)layerClass{
    return [CAEAGLLayer class];
}

// 1.设置图层
- (void)setupLayer{
    self.myLayer = (CAEAGLLayer *)self.layer;
    
    NSDictionary *options = @{kEAGLDrawablePropertyRetainedBacking: @(NO), kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8};
    
    self.myLayer.drawableProperties = options;
    
    NSLog(@"初始化图层成功");
}

// 2.设置上下文
- (void)setupContext{
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (!context){
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        if (!context) {
            NSLog(@"初始化上下文失败");
            return;
        }
    }
    BOOL status = [EAGLContext setCurrentContext:context];
    if (!status) {
        NSLog(@"设置上下文失败");
        return;
    }
    self.myContext = context;
}


// 3，清空缓存区
- (void)clearAllBuffers{
    glDeleteBuffers(1, &_myRenderBuffer);
    glDeleteBuffers(1, &_myFrameBuffer);
    
    self.myRenderBuffer = 0;
    self.myFrameBuffer = 0;
}

// 4. 初始化渲染缓冲区
- (void)setupRenderBuffer{
    GLuint buffer;
    glGenRenderbuffers(1, &buffer);
    self.myRenderBuffer = buffer;
    glBindRenderbuffer(GL_RENDERBUFFER, self.myRenderBuffer);
    [self.myContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.myLayer];
}

// 5. 初始化帧缓冲区
- (void)setupFrameBuffer{
    GLuint buffer;
    glGenFramebuffers(1, &buffer);
    self.myFrameBuffer = buffer;
    glBindFramebuffer(GL_FRAMEBUFFER, self.myFrameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.myRenderBuffer);
}


//6. 开始渲染
- (void)renderLayer{
    // 1. 清屏
    glClearColor(0.3, 0.3, 0.3, 1.0);
    // 2. 清空颜色缓存区
    glClear(GL_COLOR_BUFFER_BIT);
    // 3. 设置视口
    CGFloat scale = [UIScreen mainScreen].scale;
//    glViewport(self.frame.origin.x * scale, self.frame.origin.y * scale, self.frame.size.width * scale, self.frame.size.height * scale);
    glViewport(0, 0, self.frame.size.width, self.frame.size.width);
    // 4.设置着色器的文件路径
    NSString *vertexFile = [[NSBundle mainBundle] pathForResource:@"shaderv" ofType:@"vsh"];
    NSString *fragmentFile = [[NSBundle mainBundle] pathForResource:@"shaderf" ofType:@"fsh"];
    
    // 5.创建程序
    GLuint program = [self createProgramWithVertexShaderFilePath:vertexFile fragmentShaderFilePath:fragmentFile];
    
    // 6.链接程序并查看状态
    glLinkProgram(program);
    self.myProgram = program;
    
    GLint linkStatus;
    glGetProgramiv(program, GL_LINK_STATUS, &linkStatus);
    if (linkStatus == GL_FALSE) {
        GLchar message[512];
        glGetProgramInfoLog(program,sizeof(message), 0, &message[0]);
        NSString *errorString = [NSString stringWithCString:message encoding:NSUTF8StringEncoding];
        NSLog(@"链接程序出错：%@", errorString);
        return;
    }
    
    NSLog(@"链接成功🍺");
    
    // 7.使用程序
    glUseProgram(self.myProgram);
    
    
    // 8. 创建顶点
    GLfloat VAO[] = {
                    1.0f, -1.0f, -1.0f, 1.0f, 0.0,
                     1.0f, 1.0f, -1.0f, 1.0f, 1.0f,
                     -1.0f, 1.0f, -1.0f, 0.0, 1.0f,
        1.0f, -1.0f, -1.0f, 1.0f, 0.0,
        -1.0f, 1.0f, -1.0f, 0.0, 1.0f,
        -1.0f, -1.0f, -1.0f, 0.0, 0.0
                     };
    
    // 9. 申请顶点缓存区
    GLuint attributeBuffer;
    glGenBuffers(1, &attributeBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, attributeBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(VAO), VAO, GL_DYNAMIC_DRAW);
    
    // 10. 获取顶点数据
    GLuint position = glGetAttribLocation(program, "position");
    glEnableVertexAttribArray(position);
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, NULL);
    
    // 11. g获取纹理数据
    GLuint texture = glGetAttribLocation(program, "textureCoordinate");
    glEnableVertexAttribArray(texture);
    glVertexAttribPointer(texture, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (float *)NULL + 3);
    
    
    // 12. 加载纹理
    [self loadTextureWithName:@"earth" imageType:@"jpeg"];
    
    //13. 设置纹理采样器
    glUniform1i(glGetUniformLocation(program, "textureSampler"), 0);
    
    //14.绘制
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    // 15. 把缓存区内容输出到屏幕上
    [self.myContext presentRenderbuffer:GL_RENDERBUFFER];
    
    
    
}

- (void)loadTextureWithName: (NSString *)imageName imageType: (NSString *)type{
    NSString *path = [[NSBundle mainBundle] pathForResource:imageName ofType:type];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    CGImageRef cgImage = image.CGImage;
    
    size_t imageWidth = CGImageGetWidth(cgImage);
    size_t imageHeight = CGImageGetHeight(cgImage);
    
    GLubyte *imageData = (GLubyte *)calloc(imageWidth * imageHeight * 4, sizeof(GLubyte));
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(cgImage);
    CGContextRef context = CGBitmapContextCreate(imageData, imageWidth, imageHeight, 8, imageWidth * 4, colorSpace, kCGImageAlphaPremultipliedLast);
    
    CGRect rect = CGRectMake(0, 0, imageWidth, imageHeight);
    CGContextTranslateCTM(context, 0, imageHeight);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    CGColorSpaceRelease(colorSpace);
    CGContextClearRect(context, rect);
    CGContextDrawImage(context, rect, cgImage);
    // 翻转图片
    

    CGContextRelease(context);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    float w = imageWidth;
    float h = imageWidth;
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, w, h, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    free(imageData);
    
}

// 创建程序
- (GLuint)createProgramWithVertexShaderFilePath: (NSString *)vertexShaderFilePath fragmentShaderFilePath: (NSString *)fragmentShaderFilePath{
    
    GLuint vertexShader;
    GLuint fragmentShader;
    [self compileShader:&vertexShader shaderFilePath: vertexShaderFilePath shaderType:GL_VERTEX_SHADER];
    [self compileShader:&fragmentShader shaderFilePath: fragmentShaderFilePath shaderType:GL_FRAGMENT_SHADER];
    
    GLuint program = glCreateProgram();
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragmentShader);
    
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);
    
    return program;
}

// 变异着色器
- (void)compileShader: (GLuint *)shader shaderFilePath: (NSString *)path shaderType: (GLenum)type{
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    const GLchar *source = (GLchar *)[content UTF8String];
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
}




@end
