//
//  main.m
//  read_ean
//
//  Created by Rick Mark on 2/16/24.
//

#import <Foundation/Foundation.h>
#import <IOKit/IOKitLib.h>
#import <IOKit/IOUserServer.h>
#include <IOKit/IOCFPlugIn.h>

const uint64_t kAppleEANGetIsFormatted = 0;
const uint64_t kAppleEANFormat = 1;
const uint64_t kAppleEANWriteEAN = 2;
const uint64_t kAppleEANGetEANSize = 3;
const uint64_t kAppleEANReadEAN = 4;
const uint64_t kAppleEANEraseEAN = 5;
const uint64_t kAppleEANSwapEAN = 6;
const uint64_t kAppleEANGetUpdateCount = 7;


const uint32_t aptkKey = 0x6170746b;  // APTicket

const uint32_t ifw1Key = 0x69667731;  // iBoot Firmware 1 (a combined image of all firmwares)
const uint32_t ifw2Key = 0x69667732;  // iBoot Firmware 2 (a combined image of all firmwares - backup)

const uint32_t trstKey = 0x74727374;  // FDR "Trust Object" or how FDR is validated from the server
const uint32_t fCfgKey = 0x66436667;  // fCfg - SysCfg in the cloud configuration
const uint32_t fdr1Key = 0x66647231;  //
const uint32_t fdr2Key = 0x66647232;  //
const uint32_t sealKey = 0x7365616c;

const uint32_t dCfgKey = 0x64436667;

const uint32_t appvKey = 0x61707076;

const uint32_t nefwKey = 0x6e656677;

const uint32_t rLASKey = 0x724c4153;
const uint32_t iLACKey = 0x694c4143;

const uint32_t ADCLKey = 0x4144434c;
const uint32_t PRSTKey = 0x50525354;

const uint32_t allKeys[] = {
    aptkKey,
    trstKey,
    dCfgKey,
    ifw1Key,
    ADCLKey,
    nefwKey,
    fdr1Key,
    fCfgKey,
    sealKey,
    appvKey,
    rLASKey,
    iLACKey,
    ifw2Key,
    fdr2Key,
    PRSTKey,
    NULL
};


int main(int argc, const char * argv[]) {
    mach_port_t masterPort;
    IOMainPort(MACH_PORT_NULL, &masterPort);

    CFMutableDictionaryRef matching = IOServiceMatching("AppleNVMeEAN");
    io_service_t eanService = IOServiceGetMatchingService(masterPort, matching);

    io_connect_t eanConnect;
    kern_return_t serviceOpen = IOServiceOpen(eanService, mach_task_self(), 0, &eanConnect);
    
    NSLog(@"Open Result: %d\n", serviceOpen);
    
    io_name_t deviceName;
    if (IORegistryEntryGetName(eanService, deviceName) != kIOReturnSuccess) {
       NSLog(@"IORegistryEntryGetName failed (IOPED)");
    }
    
    printf("Service Name: %s\n", deviceName);
    
    uint64_t isFormatted;
    uint32_t count = 1;


    kern_return_t callResult = IOConnectCallScalarMethod(eanConnect, kAppleEANGetIsFormatted, NULL, 0, &isFormatted, &count);
    
    printf("Call Result: %d\n", callResult);
    printf("Is Formatted: %lld\n", isFormatted);
    
    
    for (int i = 0; i < 15; i++) {
        uint64_t eanKey = allKeys[i];
        uint64_t dataSize = 0;
        
        
        callResult = IOConnectCallScalarMethod(eanConnect, kAppleEANGetEANSize, &eanKey, 8, &dataSize, &count);
        
        void* eanDataOut = malloc(dataSize);
        
        uint64_t readParams[] = { eanKey, (uint64_t)eanDataOut, dataSize };
        
        uint64_t readResult;
        
        callResult = IOConnectCallScalarMethod(eanConnect, kAppleEANReadEAN, readParams, 3, &readResult, &count);
        
        char* fileName = (char*)malloc(128);
        snprintf(fileName, 127, "ean.0x%04llx.bin", eanKey);
        
        FILE* saveFile = fopen(fileName, "w");
        fwrite(eanDataOut, dataSize, 1, saveFile);
        fclose(saveFile);
    }
    return 0;
}
    
