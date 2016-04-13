# TagRenamer

UnrealEd plugin, renames multiple tags in multiple objects.

Renaming tags in multiple objects is both error-prone and time-intensive.
TagRenamer scans selected actors for variables containing tags and performs one
of the actions below on tags found in selected actors.

## Actions: 
- list tag names
- rename tag names
- add constant random postfix to all tag names
- make all tag names unique
- remove added postfixes
 

##  Install

### Requirements:
- Unreal Engine 2, tested on UT2004 and UE2 Runtime


### Automatic Install:
- UT2004 Only!
- Run the TagRenamer.ut4mod file.

### Manual Install: 
- Extract the TagRenamer folder to your main game folder (ie: /UT2004/).
- Run Game\TagRenamer\Install.bat.


## Help

### How to run the plugin:
- To run the plugin click on TagRenamer icon.
- The icon is located in the vertical toolbar, just below brush builders.
- The icon looks like trigger box with "REN" written on it.


### Example: List custom tags
- Select actors
- Start the plugin

### Example: Isolate tag/event relationships
- Suppose you duplicated actors with custom tag/event relationships and want to 
  be sure that original objects wont trigger duplicated objects. There are two 
  ways to do that with TagRenamer:
  
1. Fast and dirty.
  * Select actors
  * Select in TagRenamer options action A_AddPostfix
  * Start the plugin
    > Random postfix will be generated and added to all tags.
    
1. Slower but pretty.
  * Select actors
  * Select in TagRenamer options action A_List
  * Start the plugin
    > Tag names will be listed in tag window
  * Select in TagRenamer options action A_Rename
  * Enter names you want to rename and new names in TagRenamer Options
  * Start the plugin
    > Only the tags you chosen will be renamed
    > There is full control over new tag names


## Options:
- Options can be accessed by right-clicking the icon.
- [Action] = Plugin action, see below.
- [bNoSingle] = Tag will be ignored if it was found in only one variable.
- [bNoDefault] = Tag will be ignored if it has default name (class name).
- [Names] = Action A_Rename requires that you specify tag names here. 
  * [Old] is the name you want to replace.
  * [New] is what it will be replaced with.
  
  
## How it works:
- TagRenamer uses a list of known tag variables in actors.
- The list is in Game\System\TagRenamer.ini file, you can modify it.
- Each selected actor is scanned for known tag variables names.
- If tag variable is found and contains a value, it's added to internal list.
- Once all actors are scanned, chosen action is performed on all found tags. 
  
  
### Action [List]:
- Default action
- Tag variables are listed in log window, grouped by tag name.

### Action [Rename]:
- Renames tags in multiple variables & objects.
- To use this action you have to specify tag names in options.

### Action [AddPostfix]:
- This action will generate one random postfix and add it to all tags.
- Tag/event links among selected actors are preserved.
- Tag/event links with unselected actors are destroyed.
- If tag name already has random postfix, it's stripped before adding new.

### Action [AddUnique]:
- This action will generate random postfix for each tag.
- Tag/event links among selected actors are destroyed.
- Tag/event links with unselected actors are destroyed.
- If tag name already has random postfix, it's stripped before adding new.

### Action [MakeNormal]:
- This action strips postfixes added by action AddPostfix and AddUnique from
  tag names.


### Limitations:
- There is a very very small chance that non-unique postfix will be generated.
- Only basic variables can be scanned for tags, things like arrays of tags or 
  special structures are not supported. 
- The random postfix can be stripped by action MakeNormal, AddUnique or 
  AddPostfix only if:
  * nothing was added to tagname after postfix 
  * postfix wasn't resized
  * the "_ID" postfix identifier wasn't modified
  * first number of postfix wasn't changed to 0

 
##  Uninstall

### Automatic Uninstall:
- Available only if installed with TagRenamer.ut4mod
- Run UT2004\System\Setup.exe
- Select TagRenamer and click next.

### Manual Uninstall:
- Run Game\TagRenamer\Uninstall.bat.
 
