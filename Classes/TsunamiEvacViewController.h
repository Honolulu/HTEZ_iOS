// Copyright 2010 ESRI
//
// All rights reserved under the copyright laws of the United States
// and applicable international laws, treaties, and conventions.
//
// You may freely redistribute and use this sample code, with or
// without modification, provided you include the original copyright
// notice and use restrictions.
//
// See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
//
#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>
// *KS: for the info view
// http://www.youtube.com/watch?v=zu31fCIwt1E
// http://www.youtube.com/watch?v=wZnEjALOCs4
#import "InfoViewController.h"

@interface TsunamiEvacViewController : UIViewController <UISearchBarDelegate, AGSLocatorDelegate, AGSMapViewCalloutDelegate> {
    
    AGSMapView *_mapView;
    UISearchBar *_searchBar;
    AGSGraphicsLayer *_graphicsLayer;
	AGSLocator *_locator;
	AGSCalloutTemplate *_calloutTemplate;
    // *KS: add dynamic layer
    //this map has a dynamic layer, need a view to act as a container for it
	AGSDynamicMapServiceLayer *_dynamicLayer;
	UIView *_dynamicLayerView;
    // *KS: gps button
    BOOL gpsCurrentStatus;
    IBOutlet UIButton *gpsButton;
    // *KS: for the info view
    IBOutlet InfoViewController *infoViewController;
}

@property (nonatomic, retain) IBOutlet AGSMapView *mapView;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) AGSGraphicsLayer *graphicsLayer;
@property (nonatomic, retain) AGSLocator *locator;
@property (nonatomic, retain) AGSCalloutTemplate *calloutTemplate;
// *KS: add my stuff
//@property (nonatomic, assign) AGSDynamicMapServiceLayer *dynamicLayer;
//@property (nonatomic, assign) UIView *dynamicLayerView;
@property (nonatomic, retain) AGSDynamicMapServiceLayer *dynamicLayer;
@property (nonatomic, retain) UIView *dynamicLayerView;
//@property (nonatomic, retain) IBOutlet UIButton *gpsButton;
//@property (nonatomic, retain) IBOutlet InfoViewController *infoViewController;

// *KS: for the autoPanMode
- (IBAction)autoPanModeChanged:(id)sender;

// *KS: for the info view
- (IBAction)goToInfoView;

//This is the method that starts the geocoding operation
- (void)startGeocoding;

@end

