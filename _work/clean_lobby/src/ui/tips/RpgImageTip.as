package ui.tips
{
   import flash.display.Sprite;
   import ui.UIAssetsLoader;
   
   public class RpgImageTip extends Sprite implements IToolTips
   {
      
      private var _imageTips:UIAssetsLoader = null;
      
      private var _layoutFunc:Function = null;
      
      private var _fileName:String = null;
      
      private var _imageTipsURL:String = null;
      
      public function RpgImageTip(param1:Function)
      {
         super();
         this._layoutFunc = param1;
         this._imageTips = new UIAssetsLoader();
         this._imageTips.callback = onImageLoaded;
         this.addChild(this._imageTips);
      }
      
      public function dispose() : void
      {
      }
      
      private function onImageLoaded() : void
      {
         this._layoutFunc.apply();
      }
      
      public function getHeight() : int
      {
         if(null == this._imageTips.getContent())
         {
            return 266;
         }
         return this._imageTips.getContent()["bg"].height;
      }
      
      public function getWidth() : int
      {
         if(null == this._imageTips.getContent())
         {
            return 609;
         }
         return this._imageTips.getContent()["bg"].width;
      }
      
      public function hide() : void
      {
         this._layoutFunc = null;
         if(this._imageTips != null)
         {
            this._imageTips.unload();
            this._imageTips.dispose();
            this._imageTips.removeChildren();
            this._imageTips.callback = null;
            this.removeChild(_imageTips);
         }
         this._imageTips = null;
         this._fileName = null;
      }
      
      public function show(param1:Array) : void
      {
         var _loc2_:String = param1[0];
         var _loc3_:String = param1[1];
         if(_loc2_ == this._fileName)
         {
            return;
         }
         this._fileName = _loc2_;
         this._imageTipsURL = _loc3_;
         this._imageTips.callback = onImageLoaded;
         this._imageTips.path = this._imageTipsURL;
         this._imageTips.fileName = this._fileName;
      }
   }
}

