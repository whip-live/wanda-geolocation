//
//  GeolocationOpenHelperTests.m
//  CDVBackgroundGeolocation
//
//  Created by Marian Hello on 01/07/16.
//  Copyright © 2016 mauron85. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LocationContract.h"
#import "GeolocationOpenHelper.h"

@interface GeolocationOpenHelperTests : XCTestCase

@end

@implementation GeolocationOpenHelperTests

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

- (void)testIfLocationTableIsCreated {
    GeolocationOpenHelper *helper = [[GeolocationOpenHelper alloc] init];
    FMDatabaseQueue *queue = [helper getWritableDatabase];
    
    [queue inDatabase:^(FMDatabase *database) {
        NSString *sql = [NSString stringWithFormat: @"SELECT name FROM sqlite_master WHERE type='%@' AND name='table_name';", @LC_TABLE_NAME];
        FMResultSet *rs = [database executeQuery:sql];
        while([rs next]) {
            XCTAssertEqual([rs stringForColumnIndex:0], @LC_TABLE_NAME);
        }

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
        
        [rs close];
    }];
    
    [helper close];
}

- (void)testLocationTableSQLStatement {
    NSString *sql = [LocationContract createTableSQL];
    XCTAssertEqualObjects(sql, @"CREATE TABLE IF NOT EXISTS location ( id INTEGER PRIMARY KEY AUTOINCREMENT , time REAL , accuracy REAL , speed REAL , bearing REAL , altitude REAL , latitude REAL , longitude REAL , provider TEXT , service_provider TEXT , valid INTEGER , recorded_at INTEGER )");
}

@end
