//  ================================================================================================
//   * File Name:    ProtoOneDebugMenu
//   * Created By:   Hami
//   * Time Stamp:     2/7/2014 2:41:16 PM
//   * UDK Path:   C:\UDK\WhalefallStudios
//   * Unreal X-Editor v3.1.4.0
//   * © Copyright 2012 - 2014. All Rights Reserved.
//  ================================================================================================

class ProtoOneDebugMenu extends CheatManager within PlayerController;


//a single debug command
struct ProtoOneDebugCommand
{
    var string CMDName;      // the command display name
    var string Command;      //the command
};

//Debug commands are grouped py "pages"
struct ProtoOneDebugCommandPage
{
    var string PageName;     // page display name
    var array <ProtoOneDebugCommand> PageCommands; //the list of commands
};

//properties
var array<ProtoOneDebugCommandPage> Pages;
var int CurrentPage;
var int CurrentIndex;
var bool bShowDebugMenu;


///////////////// Menu Input Functions \\\\\\\\\\\\\\\\\\\\
exec function ToggleDebugMenu()
{
    `log("Entered ToggleDebugMenu");
    CurrentIndex = 0;
    CurrentPage = -1;
    bShowDebugMenu = !bShowDebugMenu;
 
    SetCinematicMode(bShowDebugMenu,false,false,true,true,true);
}
 
exec function NextMenuItem()
{
    local int maxIndex;
 
    if (bShowDebugMenu)
    {
        //Only do stuff when we actually are in the menu.
        if (CurrentPage != -1)
        {
            maxIndex = Pages[CurrentPage].PageCommands.Length-1;
        }
        else
        {
            maxIndex = Pages.Length-1;
        }
 
        CurrentIndex = Min(CurrentIndex +1, maxIndex);
    }
}
 
exec function PreviousMenuItem()
{
    if (bShowDebugMenu)
    {
        CurrentIndex = Max(CurrentIndex -1, 0);
    }
}
 
exec function DoDebugCommand()
{
    local ProtoOneDebugCommand command;
 
    if (bShowDebugMenu)
    {
        if (CurrentPage != -1)
        {
            //Leave the menu and execute the selected command
            command = Pages[CurrentPage].PageCommands[CurrentIndex];
            ToggleDebugMenu();
            ConsoleCommand(command.Command);
        }
        else
        {
            //Change page
            CurrentPage = CurrentIndex;
            CurrentIndex = 0;
        }
    }
}
 
exec function DebugMenuBack()
{
 
    if (bShowDebugMenu)
    {
        if (CurrentPage != -1)
        {
            //Get back to the top level.
            CurrentPage = -1;
            CurrentIndex = 0;
        }
        else
        {
            //We're at the top level: leave
            ToggleDebugMenu();
        }
    }
}


///////// Menu Drawing Functions \\\\\\\\\\\\\\\\
function DrawDebugMenu(HUD H)
{
    local float XL, YL, YPos;
    local ProtoOneDebugCommand command;
    local ProtoOneDebugCommandPage page;
    local int array_index;
    local Color command_color;
 
    if (bShowDebugMenu)
    {
        H.Canvas.Font = class'Engine'.Static.GetLargeFont();
        H.Canvas.StrLen("X", XL, YL);
        YPos = 0;
        H.Canvas.SetPos(0,0);
        H.Canvas.SetDrawColor(10,10,10,128);
        H.Canvas.DrawRect(H.Canvas.SizeX,H.Canvas.SizeY); //Adding a dark overlay to visually notify we're in the menu.
 
        if (CurrentPage == -1)
        {
            ProtoOneHUD(H).DrawTextSimple("Debug Menu",vect2d(0,YPos), H.Canvas.Font,H.WhiteColor);
            YPos += YL;
 
            foreach Pages(page,array_index)
            {
                if (array_index == CurrentIndex)
                {
                    command_color = H.GreenColor;
                }
                else
                {
                    command_color = H.WhiteColor;
                }
 
                ProtoOneHUD(H).DrawTextSimple(array_index$":"@page.PageName,vect2d(0,YPos), H.Canvas.Font,command_color);
                YPos += YL;
            }
        }
        else
        {
            page = Pages[CurrentPage];
            ProtoOneHUD(H).DrawTextSimple("Debug Menu - "$page.PageName,vect2d(0,YPos), H.Canvas.Font,H.WhiteColor);
            YPos += YL;
 
            foreach page.PageCommands(command,array_index)
            {
                //I know, I could have put that in a function as the body of the loop is the same as above.
 
                if (array_index == CurrentIndex)
                {
                    command_color = H.GreenColor;
                }
                else
                {
                    command_color = H.WhiteColor;
                }
 
                ProtoOneHUD(H).DrawTextSimple(array_index$":"@command.CmdName,vect2d(0,YPos), H.Canvas.Font,command_color);
                YPos += YL;
            }
        }
    }
}

defaultproperties
{
    bShowDebugMenu=false
    CurrentPage=-1
    CurrentIndex=0
    Pages(0)=(PageName="General",PageCommands[0]=(CmdName="Toggle Debug Camera",Command="ToggleDebugCamera"))
    Pages(1)=(PageName="Debug Info",PageCommands[0]=(CmdName="Turn off Debug Info",Command="showdebug none"),PageCommands[1]=(CmdName="Toggle Pawn Debug Info",Command="showdebug pawn"),PageCommands[2]=(CmdName="Toggle Camera Debug Info",Command="showdebug camera"),PageCommands[3]=(CmdName="Toggle Pawn Weapon Info",Command="showdebug weapon"))
    Pages(2)=(PageName="HUD",PageCommands[0]=(CmdName="Toggle Player HUD",Command="ToggleHUD"))
    //Pages(3)=(PageName
    
}





















