VERSION = "2.1.0"

treeView = nil
cwd = WorkingDirectory()
isWin = (OS == "windows")

-- Uncomment to enable debugging
function debug(log)
    -- messenger:AddLog(log)
end

-- ToggleTree will toggle the tree view visible (create) and hide (delete).
function ToggleTree()
    debug("***** ToggleTree() *****")
    if treeView == nil then
        OpenTree()
    else
        CloseTree()
    end
end

-- OpenTree setup's the view
function OpenTree()
    debug("***** OpenTree() *****")
    CurView():VSplitIndex(NewBuffer("", "FileManager"), 0)
    setupOptions()
    refreshTree()
end

-- setupOptions setup tree view options
function setupOptions()
    debug("***** setupOptions() *****")
    treeView = CurView()
    treeView.Width = 30
    treeView.LockWidth = true
    -- set options for tree view
    status = SetLocalOption("ruler", "false", treeView)
    if status ~= nil then messenger:Error("Error setting ruler option -> ",status) end
    status = SetLocalOption("softwrap", "true", treeView)
    if status ~= nil then messenger:Error("Error setting softwrap option -> ",status) end
    status = SetLocalOption("autosave", "false", treeView)
    if status ~= nil then messenger:Error("Error setting autosave option -> ", status)  end
    status = SetLocalOption("statusline", "false", treeView)
    if status ~= nil then messenger:Error("Error setting statusline option -> ",status) end
    status = SetLocalOption("scrollbar", "false", treeView)
    if status ~= nil then messenger:Error("Error setting scrollbar option -> ",status) end
    -- TODO: need to set readonly in view type.
    tabs[curTab+1]:Resize()
end

-- CloseTree will close the tree plugin view and release memory.
function CloseTree()
    debug("***** CloseTree() *****")
    if treeView ~= nil then
        treeView.Buf.IsModified = false
        treeView:Quit(false)
        treeView = nil
    end
end

-- refreshTree will remove the buffer and load contents from folder
function refreshTree()
    debug("***** refreshTree() *****")
    treeView.Buf:remove(treeView.Buf:Start(), treeView.Buf:End())

    -- Refresh the view to show the current dirs/files
    refresh_view(cwd)

end

-- returns currently selected line in treeView
function getSelection()
    -- -1 to conform to Go's zero-based indicies
    local selection = treeView.Buf:Line(treeView.Buf.Cursor.Loc.Y)
    messenger:AddLog("***** getSelection() ---> ", selection)
    -- Returns the string in [y] index from the buffer
    return selection
end

-- don't use built-in view.Cursor:SelectLine() as it will copy to clipboard (in old versions of Micro)
-- TODO: We require micro >= 1.3.2, so is this still an issue?
function selectLineInTree(view)
    if view == treeView then
        debug("***** selectLineInTree() *****")
        local y = view.Cursor.Loc.Y
        view.Cursor.CurSelection[1] = Loc(0, y)
        view.Cursor.CurSelection[2] = Loc(view.Width, y)
    end
end

-- 'beautiful' file selection:
function onCursorDown(view) selectLineInTree(view) end
function onCursorUp(view)   selectLineInTree(view) end

-- mouse callback from micro editor when a left button is clicked on your view
function preMousePress(view, event)
    if view == treeView then  -- check view is tree as only want inputs from that view.
         local columns, rows = event:Position()
         debug("INFO: --> Mouse pressed -> columns location rows location -> ",columns,rows)
         return true
    end
end
function onMousePress(view, event)
    if view == treeView then
        selectLineInTree(view)
        preInsertNewline(view)
        return false
    end
end


-- disallow selecting topmost line in treeView:
function preCursorUp(view)  
    if view == treeView then
        debug("***** preCursor() *****")
        if view.Cursor.Loc.Y == 1 then
            return false
end end end

