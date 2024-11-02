-- valkeymodule.lua
-- Copyright (c) 2016-2024 Evan Wies
--
-- extracted from:
--    https://github.com/valkey-io/valkey/blob/unstable/src/valkeymodule.h
--
-- VKM ==> ValkeyModule
--

local ffi = require 'ffi'

do
    local valkeymodule_cdef = require 'valkeymodule-cdef'
    ffi.cdef(valkeymodule_cdef)
end

local C = ffi.C
local ffi_new, ffi_gc, ffi_string = ffi.new, ffi.gc, ffi.string
local select, type = select, type

local VKM_LJ = ffi.load('valkey-mod_luajit', true)
ffi.cdef([[
ValkeyModuleCtx* VKM_LJ_GetEvalContext(void);
]])

local VKM_OK = 0
local VKM_ERR = 1

local int_1_t    = ffi.typeof('int[1]')
local size_1_t   = ffi.typeof('size_t[1]')
local ll_1_t     = ffi.typeof('long long[1]')
local ull_1_t    = ffi.typeof('unsigned long long[1]')
local double_1_t = ffi.typeof('double[1]')


-- ValkeyModule Lua API
local VKM = {
    -- Error status return values.
    OK = 0,
    ERR = 1,

    -- Module Based Authentication status return values.
    VKM_AUTH_HANDLED = 0,
    VKM_AUTH_NOT_HANDLED = 1,

    -- API versions.
    APIVER_1 = 1,

    -- Version of the ValkeyModuleTypeMethods structure. Once the ValkeyModuleTypeMethods
    -- structure is changed, this version number needs to be changed synchronistically.
    VKM_TYPE_METHOD_VERSION = 5,

    -- API flags and constants
    READ = 1,  -- (1 << 0)
    WRITE = 2, -- (1 << 1)

    -- ValkeyModule_OpenKey extra flags for the 'mode' argument.
    -- Avoid touching the LRU/LFU of the key when opened.
    OPEN_KEY_NOTOUCH = 65536, -- (1 << 16)
    -- Don't trigger keyspace event on key misses.
    OPEN_KEY_NONOTIFY = 131072, -- (1 << 17)
    -- Don't update keyspace hits/misses counters.
    OPEN_KEY_NOSTATS = 262144, -- (1 << 18)
    -- Avoid deleting lazy expired keys.
    OPEN_KEY_NOEXPIRE = 524288, -- (1 << 19)
    -- Avoid any effects from fetching the key
    OPEN_KEY_NOEFFECTS = 1048576, -- (1 << 20)

    -- List push and pop
    LIST_HEAD = 0,
    LIST_TAIL = 1,

    -- Key types.
    KEYTYPE_EMPTY = 0,
    KEYTYPE_STRING = 1,
    KEYTYPE_LIST = 2,
    KEYTYPE_HASH = 3,
    KEYTYPE_SET = 4,
    KEYTYPE_ZSET = 5,
    KEYTYPE_MODULE = 6,
    KEYTYPE_STREAM = 7,
    
    -- Reply types.
    REPLY_UNKNOWN = -1,
    REPLY_STRING = 0,
    REPLY_ERROR = 1,
    REPLY_INTEGER = 2,
    REPLY_ARRAY = 3,
    REPLY_NULL = 4,
    REPLY_MAP = 5,
    REPLY_SET = 6,
    REPLY_BOOL = 7,
    REPLY_DOUBLE = 8,
    REPLY_BIG_NUMBER = 9,
    REPLY_VERBATIM_STRING = 10,
    REPLY_ATTRIBUTE = 11,
    REPLY_PROMISE = 12,
    
    -- Postponed array length.
    POSTPONED_LEN = -1,

    -- Expire
    NO_EXPIRE = -1,

    -- Sorted set API flags.
    ZADD_XX      = 1, -- (1 << 0)
    ZADD_NX      = 2, -- (1 << 1)
    ZADD_ADDED   = 4, -- (1 << 2)
    ZADD_UPDATED = 8, -- (1 << 3)
    ZADD_NOP     = 16, -- (1 << 4)
    ZADD_GT      = 32, -- (1 << 5)
    ZADD_LT      = 64, -- (1 << 6)

    -- Hash API flags.
    HASH_NONE       = 0,
    HASH_NX         = 1, -- (1 << 0)
    HASH_XX         = 2, -- (1 << 1)
    HASH_CFIELDS    = 4, -- (1 << 2)
    HASH_EXISTS     = 8, -- (1 << 3)
    HASH_COUNT_ALL  = 16, -- (1 << 4)

    CONFIG_DEFAULT      = 0,                  -- This is the default for a module config.
    CONFIG_IMMUTABLE    = 1,   -- (1ULL << 0) -- Can this value only be set at startup?
    CONFIG_SENSITIVE    = 2,   -- (1ULL << 1) -- Does this value contain sensitive information
    CONFIG_HIDDEN       = 4,   -- (1ULL << 4) -- This config is hidden in `config get <pattern>` (used for tests/debugging)
    CONFIG_PROTECTED    = 32,  -- (1ULL << 5) -- Becomes immutable if enable-protected-configs is enabled.
    CONFIG_DENY_LOADING = 64,  -- (1ULL << 6) -- This config is forbidden during loading.
    CONFIG_MEMORY       = 128, -- (1ULL << 7) -- Indicates if this value can be set as a memory value
    CONFIG_BITFLAGS     = 256, -- (1ULL << 8) -- Indicates if this value can be set as a multiple enum values

    -- Server events definitions.
    -- Those flags should not be used directly by the module, instead
    -- the module should use ValkeyModuleEvent_* variables.
    -- Note: This must be synced with moduleEventVersions
    EVENTLOOP_READABLE = 1,
    EVENTLOOP_WRITABLE = 2,
    EVENT_REPLICATION_ROLE_CHANGED = 0,
    EVENT_PERSISTENCE = 1,
    EVENT_FLUSHDB = 2,
    EVENT_LOADING = 3,
    EVENT_CLIENT_CHANGE = 4,
    EVENT_SHUTDOWN = 5,
    EVENT_REPLICA_CHANGE = 6,
    EVENT_PRIMARY_LINK_CHANGE = 7,
    EVENT_CRON_LOOP = 8,
    EVENT_MODULE_CHANGE = 9,
    EVENT_LOADING_PROGRESS = 10,
    EVENT_SWAPDB = 11,
    EVENT_REPL_BACKUP = 12, -- Not used anymore.
    EVENT_FORK_CHILD = 13,
    EVENT_REPL_ASYNC_LOAD = 14,
    EVENT_EVENTLOOP = 15,
    EVENT_CONFIG = 16,
    EVENT_KEY = 17,
    EVENT_NEXT = 18, -- Next event flag, should be updated if a new event added.

    -- A special pointer that we can use between the core and the module to signal
    -- field deletion, and that is impossible to be a valid pointer.
    HASH_DELETE = 1, -- ((ValkeyModuleString*)(long)1)

    -- Error messages.
    ERRORMSG_WRONGTYPE = "WRONGTYPE Operation against a key holding the wrong kind of value",

    POSITIVE_INFINITE = (1.0/0.0),
    NEGATIVE_INFINITE = (-1.0/0.0),
}

