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
#import "TsunamiEvacViewController.h"
#import "ResultsViewController.h"
// *KS: import info view
#import "InfoViewController.h"
// *KS: for network check
#import "Reachability.h"

@implementation TsunamiEvacViewController

// *KS: for the info view
- (IBAction)goToInfoView{
    [self presentModalViewController:infoViewController animated:YES];
}

// *KS: http://stackoverflow.com/questions/7230019/how-to-set-the-uibutton-state-to-be-highlighted-after-pressing-it
-(IBAction)changeState:(UIButton*)sender{
    // *KS: hide the address search result before turning on gps
    //hide the callout
	self.mapView.callout.hidden = YES;
    
    if (gpsCurrentStatus == NO) {
        
        gpsCurrentStatus = YES;
        [gpsButton setImage:[UIImage imageNamed:@"mylocation_blue.png"] forState:UIControlStateNormal];
        
        [self.mapView.gps start];
        
        // *KS: set initial extent to focus on Oahu
        //Zooming to an initial envelope with the specified spatial reference of the map.
        //AGSSpatialReference *sr = [AGSSpatialReference spatialReferenceWithWKID:102100];
        //AGSEnvelope *env = [AGSEnvelope envelopeWithXmin:-17622457.3032347
        //                                            ymin:2412538.2061804
        //                                            xmax:-17546524.1970318
        //                                            ymax:2486948.9955196 
        //                                spatialReference:sr];
        //[self.mapView zoomToEnvelope:env animated:NO];
        
        // *KS: help from Thang at Esri
        //[self.mapView zoomToScale:100000 withCenterPoint:self.mapView.gps.currentPoint animated:NO];
        
        //self.mapView.gps.autoPanMode = true;
        
        //self.mapView.gps.autoPanMode = AGSGPSAutoPanModeCompassNavigation;
        //self.mapView.gps.navigationPointHeightFactor = 0.5;
        
        self.mapView.gps.autoPanMode = AGSGPSAutoPanModeDefault;
        self.mapView.gps.wanderExtentFactor = 0.75;
        
    }
    else {
        gpsCurrentStatus = NO;
        [gpsButton setImage:[UIImage imageNamed:@"mylocation.png"] forState:UIControlStateNormal];
        [self.mapView.gps stop];
    }
}

//The map service
// *KS: replace basemap
//static NSString *kMapServiceURL = @"http://services.arcgisonline.com/ArcGIS/rest/services/ESRI_StreetMap_World_2D/MapServer";
//static NSString *kMapServiceURL = @"http://services.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer";
// *KS: use new AGOL basemap
static NSString *kMapServiceURL = @"http://maps.esri.com/apl4/rest/services/CCH/CCHBasemap/MapServer";

//The geocode service
// *KS: replace locator service
//static NSString *kGeoLocatorURL = @"http://tasks.arcgisonline.com/ArcGIS/rest/services/Locators/ESRI_Places_World/GeocodeServer";
static NSString *kGeoLocatorURL = @"http://tasks.arcgisonline.com/ArcGIS/rest/services/Locators/TA_Address_NA/GeocodeServer";

// *KS: The dynamic map service
static NSString *kDynamicMapServiceURL = @"http://gis.hicentral.com/ArcGIS/rest/services/OperPublicSafety/MapServer";

