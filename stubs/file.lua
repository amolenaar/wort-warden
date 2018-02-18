-- # Stub implementation for NodeMCU file module
--
-- file.exists()	Determines whether the specified file exists.
-- file.open()		Opens a file for access, potentially creating it (for write modes).
-- file.obj:read()	Read content from the open file.
-- file.obj:write()	Write a string to the open file.
-- file.obj:close()	Closes the open file, if any.
--
-- ## Not implemented:
-- file.chdir()		Change current directory (and drive).
-- file.format()	Format the file system.
-- file.fscfg ()	Returns the flash address and physical size of the file system area, in bytes.
-- file.fsinfo()	Return size information for the file system.
-- file.list()		Lists all files in the file system.
-- file.mount()		Mounts a FatFs volume on SD card.
-- file.on()		Registers callback functions.
-- file.remove()	Remove a file from the file system.
-- file.rename()	Renames a file.
-- file.stat()		Get attribtues of a file or directory in a table.
-- file.close(),
-- file.flush(),
-- file.obj:flush()	Flushes any pending writes to the file system, ensuring no data is lost on a restart.
-- file.read(),
-- file.readline(),
-- file.obj:readline()	Read the next line from the open file.
-- file.seek(),
-- file.obj:seek()	Sets and gets the file position, measured from the
--			beginning of the file, to the position given by offset
--			plus a base specified by the string whence.
-- file.write(),
-- file.writeline(),
-- file.obj:writeline()	Write a string to the open file and append '\n' at the end.

local file = {}

function file.exists(filename)
   local f = io.open(filename, "r")
   if f ~= nil then
     io.close(f)
     return true
   else
     return false
   end
end

function file.open(filename, mode)
  local f = io.open(filename, mode)
  return f
end

function file.fsinfo()
  local remaining, used = 1234, 343
  return remaining, used, remaining + used
end

return file
