function ButtonClick(btn)
{
   _root.game.PlayButtonSound();
   if(btn === btnBack)
   {
      Trans(_lastFrame);
   }
   else
   {
      StartGame();
   }
}
function MapClick(btn)
{
   if(btn._locked)
   {
      popup.ShowReg();
   }
   else
   {
      btnSmall.SetSelected(btn === btnSmall);
      btnNormal.SetSelected(btn === btnNormal);
      btnLarge.SetSelected(btn === btnLarge);
   }
}
function TickClick(btn)
{
   trace("TickClick:" + btn);
   if(btn._locked)
   {
      popup._visible = true;
   }
   else
   {
      btn.SetSelected(!btn._selected);
   }
}
function StartGame()
{
   SaveState();
   if(_fade < 100)
   {
      return undefined;
   }
   this.Fade();
   _parent.LoadGame();
   Game.me.PlayButtonSound();
}
function LoadState()
{
   if(Boolean(_pdata.data.size == 2 || !_pdata.data.size))
   {
      trace("btnNormal");
      btnNormal._selected = true;
   }
   else if(_pdata.data.size == 1)
   {
      btnSmall._selected = true;
   }
   else
   {
      btnLarge._selected = true;
   }
   btnLoadLast._selected = Boolean(_pdata.data.last);
   ModeSettings.loadLastMap = btnLoadLast._selected;
   CheckSaves();
}
function CheckSaves()
{
   trace("lastmap" + ModeSettings.modeNum);
   trace(_pdata.data["lastmap" + ModeSettings.modeNum]);
   if(_pdata.data["lastmap" + ModeSettings.modeNum])
   {
      btnLoadLast._disabled = false;
   }
   else
   {
      btnLoadLast._disabled = true;
   }
   if(_pdata[ModeSettings.modeNum + "m"])
   {
      btnLoadSave.disabled = false;
   }
   else
   {
      btnLoadSave.disabled = true;
   }
   if(btnLoadSave.disabled && btnLoadLast.disabled)
   {
      txtLoadMap.text = "No Saves Available";
   }
   btnLoadLast._selected = false;
   if(_pdata.data.last)
   {
      btnLoadLast._selected = true;
   }
}
function SaveState()
{
   _pdata.data.last = Boolean(btnLoadLast._selected);
   ModeSettings.loadLastMap = btnLoadLast._selected;
   _pdata.flush();
}
btnPlay._text = "Play";
popup._visible = false;
LoadState();
txtDesc._visible = false;
btnLoadLast._locked = false;