@synthesize mapView = _mapView;
@synthesize searchBar = _searchBar;
@synthesize graphicsLayer = _graphicsLayer;
@synthesize locator = _locator;
@synthesize calloutTemplate = _calloutTemplate;
// *KS: synth my stuff
@synthesize dynamicLayer = _dynamicLayer;
@synthesize dynamicLayerView = _dynamicLayerView;
//@synthesize gpsButton = _gpsButton;
//@synthesize infoViewController = _infoViewController;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // *KS: for network check
    // http://www.iphonedevsdk.com/forum/iphone-sdk-development/19546-no-wifi-connection-best-practice.html
    // http://stackoverflow.com/questions/8812459/easiest-way-to-detect-a-connection-on-ios
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];   
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus]; 
    
    //[[Reachability sharedReachability] setHostName:@"www.drobnik.com"];
    
	//NetworkStatus internetStatus = [[Reachability sharedReachability] remoteHostStatus];
	
	if ((networkStatus != ReachableViaWiFi) && (networkStatus != ReachableViaWWAN))
	{
		UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"This app requires an internet connection via WiFi or cellular network" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[myAlert show];
		[myAlert release];
	}
    
    //set the delegate on the mapView so we get notifications for user interaction with the callout
    self.mapView.calloutDelegate = self;
    
	//create an instance of a tiled map service layer
	//Add it to the map view
    NSURL *serviceUrl = [NSURL URLWithString:kMapServiceURL];
    AGSTiledMapServiceLayer *tiledMapServiceLayer = [AGSTiledMapServiceLayer tiledMapServiceLayerWithURL:serviceUrl];
    [self.mapView addMapLayer:tiledMapServiceLayer withName:@"World Street Map"];
    
    // *KS: add dynamic map service and set alpha
    //create an instance of a dynmaic map layer
	self.dynamicLayer = [[[AGSDynamicMapServiceLayer alloc] initWithURL:[NSURL URLWithString:kDynamicMapServiceURL]] autorelease];
	
	//name the layer. This is the name that is displayed if there was a property page, tocs, etc...
	self.dynamicLayerView = [self.mapView addMapLayer:self.dynamicLayer withName:@"Dynamic Layer"];
	
	//set transparency
	self.dynamicLayerView.alpha = 0.5;
    
    //create the graphics layer that the geocoding result
    //will be stored in and add it to the map
    self.graphicsLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:self.graphicsLayer withName:@"Graphics Layer"];
    
    // *KS: set initial extent to focus on Oahu
    //Zooming to an initial envelope with the specified spatial reference of the map.
	AGSSpatialReference *sr = [AGSSpatialReference spatialReferenceWithWKID:102100];
	//AGSEnvelope *env = [AGSEnvelope envelopeWithXmin:-17622457.3032347
    //                                          ymin:2412538.2061804
    //                                            xmax:-17546524.1970318
    //                                            ymax:2486948.9955196 
	//								spatialReference:sr];
    AGSEnvelope *env = [AGSEnvelope envelopeWithXmin:-17619393
                                                ymin:2422201
                                                xmax:-17549626
                                                ymax:2470947
									spatialReference:sr];
	[self.mapView zoomToEnvelope:env animated:YES];
    
    // *KS: from Esri GPS sample
    //Listen to KVO notifications for map gps's autoPanMode property
    [self.mapView.gps addObserver:self
                       forKeyPath:@"autoPanMode"
                          options:(NSKeyValueObservingOptionNew)
                          context:NULL];
}

// *KS: for autoPanMode
- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if([keyPath isEqual:@"mapScale"]){
        if(self.mapView.mapScale < 5000) {
            [self.mapView zoomToScale:50000 withCenterPoint:nil animated:YES];
            [self.mapView removeObserver:self forKeyPath:@"mapScale"];
        }
    }
    
}