--- ValkeyModule Key class 
VKM.Key = ffi.metatype( 'struct ValkeyModuleKey', {

    -- garbage collection destructor, not invoked by user
    __gc = C.ValkeyModule_CloseKey,

    -- methods
    __index = {
        KeyType = function(key)
            return C.ValkeyModule_KeyType(key)
        end,
        ValueLength = function(key)
            return C.ValkeyModule_ValueLength(key)
        end,
        ListPush = function(key, where, elem)
            if type(elem) == 'string' then
                elem = VKM.CreateString(elem)
            end
            return C.ValkeyModule_ListPush(key, where, elem)
        end,
        ListPop = function(key, where)
            local elem = C.ValkeyModule_ListPush(pop, where)
            return elem and ffi_gc(elem, C.ValkeyModule_FreeString) or nil
        end,
        ListGet = function(key, index)
            local elem = C.Valkey_ListGet(key, index)
            return elem and ffi_gc(elem, C.ValkeyModule_FreeString) or nil
        end,
        -- ListSet
        -- ListInsert
        -- ListDelete
        -- Call
        DeleteKey = function(key)
            return C.ValkeyModule_DeleteKey(key)
        end,
        UnlinkKey = function(key)
            return C.ValkeyModule_UnlinkKey(key)
        end,
        StringSet = function(key, vkmstr)
            return C.ValkeyModule_StringSet(key, vkmstr)
        end,
        -- returns char*, size_t (ptr, len) for DMA access
        -- mode should be VKM.READ, VKM.WRITE, or VKM.READ+VKM.WRITE
        StringDMA = function(key, mode)
            local len_1 = size_1_t()
            local ptr = C.ValkeyModule_StringDMA(key, len_1, mode)
            return ptr, len_1[0]
        end,
        StringTruncate = function(key, newlen)
            return C.ValkeyModule_StringTruncate(key, newlen)
        end,
        GetExpire = function(key)
            return C.ValkeyModule_GetExpire(key)
        end,
        SetExpire = function(key, expire)
            return C.ValkeyModule_SetExpire(expire)
        end,
        -- returns result, outflags
        ZsetAdd = function(key, score, elem, flags)
            local flags_1 = int_1_t(flags or 0)
            local res = C.ValkeyModule_ZsetAdd(key, score, elem, flags_1)
            return res, flags_1[0]
        end,
        -- returns result, outflags, newscore
        ZsetIncrby = function(key, score, elem, flags)
            local flags_1 = int_1_t(flags or 0)
            local newscore_1 = double_1_t()
            local res = C.ValkeyModule_ZsetIncrby(key, score, elem, flags_1, newscore_1)
            return res, flags_1[0], newscore_1[0]
        end,
        -- returns result, score
        ZsetScore = function(key, elem, score)
            local score_1 = double_1_t()
            local res = C.ValkeyModule_ZsetIncrby(key, elem, score_1)
            return res, score_1[0]
        end,
        ZsetRem = function(key, elem)
            local deleted_1 = int_1_t()
            local res = C.ValkeyModule_ZsetRem(key, elem, deleted_1)
            return res, deleted_1[0]
        end,
        ZsetRangeStop = function(key)
            return C.ValkeyModule_ZsetRangeStop(key)
        end,
        ZsetFirstInScoreRange = function(key, min, max, minex, maxex)
            return C.ValkeyModule_ZsetFirstInScoreRange(key, min, max, minex, maxex)
        end,
        ZsetLastInScoreRange = function(key, min, max, minex, maxex)
            return C.ValkeyModule_ZsetLastInScoreRange(key, min, max, minex, maxex)
        end,
        ZsetFirstInLexRange = function(key, min, max)
            return C.ValkeyModule_ZsetFirstInLexRange(key, min, max)
        end,
        ZsetLastInLexRange = function(key, min, max)
            return C.ValkeyModule_ZsetLastInLexRange(key, min, max)
        end,
        -- returns VKM.String, score
        ZsetRangeCurrentElement = function(key)
            local score_1 = double_1_t()
            local str = C.ValkeyModule_ZsetRangeCurrentElement(key, score_1)
            return str, score_1[0]
        end,
        ZsetRangeNext = function(key)
            return C.ValkeyModule_ZsetRangeNext(key)
        end,
        ZsetRangePrev = function(key)
            return C.ValkeyModule_ZsetRangePrev(key)
        end,
        ZsetRangeEndReached = function(key)
            return C.ValkeyModule_ZsetRangeEndReached(key)
        end,
        --HashSet = function(key, int flags, ...)
        --    return C.ValkeyModule_HashSet(key)
        --end,
        --HashGet = function(key, int flags, ...)
        --    return C.ValkeyModule_HashGet(key)
        --end,
    }
})


