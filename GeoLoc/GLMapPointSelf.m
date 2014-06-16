//
//  GLMapPointSelf.m
//  GeoLoc
//
//  Created by Dmitriy Bondarev on 6/6/14.
//
//

#import "GLMapPointSelf.h"

@implementation GLMapPointSelf
@synthesize coordinate, title;

-(id)initWithCoordinate:(CLLocationCoordinate2D)coord title:(NSString *)titl fotoSelf:(UIImage *)fotoSelf
{
    self = [super init];
    if (self) {
        coordinate = coord;
        [self setTitle:titl];
        foto = fotoSelf;
    }
    return  self;
}

- (NSString *)title
{
    return title;
}

-(UIImage *)getFoto
{
    return foto;
}





@end
