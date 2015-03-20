//  ================================================================================================
//   * File Name:    ProtoOneHUD
//   * Created By:   Hami
//   * Time Stamp:     2/7/2014 3:09:54 PM
//   * UDK Path:   C:\UDK\WhalefallStudios
//   * Unreal X-Editor v3.1.4.0
//   * © Copyright 2012 - 2014. All Rights Reserved.
//  ================================================================================================

class ProtoOneHUD extends UDKHUD;

event PostRender()
{
    super.PostRender();
    ProtoOneDebugMenu(PlayerOwner.CheatManager).DrawDebugMenu(self);
}
 
function DrawTextSimple(string text, Vector2D position, Font font,Color text_color)
{
    Canvas.SetPos(position.X,position.Y);
    Canvas.SetDrawColorStruct(text_color);
    Canvas.Font = font;
    Canvas.DrawText(text);
}


defaultproperties
{
    bShowOverlays=true
}