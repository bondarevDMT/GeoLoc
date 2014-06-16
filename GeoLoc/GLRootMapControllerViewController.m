//
//  GLRootMapControllerViewController.m
//  GeoLoc
//
//  Created by Dmitriy Bondarev on 6/5/14.
//
//

#import "GLRootMapControllerViewController.h"
#import "GLUserTrack.h"
#import "GLUserTrackView.h"
#import "GLMapPointSelf.h"
#import "GLMapPoint.h"
#import "GLHorizontalScroller.h"
#import "GLUserTrackLibrary.h"

@interface GLRootMapControllerViewController () <CLLocationManagerDelegate, MKMapViewDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UINavigationControllerDelegate, GLHorizontalScrollerDelegate>
{
    //Размеры дисплея (необходимы для адоптации интерфейса под дисплеи 3,5 и 4)
    CGSize result;
    //массив геометок
    NSMutableArray *pointsAnnotations;
    //массив для Всех созраненных путей пользователя
    NSArray * allUserTrack;
    // массив отмены удаления пользовательского маршрута (клавиша myRoutes)
    NSMutableArray * undoStack;
    UIImagePickerController *imagePickerController;
    //Клавиши на globalMap + container
    UIButton *menuButton;
    UIButton *foundSelfButton;
    UIButton *recTrack;
    UIButton *buttonPoint;
    UIButton *ButtonSelfPoint;
    //TextField для ввода title UresTrack и UserPoints
    UITextField *textViewForPointMap;
    UITextField *textViewForTrackMap;
    //Клавиша для возврта из просмотра selfFoto UserPointSelf
    UIButton *buttonForUserSelfMenu;
    //UIView для Background
    UIView *viewForBackground;
    UIImageView *bgnd_dark;
    //Клавиши меню + container
    UIView *containerViewForMenu;
    UIButton *mapButton;
    UIButton *myRoutes;
    //Сontaner для views клавиши myRoutes (скролл + toolBars)
    UIView *containerForViewMyRoutesButton;
    GLHorizontalScroller * scroller;
    UIToolbar * toolbar;
    UIToolbar * toolbarForRoute;
    //объекты необходимые для скриншота карты
    UIImageView *snapshotview;
    UIImage *snapshot;
    //переменные необходимые для рассчета региона в котором будет виден весь UserTrack
    double maxX, maxY, minX, minY;
    //индекс элемента scroll
    int currentTrackIndexForScroll;
    //Текущее местоположение пользователя
    CLLocationCoordinate2D myLocation;
    //Проверка первой инициализации местоположения пользователя
    BOOL firstInit;
    //Проверка Какой тип PointMap создаю (используюется в методе делегата TextField) YES - PointMap NO - SelfPointMap
    BOOL boolForPointMap;
    //Проверка ведется ли сейчас пользователем запись пути
    BOOL isRecTrack;
    //Проверка добавил ли пользователь на карту ранее сохраненный UserTrack
    BOOL changeUserTrack;
    //Объекты для добавления на карту UserTrack
    GLUserTrack *addUserTrack;
    NSArray *addpointsAnnotations;
    //View для просмотра UserSelf в метке
    UIImageView *viewUserSelfForPoint;
    //Регион для сохранения UserTrack (чтобы при открытии был виден выбранный ранее сохраненный пользовательский путь)
    MKCoordinateRegion regionForSaveTrack;
    NSArray *arrayForRegionForSaveTrack;
    //Image для скриншота карты(используется при сохранении UserTrack)
    UIImage *imageMap;
    //View для добавленного из scroll UserTrack
    GLUserTrackView *viewForUserTrackadd;
}

@property (nonatomic, strong) CLLocationManager *locationManager;
//Путь пользователя model and View
@property (nonatomic, strong) GLUserTrack *userTrackMap;
@property (nonatomic, strong) GLUserTrackView *userTrackView;
@property (weak, nonatomic) IBOutlet MKMapView *globalMap;

@end

@implementation GLRootMapControllerViewController

