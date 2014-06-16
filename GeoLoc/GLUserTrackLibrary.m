//
//  GLUserTrackLibrary.m
//  GeoLoc
//
//  Created by Dmitriy Bondarev on 6/10/14.
//
//

#import "GLUserTrackLibrary.h"

@implementation GLUserTrackLibrary

+(GLUserTrackLibrary *)sharedInstance
{
    static GLUserTrackLibrary* _sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[GLUserTrackLibrary alloc] init];
    });
    return _sharedInstance;

}

-(id)init
{
    self = [super init];
    if (self) {
        NSData * data = [NSData dataWithContentsOfFile:[NSHomeDirectory() stringByAppendingString:@"/Documents/tracks.bin"]];
        userTrackLibrary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if (userTrackLibrary == nil) {
            userTrackLibrary = [[NSMutableArray alloc] init];
        }
    }
    return self;
}

-(NSArray *)getUserTraks
{
    return (NSMutableArray *)userTrackLibrary;
}
//Используется для добавления пользовательского пути (если пользователь воспользовался возможностью удаления)
-(void)addUserTrack:(GLUserTrackForSaved *)userTrack AtIndex:(int)index
{
    if (userTrackLibrary.count >= index)
        [userTrackLibrary insertObject:userTrack atIndex:index];
}


//Используется для обычного добавления пользвоательского пути
-(void)addUserTrack:(GLUserTrackForSaved *)userTrack
{
    [userTrackLibrary addObject:userTrack];
}

-(void)deleteUserTrackAtIndex:(int)index
{
    [userTrackLibrary removeObjectAtIndex:index];
}

- (void)saveTracks
{
    NSString * filename = [NSHomeDirectory() stringByAppendingString:@"/Documents/tracks.bin"];
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:userTrackLibrary];
    [data writeToFile:filename atomically:YES];
}

@end