- (void)startGeocoding
{
    
    //clear out previous results
    [self.graphicsLayer removeAllGraphics];
    
    //create the AGSLocator with the geo locator URL
    //and set the delegate to self, so we get AGSLocatorDelegate notifications
    self.locator = [AGSLocator locatorWithURL:[NSURL URLWithString:kGeoLocatorURL]];
    self.locator.delegate = self;
    
    //we want all out fields
    //Note that the "*" for out fields is supported for geocode services of
    //ArcGIS Server 10 and above
    // *KS: uncommented to return all fields
    NSArray *outFields = [NSArray arrayWithObject:@"*"];
    
    //for pre-10 ArcGIS Servers, you need to specify all the out fields:
    // *KS: commented out
    //NSArray *outFields = [NSArray arrayWithObjects:@"Loc_name",
    //                      @"Shape",
    //                      @"Score",
    //                      @"Name",
    //                      @"Rank",
    //                      @"Match_addr",
    //                      @"Descr",
    //                      @"Latitude",
    //                      @"Longitude",
    //                      @"City",
    //                      @"County",
    //                      @"State",
    //                      @"State_Abbr",
    //                      @"Country",
    //                      @"Cntry_Abbr",
    //                      @"Type",
    //                      @"North_Lat",
    //                      @"South_Lat",
    //                      @"West_Lon",
    //                      @"East_Lon",
    //                      nil];
    
    //Create the address dictionary with the contents of the search bar
    // *KS: use comma to delimit search bar text
    // http://www.dalmob.org/2011/03/01/alternative-autocomplete-uitextfield/
    NSString *delimiter = @",";
    NSArray *item = [self.searchBar.text componentsSeparatedByString:delimiter];
    // *KS: added alert if only street was entered
    if ([item count] < 2){
        //show alert if we didn't get results
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Results"
                                                        message:@"Please remember to use the 'Street, City' format"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    // *KS: help from Thang at Esri
    NSArray *keys = [NSArray arrayWithObjects:@"Address", @"City", @"State", nil];
    //NSArray *objs = [NSArray arrayWithObjects:self.searchBar.text, @"Honolulu", @"HI", nil];
    // *KS: use data from array
    // http://www.ios-developer.net/iphone-ipad-programmer/development/memory/arrays/using-arrays
    NSArray *objs = [NSArray arrayWithObjects:[item objectAtIndex:0], [item objectAtIndex:1], @"HI", nil];
    //NSDictionary *addresses = [NSDictionary dictionaryWithObjects:item forKeys:keys];
    NSDictionary *addresses = [NSDictionary dictionaryWithObjects:objs forKeys:keys];
    //NSDictionary *addresses = [NSDictionary dictionaryWithObjectsAndKeys:self.searchBar.text, @"PlaceName", nil];
    //NSDictionary *addresses = [NSDictionary dictionaryWithObjectsAndKeys:self.searchBar.text, @"Single Line Input", nil];

    //now request the location from the locator for our address
    // *KS: help from Thang at Esri, was missing outSpatialReference
    //[self.locator locationsForAddress:addresses returnFields:outFields];
    [self.locator locationsForAddress:addresses returnFields:outFields outSpatialReference:self.mapView.spatialReference];
}

#pragma mark -
#pragma mark AGSMapViewDelegate

- (void)mapView:(AGSMapView *) mapView didClickCalloutAccessoryButtonForGraphic:(AGSGraphic *) graphic
{
    //The user clicked the callout button, so display the complete set of results
    ResultsViewController *resultsVC = [[ResultsViewController alloc] initWithNibName:@"ResultsViewController" bundle:nil];

    //set our attributes/results into the results VC
    resultsVC.results = graphic.attributes;
    
    //display the results vc modally
    [self presentModalViewController:resultsVC animated:YES];  
	
	[resultsVC release];
}

#pragma mark -
#pragma mark AGSLocatorDelegate

- (void)locator:(AGSLocator *)locator operation:(NSOperation *)op didFindLocationsForAddress:(NSArray *)candidates
{
    //check and see if we didn't get any results
	if (candidates == nil || [candidates count] == 0)
	{
        //show alert if we didn't get results
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Results"
                                                         message:@"Please remember to use the 'Street, City' format"
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        
        [alert show];
        [alert release];
	}
	else
	{
        //use these to calculate extent of results
        double xmin = DBL_MAX;
        double ymin = DBL_MAX;
        double xmax = -DBL_MAX;
        double ymax = -DBL_MAX;
		
		//create the callout template, used when the user displays the callout
		self.calloutTemplate = [[[AGSCalloutTemplate alloc]init] autorelease];

        //loop through all candidates/results and add to graphics layer
        // *KS: remove for loop, only interested in highest scored result (0)
		//for (int i=0; i<[candidates count]; i++) {            
			//AGSAddressCandidate *addressCandidate = (AGSAddressCandidate *)[candidates objectAtIndex:i];
        AGSAddressCandidate *addressCandidate = (AGSAddressCandidate *)[candidates objectAtIndex:0];

            //get the location from the candidate
            AGSPoint *pt = addressCandidate.location;
            
            //accumulate the min/max
            if (pt.x  < xmin)
                xmin = pt.x;
            
            if (pt.x > xmax)
                xmax = pt.x;
            
            if (pt.y < ymin)
                ymin = pt.y;
            
            if (pt.y > ymax)
                ymax = pt.y;

			//create a marker symbol to use in our graphic
        // *KS: use own image, pushpin offset was too cumbersome
            //AGSPictureMarkerSymbol *marker = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"BluePushpin.png"];
        AGSPictureMarkerSymbol *marker = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"blue_dot.png"];
            //marker.xoffset = 9;
            //marker.yoffset = -16;
            //marker.hotspot = CGPointMake(-9, -11);
                        
            //set the text and detail text based on 'Name' and 'Descr' fields in the attributes
        // *KS: swapped out defaults for the matched address result
            //self.calloutTemplate.titleTemplate = @"${Name}";
            //self.calloutTemplate.detailTemplate = @"${Descr}";
			self.calloutTemplate.titleTemplate = @"${Match_addr}";
            
            //create the graphic
			AGSGraphic *graphic = [[AGSGraphic alloc] initWithGeometry: pt
																symbol:marker 
															attributes:[addressCandidate.attributes mutableCopy]
														  infoTemplateDelegate:self.calloutTemplate];
            
            
            //add the graphic to the graphics layer
			[self.graphicsLayer addGraphic:graphic];
			            
            if ([candidates count] == 1)
            {
                //we have one result, center at that point
                //[self.mapView centerAtPoint:pt animated:NO];
                // *KS: help from Thang at Esri
                [self.mapView zoomToScale:50000 withCenterPoint:(AGSPoint *)graphic.geometry animated:YES];
               
				// set the width of the callout
				self.mapView.callout.width = 250;
                
                //show the callout
                [self.mapView showCalloutAtPoint:(AGSPoint *)graphic.geometry forGraphic:graphic animated:YES];
                
            }
			
			//release the graphic
			[graphic release];
        
		// *KS: from removed for loop
        //}
        
        //if we have more than one result, zoom to the extent of all results
        int nCount = [candidates count];
        if (nCount > 1)
        {            
            //AGSMutableEnvelope *extent = [AGSMutableEnvelope envelopeWithXmin:xmin ymin:ymin xmax:xmax ymax:ymax spatialReference:self.mapView.spatialReference];
            //[extent expandByFactor:1.5];
			//[self.mapView zoomToEnvelope:extent animated:YES];
            // *KS: help from Thang at Esri
            [self.mapView zoomToScale:50000 withCenterPoint:(AGSPoint *)graphic.geometry animated:YES];
        }
	}
    
    //since we've added graphics, make sure to redraw
    [self.graphicsLayer dataChanged];
  
}