@synthesize locationManager = _locationManager;
@synthesize userTrackMap = _userTrackMap;
@synthesize globalMap = _globalMap;
@synthesize userTrackView = _userTrackView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //Создание и настройка LocationManager
        self.locationManager = [[CLLocationManager alloc] init];
        [self.locationManager setDelegate:self];
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        [self.locationManager startUpdatingLocation];
        //Инициализация массивов
        pointsAnnotations = [[NSMutableArray alloc] init];
        allUserTrack = [[GLUserTrackLibrary sharedInstance] getUserTraks];
        undoStack = [[NSMutableArray alloc] init];
        currentTrackIndexForScroll = 0;
        result = [[UIScreen mainScreen] bounds].size;
        //Подписываюсь на метод для сохранения индекса скролла при бэкграунде
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(saveCurrentState)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        firstInit = NO;
        boolForPointMap = NO;
        changeUserTrack = NO;
        isRecTrack = NO;

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //настройки globalMap
    [self.globalMap setShowsUserLocation:YES];
    [self.globalMap setDelegate:self];
    self.globalMap.mapType = MKMapTypeStandard;
    
    //Инициализация фоновой картинки меню
    viewForBackground = [[UIView alloc] initWithFrame:self.view.bounds];
    if (result.height == 568.0)
        bgnd_dark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bgnd_dark-568h"]];
    else
        bgnd_dark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bgnd_dark"]];
    [viewForBackground addSubview:bgnd_dark];
    
    //Создание и инициализация image для снимка карты
    imageMap = [[UIImage alloc] init];
    
    //Создание и настройка клавиш на globalMap
    menuButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 15, 40, 40)];
    UIImage *imageForMenuButton = [UIImage imageNamed:@"menu.png"];
    [menuButton setBackgroundImage:imageForMenuButton forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(onClickMenu) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:menuButton];
    foundSelfButton = [[UIButton alloc] initWithFrame:CGRectMake(260, result.height/2 - 110, 40, 40)];
    UIImage *imageForFoundSelfButton = [UIImage imageNamed:@"FoundMe.png"];
    [foundSelfButton setBackgroundImage:imageForFoundSelfButton forState:UIControlStateNormal];
    [foundSelfButton addTarget:self action:@selector(onClickFindSelf) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:foundSelfButton];
    recTrack = [[UIButton alloc] initWithFrame:CGRectMake(260, result.height/2 - 50, 40, 40)];
    UIImage *imageForRecTrack = [UIImage imageNamed:@"recOn.png"];
    [recTrack setBackgroundImage:imageForRecTrack forState:UIControlStateNormal];
    [recTrack addTarget:self action:@selector(recTrackOnOff) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:recTrack];
    ButtonSelfPoint = [[UIButton alloc] initWithFrame:CGRectMake(260, result.height/2 + 10, 40, 40)];
    UIImage *imageForButtonSelfPoint = [UIImage imageNamed:@"selfPoint.png"];
    [ButtonSelfPoint setBackgroundImage:imageForButtonSelfPoint forState:UIControlStateNormal];
    [ButtonSelfPoint addTarget:self action:@selector(onClickSelfPoint) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:ButtonSelfPoint];
    buttonPoint = [[UIButton alloc] initWithFrame:CGRectMake(260, result.height/2 + 70, 40, 40)];
    UIImage *imageForButtonPoint = [UIImage imageNamed:@"point.png"];
    [buttonPoint setBackgroundImage:imageForButtonPoint forState:UIControlStateNormal];
    [buttonPoint addTarget:self action:@selector(onClickPoint) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:buttonPoint];
    
    //Создание и настройка textField для ввода title UserTreck и UserPoints
    textViewForPointMap = [[UITextField alloc] initWithFrame:CGRectMake(58, 20, 205, 30)];
    [textViewForPointMap setBorderStyle:UITextBorderStyleRoundedRect];
    [textViewForPointMap setDelegate:self];
    textViewForTrackMap = [[UITextField alloc] initWithFrame:CGRectMake(58, 20, 205, 30)];
    [textViewForTrackMap setBorderStyle:UITextBorderStyleRoundedRect];
    [textViewForTrackMap setDelegate:self];
    
    // Создание и настройка клавиши возврата из просмотра selfFoto для MapPoint
    buttonForUserSelfMenu = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, 40, 40)];
    UIImage *imageForButtonForUserSelfMenu = [UIImage imageNamed:@"menu.png"];
    [buttonForUserSelfMenu setBackgroundImage:imageForButtonForUserSelfMenu forState:UIControlStateNormal];
    [buttonForUserSelfMenu addTarget:self action:@selector(buttonForUserSelfMenu) forControlEvents:UIControlEventTouchDown];
    
    // Создание и настройка клавиш меню + container
    containerViewForMenu = [[UIView alloc] initWithFrame:self.view.bounds];
    mapButton = [[UIButton alloc] initWithFrame:CGRectMake((result.width/2 - 125), ((result.height/2) - (50*2)), 250, 50)];
    [mapButton setTitle:@"карта" forState:UIControlStateNormal];
    [mapButton addTarget:self action:@selector(onClickMap) forControlEvents:UIControlEventTouchDown];
    mapButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [containerViewForMenu addSubview:mapButton];
    myRoutes = [[UIButton alloc] initWithFrame:CGRectMake((result.width/2 - 125), ((result.height/2)- (50*1)), 250, 50)];
    [myRoutes setTitle:@"мои маршруты" forState:UIControlStateNormal];
    [myRoutes addTarget:self action:@selector(onClickMyRoutes) forControlEvents:UIControlEventTouchDown];
    myRoutes.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [containerViewForMenu addSubview:myRoutes];
    
    containerForViewMyRoutesButton = [[UIView alloc] initWithFrame:self.view.bounds];
    //Создание и настройка scroll для пользовательских маршрутов
    [self loadPreviousState];
    if ([[UIScreen mainScreen] bounds].size.height == 480 && NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        scroller = [[GLHorizontalScroller alloc] initWithFrame:CGRectMake(0.f, 50.f, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height*5/6)];
    }
    if ([[UIScreen mainScreen] bounds].size.height == 480 && NSFoundationVersionNumber == NSFoundationVersionNumber_iOS_6_1) {
      scroller = [[GLHorizontalScroller alloc] initWithFrame:CGRectMake(0.f, 30.f, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height*5/6)];
    }
    if ([[UIScreen mainScreen] bounds].size.height == 568 && NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        scroller = [[GLHorizontalScroller alloc] initWithFrame:CGRectMake(0.f, 55.f, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height*5/6)];
    }
    if ([[UIScreen mainScreen] bounds].size.height == 568 && NSFoundationVersionNumber == NSFoundationVersionNumber_iOS_6_1) {
        scroller = [[GLHorizontalScroller alloc] initWithFrame:CGRectMake(0.f, 35.f, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height*5/6)];
    }
    scroller.delegate = self;
    [containerForViewMyRoutesButton addSubview:scroller];
    //Создание и настройка ToolBar для Просмотра пользовательских маршрутов
    //Верхний ToolBar
    toolbarForRoute = [[UIToolbar alloc] init];
    UIBarButtonItem * back = [[UIBarButtonItem alloc]
                              initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                              target:self
                              action:@selector(doneRoute)];
    UIBarButtonItem * spaceright = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                    target:nil
                                    action:nil];
    UIBarButtonItem *change = [[UIBarButtonItem alloc] initWithTitle:@"change" style:UIBarButtonItemStylePlain target:self action:@selector(changeTracks)];
    [toolbarForRoute setItems:@[back, spaceright,change]];
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1, 1), NO, 0.0);
    UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [toolbarForRoute setBackgroundImage:blank forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    [containerForViewMyRoutesButton addSubview:toolbarForRoute];
    //Нижний ToolBar
    toolbar = [[UIToolbar alloc] init];
    UIBarButtonItem * undoItem = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemUndo
                                  target:self
                                  action:@selector(undoAction)];
    undoItem.enabled = NO;
    UIBarButtonItem * space = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                               target:nil
                               action:nil];
    
    UIBarButtonItem * delete = [[UIBarButtonItem alloc]
                                initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                target:self
                                action:@selector(deleteTracks)];
    [toolbar setItems:@[undoItem, space, delete]];
    [toolbar setBackgroundImage:blank forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    [containerForViewMyRoutesButton addSubview:toolbar];
    
    //Создание PickerController для UserSelf
    imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    
    //Создание image для скриншота карты
    snapshot = [[UIImage alloc] init];

}