--- ValkeyModule String class 
VKM.String = ffi.metatype( 'struct ValkeyModuleString', {
    -- methods
    __index = {
        -- Returns the string converted into a long long integer.
        -- Returns `nil` if the string can't be parsed as a valid, strict long long (no spaces before/after).
        ToLongLong = function(vkmstr)
            local ll_1 = ll_1_t()
            local res = C.ValkeyModule_StringToLongLong(vkmstr, ll_1)
            return (res == VKM_OK) and ll_1[0] or nil
        end,
        -- Returns the string converted into a unsinged long long integer.
        -- Returns `nil` if the string can't be parsed as a valid, strict long long (no spaces before/after).
        ToUnsignedLongLong = function(vkmstr)
            local ull_1 = ll_1_t()
            local res = C.ValkeyModule_UnsignedStringToLongLong(vkmstr, ull_1)
            return (res == VKM_OK) and ull_1[0] or nil
        end,
        -- Returns the string converted into a Lua number.
        -- Returns `nil` if the string is not a valid string representation of a double value.
        ToDouble = function(vkmstr)
            local double_1 = double_1_t()
            local res = C.ValkeyModule_StringToDouble(vkmstr, double_1)
            return (res == VKM_OK) and double_1[0] or nil
        end,
        -- ValkeyModule_StringToStreamID
        -- Returns the const char*, size_t (ptr, len) of the String.
        PtrLen = function(str)
            local len_1 = size_1_t()
            local ptr = C.ValkeyModule_StringPtrLen(str, len_1)
            return ptr, len_1[0]
        end,
    },

    -- Creates a Lua string from this String
    __tostring = function(str)
        local len_1 = size_1_t()
        local ptr = C.ValkeyModule_StringPtrLen(str, len_1)
        return ffi_string(ptr, len_1[0])
    end,
})

