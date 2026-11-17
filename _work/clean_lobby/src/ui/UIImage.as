package ui
{
   import style.StyleConfig;
   import ui.core.UICommon;
   import utils.StringUtil;
   
   public class UIImage extends UIBase
   {
      
      protected var _bitmap:AutoBitmap;
      
      protected var _skin:String;
      
      public function UIImage(param1:String = null)
      {
         super();
         this.skin = param1;
      }
      
      override protected function createChildren() : void
      {
         addChild(_bitmap = new AutoBitmap());
      }
      
      public function get skin() : String
      {
         return _skin;
      }
      
      public function set skin(param1:String) : void
      {
         var _loc2_:String = null;
         if(_skin != param1)
         {
            _skin = param1;
            if(param1)
            {
               asset = UICommon.asset.getAsset(_skin);
               _loc2_ = UICommon.asset.getBmdSizeGrid(_skin);
               if(_loc2_)
               {
                  sizeGrid = _loc2_;
               }
            }
            else
            {
               asset = null;
            }
         }
      }
      
      public function get asset() : Asset
      {
         return _bitmap.asset;
      }
      
      public function set asset(param1:Asset) : void
      {
         if(param1)
         {
            _contentWidth = param1.data.width;
            _contentHeight = param1.data.height;
         }
         _bitmap.clip = param1;
      }
      
      override public function set width(param1:Number) : void
      {
         super.width = param1;
         _bitmap.width = width;
      }
      
      override public function set height(param1:Number) : void
      {
         super.height = param1;
         _bitmap.height = height;
      }
      
      public function get sizeGrid() : String
      {
         if(_bitmap.sizeGrid)
         {
            return _bitmap.sizeGrid.join(",");
         }
         return null;
      }
      
      public function set sizeGrid(param1:String) : void
      {
         _bitmap.sizeGrid = StringUtil.fillArray(StyleConfig.defaultSizeGrid,param1);
      }
      
      public function get bitmap() : AutoBitmap
      {
         return _bitmap;
      }
      
      public function get smoothing() : Boolean
      {
         return _bitmap.smoothing;
      }
      
      public function set smoothing(param1:Boolean) : void
      {
         _bitmap.smoothing = param1;
      }
      
      override public function dispose() : void
      {
         _bitmap.dispose();
         UICommon.asset.disposeBitmapData(_skin);
      }
   }
}

