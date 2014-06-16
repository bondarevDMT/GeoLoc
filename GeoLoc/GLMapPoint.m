//
//  GLMapPoint.m
//  GeoLoc
//
//  Created by Dmitriy Bondarev on 6/6/14.
//
//

#import "GLMapPoint.h"

@implementation GLMapPoint

@synthesize coordinate = _coordinate;
@synthesize title = _title;


-(id)initWithCoordinate:(CLLocationCoordinate2D)coordinateForPoint title:(NSString *)titleForPoint
{
    self = [super init];
    if (self) {
        _coordinate = coordinateForPoint;
        _title = titleForPoint;
    }
    return self;
}

@end
