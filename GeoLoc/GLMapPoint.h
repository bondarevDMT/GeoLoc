//
//  GLMapPoint.h
//  GeoLoc
//
//  Created by Dmitriy Bondarev on 6/6/14.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface GLMapPoint : NSObject <MKAnnotation>


@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;

-(id)initWithCoordinate:(CLLocationCoordinate2D)coordinateForPoint title:(NSString *)titleForPoint;

@end
