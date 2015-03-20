class ProtoOneGame extends GameInfo;

DefaultProperties
{
	bDelayedStart=false
	PlayerControllerClass=class'ProtoOne.ProtoOnePlayerController'
	DefaultPawnClass=class'ProtoOne.ProtoOnePawn'
	
	Name="Default_ProtoOneGameInfo"
}

exec function ShowPauseMenu()
{
	ConsoleCommand("open startMenu");
}


