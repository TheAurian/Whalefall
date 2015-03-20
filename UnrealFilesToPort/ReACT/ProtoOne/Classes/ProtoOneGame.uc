class ProtoOneGame extends GameInfo;

var ProtoOneGameCamera mainCamera;
var TierrasAI tierra;

DefaultProperties
{
    bDelayedStart=false
    PlayerControllerClass=class'ProtoOne.ProtoOnePlayerController'
    DefaultPawnClass=class'ProtoOne.ProtoOnePawn'
    
    Name="Default_ProtoOneGameInfo"
}
/*
exec function ShowPauseMenu()
{
    ConsoleCommand("open startMenu");
}
*/

