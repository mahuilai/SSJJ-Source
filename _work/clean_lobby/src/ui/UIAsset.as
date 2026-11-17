package ui
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import utils.UIUtil;
   
   public class UIAsset extends Sprite
   {
      
      private var _assetName:String;
      
      private var _asset:Sprite;
      
      private var _stopOnStart:Boolean = true;
      
      private var _isMovieClip:Boolean;
      
      private var _w:int;
      
      private var _h:int;
      
      public function UIAsset()
      {
         super();
         super.scaleX = super.scaleY = 1;
         this.removeChildren();
      }
      
      public function set assetObject(param1:Object) : void
      {
         if(param1 is Sprite)
         {
            if(param1 == _asset)
            {
               return;
            }
            if(_asset)
            {
               if(_asset.parent)
               {
                  _asset.parent.removeChild(_asset);
               }
               _asset = null;
            }
            _asset = param1 as Sprite;
            this.addChild(_asset);
            if(_stopOnStart && _asset is MovieClip)
            {
               (_asset as MovieClip).stop();
            }
            if(this._w == 0)
            {
               this._w = this._asset.width;
            }
            if(this._h == 0)
            {
               this._h = this._asset.height;
            }
         }
      }
      
      public function set assetName(param1:String) : void
      {
         var _loc2_:Class = null;
         _assetName = param1;
         if(_asset)
         {
            this.removeChild(_asset);
            _asset = null;
         }
         if(!param1 || param1.length == 0)
         {
            return;
         }
         try
         {
            _loc2_ = UIUtil.getDefinition(param1) as Class;
            _asset = new _loc2_();
            if(_w > 0)
            {
               _asset.width = _w;
            }
            if(_h > 0)
            {
               _asset.height = _h;
            }
            this.addChild(_asset);
            if(_stopOnStart && _asset is MovieClip)
            {
               (_asset as MovieClip).stop();
            }
            if(this._w == 0)
            {
               this._w = this._asset.width;
            }
            if(this._h == 0)
            {
               this._h = this._asset.height;
            }
         }
         catch(e:Error)
         {
         }
      }
      
      public function set assetNewName(param1:String) : void
      {
         var _loc2_:Class = null;
         if(_assetName == param1)
         {
            return;
         }
         _assetName = param1;
         if(_asset)
         {
            this.removeChild(_asset);
            _asset = null;
         }
         if(!param1 || param1.length == 0)
         {
            return;
         }
         try
         {
            _loc2_ = UIUtil.getDefinition(param1) as Class;
            _asset = new _loc2_();
            if(_w > 0)
            {
               _asset.width = _w;
            }
            if(_h > 0)
            {
               _asset.height = _h;
            }
            this.addChild(_asset);
            if(_stopOnStart && _asset is MovieClip)
            {
               (_asset as MovieClip).stop();
            }
            if(this._w == 0)
            {
               this._w = this._asset.width;
            }
            if(this._h == 0)
            {
               this._h = this._asset.height;
            }
         }
         catch(e:Error)
         {
         }
      }
      
      override public function set width(param1:Number) : void
      {
         _w = param1;
         if(_asset)
         {
            _asset.width = _w;
         }
      }
      
      override public function get width() : Number
      {
         return _w;
      }
      
      override public function set height(param1:Number) : void
      {
         _h = param1;
         if(_asset)
         {
            _asset.height = _h;
         }
      }
      
      override public function get height() : Number
      {
         return _h;
      }
      
      override public function set scaleX(param1:Number) : void
      {
         width = _w * param1;
      }
      
      override public function set scaleY(param1:Number) : void
      {
         height = _h * param1;
      }
      
      public function get assetName() : String
      {
         return _assetName;
      }
      
      public function set stopOnStart(param1:Boolean) : void
      {
         _stopOnStart = param1;
         if(_stopOnStart && _asset && _asset is MovieClip)
         {
            (_asset as MovieClip).gotoAndStop(1);
         }
      }
      
      public function get stopOnStart() : Boolean
      {
         return _stopOnStart;
      }
      
      public function set isMovieClip(param1:Boolean) : void
      {
         _isMovieClip = param1;
      }
      
      public function get isMovieClip() : Boolean
      {
         return _isMovieClip;
      }
   }
}

