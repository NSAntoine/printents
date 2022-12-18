//
//  main.m
//  printents
//
//  Created by Serena on 18/12/2022
//
// clang main.m -F/System/Library/PrivateFrameworks -framework AppSandbox -framework Foundation -fobjc-arc

@import Foundation;
#include <getopt.h>
#include "Entitlements.h"

#if !__has_feature(objc_arc)
#error ARC is needed, please build with -fobjc-arc
#endif

typedef NS_ENUM(NSUInteger, EntitlementsOutputFormatType) {
    EntitlementsOutputFormatTypeJSON,
    EntitlementsOutputFormatTypeXML,
    EntitlementsOutputFormatTypeNSDictionary,
};

void print_usage(char **argv) {
    printf("usage: %s <app bundle or executable path> [OPTIONS]\n", argv[0]);
    printf("Options: \n");
    
    printf("\t-f, --format <output-format>, where output-format is one of:\n");
    printf("\t\t json\n");
    printf("\t\t xml\n");
    printf("\t\t nsdictionary\n");
    
    printf("examples:\n");
    printf("\t\t %s /Applications/Antoine.app\n", argv[0]);
    printf("\t\t %s --format json /Applications/Xcode.app\n", argv[0]);
}

#define CHECK_ERROR(condition, message, ...) \
    if (condition) { \
        fprintf(stderr, message, ##__VA_ARGS__); \
        return -1; \
    }

int printFromSerializedData(NSDictionary *entsDictionary, EntitlementsOutputFormatType type) {
    NSError *error;
    NSData *data;
    
    switch (type) {
        case EntitlementsOutputFormatTypeJSON:
            data = [NSJSONSerialization dataWithJSONObject:entsDictionary options: NSJSONWritingPrettyPrinted | NSJSONWritingSortedKeys | NSJSONWritingWithoutEscapingSlashes error:&error];
            break;
        case EntitlementsOutputFormatTypeXML:
            data = [NSPropertyListSerialization dataWithPropertyList:entsDictionary format:NSPropertyListXMLFormat_v1_0 options:0 error:&error];
            break;
        case EntitlementsOutputFormatTypeNSDictionary: break; // never supposed to be here anyways
    }
    
    const char *errorCString = error.localizedDescription.UTF8String;
    CHECK_ERROR(error || !data, "Error while converting dictionary to JSON: %s\n", errorCString ? errorCString : "Unknown Error")
    
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    printf("%s\n", string.UTF8String);
    return 0;
}

int main(int argc, char **argv) {
    if (argc < 2) {
        print_usage(argv);
        return -1;
    }
    
    EntitlementsOutputFormatType outputFormat = EntitlementsOutputFormatTypeXML;
    int opt;
    
    while (true) {
        static struct option long_options[] = {
            {"format",    required_argument, 0, 'f'},
            {0, 0, 0, 0}
        };
        
        opt = getopt_long (argc, argv, "f:", long_options, NULL);
        
        if (opt == -1) break;
        
        switch (opt) {
            case 'f': {
                if (!strcmp(optarg, "json")) outputFormat = EntitlementsOutputFormatTypeJSON;
                else if (!strcmp(optarg, "xml")) outputFormat = EntitlementsOutputFormatTypeXML;
                else if (!strcmp(optarg, "nsdictionary")) outputFormat = EntitlementsOutputFormatTypeNSDictionary;
                break;
            }
            default:
                printf("unknown flag / option\n");
                return -1;
        }
    }
    
    if (!(optind < argc)) {
        printf("Error: didn't specify path to print entitlements of\n");
        print_usage(argv);
        return -1;
    }
    
    NSURL *itemURL = [NSURL fileURLWithPath: @(argv[optind++])];
    NSError *error;
    
    AppSandboxEntitlements *ents = [AppSandboxEntitlements entitlementsForCodeAtURL:itemURL error:&error];
    CHECK_ERROR(error, "Error while fetching entitlements: %s\n", error.localizedDescription.UTF8String)
    NSDictionary *entsDictionary = ents.allEntitlements;
    
    if (outputFormat == EntitlementsOutputFormatTypeNSDictionary)
        printf("%s\n", entsDictionary.description.UTF8String);
    else
        printFromSerializedData(entsDictionary, outputFormat);
    
    return 0;
}
