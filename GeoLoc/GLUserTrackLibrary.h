//
//  GLUserTrackLibrary.h
//  GeoLoc
//
//  Created by Dmitriy Bondarev on 6/10/14.
//
//

#import <Foundation/Foundation.h>
#import "GLUserTrackForSaved.h"

@interface GLUserTrackLibrary : NSObject
{
    NSMutableArray *userTrackLibrary;
}

+(GLUserTrackLibrary *)sharedInstance;

-(NSMutableArray *)getUserTraks;
-(void)addUserTrack:(GLUserTrackForSaved *)userTrack AtIndex:(int)index;
-(void)addUserTrack:(GLUserTrackForSaved *)userTrack;
-(void)deleteUserTrackAtIndex:(int)index;
-(void)saveTracks;

@end
