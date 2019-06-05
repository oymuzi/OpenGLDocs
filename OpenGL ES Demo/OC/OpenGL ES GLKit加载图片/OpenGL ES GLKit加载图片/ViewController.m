//
//  ViewController.m
//  OpenGL ES GLKit加载图片
//
//  Created by ios on 2019/6/5.
//  Copyright © 2019 oymuzi. All rights reserved.
//

#import "ViewController.h"
#import <GLKit/GLKit.h>
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>

@interface ViewController ()<GLKViewDelegate>

@property (strong, nonatomic) GLKBaseEffect *baseEffect;
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKView *glkView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self setupConfigure];
    [self setupVertexData];
    [self setupTextureData];
}


- (void)setupConfigure{
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if(!context){
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        if (!context) {
            NSLog(@"初始化上下文失败");
            return;
        }
    }
    self.context = context;
    [EAGLContext setCurrentContext:context];
    GLKView *glkView = [[GLKView alloc] initWithFrame:self.view.frame context:context];
    glkView.delegate = self;
    glkView.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    glkView.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    glkView.drawableMultisample = GLKViewDrawableMultisample4X;
    glkView.drawableStencilFormat = GLKViewDrawableStencilFormat8;
    [self.view addSubview:glkView];
    self.glkView = glkView;
    
    glClearColor(0.3, 0.3, 0.3, 1.0);
}

- (void)setupVertexData{
    // 1.顶点数据、纹理数据
    GLfloat vertexs[] = {
        1, -1, 0, 1.0, 0.0,
        1, 1, 0, 1.0, 1.0,
        -1, 1, 0, 0.0, 1.0,
        
        1, -1, 0, 1.0, 0.0,
        -1, 1, 0, 0.0, 1.0,
        -1, -1, 0, 0.0, 0.0,
    };
    
    // 2.开辟VBO
    GLuint bufferID;
    glGenBuffers(1, &bufferID);
    // 3.绑定数据
    glBindBuffer(GL_ARRAY_BUFFER, bufferID);
    // 4. 拷贝数据到缓冲区
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexs), vertexs, GL_STATIC_DRAW);
    // 5.开启属性通道x传递顶点
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 0);
    // 6.开启纹理通道传递纹理坐标
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 3);
    
    
    
}

- (void)setupTextureData{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"shell" ofType:@"jpg"];
    NSDictionary *options = @{GLKTextureLoaderOriginBottomLeft: @(YES)};
    NSError *error;
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];
    if (error) {
        NSLog(@"加载纹理出错：%@", error.localizedDescription);
    }
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.texture2d0.name = textureInfo.name;
    self.baseEffect.texture2d0.enabled = GL_TRUE;
    self.baseEffect.texture2d0.target = textureInfo.target;
    
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    
    glClear(GL_COLOR_BUFFER_BIT);
    [self.baseEffect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, 6);
}

@end

