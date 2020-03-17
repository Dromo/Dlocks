# Dlocks
Tracking dailies across servers

<pre>
Command line utility for lotro to track dailies on alts/servers.

/dlocks setserver 'servername'  -- have to do first time on each server
/dlocks add                     -- add currently logged character 
/dlocks remove 'char' 'server'  -- remove character on server
/dlocks reset                   -- Simulate thursday reset - have to do manualy so far
/dlocks reset sunday            -- Simulate sunday reset - have to do manualy so far
/dlocks show                    -- print current progress

/dlocks set 'quests' 'instances' 'scourges' -- set progress eg. /dlocks set 10 4 8

/dlocks set 'variable' 'value'   -- set tracking variable to value (advanced)

value meaning for tracker quests is 0 - dont have quest, 1 - quest in progress, 2 - quest finished
variables to set {rako,embers,task,quests,instances,scourges,questsn,instancesn,scourgesn}

If the plugin is loaded on login for a character, most of the time only performing resets on thursday/sunday is needed.

Warning: Quest completion and Deed completion produce same chat lines, 
due to this plugin ignores when line is same as last seen, which could in some cases cause discrepancy.
</pre>
