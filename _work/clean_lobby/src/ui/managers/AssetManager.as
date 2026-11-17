package ui.managers
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.utils.getQualifiedSuperclassName;
   import ui.Asset;
   import ui.core.UICommon;
   import utils.BitmapUtils;
   import utils.UIUtil;
   
   public class AssetManager
   {
      
      private var _bmdMap:Object = {};
      
      private var _clipsMap:Object = {};
      
      private var _bmdSizeGridMap:Object = {};
      
      public function AssetManager()
      {
         super();
      }
      
      public function getAsset(param1:String, param2:Boolean = false, param3:Boolean = false) : Asset
      {
         var _loc8_:Class = null;
         var _loc5_:String = null;
         var _loc7_:Sprite = null;
         var _loc4_:Object = null;
         var _loc6_:Asset = _bmdMap[param1];
         if(_loc6_ == null)
         {
            _loc6_ = new Asset();
            if(UICommon.localAsset)
            {
               _loc6_.data = UICommon.localAsset.getAssetBitmapDataByName(param1);
            }
            if(_loc6_.data)
            {
               _loc6_.type = 2;
            }
            else
            {
               _loc8_ = UIUtil.getDefinition(param1) as Class;
               if(_loc8_ == null)
               {
                  return null;
               }
               _loc5_ = getQualifiedSuperclassName(_loc8_);
               if(_loc5_ == "flash.display::BitmapData")
               {
                  _loc6_.data = new _loc8_(1,1);
                  _loc6_.type = 2;
               }
               else
               {
                  _loc7_ = new _loc8_();
                  if(_bmdSizeGridMap[param1] == null && _loc7_.scale9Grid)
                  {
                     _bmdSizeGridMap[param1] = [_loc7_.scale9Grid.left,_loc7_.scale9Grid.top,_loc7_.width - _loc7_.scale9Grid.right,_loc7_.height - _loc7_.scale9Grid.bottom].join(",");
                  }
                  if(_loc7_.numChildren > 0)
                  {
                     _loc4_ = _loc7_.getChildAt(0);
                     if(_loc4_ is Bitmap && _loc7_.numChildren == 1)
                     {
                        _loc6_.data = (_loc4_ as Bitmap).bitmapData;
                        _loc6_.type = 2;
                     }
                     else if(param2 == false && _loc7_.scale9Grid == null && _loc4_ is Shape && _loc7_.numChildren == 1)
                     {
                        _loc6_.data = _loc4_;
                        _loc6_.type = 1;
                     }
                     else
                     {
                        _loc6_.data = new BitmapData(Math.ceil(_loc7_.width),Math.ceil(_loc7_.height),true,16777215);
                        _loc6_.data.draw(_loc7_);
                        _loc6_.type = 2;
                     }
                  }
               }
            }
            if(_loc6_.data == null)
            {
               _loc6_.data = new BitmapData(1,1,true,0); _loc6_.type = 2;
            }
            if(_loc6_.type == 2 && param3)
            {
               _bmdMap[param1] = _loc6_;
            }
         }
         return _loc6_;
      }
      
      public function getClips(param1:String, param2:int, param3:int, param4:int = 0, param5:Boolean = false) : Vector.<Asset>
      {
         var _loc6_:Asset = null;
         var _loc7_:* = undefined;
         var _loc10_:int = 0;
         var _loc9_:Asset = null;
         var _loc8_:Vector.<Asset> = _clipsMap[param1];
         if(_loc8_ == null)
         {
            _loc6_ = getAsset(param1,true,false);
            if(_loc6_ == null)
            {
               return null;
            }
            if(_loc6_.type == 2)
            {
               _loc8_ = new Vector.<Asset>(0);
               _loc7_ = BitmapUtils.createClips(_loc6_.data as BitmapData,param2,param3,param4);
               _loc10_ = 0;
               while(_loc10_ < _loc7_.length)
               {
                  _loc9_ = new Asset();
                  _loc9_.type = 2;
                  _loc9_.data = _loc7_[_loc10_];
                  _loc8_.push(_loc9_);
                  _loc10_++;
               }
            }
            if(param5)
            {
               _clipsMap[param1] = _loc8_;
            }
         }
         return _loc8_;
      }
      
      public function getBmdSizeGrid(param1:String) : String
      {
         return _bmdSizeGridMap[param1];
      }
      
      public function cacheBitmapData(param1:String, param2:BitmapData) : void
      {
         if(param2)
         {
            _bmdMap[param1] = param2;
         }
      }
      
      public function disposeBitmapData(param1:String) : void
      {
         var _loc2_:BitmapData = _bmdMap[param1];
         if(_loc2_)
         {
            delete _bmdMap[param1];
            _loc2_.dispose();
         }
      }
      
      public function cacheClips(param1:String, param2:Vector.<BitmapData>) : void
      {
         if(param2)
         {
            _clipsMap[param1] = param2;
         }
      }
      
      public function destroyClips(param1:String) : void
      {
         var _loc3_:Vector.<BitmapData> = _clipsMap[param1];
         if(_loc3_)
         {
            for each(var _loc2_ in _loc3_)
            {
               _loc2_.dispose();
            }
            _loc3_.length = 0;
            delete _clipsMap[param1];
         }
      }
      
      public function disposCache() : void
      {
         var _loc1_:* = null;
         for each(_loc1_ in _clipsMap)
         {
            if(_loc1_.type == 2)
            {
               (_loc1_ as BitmapData).dispose();
            }
         }
         for each(_loc1_ in _bmdMap)
         {
            if(_loc1_.type == 2)
            {
               (_loc1_ as BitmapData).dispose();
            }
         }
         _clipsMap = {};
         _bmdMap = {};
      }
   }
}