VKM.CreateString = function(ctx, val)
    local vkmstr
    if type(val) == 'string' then
        vkmstr = C.ValkeyModule_CreateString(ctx, str, #str-1)
    elseif type(val) == 'number' then
        vkmstr = C.ValkeyModule_CreateStringFromDouble(ctx, val)
    end
    return vkmstr and VKM.String(vkmstr)
end

VKM.CreateStringFromLongLong = function(ctx, num)
    local vkmstr = C.ValkeyModule_CreateStringFromLongLong(ctx, num)
    return vkmstr and VKM.String(vkmstr)
end


--- ValkeyModule CallReply class 
VKM.CallReply = ffi.metatype( 'struct ValkeyModuleCallReply', {
    -- methods
    __index = {
        Index = function(reply, idx)
            return C.ValkeyModule_CallReplyArrayElement(reply, idx)
        end,
        ArrayElement = function(reply, idx)
            return C.ValkeyModule_CallReplyArrayElement(reply, idx)
        end,
        Length = function(reply)
            return C.ValkeyModule_CallReplyLength(reply)
        end,
        Type = function(reply)
            return C.ValkeyModule_CallReplyType(reply)
        end,
        Integer = function(reply)
            return C.ValkeyModule_CallReplyInteger(reply)
        end,
        Double = function(reply)
            return C.ValkeyModule_CallReplyDouble(reply)
        end,
        Bool = function(reply)
            return (C.ValkeyModule_CallReplyBool(reply) ~= 0)
        end,

        -- ValkeyModule_CallReplyBigNumber
        -- ValkeyModule_CallReplyVerbatim
        -- ValkeyModule_CallReplySetElement
        -- ValkeyModule_CallReplyMapElement
        -- ValkeyModule_CallReplyAttributeElement
        -- ValkeyModule_CallReplyPromiseSetUnblockHandler
        -- ValkeyModule_CallReplyPromiseAbort
        -- ValkeyModule_CallReplyAttribute
        -- ValkeyModule_CallReplyArrayElement

        -- returns const char*, size_t of this CallReply
        Proto = function(reply)
            local len_1 = size_1_t()
            local ptr = C.ValkeyModule_CallReplyProto(reply, len_1)
            return ptr, len_1[0]
        end,
        -- returns a VKM.String from this CallReply
        String = function(reply)
            return C.ValkeyModule_CreateStringFromCallReply(reply)
        end,
    }
})

--- ValkeyModule Ctx class 
VKM.Ctx = ffi.metatype( 'ValkeyModuleCtx', {
    -- methods
    __index = {
        CreateCommand = function(ctx, name, cmdfunc, strflags, firstkey, lastkey, keystep)
            return C.ValkeyModule_CreateCommand(ctx, name, cmdfunc, strflags, firstkey, lastkey, keystep)
        end,
        -- C.ValkeyModule_GetCommand
        -- C.ValkeyModule_CreateSubcommand
        -- C.ValkeyModule_SetCommandInfo
        -- C.ValkeyModule_SetCommandACLCategories
        AddACLCategory = function(ctx, name)
            return C.ValkeyModule_AddACLCategory(ctx, name)
        end,
        -- C.ValkeyModule_SetModuleAttribs
        WrongArity = function(ctx)
            return C.ValkeyModule_WrongArity(ctx)
        end,
        ReplyWithLongLong = function(ctx, ll)
            return C.ValkeyModule_ReplyWithLongLong(ctx, ll)
        end,
        GetSelectedDb = function(ctx)
            return C.ValkeyModule_GetSelectedDb(ctx)
        end,
        SelectDb = function(ctx, newid)
            return C.ValkeyModule_SelectDb(ctx, newid)
        end,
        -- KeyExists = function(ctx, keyname)
        --     vkmstr = VKM.CreateString(keyname)
        --     return C.ValkeyModule_KeyExists(ctx, vkmstr)
        -- end,
        --C.ValkeyModule_OpenKey

        CreateString = function(ctx, val)
            return VKM.CreateString(ctx, val)
        end,
        CreateStringFromLongLong = function(ctx, num)
            local vkstr = VKM.CreateStringFromLongLong(ctx, num)
        end,
        -- ValkeyModule_CreateStringFromString
        -- ValkeyModule_CreateStringFromStreamID
        -- ValkeyModule_CreateStringPrintf
        
        ReplyWithError = function(ctx, err)
            return C.ValkeyModule_ReplyWithError(ctx, err)
        end,
        -- ValkeyModule_ReplyWithErrorFormat
        ReplyWithSimpleString = function(ctx, msg)
            return C.ValkeyModule_ReplyWithSimpleString(ctx, msg)
        end,
        ReplyWithArray = function(ctx, len)
            return C.ValkeyModule_ReplyWithArray(ctx, len)
        end,
        ReplyWithMap = function(ctx, len)
            return C.ValkeyModule_ReplyWithMap(ctx, len)
        end,
        ReplyWithSet = function(ctx, len)
            return C.ValkeyModule_ReplyWithSet(ctx, len)
        end,
        ReplyWithAttribute = function(ctx, len)
            return C.ValkeyModule_ReplyWithAttribute(ctx, len)
        end,
        ReplyWithNullArray = function(ctx)
            return C.ValkeyModule_ReplyWithNullArray(ctx)
        end,
        ReplyWithEmptyArray = function(ctx)
            return C.ValkeyModule_ReplyWithEmptyArray(ctx)
        end,
        ReplySetArrayLength = function(ctx, len)
            return C.ValkeyModule_ReplySetArrayLength(ctx, len)
        end,
        ReplySetMapLength = function(ctx, len)
            return C.ValkeyModule_ReplySetMapLength(ctx, len)
        end,
        ReplySetSetLength = function(ctx, len)
            return C.ValkeyModule_ReplySetSetLength(ctx, len)
        end,
        ReplySetAttributeLength = function(ctx, len)
            return C.ValkeyModule_ReplySetAttributeLength(ctx, len)
        end,
        ReplySetPushLength = function(ctx, len)
            return C.ValkeyModule_ReplySetPushLength(ctx, len)
        end,
        ReplyWithStringBuffer = function(ctx, buf, len)
            return C.ValkeyModule_ReplyWithStringBuffer(ctx, buf, len)
        end,
        ReplyWithString = function(ctx, str)
            local vkmstr = C.ValkeyModule_CreateString(ctx, str, #str-1)
            return C.ValkeyModule_ReplyWithStringBuffer(ctx, vkmstr)
        end,
        ReplyWithNull = function(ctx)
            return C.ValkeyModule_ReplyWithNull(ctx)
        end,
        ReplyWithBool = function(ctx, b)
            local bval = b and 1 or 0
            return C.ValkeyModule_ReplyWithBool(ctx, bval)
        end,
        ReplyWithDouble = function(ctx, d)
            return C.ValkeyModule_ReplyWithNull(ctx, d)
        end,
        ReplyWithCallReply = function(ctx, reply)
            return C.ValkeyModule_ReplyWithCallReply(ctx, reply)
        end,
        AutoMemory = function(ctx)
            C.ValkeyModule_AutoMemory(ctx)
        end,
        -- TODO Replicate = function(ctx, cmdname, fmt) -- , ...)
        --end,
        ReplicateVerbatim = function(ctx)
            return C.ValkeyModule_ReplicateVerbatim(ctx)
        end,
        IsKeysPositionRequest = function(ctx)
            return C.ValkeyModule_IsKeysPositionRequest(ctx)
        end,
        KeyAtPos = function(ctx, pos)
            C.ValkeyModule_KeyAtPos(ctx, pos)
        end,
        GetClientId = function(ctx)
            return C.ValkeyModule_GetClientId(ctx)
        end,
        Call = function(ctx, cmdname, fmt, ...)
            local narg = select("#", ...)
            local reply = C.ValkeyModule_Call(ctx, cmdname, fmt, ...)
            return reply
        end,
    }
})


-- Gets the current VKM.Ctx
VKM.EvalCtx = function()
    return VKM_LJ.VKM_LJ_GetEvalContext()
end

-- Module-level functions
VKM.IsModuleNameBusy = function(name)
    return C.ValkeyModule_IsModuleNameBusy(name)
end

-- int (*ValkeyModule_GetOpenKeyModesAll)(void);


-- Return ValkeyModule Lua API
return VKM
