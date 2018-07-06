//
//  TouchBar.h
//  TouchBarTest
//
//  Created by Alexsander Akers on 2/13/17.
//  Copyright © 2017 Alexsander Akers. All rights reserved.
//

#import <AppKit/AppKit.h>

//extern void DFRElementSetControlStripPresenceForIdentifier(NSString *, BOOL);
//extern void DFRSystemModalShowsCloseBoxWhenFrontMost(BOOL);

extern void DFRElementSetControlStripPresenceForIdentifier(NSTouchBarItemIdentifier, BOOL);
extern void DFRSystemModalShowsCloseBoxWhenFrontMost(BOOL);


@interface NSTouchBarItem ()

//+ (void)addSystemTrayItem:(NSTouchBarItem *)item;

+ (void)addSystemTrayItem:(NSTouchBarItem *)item;
+ (void)removeSystemTrayItem:(NSTouchBarItem *)item;

@end

@interface NSTouchBar ()

//+ (void)presentSystemModalFunctionBar:(NSTouchBar *)touchBar systemTrayItemIdentifier:(NSString *)identifier;

+ (void)presentSystemModalTouchBar:(NSTouchBar *)touchBar placement:(long long)placement systemTrayItemIdentifier:(NSTouchBarItemIdentifier)identifier;
+ (void)presentSystemModalTouchBar:(NSTouchBar *)touchBar systemTrayItemIdentifier:(NSTouchBarItemIdentifier)identifier;
+ (void)dismissSystemModalTouchBar:(NSTouchBar *)touchBar;
+ (void)minimizeSystemModalTouchBar:(NSTouchBar *)touchBar;

@end
