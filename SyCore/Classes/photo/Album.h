//
//  Album.h
//  SunnyCore
//
//  Created by 肖志强 on 2020/11/3.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface Album : NSObject

@property(nonatomic, copy)NSString *name;

@property(nonatomic, assign)NSInteger count;

@property(nonatomic, strong)UIImage *thumb;

@property(nonatomic, strong)id collection;
@end

NS_ASSUME_NONNULL_END
