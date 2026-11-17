package editor.managers
{
   import flash.display.BitmapData;
   
   public interface ILocalAssetManager
   {
      
      function hasDefinition(param1:String) : Boolean;
      
      function getAssetBitmapDataByName(param1:String) : BitmapData;
   }
}

