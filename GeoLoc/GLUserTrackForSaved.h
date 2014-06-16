//
//  GLUserTrackForSaved.h
//  GeoLoc
//
//  Created by Dmitriy Bondarev on 6/7/14.
//
//

#import <Foundation/Foundation.h>
#import "GLUserTrack.h"
#import "GLUserTrackView.h"

@interface GLUserTrackForSaved : NSObject <NSCoding>


@property (copy, readonly) UIImageView *imageMapWithTrack;
@property (copy, readwrite) GLUserTrack *userTrack;
@property (copy, readonly) NSArray *arrayMapPoint;
@property (copy, readonly) NSString *title;
@property (copy, readwrite)NSArray *regionForMap;

-(id)initTrack:(GLUserTrack *)track titleUserTrack:(NSString*) titleTrack ImageMap:(UIImageView *)imageMap mapPoints:(NSArray *)mapPoints region:(NSArray *)region;


@end
