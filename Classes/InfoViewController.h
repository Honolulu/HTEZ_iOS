//
//  InfoViewController.h
//  TsunamiEvac
//
//  Created by DITERPMAC07 on 1/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
// *KS: legend
#import <ArcGIS/ArcGIS.h>
#import "LegendDataSource.h"
#import "LegendViewController.h"

//@interface InfoViewController : UIViewController

// *KS: add property
//@property (nonatomic, retain) UIButton *button;
//@property (nonatomic, retain) UIWindow *window;

//@end

//@interface MainViewController : UIViewController <AGSMapViewLayerDelegate> {
@interface InfoViewController : UIViewController <AGSMapViewLayerDelegate> {
	AGSMapView *_mapView;
	UIButton* _infoButton;
    
	LegendDataSource* _legendDataSource;
	LegendViewController* _legendViewController;
	
	//Only used with iPad
	UIPopoverController* _popOverController;
    
    // *KS: legend
    AGSFeatureLayer *_incidentsLayer;
	
}

// *KS: add property
@property (nonatomic, retain) UIButton *button;
@property (nonatomic, retain) UIWindow *window;

@property (nonatomic, retain) IBOutlet AGSMapView *mapView;
@property (nonatomic, retain) IBOutlet UIButton* infoButton;

@property (nonatomic, retain) LegendDataSource *legendDataSource;
@property (nonatomic, retain) LegendViewController *legendViewController;
@property (nonatomic, retain) UIPopoverController *popOverController;

// *KS: for legend
@property (nonatomic, retain) AGSFeatureLayer *incidentsLayer;

- (void)mapView:(AGSMapView *) mapView didLoadLayerForLayerView:(UIView *) layerView;

- (IBAction) presentLegendViewController:(id)sender;

@end