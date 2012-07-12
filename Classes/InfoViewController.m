//
//  InfoViewController.m
//  TsunamiEvac
//
//  Created by DITERPMAC07 on 1/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InfoViewController.h"
// *KS: for AddThis button
#import "AddThis.h"

// *KS: for legend
//#define kIncidentsLayerURL @"http://services.arcgis.com/tNJpAOha4mODLkXz/ArcGIS/rest/services/Tsunami_Evacuation_Zones_2010/FeatureServer/0?token=uUK69kZJpTORmzHheAqQi4bL82K8rv-qn612rzJBdxkW6YFJdJNHOCIKLyNIX89d2NaYsl4IK8VFQzF2HfOQFw.."

@implementation InfoViewController

// *KS: add synth
@synthesize button = _button;
@synthesize window = _window;

//*KS: legend
@synthesize mapView=_mapView;
@synthesize infoButton=_infoButton;
@synthesize legendDataSource=_legendDataSource;
@synthesize legendViewController=_legendViewController;
@synthesize popOverController=_popOverController;

@synthesize incidentsLayer = _incidentsLayer;

// *KS: for AddThis share button
- (IBAction)shareButtonClicked:(id)sender {
	
	//Show addthis menu
	UIButton *button = sender;
	UIWindow *window = [UIApplication sharedApplication].keyWindow;
	if (!window) {
		window = [[UIApplication sharedApplication].windows objectAtIndex:0];
	}
	// *KS: replace with own keys
    //[AddThisSDK setFavoriteMenuServices:@"mail",@"twitter",@"facebook",nil];
    [AddThisSDK presentAddThisMenuInPopoverForURL: @"http://www.honolulu.gov/mobile/htez.htm" 
										 fromRect:[self.view convertRect:button.frame toView:window]
                                        withTitle:@"Honolulu Tsunami Evacuation Zones iOS App" 
                                      description:@"Get more info on the Honolulu Tsunami Evacuation Zones App here"];
    
}

// *KS: for AddThis email button
//- (IBAction)emailButtonClicked:(id)sender{
	//share to native email
//	[AddThisSDK shareURL:@""
//             withService:@"mailto"
//				   title:@"Honolulu Tsunami Evacuation Zones iOS App (0.1)"
//			 description:@"AddThis is a free way to boost traffic back to your site by making it easier for visitors to share your content."];
//}

// *KS: for the info view
- (IBAction)goBack{
    [self dismissModalViewControllerAnimated:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//- (void)didReceiveMemoryWarning
//{
    // Releases the view if it doesn't have a superview.
//    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
//}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.mapView.layerDelegate = self;
	
    // *KS: use own legend service
	NSURL *mapUrl = [NSURL URLWithString:@"http://gis.hicentral.com/ArcGIS/rest/services/OperPublicSafety/MapServer"];
	AGSDynamicMapServiceLayer *tiledLyr = [AGSDynamicMapServiceLayer dynamicMapServiceLayerWithURL:mapUrl];
    [self.mapView addMapLayer:tiledLyr withName:@"Tiled Layer"];
    
    //setup the incidents layer as a feature layer and add it to the map
    //self.incidentsLayer = [AGSFeatureLayer featureServiceLayerWithURL:[NSURL URLWithString:kIncidentsLayerURL] mode:AGSFeatureLayerModeOnDemand]; 
    //NSURL *kIncidentsLayerURL = [NSURL URLWithString:@"http://services.arcgis.com/tNJpAOha4mODLkXz/ArcGIS/rest/services/Tsunami_Evacuation_Zones_2010/FeatureServer/0"];
    //AGSFeatureLayer *incidentsLayer = [AGSFeatureLayer featureServiceLayerWithURL:kIncidentsLayerURL mode:AGSFeatureLayerModeOnDemand];
    //AGSFeatureLayer *incidentsLayer = [AGSFeatureLayer featureServiceLayerWithURL:kIncidentsLayerURL mode:AGSFeatureLayerModeSelection];
    //AGSFeatureLayer *incidentsLayer = [AGSFeatureLayer featureServiceLayerWithURL:kIncidentsLayerURL mode:AGSFeatureLayerModeSnapshot];
    //self.incidentsLayer.outFields = [NSArray arrayWithObject:@"*"];
    //self.incidentsLayer.infoTemplateDelegate = self.incidentsLayer;
    
    //name the layer. This is the name that is displayed if there was a property page, tocs, etc...
	//[self.mapView addMapLayer:incidentsLayer withName:@"Incidents"];
    
	//A data source that will hold the legend items
	self.legendDataSource = [[LegendDataSource alloc] init];
	
	//Initialize the legend view controller
	//This will be displayed when user clicks on the info button
	self.legendViewController = [[LegendViewController alloc] initWithNibName:@"LegendViewController" bundle:nil];
	self.legendViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	self.legendViewController.legendDataSource = self.legendDataSource;
	
	if([[UIDevice currentDevice] isIPad]){
		self.popOverController = [[UIPopoverController alloc]
								  initWithContentViewController:self.legendViewController];
		[self.popOverController setPopoverContentSize:CGSizeMake(250, 500)];
		self.popOverController.passthroughViews = [NSArray arrayWithObject:self.view];
		self.legendViewController.popOverController = self.popOverController;
	}
}

//- (void)viewDidUnload
//{
//    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
//}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
    // Return YES for supported orientations
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
//}

// *KS: from other m files
// Override to allow orientations other than the default portrait orientation.
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
//    return YES;
//}

#pragma mark -
#pragma mark AGSMapViewDelegate

- (void)mapView:(AGSMapView *) mapView didLoadLayerForLayerView:(UIView<AGSLayerView> *) layerView {
	//Add legend for each layer added to the map
	[self.legendDataSource addLegendForLayer:(AGSLayer *)layerView.agsLayer];
}


- (IBAction) presentLegendViewController: (id) sender{
	//If iPad, show legend in the PopOver, else transition to the separate view controller
	if([[UIDevice currentDevice] isIPad]){
		[_popOverController presentPopoverFromRect:self.infoButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES ];
		
	}else {
		[self presentModalViewController:self.legendViewController animated:YES];
	}
    
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	//Re-show popOver to position it correctly after orientation change
	if([[UIDevice currentDevice] isIPad] && self.popOverController.popoverVisible) {
		[self.popOverController dismissPopoverAnimated:NO];
		[self.popOverController presentPopoverFromRect:self.infoButton.frame 
												inView:self.view 
							  permittedArrowDirections:UIPopoverArrowDirectionUp 
											  animated:YES ];
	}
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
	self.mapView = nil;
	self.infoButton = nil;
	self.legendDataSource = nil;
	self.legendViewController = nil;
	if([[UIDevice currentDevice] isIPad])
		self.popOverController = nil;
}

// *KS: add dealloc
- (void)dealloc {
    [super dealloc];
    
    self.button = nil;
    self.window = nil;
}

@end
