//
//  GeolocationDBUpgrades.m
//  CDVBackgroundGeolocation
//
//  Created by Marian Hello on 17/09/2016.
//  Copyright © 2016 mauron85. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SQLiteHelper.h"
#import "LocationContract.h"
#import "GeolocationOpenHelper.h"
#import "GeolocationOpenHelperV1.h"

@interface GeolocationDBUpgrades : XCTestCase

@end

@implementation GeolocationDBUpgrades

- (void)setUp {
    [super setUp];
    GeolocationOpenHelper *helper = [[GeolocationOpenHelper alloc] init];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dbPath = [helper getDatabasePath];
    [fileManager removeItemAtPath:dbPath error:nil];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDbUpgradeColumnsFromVersionOneToVersionTwo {
    SQLiteOpenHelper *helper;
    FMDatabaseQueue *queue;
    
    helper = [[GeolocationOpenHelperV1 alloc] init];
    queue = [helper getWritableDatabase];
    [helper close];
    
    helper = [[GeolocationOpenHelper alloc] init];
    queue = [helper getWritableDatabase];
    [queue inDatabase:^(FMDatabase *database) {
        XCTAssertTrue([database columnExists:@LC_COLUMN_NAME_ID inTableWithName:@LC_TABLE_NAME]);
        XCTAssertTrue([database columnExists:@LC_COLUMN_NAME_TIME inTableWithName:@LC_TABLE_NAME]);
        XCTAssertTrue([database columnExists:@LC_COLUMN_NAME_ACCURACY inTableWithName:@LC_TABLE_NAME]);
        XCTAssertTrue([database columnExists:@LC_COLUMN_NAME_SPEED inTableWithName:@LC_TABLE_NAME]);
        XCTAssertTrue([database columnExists:@LC_COLUMN_NAME_BEARING inTableWithName:@LC_TABLE_NAME]);
        XCTAssertTrue([database columnExists:@LC_COLUMN_NAME_ALTITUDE inTableWithName:@LC_TABLE_NAME]);
        XCTAssertTrue([database columnExists:@LC_COLUMN_NAME_LATITUDE inTableWithName:@LC_TABLE_NAME]);
        XCTAssertTrue([database columnExists:@LC_COLUMN_NAME_LONGITUDE inTableWithName:@LC_TABLE_NAME]);
        XCTAssertTrue([database columnExists:@LC_COLUMN_NAME_PROVIDER inTableWithName:@LC_TABLE_NAME]);
        XCTAssertTrue([database columnExists:@LC_COLUMN_NAME_LOCATION_PROVIDER inTableWithName:@LC_TABLE_NAME]);
        XCTAssertTrue([database columnExists:@LC_COLUMN_NAME_VALID inTableWithName:@LC_TABLE_NAME]);
        XCTAssertTrue([database columnExists:@LC_COLUMN_NAME_RECORDED_AT inTableWithName:@LC_TABLE_NAME]);
    }];
    
    [helper close];
}

- (void)testDbUpgradeFromVersionOneToVersion {
    SQLiteOpenHelper *helper;
    FMDatabaseQueue *queue;
    
    helper = [[GeolocationOpenHelperV1 alloc] init];
    queue = [helper getWritableDatabase];
    [queue inDatabase:^(FMDatabase *database) {
        NSString *sql = @"INSERT INTO " @LC_TABLE_NAME @" ("
        @LC_COLUMN_NAME_TIME
        @COMMA_SEP @LC_COLUMN_NAME_ACCURACY
        @COMMA_SEP @LC_COLUMN_NAME_SPEED
        @COMMA_SEP @LC_COLUMN_NAME_BEARING
        @COMMA_SEP @LC_COLUMN_NAME_ALTITUDE
        @COMMA_SEP @LC_COLUMN_NAME_LATITUDE
        @COMMA_SEP @LC_COLUMN_NAME_LONGITUDE
        @COMMA_SEP @LC_COLUMN_NAME_PROVIDER
        @COMMA_SEP @LC_COLUMN_NAME_LOCATION_PROVIDER
        @COMMA_SEP @LC_COLUMN_NAME_VALID
        @") VALUES (?,?,?,?,?,?,?,?,?)";

        [database executeUpdate:sql,
            [NSNumber numberWithInt:1234], //time
            [NSNumber numberWithInt:10],   //acy
            [NSNumber numberWithInt:8],    //speed
            [NSNumber numberWithInt:14],   //bear
            [NSNumber numberWithInt:120],  //alt
            [NSNumber numberWithInt:40],   //lat
            [NSNumber numberWithInt:56],   //long
            @"test",
            [NSNumber numberWithInt:2],    //location provider
            [NSNumber numberWithInt:1]     //valid
        ];
    }];
    [helper close];

    helper = [[GeolocationOpenHelper alloc] init];
    queue = [helper getWritableDatabase];

    [queue inDatabase:^(FMDatabase *database) {
        NSString *sql = @"SELECT "
        @LC_COLUMN_NAME_ID
        @COMMA_SEP @LC_COLUMN_NAME_TIME
        @COMMA_SEP @LC_COLUMN_NAME_ACCURACY
        @COMMA_SEP @LC_COLUMN_NAME_SPEED
        @COMMA_SEP @LC_COLUMN_NAME_BEARING
        @COMMA_SEP @LC_COLUMN_NAME_ALTITUDE
        @COMMA_SEP @LC_COLUMN_NAME_LATITUDE
        @COMMA_SEP @LC_COLUMN_NAME_LONGITUDE
        @COMMA_SEP @LC_COLUMN_NAME_PROVIDER
        @COMMA_SEP @LC_COLUMN_NAME_LOCATION_PROVIDER
        @COMMA_SEP @LC_COLUMN_NAME_VALID
        @COMMA_SEP @LC_COLUMN_NAME_RECORDED_AT
        @" FROM " @LC_TABLE_NAME @" ORDER BY " @LC_COLUMN_NAME_RECORDED_AT;
        
        FMResultSet *rs = [database executeQuery:sql];
        while([rs next]) {
            XCTAssertEqual([rs longForColumnIndex:0], 1);
            XCTAssertEqual([rs longForColumnIndex:1], 1234);
            XCTAssertEqual([rs longForColumnIndex:2], 10);
            XCTAssertEqual([rs longForColumnIndex:3], 8);
            XCTAssertEqual([rs longForColumnIndex:4], 14);
            XCTAssertEqual([rs longForColumnIndex:5], 120);
            XCTAssertEqual([rs longForColumnIndex:6], 40);
            XCTAssertEqual([rs longForColumnIndex:7], 56);
            XCTAssertEqualObjects([rs stringForColumnIndex:8], @"test");
            XCTAssertEqual([rs longForColumnIndex:9], 2);
            XCTAssertEqual([rs longForColumnIndex:10], 1);
            XCTAssertEqual([rs longForColumnIndex:11], 1234);
        }
        
        [rs close];
    }];
    
    
    [helper close];
}

@end
