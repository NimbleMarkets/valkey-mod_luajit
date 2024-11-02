-- valkeymodule-cdef.lua
-- Copyright (c) 2016-2024 Evan Wies
--
-- This file holds the ffi.cdef for the Valkey Module API.
-- Since the stanza is relatively large and mostly mirrors valkeymodule.h, it is 
-- in it's own file, extracted from:
--    https://github.com/valkey-io/valkey/blob/unstable/src/valkeymodule.h
--
-- Requiring this module returns the string itself

local valkeymodule_cdef = [[
typedef struct ValkeyModuleString ValkeyModuleString;
typedef struct ValkeyModuleKey ValkeyModuleKey;

typedef long long mstime_t;
typedef long long ustime_t;

/* StreamID type. */
typedef struct ValkeyModuleStreamID {
    uint64_t ms;
    uint64_t seq;
} ValkeyModuleStreamID;

typedef struct ValkeyModuleEvent {
    uint64_t id;      /* VALKEYMODULE_EVENT_... defines. */
    uint64_t dataver; /* Version of the structure we pass as 'data'. */
} ValkeyModuleEvent;

typedef void (*ValkeyModuleEventLoopFunc)(int fd, void *user_data, int mask);
typedef void (*ValkeyModuleEventLoopOneShotFunc)(void *user_data);

typedef void (*ValkeyModuleEventCallback)(struct ValkeyModuleCtx *ctx,
                                          ValkeyModuleEvent eid,
                                          uint64_t subevent,
                                          void *data);

/* Incomplete structures for compiler checks but opaque access. */
typedef struct ValkeyModuleCtx ValkeyModuleCtx;
typedef struct ValkeyModuleCommand ValkeyModuleCommand;
typedef struct ValkeyModuleCallReply ValkeyModuleCallReply;
typedef struct ValkeyModuleType ValkeyModuleType;
typedef struct ValkeyModuleBlockedClient ValkeyModuleBlockedClient;
typedef struct ValkeyModuleClusterInfo ValkeyModuleClusterInfo;
typedef struct ValkeyModuleDict ValkeyModuleDict;
typedef struct ValkeyModuleDictIter ValkeyModuleDictIter;
typedef struct ValkeyModuleCommandFilterCtx ValkeyModuleCommandFilterCtx;
typedef struct ValkeyModuleCommandFilter ValkeyModuleCommandFilter;
typedef struct ValkeyModuleServerInfoData ValkeyModuleServerInfoData;
typedef struct ValkeyModuleScanCursor ValkeyModuleScanCursor;
typedef struct ValkeyModuleUser ValkeyModuleUser;
typedef struct ValkeyModuleKeyOptCtx ValkeyModuleKeyOptCtx;
typedef struct ValkeyModuleRdbStream ValkeyModuleRdbStream;

typedef enum {
    VALKEYMODULE_ACL_LOG_AUTH = 0, /* Authentication failure */
    VALKEYMODULE_ACL_LOG_CMD,      /* Command authorization failure */
    VALKEYMODULE_ACL_LOG_KEY,      /* Key authorization failure */
    VALKEYMODULE_ACL_LOG_CHANNEL   /* Channel authorization failure */
} ValkeyModuleACLLogEntryReason;

/* Incomplete structures needed by both the core and modules. */
typedef struct ValkeyModuleIO ValkeyModuleIO;
typedef struct ValkeyModuleDigest ValkeyModuleDigest;
typedef struct ValkeyModuleInfoCtx ValkeyModuleInfoCtx;
typedef struct ValkeyModuleDefragCtx ValkeyModuleDefragCtx;

/* Function pointers needed by both the core and modules, these needs to be
 * exposed since you can't cast a function pointer to (void *). */
typedef void (*ValkeyModuleInfoFunc)(ValkeyModuleInfoCtx *ctx, int for_crash_report);
typedef void (*ValkeyModuleDefragFunc)(ValkeyModuleDefragCtx *ctx);
typedef void (*ValkeyModuleUserChangedFunc)(uint64_t client_id, void *privdata);

typedef int (*ValkeyModuleCmdFunc)(ValkeyModuleCtx *ctx, ValkeyModuleString **argv, int argc);
typedef void (*ValkeyModuleDisconnectFunc)(ValkeyModuleCtx *ctx, ValkeyModuleBlockedClient *bc);
typedef int (*ValkeyModuleNotificationFunc)(ValkeyModuleCtx *ctx, int type, const char *event, ValkeyModuleString *key);
typedef void (*ValkeyModulePostNotificationJobFunc)(ValkeyModuleCtx *ctx, void *pd);
typedef void *(*ValkeyModuleTypeLoadFunc)(ValkeyModuleIO *rdb, int encver);
typedef void (*ValkeyModuleTypeSaveFunc)(ValkeyModuleIO *rdb, void *value);
typedef int (*ValkeyModuleTypeAuxLoadFunc)(ValkeyModuleIO *rdb, int encver, int when);
typedef void (*ValkeyModuleTypeAuxSaveFunc)(ValkeyModuleIO *rdb, int when);
typedef void (*ValkeyModuleTypeRewriteFunc)(ValkeyModuleIO *aof, ValkeyModuleString *key, void *value);
typedef size_t (*ValkeyModuleTypeMemUsageFunc)(const void *value);
typedef size_t (*ValkeyModuleTypeMemUsageFunc2)(ValkeyModuleKeyOptCtx *ctx, const void *value, size_t sample_size);
typedef void (*ValkeyModuleTypeDigestFunc)(ValkeyModuleDigest *digest, void *value);
typedef void (*ValkeyModuleTypeFreeFunc)(void *value);
typedef size_t (*ValkeyModuleTypeFreeEffortFunc)(ValkeyModuleString *key, const void *value);
typedef size_t (*ValkeyModuleTypeFreeEffortFunc2)(ValkeyModuleKeyOptCtx *ctx, const void *value);
typedef void (*ValkeyModuleTypeUnlinkFunc)(ValkeyModuleString *key, const void *value);
typedef void (*ValkeyModuleTypeUnlinkFunc2)(ValkeyModuleKeyOptCtx *ctx, const void *value);
typedef void *(*ValkeyModuleTypeCopyFunc)(ValkeyModuleString *fromkey, ValkeyModuleString *tokey, const void *value);
typedef void *(*ValkeyModuleTypeCopyFunc2)(ValkeyModuleKeyOptCtx *ctx, const void *value);
typedef int (*ValkeyModuleTypeDefragFunc)(ValkeyModuleDefragCtx *ctx, ValkeyModuleString *key, void **value);
typedef void (*ValkeyModuleClusterMessageReceiver)(ValkeyModuleCtx *ctx,
                                                   const char *sender_id,
                                                   uint8_t type,
                                                   const unsigned char *payload,
                                                   uint32_t len);
typedef void (*ValkeyModuleTimerProc)(ValkeyModuleCtx *ctx, void *data);
typedef void (*ValkeyModuleCommandFilterFunc)(ValkeyModuleCommandFilterCtx *filter);
typedef void (*ValkeyModuleForkDoneHandler)(int exitcode, int bysignal, void *user_data);
typedef void (*ValkeyModuleScanCB)(ValkeyModuleCtx *ctx,
                                   ValkeyModuleString *keyname,
                                   ValkeyModuleKey *key,
                                   void *privdata);
typedef void (*ValkeyModuleScanKeyCB)(ValkeyModuleKey *key,
                                      ValkeyModuleString *field,
                                      ValkeyModuleString *value,
                                      void *privdata);
typedef ValkeyModuleString *(*ValkeyModuleConfigGetStringFunc)(const char *name, void *privdata);
typedef long long (*ValkeyModuleConfigGetNumericFunc)(const char *name, void *privdata);
typedef int (*ValkeyModuleConfigGetBoolFunc)(const char *name, void *privdata);
typedef int (*ValkeyModuleConfigGetEnumFunc)(const char *name, void *privdata);
typedef int (*ValkeyModuleConfigSetStringFunc)(const char *name,
                                               ValkeyModuleString *val,
                                               void *privdata,
                                               ValkeyModuleString **err);
typedef int (*ValkeyModuleConfigSetNumericFunc)(const char *name,
                                                long long val,
                                                void *privdata,
                                                ValkeyModuleString **err);
typedef int (*ValkeyModuleConfigSetBoolFunc)(const char *name, int val, void *privdata, ValkeyModuleString **err);
typedef int (*ValkeyModuleConfigSetEnumFunc)(const char *name, int val, void *privdata, ValkeyModuleString **err);
typedef int (*ValkeyModuleConfigApplyFunc)(ValkeyModuleCtx *ctx, void *privdata, ValkeyModuleString **err);
typedef void (*ValkeyModuleOnUnblocked)(ValkeyModuleCtx *ctx, ValkeyModuleCallReply *reply, void *private_data);
typedef int (*ValkeyModuleAuthCallback)(ValkeyModuleCtx *ctx,
                                        ValkeyModuleString *username,
                                        ValkeyModuleString *password,
                                        ValkeyModuleString **err);

typedef struct ValkeyModuleTypeMethods {
    uint64_t version;
    ValkeyModuleTypeLoadFunc rdb_load;
    ValkeyModuleTypeSaveFunc rdb_save;
    ValkeyModuleTypeRewriteFunc aof_rewrite;
    ValkeyModuleTypeMemUsageFunc mem_usage;
    ValkeyModuleTypeDigestFunc digest;
    ValkeyModuleTypeFreeFunc free;
    ValkeyModuleTypeAuxLoadFunc aux_load;
    ValkeyModuleTypeAuxSaveFunc aux_save;
    int aux_save_triggers;
    ValkeyModuleTypeFreeEffortFunc free_effort;
    ValkeyModuleTypeUnlinkFunc unlink;
    ValkeyModuleTypeCopyFunc copy;
    ValkeyModuleTypeDefragFunc defrag;
    ValkeyModuleTypeMemUsageFunc2 mem_usage2;
    ValkeyModuleTypeFreeEffortFunc2 free_effort2;
    ValkeyModuleTypeUnlinkFunc2 unlink2;
    ValkeyModuleTypeCopyFunc2 copy2;
    ValkeyModuleTypeAuxSaveFunc aux_save2;
} ValkeyModuleTypeMethods;

typedef uint64_t ValkeyModuleTimerID;

void *(*ValkeyModule_Alloc)(size_t bytes);
void *(*ValkeyModule_TryAlloc)(size_t bytes);
void *(*ValkeyModule_Realloc)(void *ptr, size_t bytes);
void *(*ValkeyModule_TryRealloc)(void *ptr, size_t bytes);
void (*ValkeyModule_Free)(void *ptr);
void *(*ValkeyModule_Calloc)(size_t nmemb, size_t size);
void *(*ValkeyModule_TryCalloc)(size_t nmemb, size_t size);
char *(*ValkeyModule_Strdup)(const char *str);
int (*ValkeyModule_GetApi)(const char *, void *);

int ValkeyModule_CreateCommand(ValkeyModuleCtx *ctx,
                                                   const char *name,
                                                   ValkeyModuleCmdFunc cmdfunc,
                                                   const char *strflags,
                                                   int firstkey,
                                                   int lastkey,
                                                   int keystep);
ValkeyModuleCommand *(*ValkeyModule_GetCommand)(ValkeyModuleCtx *ctx,
                                                                 const char *name);
int (*ValkeyModule_CreateSubcommand)(ValkeyModuleCommand *parent,
                                                      const char *name,
                                                      ValkeyModuleCmdFunc cmdfunc,
                                                      const char *strflags,
                                                      int firstkey,
                                                      int lastkey,
                                                      int keystep);
//TODO int (*ValkeyModule_SetCommandInfo)(ValkeyModuleCommand *command,
//                                                    const ValkeyModuleCommandInfo *info);
int (*ValkeyModule_SetCommandACLCategories)(ValkeyModuleCommand *command,
                                                             const char *ctgrsflags);
int (*ValkeyModule_AddACLCategory)(ValkeyModuleCtx *ctx, const char *name);
void (*ValkeyModule_SetModuleAttribs)(ValkeyModuleCtx *ctx, const char *name, int ver, int apiver)
   ;
int (*ValkeyModule_IsModuleNameBusy)(const char *name);
int (*ValkeyModule_WrongArity)(ValkeyModuleCtx *ctx);
int (*ValkeyModule_ReplyWithLongLong)(ValkeyModuleCtx *ctx, long long ll);
int (*ValkeyModule_GetSelectedDb)(ValkeyModuleCtx *ctx);
int (*ValkeyModule_SelectDb)(ValkeyModuleCtx *ctx, int newid);
int (*ValkeyModule_KeyExists)(ValkeyModuleCtx *ctx, ValkeyModuleString *keyname);
ValkeyModuleKey *(*ValkeyModule_OpenKey)(ValkeyModuleCtx *ctx,
                                                          ValkeyModuleString *keyname,
                                                          int mode);
int (*ValkeyModule_GetOpenKeyModesAll)(void);
void (*ValkeyModule_CloseKey)(ValkeyModuleKey *kp);
int (*ValkeyModule_KeyType)(ValkeyModuleKey *kp);
size_t (*ValkeyModule_ValueLength)(ValkeyModuleKey *kp);
int (*ValkeyModule_ListPush)(ValkeyModuleKey *kp,
                                              int where,
                                              ValkeyModuleString *ele);
ValkeyModuleString *(*ValkeyModule_ListPop)(ValkeyModuleKey *key, int where);
ValkeyModuleString *(*ValkeyModule_ListGet)(ValkeyModuleKey *key, long index);
int (*ValkeyModule_ListSet)(ValkeyModuleKey *key,
                                             long index,
                                             ValkeyModuleString *value);
int (*ValkeyModule_ListInsert)(ValkeyModuleKey *key,
                                                long index,
                                                ValkeyModuleString *value);
int (*ValkeyModule_ListDelete)(ValkeyModuleKey *key, long index);
ValkeyModuleCallReply *(*ValkeyModule_Call)(ValkeyModuleCtx *ctx,
                                                             const char *cmdname,
                                                             const char *fmt,
                                                             ...);
const char *(*ValkeyModule_CallReplyProto)(ValkeyModuleCallReply *reply, size_t *len);
void (*ValkeyModule_FreeCallReply)(ValkeyModuleCallReply *reply);
int (*ValkeyModule_CallReplyType)(ValkeyModuleCallReply *reply);
long long (*ValkeyModule_CallReplyInteger)(ValkeyModuleCallReply *reply);
double (*ValkeyModule_CallReplyDouble)(ValkeyModuleCallReply *reply);
int (*ValkeyModule_CallReplyBool)(ValkeyModuleCallReply *reply);
const char *(*ValkeyModule_CallReplyBigNumber)(ValkeyModuleCallReply *reply,
                                                                size_t *len);
const char *(*ValkeyModule_CallReplyVerbatim)(ValkeyModuleCallReply *reply,
                                                               size_t *len,
                                                               const char **format);
ValkeyModuleCallReply *(*ValkeyModule_CallReplySetElement)(ValkeyModuleCallReply *reply,
                                                                            size_t idx);
int (*ValkeyModule_CallReplyMapElement)(ValkeyModuleCallReply *reply,
                                                         size_t idx,
                                                         ValkeyModuleCallReply **key,
                                                         ValkeyModuleCallReply **val);
int (*ValkeyModule_CallReplyAttributeElement)(ValkeyModuleCallReply *reply,
                                                               size_t idx,
                                                               ValkeyModuleCallReply **key,
                                                               ValkeyModuleCallReply **val);
void (*ValkeyModule_CallReplyPromiseSetUnblockHandler)(ValkeyModuleCallReply *reply,
                                                                        ValkeyModuleOnUnblocked on_unblock,
                                                                        void *private_data);
int (*ValkeyModule_CallReplyPromiseAbort)(ValkeyModuleCallReply *reply,
                                                           void **private_data);
ValkeyModuleCallReply *(*ValkeyModule_CallReplyAttribute)(ValkeyModuleCallReply *reply)
   ;
size_t (*ValkeyModule_CallReplyLength)(ValkeyModuleCallReply *reply);
ValkeyModuleCallReply *(*ValkeyModule_CallReplyArrayElement)(ValkeyModuleCallReply *reply,
                                                                              size_t idx);
ValkeyModuleString *(*ValkeyModule_CreateString)(ValkeyModuleCtx *ctx,
                                                                  const char *ptr,
                                                                  size_t len);
ValkeyModuleString *(*ValkeyModule_CreateStringFromLongLong)(ValkeyModuleCtx *ctx,
                                                                              long long ll);
ValkeyModuleString *(*ValkeyModule_CreateStringFromULongLong)(ValkeyModuleCtx *ctx,
                                                                               unsigned long long ull);
ValkeyModuleString *(*ValkeyModule_CreateStringFromDouble)(ValkeyModuleCtx *ctx,
                                                                            double d);
ValkeyModuleString *(*ValkeyModule_CreateStringFromLongDouble)(ValkeyModuleCtx *ctx,
                                                                                long double ld,
                                                                                int humanfriendly);
ValkeyModuleString *(
    *ValkeyModule_CreateStringFromString)(ValkeyModuleCtx *ctx, const ValkeyModuleString *str);
ValkeyModuleString *(
    *ValkeyModule_CreateStringFromStreamID)(ValkeyModuleCtx *ctx, const ValkeyModuleStreamID *id);
void (*ValkeyModule_FreeString)(ValkeyModuleCtx *ctx, ValkeyModuleString *str);
const char *(*ValkeyModule_StringPtrLen)(const ValkeyModuleString *str, size_t *len);
int (*ValkeyModule_ReplyWithError)(ValkeyModuleCtx *ctx, const char *err);
int (*ValkeyModule_ReplyWithErrorFormat)(ValkeyModuleCtx *ctx, const char *fmt, ...);
int (*ValkeyModule_ReplyWithSimpleString)(ValkeyModuleCtx *ctx, const char *msg);
int (*ValkeyModule_ReplyWithArray)(ValkeyModuleCtx *ctx, long len);
int (*ValkeyModule_ReplyWithMap)(ValkeyModuleCtx *ctx, long len);
int (*ValkeyModule_ReplyWithSet)(ValkeyModuleCtx *ctx, long len);
int (*ValkeyModule_ReplyWithAttribute)(ValkeyModuleCtx *ctx, long len);
int (*ValkeyModule_ReplyWithNullArray)(ValkeyModuleCtx *ctx);
int (*ValkeyModule_ReplyWithEmptyArray)(ValkeyModuleCtx *ctx);
void (*ValkeyModule_ReplySetArrayLength)(ValkeyModuleCtx *ctx, long len);
void (*ValkeyModule_ReplySetMapLength)(ValkeyModuleCtx *ctx, long len);
void (*ValkeyModule_ReplySetSetLength)(ValkeyModuleCtx *ctx, long len);
void (*ValkeyModule_ReplySetAttributeLength)(ValkeyModuleCtx *ctx, long len);
void (*ValkeyModule_ReplySetPushLength)(ValkeyModuleCtx *ctx, long len);
int (*ValkeyModule_ReplyWithStringBuffer)(ValkeyModuleCtx *ctx,
                                                           const char *buf,
                                                           size_t len);
int (*ValkeyModule_ReplyWithCString)(ValkeyModuleCtx *ctx, const char *buf);
int (*ValkeyModule_ReplyWithString)(ValkeyModuleCtx *ctx, ValkeyModuleString *str);
int (*ValkeyModule_ReplyWithEmptyString)(ValkeyModuleCtx *ctx);
int (*ValkeyModule_ReplyWithVerbatimString)(ValkeyModuleCtx *ctx,
                                                             const char *buf,
                                                             size_t len);
int (*ValkeyModule_ReplyWithVerbatimStringType)(ValkeyModuleCtx *ctx,
                                                                 const char *buf,
                                                                 size_t len,
                                                                 const char *ext);
int (*ValkeyModule_ReplyWithNull)(ValkeyModuleCtx *ctx);
int (*ValkeyModule_ReplyWithBool)(ValkeyModuleCtx *ctx, int b);
int (*ValkeyModule_ReplyWithLongDouble)(ValkeyModuleCtx *ctx, long double d);
int (*ValkeyModule_ReplyWithDouble)(ValkeyModuleCtx *ctx, double d);
int (*ValkeyModule_ReplyWithBigNumber)(ValkeyModuleCtx *ctx,
                                                        const char *bignum,
                                                        size_t len);
int (*ValkeyModule_ReplyWithCallReply)(ValkeyModuleCtx *ctx,
                                                        ValkeyModuleCallReply *reply);
int (*ValkeyModule_StringToLongLong)(const ValkeyModuleString *str, long long *ll);
int (*ValkeyModule_StringToULongLong)(const ValkeyModuleString *str,
                                                       unsigned long long *ull);
int (*ValkeyModule_StringToDouble)(const ValkeyModuleString *str, double *d);
int (*ValkeyModule_StringToLongDouble)(const ValkeyModuleString *str,
                                                        long double *d);
int (*ValkeyModule_StringToStreamID)(const ValkeyModuleString *str,
                                                      ValkeyModuleStreamID *id);
void (*ValkeyModule_AutoMemory)(ValkeyModuleCtx *ctx);
int (*ValkeyModule_Replicate)(ValkeyModuleCtx *ctx, const char *cmdname, const char *fmt, ...)
   ;
int (*ValkeyModule_ReplicateVerbatim)(ValkeyModuleCtx *ctx);
const char *(*ValkeyModule_CallReplyStringPtr)(ValkeyModuleCallReply *reply,
                                                                size_t *len);
ValkeyModuleString *(*ValkeyModule_CreateStringFromCallReply)(ValkeyModuleCallReply *reply)
   ;
int (*ValkeyModule_DeleteKey)(ValkeyModuleKey *key);
int (*ValkeyModule_UnlinkKey)(ValkeyModuleKey *key);
int (*ValkeyModule_StringSet)(ValkeyModuleKey *key, ValkeyModuleString *str);
char *(*ValkeyModule_StringDMA)(ValkeyModuleKey *key, size_t *len, int mode);
int (*ValkeyModule_StringTruncate)(ValkeyModuleKey *key, size_t newlen);
mstime_t (*ValkeyModule_GetExpire)(ValkeyModuleKey *key);
int (*ValkeyModule_SetExpire)(ValkeyModuleKey *key, mstime_t expire);
mstime_t (*ValkeyModule_GetAbsExpire)(ValkeyModuleKey *key);
int (*ValkeyModule_SetAbsExpire)(ValkeyModuleKey *key, mstime_t expire);
void (*ValkeyModule_ResetDataset)(int restart_aof, int async);
unsigned long long (*ValkeyModule_DbSize)(ValkeyModuleCtx *ctx);
ValkeyModuleString *(*ValkeyModule_RandomKey)(ValkeyModuleCtx *ctx);
int (*ValkeyModule_ZsetAdd)(ValkeyModuleKey *key, double score, ValkeyModuleString *ele, int *flagsptr)
   ;
int (*ValkeyModule_ZsetIncrby)(ValkeyModuleKey *key,
                                                double score,
                                                ValkeyModuleString *ele,
                                                int *flagsptr,
                                                double *newscore);
int (*ValkeyModule_ZsetScore)(ValkeyModuleKey *key,
                                               ValkeyModuleString *ele,
                                               double *score);
int (*ValkeyModule_ZsetRem)(ValkeyModuleKey *key,
                                             ValkeyModuleString *ele,
                                             int *deleted);
void (*ValkeyModule_ZsetRangeStop)(ValkeyModuleKey *key);
int (*ValkeyModule_ZsetFirstInScoreRange)(ValkeyModuleKey *key,
                                                           double min,
                                                           double max,
                                                           int minex,
                                                           int maxex);
int (*ValkeyModule_ZsetLastInScoreRange)(ValkeyModuleKey *key,
                                                          double min,
                                                          double max,
                                                          int minex,
                                                          int maxex);
int (*ValkeyModule_ZsetFirstInLexRange)(ValkeyModuleKey *key,
                                                         ValkeyModuleString *min,
                                                         ValkeyModuleString *max);
int (*ValkeyModule_ZsetLastInLexRange)(ValkeyModuleKey *key,
                                                        ValkeyModuleString *min,
                                                        ValkeyModuleString *max);
ValkeyModuleString *(*ValkeyModule_ZsetRangeCurrentElement)(ValkeyModuleKey *key,
                                                                             double *score);
int (*ValkeyModule_ZsetRangeNext)(ValkeyModuleKey *key);
int (*ValkeyModule_ZsetRangePrev)(ValkeyModuleKey *key);
int (*ValkeyModule_ZsetRangeEndReached)(ValkeyModuleKey *key);
int (*ValkeyModule_HashSet)(ValkeyModuleKey *key, int flags, ...);
int (*ValkeyModule_HashGet)(ValkeyModuleKey *key, int flags, ...);
int (*ValkeyModule_StreamAdd)(ValkeyModuleKey *key,
                                               int flags,
                                               ValkeyModuleStreamID *id,
                                               ValkeyModuleString **argv,
                                               int64_t numfields);
int (*ValkeyModule_StreamDelete)(ValkeyModuleKey *key, ValkeyModuleStreamID *id);
int (*ValkeyModule_StreamIteratorStart)(ValkeyModuleKey *key,
                                                         int flags,
                                                         ValkeyModuleStreamID *startid,
                                                         ValkeyModuleStreamID *endid);
int (*ValkeyModule_StreamIteratorStop)(ValkeyModuleKey *key);
int (*ValkeyModule_StreamIteratorNextID)(ValkeyModuleKey *key,
                                                          ValkeyModuleStreamID *id,
                                                          long *numfields);
int (*ValkeyModule_StreamIteratorNextField)(ValkeyModuleKey *key,
                                                             ValkeyModuleString **field_ptr,
                                                             ValkeyModuleString **value_ptr);
int (*ValkeyModule_StreamIteratorDelete)(ValkeyModuleKey *key);
long long (*ValkeyModule_StreamTrimByLength)(ValkeyModuleKey *key,
                                                              int flags,
                                                              long long length);
long long (*ValkeyModule_StreamTrimByID)(ValkeyModuleKey *key,
                                                          int flags,
                                                          ValkeyModuleStreamID *id);
int (*ValkeyModule_IsKeysPositionRequest)(ValkeyModuleCtx *ctx);
void (*ValkeyModule_KeyAtPos)(ValkeyModuleCtx *ctx, int pos);
void (*ValkeyModule_KeyAtPosWithFlags)(ValkeyModuleCtx *ctx, int pos, int flags);
int (*ValkeyModule_IsChannelsPositionRequest)(ValkeyModuleCtx *ctx);
void (*ValkeyModule_ChannelAtPosWithFlags)(ValkeyModuleCtx *ctx, int pos, int flags);
unsigned long long (*ValkeyModule_GetClientId)(ValkeyModuleCtx *ctx);
ValkeyModuleString *(*ValkeyModule_GetClientUserNameById)(ValkeyModuleCtx *ctx,
                                                                           uint64_t id);
int (*ValkeyModule_GetClientInfoById)(void *ci, uint64_t id);
ValkeyModuleString *(*ValkeyModule_GetClientNameById)(ValkeyModuleCtx *ctx,
                                                                       uint64_t id);
int (*ValkeyModule_SetClientNameById)(uint64_t id, ValkeyModuleString *name);
int (*ValkeyModule_PublishMessage)(ValkeyModuleCtx *ctx,
                                                    ValkeyModuleString *channel,
                                                    ValkeyModuleString *message);
int (*ValkeyModule_PublishMessageShard)(ValkeyModuleCtx *ctx,
                                                         ValkeyModuleString *channel,
                                                         ValkeyModuleString *message);
int (*ValkeyModule_GetContextFlags)(ValkeyModuleCtx *ctx);
int (*ValkeyModule_AvoidReplicaTraffic)(void);
void *(*ValkeyModule_PoolAlloc)(ValkeyModuleCtx *ctx, size_t bytes);
ValkeyModuleType *(*ValkeyModule_CreateDataType)(ValkeyModuleCtx *ctx,
                                                                  const char *name,
                                                                  int encver,
                                                                  ValkeyModuleTypeMethods *typemethods);
int (*ValkeyModule_ModuleTypeSetValue)(ValkeyModuleKey *key,
                                                        ValkeyModuleType *mt,
                                                        void *value);
int (*ValkeyModule_ModuleTypeReplaceValue)(ValkeyModuleKey *key,
                                                            ValkeyModuleType *mt,
                                                            void *new_value,
                                                            void **old_value);
ValkeyModuleType *(*ValkeyModule_ModuleTypeGetType)(ValkeyModuleKey *key);
void *(*ValkeyModule_ModuleTypeGetValue)(ValkeyModuleKey *key);
int (*ValkeyModule_IsIOError)(ValkeyModuleIO *io);
void (*ValkeyModule_SetModuleOptions)(ValkeyModuleCtx *ctx, int options);
int (*ValkeyModule_SignalModifiedKey)(ValkeyModuleCtx *ctx,
                                                       ValkeyModuleString *keyname);
void (*ValkeyModule_SaveUnsigned)(ValkeyModuleIO *io, uint64_t value);
uint64_t (*ValkeyModule_LoadUnsigned)(ValkeyModuleIO *io);
void (*ValkeyModule_SaveSigned)(ValkeyModuleIO *io, int64_t value);
int64_t (*ValkeyModule_LoadSigned)(ValkeyModuleIO *io);
void (*ValkeyModule_EmitAOF)(ValkeyModuleIO *io, const char *cmdname, const char *fmt, ...)
   ;
void (*ValkeyModule_SaveString)(ValkeyModuleIO *io, ValkeyModuleString *s);
void (*ValkeyModule_SaveStringBuffer)(ValkeyModuleIO *io,
                                                       const char *str,
                                                       size_t len);
ValkeyModuleString *(*ValkeyModule_LoadString)(ValkeyModuleIO *io);
char *(*ValkeyModule_LoadStringBuffer)(ValkeyModuleIO *io, size_t *lenptr);
void (*ValkeyModule_SaveDouble)(ValkeyModuleIO *io, double value);
double (*ValkeyModule_LoadDouble)(ValkeyModuleIO *io);
void (*ValkeyModule_SaveFloat)(ValkeyModuleIO *io, float value);
float (*ValkeyModule_LoadFloat)(ValkeyModuleIO *io);
void (*ValkeyModule_SaveLongDouble)(ValkeyModuleIO *io, long double value);
long double (*ValkeyModule_LoadLongDouble)(ValkeyModuleIO *io);
void *(*ValkeyModule_LoadDataTypeFromString)(const ValkeyModuleString *str,
                                                              const ValkeyModuleType *mt);
void *(*ValkeyModule_LoadDataTypeFromStringEncver)(const ValkeyModuleString *str,
                                                                    const ValkeyModuleType *mt,
                                                                    int encver);
ValkeyModuleString *(*ValkeyModule_SaveDataTypeToString)(ValkeyModuleCtx *ctx,
                                                                          void *data,
                                                                          const ValkeyModuleType *mt);
void (*ValkeyModule__Assert)(const char *estr, const char *file, int line);
void (*ValkeyModule_LatencyAddSample)(const char *event, mstime_t latency);
int (*ValkeyModule_StringAppendBuffer)(ValkeyModuleCtx *ctx,
                                                        ValkeyModuleString *str,
                                                        const char *buf,
                                                        size_t len);
void (*ValkeyModule_TrimStringAllocation)(ValkeyModuleString *str);
void (*ValkeyModule_RetainString)(ValkeyModuleCtx *ctx, ValkeyModuleString *str);
ValkeyModuleString *(*ValkeyModule_HoldString)(ValkeyModuleCtx *ctx,
                                                                ValkeyModuleString *str);
int (*ValkeyModule_StringCompare)(const ValkeyModuleString *a,
                                                   const ValkeyModuleString *b);
ValkeyModuleCtx *(*ValkeyModule_GetContextFromIO)(ValkeyModuleIO *io);
const ValkeyModuleString *(*ValkeyModule_GetKeyNameFromIO)(ValkeyModuleIO *io);
const ValkeyModuleString *(*ValkeyModule_GetKeyNameFromModuleKey)(ValkeyModuleKey *key)
   ;
int (*ValkeyModule_GetDbIdFromModuleKey)(ValkeyModuleKey *key);
int (*ValkeyModule_GetDbIdFromIO)(ValkeyModuleIO *io);
int (*ValkeyModule_GetDbIdFromOptCtx)(ValkeyModuleKeyOptCtx *ctx);
int (*ValkeyModule_GetToDbIdFromOptCtx)(ValkeyModuleKeyOptCtx *ctx);
const ValkeyModuleString *(*ValkeyModule_GetKeyNameFromOptCtx)(ValkeyModuleKeyOptCtx *ctx)
   ;
const ValkeyModuleString *(*ValkeyModule_GetToKeyNameFromOptCtx)(ValkeyModuleKeyOptCtx *ctx)
   ;
mstime_t (*ValkeyModule_Milliseconds)(void);
uint64_t (*ValkeyModule_MonotonicMicroseconds)(void);
ustime_t (*ValkeyModule_Microseconds)(void);
ustime_t (*ValkeyModule_CachedMicroseconds)(void);
void (*ValkeyModule_DigestAddStringBuffer)(ValkeyModuleDigest *md,
                                                            const char *ele,
                                                            size_t len);
void (*ValkeyModule_DigestAddLongLong)(ValkeyModuleDigest *md, long long ele);
void (*ValkeyModule_DigestEndSequence)(ValkeyModuleDigest *md);
int (*ValkeyModule_GetDbIdFromDigest)(ValkeyModuleDigest *dig);
const ValkeyModuleString *(*ValkeyModule_GetKeyNameFromDigest)(ValkeyModuleDigest *dig)
   ;
ValkeyModuleDict *(*ValkeyModule_CreateDict)(ValkeyModuleCtx *ctx);
void (*ValkeyModule_FreeDict)(ValkeyModuleCtx *ctx, ValkeyModuleDict *d);
uint64_t (*ValkeyModule_DictSize)(ValkeyModuleDict *d);
int (*ValkeyModule_DictSetC)(ValkeyModuleDict *d, void *key, size_t keylen, void *ptr)
   ;
int (*ValkeyModule_DictReplaceC)(ValkeyModuleDict *d, void *key, size_t keylen, void *ptr)
   ;
int (*ValkeyModule_DictSet)(ValkeyModuleDict *d, ValkeyModuleString *key, void *ptr);
int (*ValkeyModule_DictReplace)(ValkeyModuleDict *d,
                                                 ValkeyModuleString *key,
                                                 void *ptr);
void *(*ValkeyModule_DictGetC)(ValkeyModuleDict *d, void *key, size_t keylen, int *nokey)
   ;
void *(*ValkeyModule_DictGet)(ValkeyModuleDict *d,
                                               ValkeyModuleString *key,
                                               int *nokey);
int (*ValkeyModule_DictDelC)(ValkeyModuleDict *d, void *key, size_t keylen, void *oldval)
   ;
int (*ValkeyModule_DictDel)(ValkeyModuleDict *d,
                                             ValkeyModuleString *key,
                                             void *oldval);
ValkeyModuleDictIter *(*ValkeyModule_DictIteratorStartC)(ValkeyModuleDict *d,
                                                                          const char *op,
                                                                          void *key,
                                                                          size_t keylen);
ValkeyModuleDictIter *(*ValkeyModule_DictIteratorStart)(ValkeyModuleDict *d,
                                                                         const char *op,
                                                                         ValkeyModuleString *key);
void (*ValkeyModule_DictIteratorStop)(ValkeyModuleDictIter *di);
int (*ValkeyModule_DictIteratorReseekC)(ValkeyModuleDictIter *di,
                                                         const char *op,
                                                         void *key,
                                                         size_t keylen);
int (*ValkeyModule_DictIteratorReseek)(ValkeyModuleDictIter *di,
                                                        const char *op,
                                                        ValkeyModuleString *key);
void *(*ValkeyModule_DictNextC)(ValkeyModuleDictIter *di,
                                                 size_t *keylen,
                                                 void **dataptr);
void *(*ValkeyModule_DictPrevC)(ValkeyModuleDictIter *di,
                                                 size_t *keylen,
                                                 void **dataptr);
ValkeyModuleString *(*ValkeyModule_DictNext)(ValkeyModuleCtx *ctx,
                                                              ValkeyModuleDictIter *di,
                                                              void **dataptr);
ValkeyModuleString *(*ValkeyModule_DictPrev)(ValkeyModuleCtx *ctx,
                                                              ValkeyModuleDictIter *di,
                                                              void **dataptr);
int (*ValkeyModule_DictCompareC)(ValkeyModuleDictIter *di, const char *op, void *key, size_t keylen)
   ;
int (*ValkeyModule_DictCompare)(ValkeyModuleDictIter *di,
                                                 const char *op,
                                                 ValkeyModuleString *key);
int (*ValkeyModule_RegisterInfoFunc)(ValkeyModuleCtx *ctx, ValkeyModuleInfoFunc cb);
void (*ValkeyModule_RegisterAuthCallback)(ValkeyModuleCtx *ctx,
                                                           ValkeyModuleAuthCallback cb);
int (*ValkeyModule_InfoAddSection)(ValkeyModuleInfoCtx *ctx, const char *name);
int (*ValkeyModule_InfoBeginDictField)(ValkeyModuleInfoCtx *ctx, const char *name);
int (*ValkeyModule_InfoEndDictField)(ValkeyModuleInfoCtx *ctx);
int (*ValkeyModule_InfoAddFieldString)(ValkeyModuleInfoCtx *ctx,
                                                        const char *field,
                                                        ValkeyModuleString *value);
int (*ValkeyModule_InfoAddFieldCString)(ValkeyModuleInfoCtx *ctx,
                                                         const char *field,
                                                         const char *value);
int (*ValkeyModule_InfoAddFieldDouble)(ValkeyModuleInfoCtx *ctx,
                                                        const char *field,
                                                        double value);
int (*ValkeyModule_InfoAddFieldLongLong)(ValkeyModuleInfoCtx *ctx,
                                                          const char *field,
                                                          long long value);
int (*ValkeyModule_InfoAddFieldULongLong)(ValkeyModuleInfoCtx *ctx,
                                                           const char *field,
                                                           unsigned long long value);
ValkeyModuleServerInfoData *(*ValkeyModule_GetServerInfo)(ValkeyModuleCtx *ctx,
                                                                           const char *section);
void (*ValkeyModule_FreeServerInfo)(ValkeyModuleCtx *ctx,
                                                     ValkeyModuleServerInfoData *data);
ValkeyModuleString *(*ValkeyModule_ServerInfoGetField)(ValkeyModuleCtx *ctx,
                                                                        ValkeyModuleServerInfoData *data,
                                                                        const char *field);
const char *(*ValkeyModule_ServerInfoGetFieldC)(ValkeyModuleServerInfoData *data,
                                                                 const char *field);
long long (*ValkeyModule_ServerInfoGetFieldSigned)(ValkeyModuleServerInfoData *data,
                                                                    const char *field,
                                                                    int *out_err);
unsigned long long (*ValkeyModule_ServerInfoGetFieldUnsigned)(ValkeyModuleServerInfoData *data,
                                                                               const char *field,
                                                                               int *out_err);
double (*ValkeyModule_ServerInfoGetFieldDouble)(ValkeyModuleServerInfoData *data,
                                                                 const char *field,
                                                                 int *out_err);
int (*ValkeyModule_SubscribeToServerEvent)(ValkeyModuleCtx *ctx,
                                                            ValkeyModuleEvent event,
                                                            ValkeyModuleEventCallback callback);
int (*ValkeyModule_SetLRU)(ValkeyModuleKey *key, mstime_t lru_idle);
int (*ValkeyModule_GetLRU)(ValkeyModuleKey *key, mstime_t *lru_idle);
int (*ValkeyModule_SetLFU)(ValkeyModuleKey *key, long long lfu_freq);
int (*ValkeyModule_GetLFU)(ValkeyModuleKey *key, long long *lfu_freq);
ValkeyModuleBlockedClient *(*ValkeyModule_BlockClientOnKeys)(ValkeyModuleCtx *ctx,
            ValkeyModuleCmdFunc reply_callback,
            ValkeyModuleCmdFunc timeout_callback,
            void (*free_privdata)(ValkeyModuleCtx *,
                                void *),
            long long timeout_ms,
            ValkeyModuleString **keys,
            int numkeys,
            void *privdata);
ValkeyModuleBlockedClient *(*ValkeyModule_BlockClientOnKeysWithFlags)(
    ValkeyModuleCtx *ctx,
    ValkeyModuleCmdFunc reply_callback,
    ValkeyModuleCmdFunc timeout_callback,
    void (*free_privdata)(ValkeyModuleCtx *, void *),
    long long timeout_ms,
    ValkeyModuleString **keys,
    int numkeys,
    void *privdata,
    int flags);
void (*ValkeyModule_SignalKeyAsReady)(ValkeyModuleCtx *ctx, ValkeyModuleString *key);
ValkeyModuleString *(*ValkeyModule_GetBlockedClientReadyKey)(ValkeyModuleCtx *ctx);
ValkeyModuleScanCursor *(*ValkeyModule_ScanCursorCreate)(void);
void (*ValkeyModule_ScanCursorRestart)(ValkeyModuleScanCursor *cursor);
void (*ValkeyModule_ScanCursorDestroy)(ValkeyModuleScanCursor *cursor);
int (*ValkeyModule_Scan)(ValkeyModuleCtx *ctx,
                                          ValkeyModuleScanCursor *cursor,
                                          ValkeyModuleScanCB fn,
                                          void *privdata);
int (*ValkeyModule_ScanKey)(ValkeyModuleKey *key,
                                             ValkeyModuleScanCursor *cursor,
                                             ValkeyModuleScanKeyCB fn,
                                             void *privdata);
int (*ValkeyModule_GetContextFlagsAll)(void);
int (*ValkeyModule_GetModuleOptionsAll)(void);
int (*ValkeyModule_GetKeyspaceNotificationFlagsAll)(void);
int (*ValkeyModule_IsSubEventSupported)(ValkeyModuleEvent event, uint64_t subevent);
int (*ValkeyModule_GetServerVersion)(void);
int (*ValkeyModule_GetTypeMethodVersion)(void);
void (*ValkeyModule_Yield)(ValkeyModuleCtx *ctx, int flags, const char *busy_reply);
ValkeyModuleBlockedClient *(*ValkeyModule_BlockClient)(ValkeyModuleCtx *ctx,
                                                                        ValkeyModuleCmdFunc reply_callback,
                                                                        ValkeyModuleCmdFunc timeout_callback,
                                                                        void (*free_privdata)(ValkeyModuleCtx *,
                                                                                              void *),
                                                                        long long timeout_ms);
void *(*ValkeyModule_BlockClientGetPrivateData)(ValkeyModuleBlockedClient *blocked_client)
   ;
void (*ValkeyModule_BlockClientSetPrivateData)(ValkeyModuleBlockedClient *blocked_client,
                                                                void *private_data);
ValkeyModuleBlockedClient *(*ValkeyModule_BlockClientOnAuth)(
    ValkeyModuleCtx *ctx,
    ValkeyModuleAuthCallback reply_callback,
    void (*free_privdata)(ValkeyModuleCtx *, void *));
int (*ValkeyModule_UnblockClient)(ValkeyModuleBlockedClient *bc, void *privdata);
int (*ValkeyModule_IsBlockedReplyRequest)(ValkeyModuleCtx *ctx);
int (*ValkeyModule_IsBlockedTimeoutRequest)(ValkeyModuleCtx *ctx);
void *(*ValkeyModule_GetBlockedClientPrivateData)(ValkeyModuleCtx *ctx);
ValkeyModuleBlockedClient *(*ValkeyModule_GetBlockedClientHandle)(ValkeyModuleCtx *ctx)
   ;
int (*ValkeyModule_AbortBlock)(ValkeyModuleBlockedClient *bc);
int (*ValkeyModule_BlockedClientMeasureTimeStart)(ValkeyModuleBlockedClient *bc);
int (*ValkeyModule_BlockedClientMeasureTimeEnd)(ValkeyModuleBlockedClient *bc);
ValkeyModuleCtx *(*ValkeyModule_GetThreadSafeContext)(ValkeyModuleBlockedClient *bc);
ValkeyModuleCtx *(*ValkeyModule_GetDetachedThreadSafeContext)(ValkeyModuleCtx *ctx);
void (*ValkeyModule_FreeThreadSafeContext)(ValkeyModuleCtx *ctx);
void (*ValkeyModule_ThreadSafeContextLock)(ValkeyModuleCtx *ctx);
int (*ValkeyModule_ThreadSafeContextTryLock)(ValkeyModuleCtx *ctx);
void (*ValkeyModule_ThreadSafeContextUnlock)(ValkeyModuleCtx *ctx);
int (*ValkeyModule_SubscribeToKeyspaceEvents)(ValkeyModuleCtx *ctx,
                                                               int types,
                                                               ValkeyModuleNotificationFunc cb);
int (*ValkeyModule_AddPostNotificationJob)(ValkeyModuleCtx *ctx,
                                                            ValkeyModulePostNotificationJobFunc callback,
                                                            void *pd,
                                                            void (*free_pd)(void *));
int (*ValkeyModule_NotifyKeyspaceEvent)(ValkeyModuleCtx *ctx,
                                                         int type,
                                                         const char *event,
                                                         ValkeyModuleString *key);
int (*ValkeyModule_GetNotifyKeyspaceEvents)(void);
int (*ValkeyModule_BlockedClientDisconnected)(ValkeyModuleCtx *ctx);
void (*ValkeyModule_RegisterClusterMessageReceiver)(ValkeyModuleCtx *ctx,
                                                                     uint8_t type,
                                                                     ValkeyModuleClusterMessageReceiver callback)
   ;
int (*ValkeyModule_SendClusterMessage)(ValkeyModuleCtx *ctx,
                                                        const char *target_id,
                                                        uint8_t type,
                                                        const char *msg,
                                                        uint32_t len);
int (*ValkeyModule_GetClusterNodeInfo)(ValkeyModuleCtx *ctx,
                                                        const char *id,
                                                        char *ip,
                                                        char *primary_id,
                                                        int *port,
                                                        int *flags);
int (*ValkeyModule_GetClusterNodeInfoForClient)(ValkeyModuleCtx *ctx,
                                                                 uint64_t client_id,
                                                                 const char *node_id,
                                                                 char *ip,
                                                                 char *primary_id,
                                                                 int *port,
                                                                 int *flags);
char **(*ValkeyModule_GetClusterNodesList)(ValkeyModuleCtx *ctx, size_t *numnodes);
void (*ValkeyModule_FreeClusterNodesList)(char **ids);
ValkeyModuleTimerID (*ValkeyModule_CreateTimer)(ValkeyModuleCtx *ctx,
                                                                 mstime_t period,
                                                                 ValkeyModuleTimerProc callback,
                                                                 void *data);
int (*ValkeyModule_StopTimer)(ValkeyModuleCtx *ctx,
                                               ValkeyModuleTimerID id,
                                               void **data);
int (*ValkeyModule_GetTimerInfo)(ValkeyModuleCtx *ctx,
                                                  ValkeyModuleTimerID id,
                                                  uint64_t *remaining,
                                                  void **data);
const char *(*ValkeyModule_GetMyClusterID)(void);
size_t (*ValkeyModule_GetClusterSize)(void);
void (*ValkeyModule_GetRandomBytes)(unsigned char *dst, size_t len);
void (*ValkeyModule_GetRandomHexChars)(char *dst, size_t len);
void (*ValkeyModule_SetDisconnectCallback)(ValkeyModuleBlockedClient *bc,
                                                            ValkeyModuleDisconnectFunc callback);
void (*ValkeyModule_SetClusterFlags)(ValkeyModuleCtx *ctx, uint64_t flags);
unsigned int (*ValkeyModule_ClusterKeySlot)(ValkeyModuleString *key);
const char *(*ValkeyModule_ClusterCanonicalKeyNameInSlot)(unsigned int slot);
int (*ValkeyModule_ExportSharedAPI)(ValkeyModuleCtx *ctx,
                                                     const char *apiname,
                                                     void *func);
void *(*ValkeyModule_GetSharedAPI)(ValkeyModuleCtx *ctx, const char *apiname);
ValkeyModuleCommandFilter *(*ValkeyModule_RegisterCommandFilter)(ValkeyModuleCtx *ctx,
                                                                                  ValkeyModuleCommandFilterFunc cb,
                                                                                  int flags);
int (*ValkeyModule_UnregisterCommandFilter)(ValkeyModuleCtx *ctx,
                                                             ValkeyModuleCommandFilter *filter);
int (*ValkeyModule_CommandFilterArgsCount)(ValkeyModuleCommandFilterCtx *fctx);
ValkeyModuleString *(*ValkeyModule_CommandFilterArgGet)(ValkeyModuleCommandFilterCtx *fctx,
                                                                         int pos);
int (*ValkeyModule_CommandFilterArgInsert)(ValkeyModuleCommandFilterCtx *fctx,
                                                            int pos,
                                                            ValkeyModuleString *arg);
int (*ValkeyModule_CommandFilterArgReplace)(ValkeyModuleCommandFilterCtx *fctx,
                                                             int pos,
                                                             ValkeyModuleString *arg);
int (*ValkeyModule_CommandFilterArgDelete)(ValkeyModuleCommandFilterCtx *fctx,
                                                            int pos);
unsigned long long (*ValkeyModule_CommandFilterGetClientId)(ValkeyModuleCommandFilterCtx *fctx)
   ;
int (*ValkeyModule_Fork)(ValkeyModuleForkDoneHandler cb, void *user_data);
void (*ValkeyModule_SendChildHeartbeat)(double progress);
int (*ValkeyModule_ExitFromChild)(int retcode);
int (*ValkeyModule_KillForkChild)(int child_pid);
float (*ValkeyModule_GetUsedMemoryRatio)(void);
size_t (*ValkeyModule_MallocSize)(void *ptr);
size_t (*ValkeyModule_MallocUsableSize)(void *ptr);
size_t (*ValkeyModule_MallocSizeString)(ValkeyModuleString *str);
size_t (*ValkeyModule_MallocSizeDict)(ValkeyModuleDict *dict);
ValkeyModuleUser *(*ValkeyModule_CreateModuleUser)(const char *name);
void (*ValkeyModule_FreeModuleUser)(ValkeyModuleUser *user);
void (*ValkeyModule_SetContextUser)(ValkeyModuleCtx *ctx,
                                                     const ValkeyModuleUser *user);
int (*ValkeyModule_SetModuleUserACL)(ValkeyModuleUser *user, const char *acl);
int (*ValkeyModule_SetModuleUserACLString)(ValkeyModuleCtx *ctx,
                                                            ValkeyModuleUser *user,
                                                            const char *acl,
                                                            ValkeyModuleString **error);
ValkeyModuleString *(*ValkeyModule_GetModuleUserACLString)(ValkeyModuleUser *user);
ValkeyModuleString *(*ValkeyModule_GetCurrentUserName)(ValkeyModuleCtx *ctx);
ValkeyModuleUser *(*ValkeyModule_GetModuleUserFromUserName)(ValkeyModuleString *name);
int (*ValkeyModule_ACLCheckCommandPermissions)(ValkeyModuleUser *user,
                                                                ValkeyModuleString **argv,
                                                                int argc);
int (*ValkeyModule_ACLCheckKeyPermissions)(ValkeyModuleUser *user,
                                                            ValkeyModuleString *key,
                                                            int flags);
int (*ValkeyModule_ACLCheckChannelPermissions)(ValkeyModuleUser *user,
                                                                ValkeyModuleString *ch,
                                                                int literal);
void (*ValkeyModule_ACLAddLogEntry)(ValkeyModuleCtx *ctx,
                                                     ValkeyModuleUser *user,
                                                     ValkeyModuleString *object,
                                                     ValkeyModuleACLLogEntryReason reason);
void (*ValkeyModule_ACLAddLogEntryByUserName)(ValkeyModuleCtx *ctx,
                                                               ValkeyModuleString *user,
                                                               ValkeyModuleString *object,
                                                               ValkeyModuleACLLogEntryReason reason);
int (*ValkeyModule_AuthenticateClientWithACLUser)(ValkeyModuleCtx *ctx,
                                                                   const char *name,
                                                                   size_t len,
                                                                   ValkeyModuleUserChangedFunc callback,
                                                                   void *privdata,
                                                                   uint64_t *client_id);
int (*ValkeyModule_AuthenticateClientWithUser)(ValkeyModuleCtx *ctx,
                                                                ValkeyModuleUser *user,
                                                                ValkeyModuleUserChangedFunc callback,
                                                                void *privdata,
                                                                uint64_t *client_id);
int (*ValkeyModule_DeauthenticateAndCloseClient)(ValkeyModuleCtx *ctx,
                                                                  uint64_t client_id);
int (*ValkeyModule_RedactClientCommandArgument)(ValkeyModuleCtx *ctx, int pos);
ValkeyModuleString *(*ValkeyModule_GetClientCertificate)(ValkeyModuleCtx *ctx,
                                                                          uint64_t id);
int *(*ValkeyModule_GetCommandKeys)(ValkeyModuleCtx *ctx,
                                                     ValkeyModuleString **argv,
                                                     int argc,
                                                     int *num_keys);
int *(*ValkeyModule_GetCommandKeysWithFlags)(ValkeyModuleCtx *ctx,
                                                              ValkeyModuleString **argv,
                                                              int argc,
                                                              int *num_keys,
                                                              int **out_flags);
const char *(*ValkeyModule_GetCurrentCommandName)(ValkeyModuleCtx *ctx);
int (*ValkeyModule_RegisterDefragFunc)(ValkeyModuleCtx *ctx,
                                                        ValkeyModuleDefragFunc func);
void *(*ValkeyModule_DefragAlloc)(ValkeyModuleDefragCtx *ctx, void *ptr);
ValkeyModuleString *(*ValkeyModule_DefragValkeyModuleString)(ValkeyModuleDefragCtx *ctx,
                                                                              ValkeyModuleString *str);
int (*ValkeyModule_DefragShouldStop)(ValkeyModuleDefragCtx *ctx);
int (*ValkeyModule_DefragCursorSet)(ValkeyModuleDefragCtx *ctx,
                                                     unsigned long cursor);
int (*ValkeyModule_DefragCursorGet)(ValkeyModuleDefragCtx *ctx,
                                                     unsigned long *cursor);
int (*ValkeyModule_GetDbIdFromDefragCtx)(ValkeyModuleDefragCtx *ctx);
const ValkeyModuleString *(*ValkeyModule_GetKeyNameFromDefragCtx)(ValkeyModuleDefragCtx *ctx)
   ;
int (*ValkeyModule_EventLoopAdd)(int fd, int mask, ValkeyModuleEventLoopFunc func, void *user_data)
   ;
int (*ValkeyModule_EventLoopDel)(int fd, int mask);
int (*ValkeyModule_EventLoopAddOneShot)(ValkeyModuleEventLoopOneShotFunc func,
                                                         void *user_data);
int (*ValkeyModule_RegisterBoolConfig)(ValkeyModuleCtx *ctx,
                                                        const char *name,
                                                        int default_val,
                                                        unsigned int flags,
                                                        ValkeyModuleConfigGetBoolFunc getfn,
                                                        ValkeyModuleConfigSetBoolFunc setfn,
                                                        ValkeyModuleConfigApplyFunc applyfn,
                                                        void *privdata);
int (*ValkeyModule_RegisterNumericConfig)(ValkeyModuleCtx *ctx,
                                                           const char *name,
                                                           long long default_val,
                                                           unsigned int flags,
                                                           long long min,
                                                           long long max,
                                                           ValkeyModuleConfigGetNumericFunc getfn,
                                                           ValkeyModuleConfigSetNumericFunc setfn,
                                                           ValkeyModuleConfigApplyFunc applyfn,
                                                           void *privdata);
int (*ValkeyModule_RegisterStringConfig)(ValkeyModuleCtx *ctx,
                                                          const char *name,
                                                          const char *default_val,
                                                          unsigned int flags,
                                                          ValkeyModuleConfigGetStringFunc getfn,
                                                          ValkeyModuleConfigSetStringFunc setfn,
                                                          ValkeyModuleConfigApplyFunc applyfn,
                                                          void *privdata);
int (*ValkeyModule_RegisterEnumConfig)(ValkeyModuleCtx *ctx,
                                                        const char *name,
                                                        int default_val,
                                                        unsigned int flags,
                                                        const char **enum_values,
                                                        const int *int_values,
                                                        int num_enum_vals,
                                                        ValkeyModuleConfigGetEnumFunc getfn,
                                                        ValkeyModuleConfigSetEnumFunc setfn,
                                                        ValkeyModuleConfigApplyFunc applyfn,
                                                        void *privdata);
int (*ValkeyModule_LoadConfigs)(ValkeyModuleCtx *ctx);
ValkeyModuleRdbStream *(*ValkeyModule_RdbStreamCreateFromFile)(const char *filename);
void (*ValkeyModule_RdbStreamFree)(ValkeyModuleRdbStream *stream);
int (*ValkeyModule_RdbLoad)(ValkeyModuleCtx *ctx,
                                             ValkeyModuleRdbStream *stream,
                                             int flags);
int (*ValkeyModule_RdbSave)(ValkeyModuleCtx *ctx,
                                             ValkeyModuleRdbStream *stream,
                                             int flags);
]]

return valkeymodule_cdef
