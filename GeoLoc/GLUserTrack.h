//
//  GLUserTrack.h
//  GeoLoc
//
//  Created by Dmitriy Bondarev on 6/5/14.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface GLUserTrack : NSObject <MKOverlay>
{
    NSUInteger pointSpace;
    MKMapRect boundingMapRect;
    NSLock *lockForRec;
    MKMapPoint *firstPoint;
}


@property (readonly) MKMapPoint *points;
@property (readonly) NSUInteger pointCount;


// Инициализация CrumbPath с начальными координатами (текущим местоположение пользователя)
// BoundingMapRect в CrumbPath будут установлены на достаточно большой площади

- (id)initWithCenterCoordinate:(CLLocationCoordinate2D)coord;

- (MKMapRect)addCoordinate:(CLLocationCoordinate2D)coord;
-(MKMapPoint)getFirstPoint;
-(MKMapPoint)getPoint;

@end
