//
//  main.m
//  read_ean
//
//  Created by Rick Mark on 2/18/24.
//

#import <Foundation/Foundation.h>
#import <IOKit/IOKitLib.h>
#import <string>


const uint64_t kAppleNVMeNamespaceRead = 0;
const uint64_t kAppleNVMeNamespaceWrite = 1;
const uint64_t kAppleNVMeNamespaceGetBlockSize = 2;
const uint64_t kAppleNVMeNamespaceGetBlockCount = 3;
const uint64_t kAppleNVMeNamespaceUnmap = 4;


int main(int argc, const char * argv[]) {
    mach_port_t masterPort;
    io_name_t serviceName;
    IOMainPort(MACH_PORT_NULL, &masterPort);

    CFMutableDictionaryRef matching = IOServiceMatching("AppleNVMeNamespaceDevice");
    io_iterator_t serviceIterator;
    io_service_t nvmeNsService;
    IOServiceGetMatchingServices(masterPort, matching, &serviceIterator);
    
    while ((nvmeNsService = IOIteratorNext(serviceIterator)) != 0) {
        IORegistryEntryGetName(nvmeNsService, serviceName);
        if (strcmp(argv[1], serviceName) == 0) {
            break;
        }
    }
    
    if (nvmeNsService != 0) {
        printf("Found Service: %s\n", serviceName);
    }
    else {
        printf("Unable to find match for %s\n", argv[1]);
        return -1;
    }

    io_connect_t nvmeNsConnect;
    kern_return_t serviceOpen = IOServiceOpen(nvmeNsService, mach_task_self(), 0, &nvmeNsConnect);
    
    NSLog(@"Open Result: %d\n", serviceOpen);
    
    uint64_t blockSize;
    uint64_t blockCount;
    
    uint32_t count;
    
    kern_return_t opResult;
    
    opResult = IOConnectCallScalarMethod(nvmeNsConnect, kAppleNVMeNamespaceGetBlockSize, NULL, 0, &blockSize, &count);
    if (opResult != kIOReturnSuccess) {
        printf("Unable to call GetBlockSize, %x\n", opResult);
    }
    opResult = IOConnectCallScalarMethod(nvmeNsConnect, kAppleNVMeNamespaceGetBlockCount, NULL, 0, &blockCount, &count);
    if (opResult != kIOReturnSuccess) {
        printf("Unable to call GetBlockCount, %x\n", opResult);
    }
    
    printf("Device has %lld blocks of %lld each...\n", blockCount, blockSize);
}

