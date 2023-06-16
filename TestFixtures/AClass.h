#import <Foundation/Foundation.h>

@interface AClass
@property (assign) int count;
@property (assign) NSString* name;
-(instancetype)init;
-(instancetype)initWithCount: (int32_t)integer name: (const char *)name;
-(void)printCount;
-(int)execute: (id)block;
+(AClass*)shared;
@end

//void* aclass_create(int);
AClass *AClass_init();
void *AClass_initWithCountName(int32_t count, const char *name);
void* AClass_printCount(void*);
int getProp_int(void*, void*);
int AClass_execute(void *instance, int (*completion)(int));
NSString *AClass_name(void *);
int AClass_count(void *);
