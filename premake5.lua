--[[
    MIT License

    Copyright (c) 2016-2023 Raúl Ramos

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
--]]


--[[
    =================================================
    The Workspace
    =================================================
--]]

workspace "get_pdb_id"

    -- Language & compiler settings

	language          "C++"
	cppdialect        "C++17"
    warnings          "extra"
    flags             { "FatalCompileWarnings", "FatalLinkWarnings" }
    exceptionhandling "off"

    -- Folders

    location ".build" -- Here will live all the projects/solutions (VS, XCode, etc.)

    -- Targets

    configurations { "debug", "release" }
    platforms      { "x64" }
    filter         { "configurations:debug"   } defines { "DEBUG" } symbols  "On" 
    filter         { "configurations:release" } defines { "NDEBUG" } optimize "Speed" 
    filter         { "platforms:*64"          } architecture "x86_64"
    filter         { "platforms:*86"          } architecture "x86"

    -- Misc setup

    toolset "msc" -- we can use "clang" too

    -- Startup

    startproject "get_pdb_id"

--[[
    =================================================
    The library
    =================================================
--]]

project "get_pdb_id"

    -- Type

    kind "ConsoleApp"

    -- Compiler

    includedirs { "C:\\Program Files (x86)\\Microsoft Visual Studio\\2019\\Community\\DIA SDK\\include" }

    -- Target

    targetdir   ".out/%{cfg.platform}/%{cfg.buildcfg}"
    objdir      ".tmp/%{prj.name}"

    -- Debugging

    debugdir "%{prj.location}/.." -- We debug from the root of the repo

    -- Dependencies

    -- libdirs { "libs/%{cfg.shortname}/" }

    links { 
        -- "websockets_static",
        -- "Ws2_32"
    }

    files { "src/**" }

--[[
    =================================================
    Prevent Dropbox from synchronising hidden folders
    =================================================
--]]

print("[] Excluding .build, .tmp and .out from Dropbox sync...");

if os.target() == "windows" then

    -- Do not allow Dropbox to sync these temporary folders

    local script = [[
        New-Item .build    -type directory -force | Out-Null
        New-Item .tmp      -type directory -force | Out-Null
        New-Item .out      -type directory -force | Out-Null
        Set-Content -Path '.build' -Stream com.dropbox.ignored -Value 1
        Set-Content -Path '.tmp'   -Stream com.dropbox.ignored -Value 1
        Set-Content -Path '.out'   -Stream com.dropbox.ignored -Value 1
    ]]

    -- Feed the script to powershell process stdin

    local pipe = io.popen("powershell -command -", "w")
    pipe:write(script)
    pipe:close()

elseif os.target() == "macosx" then

    -- Do not allow Dropbox to sync these temporary folders

    local script = [[
        mkdir -p .build
        mkdir -p .tmp
        mkdir -p .out
        xattr -w com.dropbox.ignored 1 .build
        xattr -w com.dropbox.ignored 1 .tmp
        xattr -w com.dropbox.ignored 1 .out
    ]]

    -- Run the script

    local pipe = io.popen("bash", "w")
    pipe:write(script)
    pipe:close()

end

