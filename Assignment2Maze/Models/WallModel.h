//
//  CubeModel.h
//  Project1
//
//  Created by Kris Olsson on 2021-02-24.
//

#import "Model.h"

@interface WallModel : Model

@property int wallType;

- (instancetype) initWithShader :(BaseEffect *)shader;

@end
