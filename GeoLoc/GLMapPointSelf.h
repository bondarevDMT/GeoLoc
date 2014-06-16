//
//  GLMapPointSelf.h
//  GeoLoc
//
//  Created by Dmitriy Bondarev on 6/6/14.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface GLMapPointSelf : NSObject <MKAnnotation>

{
    NSString *title;
    CLLocationCoordinate2D coordinate;
    UIImage *foto;
}


@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;

-(id)initWithCoordinate:(CLLocationCoordinate2D)coord title:(NSString *)title fotoSelf:(UIImage *)fotoSelf;
-(UIImage *)getFoto;


@end
