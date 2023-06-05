# Paint 3D Project Manager
## How to use:
When you open the program for the first time, it'll take you to a page with all of your projects. (If it takes you to a window dialogue, just choose your "Projects.json" file)

## Exporting
1. Choose the project(s) that you'd like to export (you can select multiple using the checkboxes next to the buttons)
2. Press the "Export" button
3. Press "Yes"
4. Wait for it to finish exporting (This may take awhile depending on the size of the project(s))
5. Save the file (make sure to include the .p3d extention to the filename!)

## Importing
1. Press the "Import" button
2. Choose the p3d file you would like to import
3. Wait for it to finish importing (This may take awhile depending on the size of the project(s))
4. Open Paint 3D to see the project!

## Troubleshooting/Q&A
### I cant find my Projects.json!
Press the "Appdata Path" on the main menu, then copy the file path. 
Then, press "Change Projects.json" and paste it into the file dialouge.

### I don't have a Projects.json!
Open paint 3d and make a project, that should create a Projects.json for you.

### I got a "Missing Files" error!
That usually means the P3D file does not have all the necessary files, and may softlock your Paint 3D (this is recoverable)

It is still possible to continue importing, but i _highly_ discourage it. Try asking the person you got it from for a new export of the project.

### My Paint 3D crashes on startup after importing the project!
Delete the project you imported in P3DPM, and ask for a new one from the person you got it from.

### How do I know how much time is left on an Import/Export?
Check your Discord Rich Presence, it should say the files/projects remaining under there (don't question it)

### All of my projects in Paint 3D are gone!
Go to `%localappdata%\Packages\Microsoft.MSPaint_8wekyb3d8bbwe\LocalState\.Bak` and copy the json with the highest number (eg: Projects.json.bak6), then replace the Projects.json with the file you copied (make sure to name it exactly the same!) 

If your projects are still gone, keep doing this same method but with the 2nd highest, then 3rd highest, and so on. checking each time you replace it to see if your projects have come back or not

If you've done all of that, or your .Bak folder is missing. Press CTRL + R and hit yes to rebuilding your Projects.json (WARNING: I WOULD HIGHLY RECCOMEND MANUALLY BACKING UP YOUR PROJECTS BEFORE DOING THIS AND PLACING IT SOMEWHERE SAFE!!)

### Theres a bunch of duplicate folders in my projects folder!
On the main menu, press `R` and hit yes to delete all projects that are not linked to a folder. (WARNING: This will delete _ALL_ folders that are in the same directory of your Projects.json (except for .Bak) that are not linked to a project)

### My issue isn't listed here!
Please make a new issue under the "Issues" tab, or contact me on [discord (silkycell#1337)](https://discordapp.com/users/302271402277339146)/[twitter](https://twitter.com/silkycell)


# Credits:
Icon by [stev](https://twitter.com/weeweecrease)
