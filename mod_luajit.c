#include <stdio.h>
#include <luajit-2.1/lua.h>
#include <luajit-2.1/lualib.h>
#include <luajit-2.1/lauxlib.h>
#include "valkeymodule.h"

/// LuaJIT state shared by module
lua_State* VKM_LJ_state = NULL;

/// The ValkeyModuleContext in active use by EVAL
ValkeyModuleCtx* VKM_LJ_evalCtx = NULL;

/// Index of the pcall handler (which creates a traceback)
int VKM_LJ_pcallHandlerIndex;

/// Buffer we use for formatting error messages
char VKM_LJ_errorBuffer[2048];


// http://stackoverflow.com/questions/12256455/print-stacktrace-from-c-code-with-embedded-lua
static int traceback(lua_State *L) {
  if (!lua_isstring(L, 1))  /* 'message' not a string? */
    return 1;  /* keep it intact */
  lua_getfield(L, LUA_GLOBALSINDEX, "debug");
  if (!lua_istable(L, -1)) {
    lua_pop(L, 1);
    return 1;
  }
  lua_getfield(L, -1, "traceback");
  if (!lua_isfunction(L, -1)) {
    lua_pop(L, 2);
    return 1;
  }
  lua_pushvalue(L, 1);  /* pass error message */
  lua_pushinteger(L, 2);  /* skip this function and traceback */
  lua_call(L, 2, 1);  /* call debug.traceback */
  return 1;
}


// hook for the lua_State to extract the current context
extern ValkeyModuleCtx* VKM_LJ_GetEvalContext(void) {
    return VKM_LJ_evalCtx;
}


/* LUAJIT.EVAL script
 * 
 */
int LuajitEval_ValkeyCommand(ValkeyModuleCtx *ctx, ValkeyModuleString **argv, int argc)
{
    if (argc != 2)
        return ValkeyModule_WrongArity(ctx);

    size_t len;
    const char* script = ValkeyModule_StringPtrLen(argv[1], &len);
    if (!script) 
        return ValkeyModule_ReplyWithError(ctx, "LUAJIT.EVAL: script was null");

    int res = luaL_loadstring(VKM_LJ_state, script);
    if (res != 0) {
        snprintf(VKM_LJ_errorBuffer, sizeof(VKM_LJ_errorBuffer)-1,
                 "LUAJIT.EVAL luaL_loadstring failed: %d %s\n", res, lua_tostring(VKM_LJ_state, -1));
        lua_pop(VKM_LJ_state, 1);
        return ValkeyModule_ReplyWithError(ctx, VKM_LJ_errorBuffer);
    }

    // store the context for the LuaJIT world
    VKM_LJ_evalCtx = ctx;

    res = lua_pcall(VKM_LJ_state, 0, LUA_MULTRET, VKM_LJ_pcallHandlerIndex);
    if (res != 0) {
        snprintf(VKM_LJ_errorBuffer, sizeof(VKM_LJ_errorBuffer)-1,
                 "LUAJIT.EVAL lua_pcall failed: %d %s\n", res, lua_tostring(VKM_LJ_state, -1));
        lua_pop(VKM_LJ_state, 1);
        VKM_LJ_evalCtx = NULL;
        return ValkeyModule_ReplyWithError(ctx, VKM_LJ_errorBuffer);
    }

    // TODO see if the EVAL script made a reply?  is that possible?
    VKM_LJ_evalCtx = NULL;
    return VALKEYMODULE_OK;
}


extern int ValkeyModule_OnLoad(ValkeyModuleCtx *ctx) {
    // register our module
    if (ValkeyModule_Init(ctx,"luajit",1,VALKEYMODULE_APIVER_1) == VALKEYMODULE_ERR)
        return VALKEYMODULE_ERR;

    // create the shared lua_State
    if (!VKM_LJ_state) {
        VKM_LJ_state = luaL_newstate();
        if (!VKM_LJ_state) {
            printf("mod_luajit: failed to load Lua state\n");
            return VALKEYMODULE_ERR;
        }

        // load the libraries
        // TODO: make this configurable for better sandboxing
        lua_pushcfunction(VKM_LJ_state, luaopen_base);
        lua_call(VKM_LJ_state,0,0);
        lua_pushcfunction(VKM_LJ_state,luaopen_os);
        lua_call(VKM_LJ_state,0,0);
        lua_pushcfunction(VKM_LJ_state,luaopen_table);
        lua_call(VKM_LJ_state,0,0);
        lua_pushcfunction(VKM_LJ_state,luaopen_string);
        lua_call(VKM_LJ_state,0,0);
        lua_pushcfunction(VKM_LJ_state,luaopen_math);
        lua_call(VKM_LJ_state,0,0);
        lua_pushcfunction(VKM_LJ_state,luaopen_debug);
        lua_call(VKM_LJ_state,0,0);
        lua_pushcfunction(VKM_LJ_state, luaopen_package);
        lua_call(VKM_LJ_state,0,0);
        lua_pushcfunction(VKM_LJ_state, luaopen_ffi);
        lua_call(VKM_LJ_state,0,0);
        lua_pushcfunction(VKM_LJ_state, luaopen_jit);
        lua_call(VKM_LJ_state,0,0);
        lua_pushcfunction(VKM_LJ_state, luaopen_bit);
        lua_call(VKM_LJ_state,0,0);

        // install error pcall handler
        lua_pushcfunction(VKM_LJ_state, traceback);
        VKM_LJ_pcallHandlerIndex = lua_gettop(VKM_LJ_state);

        // load the VALKEYMODULE library
        lua_getfield(VKM_LJ_state, LUA_GLOBALSINDEX, "require");
        lua_pushstring(VKM_LJ_state, "valkeymodule");
        int res = lua_pcall(VKM_LJ_state, 1, 1, VKM_LJ_pcallHandlerIndex);
        if (res != 0) {
            printf("valkey-mod_luajit require 'valkeymodule' failed: %d %s\n", res, lua_tostring(VKM_LJ_state, -1));
            lua_pop(VKM_LJ_state, 1);
            return VALKEYMODULE_ERR;
        }
        lua_setfield(VKM_LJ_state, LUA_GLOBALSINDEX, "VKM");
    }

    // register commands
    if (ValkeyModule_CreateCommand(ctx,"luajit.eval",LuajitEval_ValkeyCommand,"",1,1,1) == VALKEYMODULE_ERR)
        return VALKEYMODULE_ERR;

    return VALKEYMODULE_OK;
}


// TODO ValkeyModule_UnLoad(ValkeyModuleCtx *ctx)
