# Screen Debugger

This is a plugin which enables the user to show their variables in-game. You can see the variables changing on-screen instead of printing them into console...

## How to use

* Copy the extracted folder to your proyect
* Enable the plugin (in the proyect config)
* Make sure the singleton is the first one in the list

* In any script at "process" function type:

```
var life = 10

_process(delta):
    ScreenDebugger.dict["Life"] = life

```

Original plugin (1.0 version) made by nonunknown. Fork by Danny Garay (2.0 version).
