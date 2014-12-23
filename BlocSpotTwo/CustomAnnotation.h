//
//  CustomAnnotation.h
//  BlocSpotTwo
//
//  Created by Richie Austerberry on 27/11/2014.
//  Copyright (c) 2014 Bloc.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CustomAnnotation : NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

-(id)initWithTitle:(NSString *)newTitle Subtitle:(NSString *)subTitle Location:(CLLocationCoordinate2D)location;
-(MKAnnotationView *) annotationView;

@end
