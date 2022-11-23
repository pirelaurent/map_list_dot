# run test 
In terminal , go to test directory    
for me:  "pirla@MacBook-Pro map_list_dot % cd test" .  
Type in: dart *anyTestFileName.dart*   
## Comfort with a shortcut  
For more comfort, you can add a key into *keybindings.json*    
**command Shift P**    
-> Open keyboard shortcuts    
edit keybindings.json to add :    
``` js 
[
    {
        "key": "ctrl+shift+t",
        "command": "workbench.action.terminal.sendSequence",
        "args": { "text": " ${fileBasename} " },
        "when": "terminalFocus"
      }
]
```

This command will give you the current active file in editor.    
So when looking at some test code like  *1_checkNull_test.dart*  
In terminal type :   
dart *ctrl shift t*   
and you will run the current test    
 *dart 1_checkNull_test.dart*

# run examples 
Same thing :  go to the example directory   
type in the desired example :    
*dart example1.dart* 

Or, using the keybord shortcut :   
Edit the example in editor  
type in terminal:    
*dart ctrl shif t*   
This will run the current sample in editor.   


HTH