- (void)locator:(AGSLocator *)locator operation:(NSOperation *)op didFailLocationsForAddress:(NSError *)error
{
    //The location operation failed, display the error
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Locator Failed"
                                                    message:[NSString stringWithFormat:@"Error: %@", error.description]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"                                          
                                          otherButtonTitles:nil];

    [alert show];
    [alert release];
}

#pragma mark _
#pragma mark UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	
	//hide the callout
	self.mapView.callout.hidden = YES;
	
    // *KS: stop gps before address search
    if (gpsCurrentStatus == YES) {
        gpsCurrentStatus = NO;
        [gpsButton setImage:[UIImage imageNamed:@"mylocation.png"] forState:UIControlStateNormal];
        [self.mapView.gps stop];
    }
    
    //First, hide the keyboard, then starGeocoding
    [searchBar resignFirstResponder];
    [self startGeocoding];
}


- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    //hide the keyboard
    [searchBar resignFirstResponder];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

- (void)dealloc {
    [super dealloc];
    
    self.mapView = nil;
    self.searchBar = nil;
    self.graphicsLayer = nil;
	self.locator = nil;
	self.calloutTemplate = nil;
    // *KS: add dealloc for my stuff
    self.dynamicLayer = nil;
    self.dynamicLayerView = nil;
    //self.gpsButton = nil;
    //self.infoViewController = nil;
}

// *KS: for autoPanMode
#pragma mark - Action methods

- (IBAction)autoPanModeChanged:(id)sender {
    //Start the map's gps if it isn't enabled already
    if(!self.mapView.gps.enabled)
        [self.mapView.gps start];
    
    //Listen to KVO notifications for map scale property
    [self.mapView addObserver:self
                   forKeyPath:@"mapScale"
                      options:(NSKeyValueObservingOptionNew)
                      context:NULL];
}

@end