-- allows for deleting files
function preDelete(view)
    if view == treeView then
        if debug == true then messenger:AddLog("***** preDelete() *****") end
        local selected = getSelection()
        if selected == ".." then return false end
        
        local type = "file"
        if isDir(selected) then
            type = "dir"
        end

        -- Use the full path instead of relative.
        selected = JoinPaths(cwd, selected)
        
        local yes, cancel = messenger:YesNoPrompt("Do you want to delete the " .. type .. " '" .. selected .. "'? ")
        if not cancel and yes then
          -- Use Go's os.Remove to delete the file
          local go_os = import("os")
          go_os.Remove(selected)
          refreshTree()
        end
        -- Clears messenger:
        messenger:Reset()
        messenger:Clear()
        return false -- don't "allow" delete
    end
end


-- When user presses enter then if it is a folder clear buffer and reload contents with folder selected.
-- If it is a file then open it in a new vertical view
function preInsertNewline(view)
    if view == treeView then
        debug("***** preInsertNewLine()  *****")
        local selected = getSelection()
        if view.Cursor.Loc.Y == 0 then
            return false -- topmost line is cwd, so disallowing selecting it
        elseif isDir(selected) then  -- if directory then reload contents of tree view
            cwd = JoinPaths(cwd, selected)
            refreshTree()
        else  -- open file in new vertical view
            local filename = JoinPaths(cwd, selected)
            CurView():VSplitIndex(NewBuffer("", filename), 1)
            CurView():ReOpen()
            tabs[curTab+1]:Resize()
        end
        return false
    end
    return true
end

-- don't prompt to save tree view
function preQuit(view)
    if view == treeView then
        debug("***** preQuit() *****")
        view.Buf.IsModified = false
        treeView = nil
    end
end
function preQuitAll(view) treeView.Buf.IsModified = false end

local function insert_to_view(loc_struct, content, concat_newline)
  if concat_newline then
    content = content .. "\n"
  end
  treeView.Buf:Insert(loc_struct, content)
end

-- refresh_view will scan contents of the directory passed and fill the view with them
function refresh_view(directory)
  messenger:AddLog("***** refresh_view(directory) ---> ", directory)

  local go_ioutil = import("ioutil")
  -- Gets a list of all the files in the current dir
  local readout = go_ioutil.ReadDir(directory)

  if readout == nil then
    messenger:Error("Error reading directory: ", directory)
  else
    -- Passed to insert_to_view() to tell it whether or not to concat a newline
    local use_newline = true

    -- Insert the dir and ".." before anything else
    insert_to_view(Loc(0, 0), directory, use_newline)
    insert_to_view(Loc(0, 1), "..", use_newline)
  
    local readout_name = ""
    -- Loop through all the files/directories in current dir
    for i = 1, #readout do
      -- Save the current dir/file name
      readout_name = readout[i]:Name()
      -- Check if the current file is a dir
      if isDir(readout_name) then
        -- Add on a slash to signify the listing is a directory
        -- Shouldn't cause issues on Windows, as it lets you use either slash type
        readout_name = readout_name .. "/"
      end

      -- Check if we're on the last line
      if i == #readout then
        -- Don't use a newline on the last insert
        use_newline = false
      end

      -- Insert the current file/dir to buffer
      -- +1 to skip the first two positions that hold the dir & ".."
      insert_to_view(Loc(0, i + 1), readout_name, use_newline)
    end
  end
end

-- isDir checks if the path passed is a directory.
-- return true if it is a directory else false if it is not a directory.
function isDir(path)
  debug("***** isDir(path) ---> ", path)

  local go_os = import("os")

  local check_path = JoinPaths(cwd, path)

  -- Returns a FileInfo on the current file/path
  local file_info = go_os.Stat(check_path)

  if file_info ~= nil then
    -- Returns the true/false of if the file is a directory
    return file_info:IsDir()
  else
    messenger:AddLog("isDir() failed, returning nil")
    return nil
  end
end

-- micro editor commands
MakeCommand("tree", "filemanager.ToggleTree", 0)
AddRuntimeFile("filemanager", "syntax", "syntax.yaml")
