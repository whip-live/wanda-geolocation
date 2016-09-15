//
//  GeolocationOpenHelperV1.m
//  CDVBackgroundGeolocation
//
//  Created by Marian Hello on 27/06/16.
//  Copyright © 2016 mauron85. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GeolocationOpenHelperV1.h"
#import "LocationContract.h"
#import "SQLiteHelper.h"

@implementation GeolocationOpenHelperV1

static NSString *const kDatabaseName = @"cordova_bg_geolocation.db";
static NSInteger const kDatabaseVersion = 1;

- (instancetype)init
{
    self = [super init:kDatabaseName version:kDatabaseVersion];
    return self;
}

- (void) drop:(NSString*)table inDatabase:(FMDatabase*)database
{
    NSString *sql = [NSString stringWithFormat: @"DROP TABLE IF EXISTS %@", table];
    if (![database executeStatements:sql]) {
        NSLog(@"%@ failed code: %d: message: %@", sql, [database lastErrorCode], [database lastErrorMessage]);
    }
}

- (void) onCreate:(FMDatabaseQueue*)queue
{
    [queue inDatabase:^(FMDatabase *database) {
        // because of some legacy code we have to drop table
        [self drop:@LC_TABLE_NAME inDatabase:database];
        
        NSArray *columns = @[
            @{ @"name": @LC_COLUMN_NAME_ID, @"type": [SQLPrimaryKeyAutoIncColumnType sqlColumnWithType: kInteger]},
            @{ @"name": @LC_COLUMN_NAME_TIME, @"type": [SQLColumnType sqlColumnWithType: kReal]},
            @{ @"name": @LC_COLUMN_NAME_ACCURACY, @"type": [SQLColumnType sqlColumnWithType: kReal]},
            @{ @"name": @LC_COLUMN_NAME_SPEED, @"type": [SQLColumnType sqlColumnWithType: kReal]},
            @{ @"name": @LC_COLUMN_NAME_BEARING, @"type": [SQLColumnType sqlColumnWithType: kReal]},
            @{ @"name": @LC_COLUMN_NAME_ALTITUDE, @"type": [SQLColumnType sqlColumnWithType: kReal]},
            @{ @"name": @LC_COLUMN_NAME_LATITUDE, @"type": [SQLColumnType sqlColumnWithType: kReal]},
            @{ @"name": @LC_COLUMN_NAME_LONGITUDE, @"type": [SQLColumnType sqlColumnWithType: kReal]},
            @{ @"name": @LC_COLUMN_NAME_PROVIDER, @"type": [SQLColumnType sqlColumnWithType: kText]},
            @{ @"name": @LC_COLUMN_NAME_LOCATION_PROVIDER, @"type": [SQLColumnType sqlColumnWithType: kText]},
            @{ @"name": @LC_COLUMN_NAME_VALID, @"type": [SQLColumnType sqlColumnWithType: kInteger]}
        ];
        
        NSString *tableSql = [SQLiteHelper createTableSqlStatement:@LC_TABLE_NAME columns:columns];

        NSString *sql = [@[
            tableSql,
            @"CREATE INDEX time_idx ON " @LC_TABLE_NAME @" (" @LC_COLUMN_NAME_TIME @")"
        ] componentsJoinedByString:@";"];
        if (![database executeStatements:sql]) {
            NSLog(@"%@ failed code: %d: message: %@", sql, [database lastErrorCode], [database lastErrorMessage]);
        }
    }];
}

- (void) onDowngrade:(FMDatabaseQueue*)queue fromVersion:(NSInteger)oldVersion toVersion:(NSInteger)newVersion
{
    // no upgrade policy yet
}

- (void) onUpgrade:(FMDatabaseQueue*)queue fromVersion:(NSInteger)oldVersion toVersion:(NSInteger)newVersion
{
    // no downgrade policy yet
}

@end