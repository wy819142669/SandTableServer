package lua

import (
	"os"
)

var CompatVarArg = true
var FieldsPerFlush = 50
var RegistrySize = 256 * 20
var CallStackSize = 256
var MaxTableGetLoop = 100
var MaxArrayIndex = 67108864

type LNumber float64
type LInteger int64

const LNumberBit = 64
const LNumberScanFormat = "%f"

const LIntegerBit = 64
const LIntegerScanFormat = "%ld"

const LuaVersion = "Lua 5.1"

var LuaPath = "LUA_PATH"
var LuaLDir string
var LuaPathDefault string
var LuaOS string

func init() {
	if os.PathSeparator == '/' { // unix-like
		LuaOS = "unix"
		LuaLDir = "/usr/local/share/lua/5.3"
		LuaPathDefault = "./?.lua;" + LuaLDir + "/?.lua;" + LuaLDir + "/?/init.lua"
	} else { // windows
		LuaOS = "windows"
		LuaLDir = "!\\lua"
		LuaPathDefault = ".\\?.lua;" + LuaLDir + "\\?.lua;" + LuaLDir + "\\?\\init.lua"
	}
}
