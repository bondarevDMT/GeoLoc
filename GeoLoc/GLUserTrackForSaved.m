//
//  GLUserTrackForSaved.m
//  GeoLoc
//
//  Created by Dmitriy Bondarev on 6/7/14.
//
//

#import "GLUserTrackForSaved.h"

@implementation GLUserTrackForSaved

@synthesize imageMapWithTrack = _imageMapWithTrack;
@synthesize userTrack = _userTrack;
@synthesize arrayMapPoint = _arrayMapPoint;
@synthesize title = _title;
@synthesize regionForMap = _regionForMap;

-(id)initTrack:(GLUserTrack *)track titleUserTrack:(NSString *)titleTrack ImageMap:(UIImageView *)imageMap mapPoints:(NSArray *)mapPoints region:(NSArray *)region
{
    self = [super init];
    if (self) {
        _regionForMap = region;
        _userTrack = track;
        _title = titleTrack;
        _imageMapWithTrack = imageMap;
        _arrayMapPoint = mapPoints;
    }
    return  self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        _regionForMap = [aDecoder decodeObjectForKey:@"regionMap"];
        _userTrack = [aDecoder decodeObjectForKey:@"userTrack"];
        _imageMapWithTrack = [aDecoder decodeObjectForKey:@"imageMapWithTrack"];
        _arrayMapPoint = [aDecoder decodeObjectForKey:@"arrayMapPoint"];
        _title = [aDecoder decodeObjectForKey:@"title"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.regionForMap forKey:@"regionMap"];
    [aCoder encodeObject:self.userTrack forKey:@"userTrack"];
    [aCoder encodeObject:self.imageMapWithTrack forKey:@"imageMapWithTrack"];
    [aCoder encodeObject:self.arrayMapPoint forKey:@"arrayMapPoint"];
    [aCoder encodeObject:self.title forKey:@"title"];
}



@end
