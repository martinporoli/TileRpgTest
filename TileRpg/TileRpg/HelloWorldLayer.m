//
//  HelloWorldLayer.m
//  TileRpg
//
//  Created by T2 on 7/4/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer
{
    CCTMXTiledMap * tileMap;
    CCTMXLayer * background;
    CCTMXLayer * foreground;
    CCTMXLayer * meta;
    CCSprite *player;
    int playerWalk;
}

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
		
        tileMap = [CCTMXTiledMap tiledMapWithTMXFile:@"World1.tmx"];
        background = [tileMap layerNamed:@"background"];
        foreground = [tileMap layerNamed:@"foreground"];
        meta = [tileMap layerNamed:@"Meta"];
        player = [CCSprite spriteWithFile:@"gubbe.png"];
        meta.visible=NO;
        
        CCTMXObjectGroup *objects = [tileMap objectGroupNamed:@"Objects"];
        NSAssert(objects != nil, @"'Objects' object group not found");
        NSMutableDictionary *spawnPoint = [objects objectNamed:@"SpawnPoint"];        
        NSAssert(spawnPoint != nil, @"SpawnPoint object not found");
        int x = [[spawnPoint valueForKey:@"x"] intValue];
        int y = [[spawnPoint valueForKey:@"y"] intValue];
        
        player.position = ccp(x, y);
        [self addChild:player]; 
        
        [self setViewpointCenter:player.position];
        [self addChild:tileMap z:-1];
        self.isTouchEnabled = YES;
    }
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

- (CGPoint)tileCoordForPosition:(CGPoint)position {
    int x = position.x / tileMap.tileSize.width;
    int y = ((tileMap.mapSize.height * tileMap.tileSize.height) - position.y) / tileMap.tileSize.height;
    return ccp(x, y);
}

-(void)setViewpointCenter:(CGPoint) position {
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    int x = MAX(position.x, winSize.width / 2);
    int y = MAX(position.y, winSize.height / 2);
    x = MIN(x, (tileMap.mapSize.width * tileMap.tileSize.width) 
            - winSize.width / 2);
    y = MIN(y, (tileMap.mapSize.height * tileMap.tileSize.height) 
            - winSize.height/2);
    CGPoint actualPosition = ccp(x, y);
    
    CGPoint centerOfView = ccp(winSize.width/2, winSize.height/2);
    CGPoint viewPoint = ccpSub(centerOfView, actualPosition);
    self.position = viewPoint;
    
}

-(void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self 
                                                     priority:0 swallowsTouches:YES];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	return YES;
}

-(void)setPlayerPosition:(CGPoint)position {
	CGPoint tileCoord = [self tileCoordForPosition:position];
    int tileGid = [meta tileGIDAt:tileCoord];
    if (tileGid) {
        NSDictionary *properties = [tileMap propertiesForGID:tileGid];
        if (properties) {
            NSString *collision = [properties valueForKey:@"Collidable"];
            if (collision && [collision compare:@"True"] == NSOrderedSame) {
                return;
            }
        }
    }
    player.position = position;
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    
    CGPoint touchLocation = [touch locationInView: [touch view]];		
    touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
    touchLocation = [self convertToNodeSpace:touchLocation];
    
    CGPoint playerPos = player.position;
    CGPoint diff = ccpSub(touchLocation, playerPos);
    if (abs(diff.x) > abs(diff.y)) {
        if (diff.x > 0) {
            if(playerWalk==0)
            {
                playerPos.x += tileMap.tileSize.width;
                [player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"gubbeSidan.png"]];
                playerWalk++;
            }
            else if(playerWalk==1)
            {
                playerPos.x += tileMap.tileSize.width;
                [player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"gubbeSidan2.png"]];
                playerWalk=0;
            }
        } else {
            if(playerWalk==0)
            {
                playerPos.x -= tileMap.tileSize.width;
                [player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"gubbeSidanLeft.png"]];
                playerWalk++;
            }
            else if(playerWalk==1)
            {
                playerPos.x -= tileMap.tileSize.width;
                [player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"gubbeSidanLeft2.png"]];
                playerWalk=0;
            }
        }    
    } else {
        if (diff.y > 0) {
            if(playerWalk==0)
            {
                playerPos.y += tileMap.tileSize.height;
                [player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"gubbeBak1.png"]];
                playerWalk++;
            }
            else if(playerWalk==1)
            {
                playerPos.y += tileMap.tileSize.height;
                [player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"gubbeBak2.png"]];
                playerWalk=0;
            }
        } else {
            if(playerWalk==0)
            {
                playerPos.y -= tileMap.tileSize.height;
                [player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"gubbe1.png"]];
                playerWalk++;
            }
            else if(playerWalk==1)
            {
                playerPos.y -= tileMap.tileSize.height;
                [player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"gubbe2.png"]];
                playerWalk=0;
            }
        }
    }
    
    if (playerPos.x <= (tileMap.mapSize.width * tileMap.tileSize.width) &&
        playerPos.y <= (tileMap.mapSize.height * tileMap.tileSize.height) &&
        playerPos.y >= 0 &&
        playerPos.x >= 0 ) 
    {
        [self setPlayerPosition:playerPos];
    }
    
    [self setViewpointCenter:player.position];
    
}


#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}
@end
