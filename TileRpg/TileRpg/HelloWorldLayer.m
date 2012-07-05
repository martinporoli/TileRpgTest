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
@implementation StatLayer
{
    CCLayer * layer;
    CCSprite * ruta;
    CCLabelTTF * statLabel;
    CCLabelTTF * Int;
    CCLabelTTF * Str;
    CCLabelTTF * Cha;
    CCLabelTTF * Money;
}
-(id) init
{
    if (self = [super init])
    {
        
        ruta=[CCSprite spriteWithFile:@"statRuta.png"];
        statLabel=[CCLabelTTF labelWithString:@"" dimensions:CGSizeMake(300, 300) hAlignment:CCTextAlignmentLeft lineBreakMode:CCLineBreakModeMiddleTruncation fontName:@"Verdana-Bold" fontSize:25];
        statLabel.color=ccc3(0,0,0);
        [self addChild:ruta];
        [self addChild:statLabel];
        
        CGSize size = [[CCDirector sharedDirector] winSize];
        [ruta setScaleX: size.width/1000];
        [ruta setScaleY: size.height/1000];
        [statLabel setScaleX: size.width/1000];
        [statLabel setScaleY: size.height/1000];
        
    }
    return self;
}
-(void)showRuta:(CGPoint)point:(int)newMoney:(int)newInt:(int)newStr:(int)newCha
{
    NSString * statString = [NSString stringWithFormat:@"Money:\t%i\nIntelligence:\t%i\nStrength:\t%i\nCharm:\t%i",newMoney,newInt,newStr,newCha];
    [statLabel setString:statString];
    ruta.position=point;
    statLabel.position=point;
}
@end
// HelloWorldLayer implementation
@implementation HelloWorldLayer
{
    CCTMXTiledMap * tileMap;
    CCTMXLayer * background;
    CCTMXLayer * foreground;
    CCTMXLayer * meta;
    CCSprite *player;
    int playerWalk,jumpAble,chestMoney;
    int money,Int,Str,Cha;
    StatLayer * stats;
    CGPoint viewPoint;
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
        money=0;
        Int=0;
        Str=0;
        Cha=0;
        
        stats = [StatLayer node];
        [self addChild:stats];
        tileMap = [CCTMXTiledMap tiledMapWithTMXFile:@"World1.tmx"];
        background = [tileMap layerNamed:@"background"];
        foreground = [tileMap layerNamed:@"foreground"];
        meta = [tileMap layerNamed:@"Meta"];
        meta.visible=NO;
        [self addChild:tileMap z:-1];
        player = [CCSprite spriteWithFile:@"gubbe.png"];
        
        CCTMXObjectGroup *objects = [tileMap objectGroupNamed:@"Objects"];
        NSAssert(objects != nil, @"'Objects' object group not found");
        NSMutableDictionary *spawnPoint = [objects objectNamed:@"SpawnPoint"];        
        NSAssert(spawnPoint != nil, @"SpawnPoint object not found");
        int x = [[spawnPoint valueForKey:@"x"] intValue];
        int y = [[spawnPoint valueForKey:@"y"] intValue];
        
        player.position = ccp(x, y);
        [self addChild:player]; 
        
        [self setViewpointCenter:player.position];
        self.isTouchEnabled = YES;
    }
	return self;
}


-(void)loadWorld:(NSString*)world:spawn
{
    tileMap = [CCTMXTiledMap tiledMapWithTMXFile:world];
    background = [tileMap layerNamed:@"background"];
    foreground = [tileMap layerNamed:@"foreground"];
    meta = [tileMap layerNamed:@"Meta"];
    meta.visible=NO;
    [self addChild:tileMap z:-1];

    CCTMXObjectGroup *objects = [tileMap objectGroupNamed:@"Objects"];
    NSAssert(objects != nil, @"'Objects' object group not found");
    NSMutableDictionary *spawnPoint = [objects objectNamed:spawn];        
    NSAssert(spawnPoint != nil, @"SpawnPoint object not found");
    int x = [[spawnPoint valueForKey:@"x"] intValue];
    int y = [[spawnPoint valueForKey:@"y"] intValue];
    
    player.position = ccp(x, y);
}

-(void)unloadWorld
{
    [self removeChild:tileMap cleanup:YES];
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
    viewPoint = ccpSub(centerOfView, actualPosition);
    self.position = viewPoint;
    [stats showRuta:ccp(x+winSize.width/3,y+winSize.height/3):money:Int:Str:Cha];
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
            NSString *home = [properties valueForKey:@"Home"];
            if (home && [home compare:@"True"] == NSOrderedSame) {
                [self unloadWorld];
                [self loadWorld:@"home.tmx":@"SpawnPoint"];
                return;
            }
            NSString *coin = [properties valueForKey:@"Coin"];
            if (coin && [coin compare:@"True"] == NSOrderedSame) {
                if(chestMoney<5)
                {
                    money+=100;
                    chestMoney++;
                }
                else {
                    return;
                }
            }
            NSString *collision = [properties valueForKey:@"Collidable"];
            if (collision && [collision compare:@"True"] == NSOrderedSame) {
                return;
            }
            NSString *jump = [properties valueForKey:@"jump"];
            if (jump && [jump compare:@"True"] == NSOrderedSame) {
                if(jumpAble==0)
                {
                    return;
                }
                else{
                    
                }
            }
            
            
            NSString *world2 = [properties valueForKey:@"NewWorld"];
            if (world2 && [world2 compare:@"True"] == NSOrderedSame) {
                [self unloadWorld];
                [self loadWorld:@"World2.tmx":@"SpawnPoint2"];
                return;
            }
            NSString *world1 = [properties valueForKey:@"World1"];
            if (world1 && [world1 compare:@"True"] == NSOrderedSame) {
                [self unloadWorld];
                [self loadWorld:@"World1.tmx":@"SpawnPoint2"];
                return;
            }
            NSString *outhome = [properties valueForKey:@"OutHome"];
            if (outhome && [outhome compare:@"True"] == NSOrderedSame) {
                [self unloadWorld];
                [self loadWorld:@"World2.tmx":@"SpawnPointHome"];
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
            jumpAble=0;
            playerPos.x += tileMap.tileSize.width;
            if(playerWalk==0)
            {
                [player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"gubbeSidan.png"]];
                playerWalk++;
            }
            else if(playerWalk==1)
            {
                [player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"gubbeSidan2.png"]];
                playerWalk=0;
            }
        } else {
            jumpAble=0;
            playerPos.x -= tileMap.tileSize.width;
            if(playerWalk==0)
            {
                [player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"gubbeSidanLeft.png"]];
                playerWalk++;
            }
            else if(playerWalk==1)
            {
                [player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"gubbeSidanLeft2.png"]];
                playerWalk=0;
            }
        }    
    } else {
        if (diff.y > 0) {
            jumpAble=0;
            playerPos.y += tileMap.tileSize.height;
            if(playerWalk==0)
            {
                [player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"gubbeBak1.png"]];
                playerWalk++;
            }
            else if(playerWalk==1)
            {
                [player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"gubbeBak2.png"]];
                playerWalk=0;
            }
        } else {
            jumpAble=1;
            playerPos.y -= tileMap.tileSize.height;
            if(playerWalk==0)
            {
                [player setTexture:[[CCTextureCache sharedTextureCache] addImage:@"gubbe1.png"]];
                playerWalk++;
            }
            else if(playerWalk==1)
            {
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
