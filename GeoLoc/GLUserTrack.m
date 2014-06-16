//
//  GLUserTrack.m
//  GeoLoc
//
//  Created by Dmitriy Bondarev on 6/5/14.
//
//

#import "GLUserTrack.h"
#define INITIAL_POINT_SPACE 1000
#define MINIMUM_DELTA_METERS 10.0

@implementation GLUserTrack

@synthesize points = _points;
@synthesize pointCount = _pointCount;

- (id)initWithCenterCoordinate:(CLLocationCoordinate2D)coord
{
	self = [super init];
    if (self)
	{
        // initialize point storage and place this first coordinate in it
        // Инициализируем точку (метоположения пользователя) и добавляем ее первой
        lockForRec = [[NSLock alloc] init]; // мьютекс для записи новых координат
        pointSpace = INITIAL_POINT_SPACE; //количество точек
        _points = malloc(sizeof(MKMapPoint) * pointSpace); //массив из 1000 точек
        _points[0] = MKMapPointForCoordinate(coord); //0 элемент массива - нынешняя точка
        _pointCount = 1; // общее количество число точек равно 1
        firstPoint = &_points[0];
        // созадем квадрат размерами в 1/4 карты
        //создаем точку с координатами (от которой идет отсчет сторон квадрата)
        MKMapPoint origin = _points[0];
        origin.x -= MKMapSizeWorld.width / 8.0;
        origin.y -= MKMapSizeWorld.height / 8.0;
        //Создаем размеры квадрата (1/4 карты)
        MKMapSize size = MKMapSizeWorld;
        size.width /= 4.0;
        size.height /= 4.0;
        //создаем квадрат с ранее посчитанной точкой и размерами
        boundingMapRect = (MKMapRect) { origin, size };
        //создаем квадрат размером с карту
        MKMapRect worldRect = MKMapRectMake(0, 0, MKMapSizeWorld.width, MKMapSizeWorld.height);
        //рисуем наш прямоугольник (как пересечкение двух прямоугольников)
        boundingMapRect = MKMapRectIntersection(boundingMapRect, worldRect);
    }
    return self;
}

- (void)dealloc
{
    free(_points);
}

-(MKMapPoint)getPoint
{
    return _points[_pointCount - 1];
}

-(MKMapPoint)getFirstPoint
{
    return *(firstPoint);
}

- (CLLocationCoordinate2D)coordinate
{
    return MKCoordinateForMapPoint(_points[0]);
}

- (MKMapRect)boundingMapRect
{
    return boundingMapRect;
}

- (void)lockForReading
{
    [lockForRec lock];
}

- (void)unlockForReading
{
    [lockForRec unlock];
}

- (MKMapRect)addCoordinate:(CLLocationCoordinate2D)coord
{
    [lockForRec lock];
    //Преобразуем CLLocationCoordinate2D в MKMapPoint
    MKMapPoint newPoint = MKMapPointForCoordinate(coord);
    MKMapPoint prevPoint = _points[_pointCount - 1];
    //Получаем расстояние между двумя точками (новой и предшествующей)
    CLLocationDistance metersApart = MKMetersBetweenMapPoints(newPoint, prevPoint);
    MKMapRect updateRect = MKMapRectNull;

    if (metersApart > MINIMUM_DELTA_METERS)
    {
        //Если не хватает места в масиве (увеличиваем вдвое)
        if (pointSpace == self.pointCount)
        {
            pointSpace *= 2;
            _points = realloc(_points, sizeof(MKMapPoint) * pointSpace);
        }
        
        //Добавляем новую точку в массив
        _points[self.pointCount] = newPoint;
        _pointCount++;
        
        // Compute MKMapRect bounding prevPoint and newPoint
        double minX = MIN(newPoint.x, prevPoint.x);
        double minY = MIN(newPoint.y, prevPoint.y);
        double maxX = MAX(newPoint.x, prevPoint.x);
        double maxY = MAX(newPoint.y, prevPoint.y);
        
        updateRect = MKMapRectMake(minX, minY, maxX - minX, maxY - minY);
    }
    [lockForRec unlock];
    return updateRect;
}

@end
