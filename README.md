valkey-mod_luajit
=================

[Valkey](https://valkey.io) Module adding LuaJIT support

*This is very unstable! It also depends on Valkey built without Lua.  This [support is in progress](https://github.com/valkey-io/valkey/issues/1204). *

Install
=======

Dependencies:

 * cmake
 * a C compiler
 * luajit-2.1
 * Valkey 8.0

```
cd valkey-mod_luajit
cmake .
make

# install files to system paths
sudo cp valkeymodule.lua /usr/local/share/lua/5.1/
sudo cp libvalkey-mod_luajit.so /usr/local/lib
```

Example
=======

Here's an example of loading the module, and invoking a simple reply, and registering a new Valkey command using LuaJIT FFI callbacks.

```
# start valkey with modules enabled
$ echo 'enable-module-command yes' | valkey-server -

# must use Valkey valkey-cli
$ valkey-cli
172.0.0.1:6379> module load /usr/local/lib/libvalkey-mod_luajit.so
172.0.0.1:6379> luajit.eval "VKM.EvalCtx():ReplyWithSimpleString('hello from LuaJIT')"
hello from LuaJIT
127.0.0.1:6379> luajit.eval "VKM.EvalCtx():CreateCommand('hello.lua', function(ctx,argv,argc) print('hello world', argc) ; return ctx:ReplyWithLongLong(420) ; end,'',1,1,1) ; VKM.EvalCtx():ReplyWithLongLong(2)"
(integer) 2
127.0.0.1:6379> hello.lua
(integer) 420
[and you should see 'hello world    1' in the valkey.log]
```

TODO
====

 * fill out the implementation
 * add LUAJIT.EVALSHA and maybe some other SCRIPT-like methods
 * think of configuration
 * think of helpers (like Call wrappers? auto-reply)
 * more bulletproofing
 * more examples
 * change the name depending on what module naming conventions people come up with


Backstory
=========

In 2013, I spent some time exploring deeper integration of [LuaJIT with Redis 2.6](https://github.com/redis/redis/compare/unstable...neomantra:redis:luajit_ffi).  My beef was that the existing Lua Scripting does so much marshalling and other work that might not be needed.  As I dove in, I reallized what I was making was low-level wrappers around Redis internals.  I gave up after a while because I knew it would never be merged.

In 2016, @antirez released a preview of the [Redis Module API](https://github.com/antirez/redis/blob/unstable/src/modules/INTRO.md).  It was basically what I wanted before, so I am starting to explore the ideas again.

In 2024, Valkey enabled the removal of the statically-linked Lua engine, allowing the creation of a LuaJIT-injecting Valkey module.   Since it's possible, it makes sense to update the project to use the [Valkey Module API](https://valkey.io/topics/modules-api-ref/).  Note that this is not equivalient to Valkey's [Lua Scripting](https://valkey.io/topics/eval-intro/) in that **it is not sandboxed**.

License
=======

BSD-licensed, just like Redis and Valkey. See the file `COPYING`.

```
Copyright (c) 2016-2024, Evan Wies. evan@neomantra.net

All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of Redis nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```