//Рассчет размеров и местоположения toolbars для просмотра пользовательских маршрутов
- (void)viewWillLayoutSubviews
{
     if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1)
     {
         toolbarForRoute.frame = CGRectMake(0, 20, result.width, 30);
     }
    else
        toolbarForRoute.frame = CGRectMake(0, 0, result.width, 30);
    toolbar.frame = CGRectMake(0, self.view.frame.size.height - 30, self.view.frame.size.width, 30);
}

-(void)dealloc
{
    self.locationManager.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Metods for delegate MKMapView

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    myLocation = [userLocation coordinate];
    //При первом обновлении местоположения пользователя устанавливаем регион для удобной работы с картой
    if (!firstInit)
    {
        [self.globalMap setRegion:MKCoordinateRegionMakeWithDistance(myLocation, 250, 250) animated:YES];
        firstInit = YES;
    }
}

#pragma mark Metods for delegate CLLocationManager

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if (newLocation)
    {
        //Проверка что старые и новые координаты различны
        if ((oldLocation.coordinate.latitude != newLocation.coordinate.latitude) &&
            (oldLocation.coordinate.longitude != newLocation.coordinate.longitude))
        {
            //Если включена запись UserTrack то в self.userTrackMap добавляем новую координату (обновленную)
            if (isRecTrack == YES) {
                MKMapRect updateRect = [self.userTrackMap addCoordinate:newLocation.coordinate];
                //отображаем UserTrack на globalMap
                if (!MKMapRectIsNull(updateRect))
                {
                    MKZoomScale currentZoomScale = (CGFloat)(self.globalMap.bounds.size.width / self.globalMap.visibleMapRect.size.width);
                    CGFloat lineWidth = MKRoadWidthAtZoomScale(currentZoomScale);
                    updateRect = MKMapRectInset(updateRect, -lineWidth, -lineWidth);
                    [self.userTrackView setNeedsDisplayInMapRect:updateRect];
                }
            }
        }
        
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    //TODO Сдалать данный метод (вызывается в случае если менеджеру не удалось определить местоположение)
    NSLog(@"Could not find location: %@", error);
}


- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    if (changeUserTrack && (viewForUserTrackadd == Nil)) {
        viewForUserTrackadd = [[GLUserTrackView alloc] initWithOverlay:overlay];
        return viewForUserTrackadd;
    }
    else
    {
        if (!self.userTrackView)
        {
            _userTrackView = [[GLUserTrackView alloc] initWithOverlay:overlay];
        }
        return self.userTrackView;
    }
}

//Обновление местоположения пользователя при уходе в "Background"
#pragma mark - Actions

- (void)switchToBackgroundMode:(BOOL)background
{
    if (background)
    {
        if (isRecTrack)
        {
            self.locationManager.delegate = self;
            [self.locationManager startUpdatingLocation];
        }
        else
        {
            [self.locationManager stopUpdatingLocation];
            self.locationManager.delegate = nil;
        }
    }
    
}

#pragma mark Metods for delegate UITextField
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == textViewForTrackMap) {
        if (arrayForRegionForSaveTrack == Nil) {
            arrayForRegionForSaveTrack = [[NSArray alloc] initWithObjects:[NSNumber numberWithFloat:regionForSaveTrack.center.latitude], [NSNumber numberWithFloat:regionForSaveTrack.center.longitude], [NSNumber numberWithFloat:regionForSaveTrack.span.latitudeDelta], [NSNumber numberWithFloat:regionForSaveTrack.span.longitudeDelta], nil];
        }
        GLUserTrackForSaved *userTrackSaved = [[GLUserTrackForSaved alloc] initTrack:self.userTrackMap titleUserTrack:textField.text ImageMap:snapshotview mapPoints:pointsAnnotations region:arrayForRegionForSaveTrack];
        [[GLUserTrackLibrary sharedInstance] addUserTrack:userTrackSaved];
        [self.globalMap removeAnnotations:pointsAnnotations];
        [self.globalMap removeOverlay:self.userTrackMap];
        textViewForTrackMap.text = @"";
        [textViewForTrackMap removeFromSuperview];
        pointsAnnotations = Nil;
        self.userTrackMap = Nil;
        self.userTrackView = Nil;
        arrayForRegionForSaveTrack = Nil;
        snapshotview = Nil;
        
    }
    else if (textField == textViewForPointMap && boolForPointMap == NO)
    {
        GLMapPointSelf *mapPointSelf = [[GLMapPointSelf alloc] initWithCoordinate:myLocation title:textField.text fotoSelf:imageMap];
        [pointsAnnotations addObject:mapPointSelf];
        [self.globalMap addAnnotation:mapPointSelf];
        textViewForPointMap.text = @"";
        [textViewForPointMap removeFromSuperview];
    } else if (textField == textViewForPointMap && boolForPointMap == YES)
    {
        GLMapPoint *mapPoint = [[GLMapPoint alloc] initWithCoordinate:myLocation title:textField.text];
        [pointsAnnotations addObject:mapPoint];
        [self.globalMap addAnnotation:mapPoint];
        textViewForPointMap.text = @"";
        [textViewForPointMap removeFromSuperview];
    }
    [viewForBackground removeFromSuperview];
    return YES;
}

