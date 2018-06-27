-- This file is automatically referenced via init_by_lua_file when present:
--  https://github.com/openresty/lua-nginx-module#init_by_lua_file

-- Load a Lua module for handling gzipped responses in body_filter_by_lua
gz = require("sectionio.gzip")

-- Optionally change the default sectionio.gzip compression level with:
-- gz.compression_level = 6 -- valid values are 1 through 9

-- Configure `require()` to find custom Lua modules
package.path = package.path .. ";/opt/proxy_config/?.lua"
