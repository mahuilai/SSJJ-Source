package ui
{
   import flash.events.Event;
   import style.StyleConfig;
   import ui.core.UICommon;
   import utils.StringUtil;
   
   public class UIClip extends UIBase
   {
      
      protected var _autoStopAtRemoved:Boolean = true;
      
      protected var _bitmap:AutoBitmap;
      
      protected var _clipX:int = 1;
      
      protected var _clipY:int = 1;
      
      protected var _length:int = 0;
      
      protected var _skin:String;
      
      protected var _autoPlay:Boolean;
      
      protected var _interval:int = StyleConfig.MOVIE_INTERVAL;
      
      protected var _from:int = -1;
      
      protected var _to:int = -1;
      
      protected var _isPlaying:Boolean;
      
      public function UIClip(param1:String = null, param2:int = 1, param3:int = 1, param4:int = 0)
      {
         super();
         _clipX = param2;
         _clipY = param3;
         _length = param4;
         this.skin = param1;
      }
      
      override protected function createChildren() : void
      {
         addChild(_bitmap = new AutoBitmap());
      }
      
      override protected function initialize() : void
      {
         addEventListener("addedToStage",onAddedToStage);
         addEventListener("removedFromStage",onRemovedFromStage);
      }
      
      protected function onAddedToStage(param1:Event) : void
      {
         if(_autoPlay)
         {
            play();
         }
      }
      
      protected function onRemovedFromStage(param1:Event) : void
      {
         if(_autoStopAtRemoved)
         {
            stop();
         }
      }
      
      public function get skin() : String
      {
         return _skin;
      }
      
      public function set skin(param1:String) : void
      {
         if(_skin != param1 && Boolean(param1))
         {
            _skin = param1;
            callLater(changeClip);
         }
      }
      
      public function get clipX() : int
      {
         return _clipX;
      }
      
      public function set clipX(param1:int) : void
      {
         if(_clipX != param1)
         {
            _clipX = param1;
            callLater(changeClip);
         }
      }
      
      public function get clipY() : int
      {
         return _clipY;
      }
      
      public function set clipY(param1:int) : void
      {
         if(_clipY != param1)
         {
            _clipY = param1;
            callLater(changeClip);
         }
      }
      
      public function get length() : int
      {
         return _length;
      }
      
      public function set length(param1:int) : void
      {
         if(_length != param1)
         {
            _length = param1;
            callLater(changeClip);
         }
      }
      
      protected function changeClip() : void
      {
         if(_skin)
         {
            clips = UICommon.asset.getClips(_skin,_clipX,_clipY,_length);
         }
      }
      
      public function get clips() : Vector.<Asset>
      {
         return _bitmap.clips;
      }
      
      public function set clips(param1:Vector.<Asset>) : void
      {
         if(param1)
         {
            _bitmap.clips = param1;
            _contentWidth = _bitmap.width;
            _contentHeight = _bitmap.height;
         }
      }
      
      override public function set width(param1:Number) : void
      {
         super.width = param1;
         _bitmap.width = param1;
      }
      
      override public function set height(param1:Number) : void
      {
         super.height = param1;
         _bitmap.height = param1;
      }
      
      override public function commitMeasure() : void
      {
         exeCallLater(changeClip);
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
      
      public function get frame() : int
      {
         return _bitmap.index;
      }
      
      public function set frame(param1:int) : void
      {
         _bitmap.index = param1;
         sendEvent("FRAME_CHANGED");
         if(_bitmap.index == _to)
         {
            stop();
            _to = -1;
            sendEvent("FRAME_COMPLETE");
         }
      }
      
      public function get totalFrame() : int
      {
         return _bitmap.clips ? _bitmap.clips.length : 0;
      }
      
      public function get autoStopAtRemoved() : Boolean
      {
         return _autoStopAtRemoved;
      }
      
      public function set autoStopAtRemoved(param1:Boolean) : void
      {
         _autoStopAtRemoved = param1;
      }
      
      public function get autoPlay() : Boolean
      {
         return _autoPlay;
      }
      
      public function set autoPlay(param1:Boolean) : void
      {
         if(_autoPlay != param1)
         {
            _autoPlay = param1;
            _autoPlay ? play() : stop();
         }
      }
      
      public function get interval() : int
      {
         return _interval;
      }
      
      public function set interval(param1:int) : void
      {
         if(_interval != param1)
         {
            _interval = param1;
            if(_isPlaying)
            {
               play();
            }
         }
      }
      
      public function get isPlaying() : Boolean
      {
         return _isPlaying;
      }
      
      public function set isPlaying(param1:Boolean) : void
      {
         _isPlaying = param1;
      }
      
      public function play() : void
      {
         _isPlaying = true;
         frame = _bitmap.index;
         UICommon.timer.doLoop(_interval,loop);
      }
      
      protected function loop() : void
      {
         frame = frame + 1;
      }
      
      public function stop() : void
      {
         UICommon.timer.clearTimer(loop);
         _isPlaying = false;
      }
      
      public function gotoAndPlay(param1:int) : void
      {
         this.frame = param1;
         play();
      }
      
      public function gotoAndStop(param1:int) : void
      {
         stop();
         this.frame = param1;
      }
      
      public function playFromTo(param1:int = -1, param2:int = -1) : void
      {
         _from = param1 == -1 ? 0 : param1;
         _to = param2 == -1 ? _clipX * _clipY - 1 : param2;
         gotoAndPlay(_from);
      }
      
      public function get smoothing() : Boolean
      {
         return _bitmap.smoothing;
      }
      
      public function set smoothing(param1:Boolean) : void
      {
         _bitmap.smoothing = param1;
      }
      
      public function get bitmap() : AutoBitmap
      {
         return _bitmap;
      }
      
      override public function dispose() : void
      {
         _bitmap.dispose();
         UICommon.asset.destroyClips(_skin);
      }
   }
}