#pragma mark Metods for UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    imageMap = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImageWriteToSavedPhotosAlbum(imageMap, nil, nil, nil);
        [self.view addSubview:viewForBackground];
        [self.view addSubview:textViewForPointMap];
    }
}

#pragma mark methods for button on map
//Метод клавиши меню
-(void)onClickMenu
{
    [self.view addSubview:viewForBackground];
    [self.view addSubview: containerViewForMenu];
}
//Метод Создания PointMap
-(void)onClickPoint
{
    if (pointsAnnotations == Nil)
        pointsAnnotations = [[NSMutableArray alloc] init];
    [self.view addSubview:viewForBackground];
    [self.view addSubview:textViewForPointMap];
    boolForPointMap = YES;
}
//Метод Создания SelfPointMap
-(void)onClickSelfPoint
{
    if (pointsAnnotations == Nil)
        pointsAnnotations = [[NSMutableArray alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:imagePickerController animated:YES completion:nil];
    boolForPointMap = NO;
}
//Метод для включения слежения за пользователем
-(void)onClickFindSelf
{
    [self.globalMap setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
}

-(void)recTrackOnOff
{
    if (isRecTrack == NO)
    {
        self.userTrackMap = [[GLUserTrack alloc] initWithCenterCoordinate:myLocation];
        //Если на курту был добавлен ранее сохраненный маршрут то удаляем его из отображения
        if (changeUserTrack == YES) {
            [self.globalMap removeOverlay:addUserTrack];
            [self.globalMap removeAnnotations:addpointsAnnotations];
            addUserTrack = Nil;
            viewForUserTrackadd = Nil;
            changeUserTrack = NO;
        }
        isRecTrack = YES;
        //Меняю изображение кнопки записи
        UIImage *imageForRecTrack = [UIImage imageNamed:@"recOff.png"];
        [recTrack setBackgroundImage:imageForRecTrack forState:UIControlStateNormal];
        [self.globalMap addOverlay:self.userTrackMap];
        //Включаю отслеживание местоположения пользователя
        [self.globalMap setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
    }
    else if (isRecTrack == YES)
    {
        UIImage *imageForRecTrack = [UIImage imageNamed:@"recOn.png"];
        [recTrack setBackgroundImage:imageForRecTrack forState:UIControlStateNormal];
        isRecTrack = NO;
        //отключаем слежение за местоположением пользователя
        [self.globalMap setUserTrackingMode:MKUserTrackingModeNone animated:NO];
        [self skrinshotMapWithTrack];
    }
}

#pragma mark methods for Create region and image for userTrackMap

-(void)skrinshotMapWithTrack
{
    //Получаю первую точку UserTrack и инициализирую ее координатами переменные необходимые для дальнейшего рассчета региона? в котором будет виден весь UserTrack
    MKMapPoint firstPointForСalculation = [self.userTrackMap getFirstPoint];
    minX = firstPointForСalculation.x;
    maxX = firstPointForСalculation.x;
    minY = firstPointForСalculation.y;
    maxY = firstPointForСalculation.y;
    double currentValueX;
    double currentValueY;
    for (int i = 0; i< self.userTrackMap.pointCount - 1; i++) {
        currentValueX = self.userTrackMap.points[i].x;
        currentValueY = self.userTrackMap.points[i].y;
        if (currentValueX > maxX) {
            maxX = currentValueX;
        }
        if (currentValueX < minX) {
            minX = currentValueX;
        }
        
        if (currentValueY > maxY) {
            maxY = currentValueY;
        }
        if (currentValueY < minY) {
            minY = currentValueY;
        }
    }
    //Рассчитываем и устанавливаем регион на котором будет виден весь UserTrack
    [self createUserRegion];
    //Делаем скриншот карты
    CGRect rect = [self.view bounds];
    UIGraphicsBeginImageContextWithOptions(rect.size,YES,0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.view.layer renderInContext:context];
    snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //Создание snapshotview для добавления к UserTrackSaved
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width*3/4;
    CGFloat screenHeight = screenRect.size.height*3/4;
    snapshotview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    [snapshotview setImage:snapshot];
    //Предоставляем пользователю окно для ввода title UserTrack
    [self.view addSubview:viewForBackground];
    [self.view addSubview:textViewForTrackMap];
}

-(void) createUserRegion
{
    MKMapPoint minXMinY = MKMapPointMake(minX, minY);
    MKMapPoint maxXMinY = MKMapPointMake(maxX, minY);
    MKMapPoint minXMaxY = MKMapPointMake(minX, maxY);
    MKMapPoint central = MKMapPointMake((maxX - minX)/2+minX, (maxY - minY)/2 + minY);
    CLLocationCoordinate2D centralCoordinate = MKCoordinateForMapPoint(central);
    CLLocationCoordinate2D minXcoord = MKCoordinateForMapPoint(minXMinY);
    CLLocationCoordinate2D maxXcoord = MKCoordinateForMapPoint(maxXMinY);
    CLLocationCoordinate2D minYcoord = MKCoordinateForMapPoint(minXMinY);
    CLLocationCoordinate2D maxYcoord = MKCoordinateForMapPoint(minXMaxY);
    CLLocationDistance longitudinalMeters = [self getDistanceFrom:minXcoord to:maxXcoord];
    CLLocationDistance latitudinalMeters = [self getDistanceFrom:minYcoord to:maxYcoord];
    
    if (longitudinalMeters < 250 && latitudinalMeters < 250) {
        regionForSaveTrack = MKCoordinateRegionMakeWithDistance(centralCoordinate, 250, 250);
        self.globalMap.region = regionForSaveTrack;
    } else if (longitudinalMeters < 250) {
        regionForSaveTrack = MKCoordinateRegionMakeWithDistance(centralCoordinate, latitudinalMeters+400, 250);
        self.globalMap.region = regionForSaveTrack;
    } else if (latitudinalMeters < 250) {
        
        regionForSaveTrack = MKCoordinateRegionMakeWithDistance(centralCoordinate, 250, longitudinalMeters+400);
        self.globalMap.region = regionForSaveTrack;
    } else
    {
        regionForSaveTrack = MKCoordinateRegionMakeWithDistance(centralCoordinate, latitudinalMeters+400, longitudinalMeters+400);
        self.globalMap.region = regionForSaveTrack;
    }
}

//Рассчет расстояния между двумя точками
- (CLLocationDistance)getDistanceFrom:(CLLocationCoordinate2D)start to:(CLLocationCoordinate2D)end
{
	CLLocation *startLoc = [[CLLocation alloc] initWithLatitude:start.latitude longitude:start.longitude];
	CLLocation *endLoc = [[CLLocation alloc] initWithLatitude:end.latitude longitude:end.longitude];
	CLLocationDistance retVal = [startLoc distanceFromLocation:endLoc];
	return retVal;
}

#pragma mark methods for button on menu

-(void)onClickMap
{
    [viewForBackground removeFromSuperview];
    [containerViewForMenu removeFromSuperview];
}

-(void)onClickMyRoutes
{
    [containerViewForMenu removeFromSuperview];
    [self.view addSubview:containerForViewMyRoutesButton];
    [self reloadScroller];
}

#pragma mark methods For Tollbars for myRoute

- (void)addTrack:(GLUserTrackForSaved *)Track atIndex:(int)index
{
    [[GLUserTrackLibrary sharedInstance] addUserTrack:Track AtIndex:index];
    currentTrackIndexForScroll = index;
    [self reloadScroller];
}

- (void)deleteTracks
{
    if (currentTrackIndexForScroll >= 0) {
    GLUserTrackForSaved *deletedTrack = allUserTrack[currentTrackIndexForScroll];
    NSMethodSignature * sig = [self methodSignatureForSelector:@selector(addTrack:atIndex:)];
    NSInvocation * undoDeleteAction = [NSInvocation invocationWithMethodSignature:sig];
    [undoDeleteAction setTarget:self];
    [undoDeleteAction setSelector:@selector(addTrack:atIndex:)];
    [undoDeleteAction setArgument:&deletedTrack atIndex:2];
    [undoDeleteAction setArgument:&currentTrackIndexForScroll atIndex:3];
    [undoDeleteAction retainArguments];
    [undoStack addObject:undoDeleteAction];
    [[GLUserTrackLibrary sharedInstance] deleteUserTrackAtIndex:currentTrackIndexForScroll];
    [self reloadScroller];
    [toolbar.items[0] setEnabled:YES];
    }
    else
        return;
}

-(void)changeTracks
{
    //проверка не отрицателен ли currentTrackIndexForScroll
    if (currentTrackIndexForScroll >= 0) {
        [viewForBackground removeFromSuperview];
        [containerForViewMyRoutesButton removeFromSuperview];
        //проверка ведется ли сейчас запись пользовательского пути (если да то завершаем ее)
        if (isRecTrack) {
            [self recTrackOnOff];
        }
        //проверка есть ли сейчас на карте добавленный userTrack если да то убираем его с отображения (на карте всегда должен быть лишь 1 userTrack)
        if (changeUserTrack) {
            [self.globalMap removeOverlay:addUserTrack];
            [self.globalMap removeAnnotations:addpointsAnnotations];
            addUserTrack = Nil;
            viewForUserTrackadd = Nil;
            changeUserTrack = NO;
        }
        changeUserTrack = YES;
        //Если все проверки пройдены то добавляем UserTrack из коллекции
        addUserTrack = [[GLUserTrack alloc] init];
        NSLog(@"INDEX = %d", currentTrackIndexForScroll);
        NSLog(@"COUNT = %d", [[GLUserTrackLibrary sharedInstance] getUserTraks].count);
        addUserTrack = [[[GLUserTrackLibrary sharedInstance] getUserTraks][currentTrackIndexForScroll] userTrack];
        [self.globalMap addOverlay:addUserTrack];
        addpointsAnnotations = (NSMutableArray *)[[[GLUserTrackLibrary sharedInstance] getUserTraks][currentTrackIndexForScroll] arrayMapPoint];
        [self.globalMap addAnnotations:addpointsAnnotations];
        NSArray *reg = [[[GLUserTrackLibrary sharedInstance] getUserTraks][currentTrackIndexForScroll] regionForMap];
        MKCoordinateRegion region;
        region.center.latitude = [reg[0] doubleValue];
        region.center.longitude = [reg[1] doubleValue];
        region.span.latitudeDelta = [reg[2] doubleValue];
        region.span.longitudeDelta = [reg[3] doubleValue];
        [self.globalMap setRegion:region animated:YES];
    } else
        return;
}

- (void)undoAction
{
    if (undoStack.count > 0)
    {
        NSInvocation * undoAction = [undoStack lastObject];
        [undoStack removeLastObject];
        [undoAction invoke];
    }
    
    if (undoStack.count == 0)
    {
        [toolbar.items[0] setEnabled:NO];
    }
}

-(void)doneRoute
{
    [containerForViewMyRoutesButton removeFromSuperview];
    [self.view addSubview:containerViewForMenu];
}

#pragma mark - HorizontalScrollerDelegate methods

- (void)horizontalScroller:(GLHorizontalScroller *)scroller clickedViewAtIndex:(int)index
{
    currentTrackIndexForScroll = index;
}

- (NSInteger)numberOfViewsForHorizontalScroller:(GLHorizontalScroller *)scroller
{
    return allUserTrack.count;
}

- (UIView *)horizontalScroller:(GLHorizontalScroller *)scroller viewAtIndex:(int)index
{
    return [allUserTrack[index] imageMapWithTrack];
}

- (void)reloadScroller
{
    allUserTrack = [[GLUserTrackLibrary sharedInstance] getUserTraks];
    if (currentTrackIndexForScroll < 0) {
        currentTrackIndexForScroll = 0;
    }
    else if (currentTrackIndexForScroll>= allUserTrack.count)
        currentTrackIndexForScroll = (int)allUserTrack.count - 1;
    [scroller reload];
}

- (NSInteger)initialViewIndexForHorizontalScroller:(GLHorizontalScroller *)scroller
{
    return currentTrackIndexForScroll;
}

#pragma mark SavedUserState

//Сохранение в standardUserDefaults индекс элемента на котором остановился пользователь в scroll + сохранение UserTrack в память
- (void)saveCurrentState
{
    [[NSUserDefaults standardUserDefaults] setInteger:currentTrackIndexForScroll
                                               forKey:@"currentTrackIndexForScroll"];
    [[GLUserTrackLibrary sharedInstance] saveTracks];

}
- (void)loadPreviousState
{
    currentTrackIndexForScroll = [[NSUserDefaults standardUserDefaults] integerForKey:@"currentTrackIndexForScroll"];
}

#pragma  mark Annotation
//Метод для клавиши возврата из просмотра пользовательского self
-(void)buttonForUserSelfMenu
{
    [viewUserSelfForPoint removeFromSuperview];
    [buttonForUserSelfMenu removeFromSuperview];
}

//метод при "тапе" по Annotation (если это SelfPoint то открывается ассоциированная с Annotation view)
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    id <MKAnnotation> annotation = [view annotation];
    if ([annotation isKindOfClass:[GLMapPointSelf class]])
    {
        NSLog(@"clicked GLMapPointSelfAnnotation");
        GLMapPointSelf *annot = (GLMapPointSelf *)view.annotation;
        viewUserSelfForPoint = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, result.width, result.height)];
        viewUserSelfForPoint.image = [annot getFoto];
        [self.view addSubview:viewUserSelfForPoint];
        [self.view addSubview:buttonForUserSelfMenu];
    }
}

//Создаю MKPinAnnotationView для SelfPoint
- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    //проверка есть ли уже метка на данной локации (если да то выход)
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    if ([annotation isKindOfClass:[GLMapPointSelf class]])
    {
        static NSString *GLMapPoinSelfIdentifier = @"GLMapPoinSelfIdentifier";
        
        MKPinAnnotationView *pinView =
        (MKPinAnnotationView *) [self.globalMap dequeueReusableAnnotationViewWithIdentifier:GLMapPoinSelfIdentifier];
        if (pinView == nil)
        {
            MKPinAnnotationView *customPinView = [[MKPinAnnotationView alloc]
                                                  initWithAnnotation:annotation reuseIdentifier:GLMapPoinSelfIdentifier];
            customPinView.pinColor = MKPinAnnotationColorPurple;
            customPinView.animatesDrop = YES;
            customPinView.canShowCallout = YES;
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [rightButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
            customPinView.rightCalloutAccessoryView = rightButton;
            return customPinView;
        }
        else
        {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    return nil;
}

@end
