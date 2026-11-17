package com.junkbyte.console.view
{
   import com.junkbyte.console.Console;
   import com.junkbyte.console.ConsoleConfig;
   import com.junkbyte.console.ConsoleStyle;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   
   public class ConsolePanel extends Sprite
   {
      
      public static const DRAGGING_STARTED:String = "draggingStarted";
      
      public static const DRAGGING_ENDED:String = "draggingEnded";
      
      public static const SCALING_STARTED:String = "scalingStarted";
      
      public static const SCALING_ENDED:String = "scalingEnded";
      
      public static const VISIBLITY_CHANGED:String = "visibilityChanged";
      
      private static const TEXT_ROLL:String = "TEXT_ROLL";
      
      private var _snaps:Array;
      
      private var _dragOffset:Point;
      
      private var _resizeTxt:TextField;
      
      protected var console:Console;
      
      protected var bg:Sprite;
      
      protected var scaler:Sprite;
      
      protected var txtField:TextField;
      
      protected var minWidth:int = 18;
      
      protected var minHeight:int = 18;
      
      private var _movedFrom:Point;
      
      public var moveable:Boolean = true;
      
      public function ConsolePanel(param1:Console)
      {
         super();
         console = param1;
         bg = new Sprite();
         bg.name = "background";
         addChild(bg);
      }
      
      private static function onTextFieldMouseOut(param1:MouseEvent) : void
      {
         TextField(param1.currentTarget).dispatchEvent(new TextEvent("TEXT_ROLL"));
      }
      
      private static function onTextFieldMouseMove(param1:MouseEvent) : void
      {
         var _loc4_:int = 0;
         var _loc8_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc6_:XML = null;
         var _loc5_:XML = null;
         var _loc3_:TextField = param1.currentTarget as TextField;
         if(_loc3_.scrollH > 0)
         {
            _loc8_ = _loc3_.scrollH;
            _loc2_ = _loc3_.width;
            _loc3_.width = _loc2_ + _loc8_;
            _loc4_ = _loc3_.getCharIndexAtPoint(_loc3_.mouseX + _loc8_,_loc3_.mouseY);
            _loc3_.width = _loc2_;
            _loc3_.scrollH = _loc8_;
         }
         else
         {
            _loc4_ = _loc3_.getCharIndexAtPoint(_loc3_.mouseX,_loc3_.mouseY);
         }
         var _loc7_:String = null;
         if(_loc4_ > 0)
         {
            try
            {
               _loc6_ = new XML(_loc3_.getXMLText(_loc4_,_loc4_ + 1));
               if(_loc6_.hasOwnProperty("textformat"))
               {
                  _loc5_ = _loc6_["textformat"][0] as XML;
                  if(_loc5_)
                  {
                     _loc7_ = _loc5_.@url;
                  }
               }
            }
            catch(err:Error)
            {
               _loc7_ = null;
            }
         }
         _loc3_.dispatchEvent(new TextEvent("TEXT_ROLL",false,false,_loc7_));
      }
      
      protected function get config() : ConsoleConfig
      {
         return console.config;
      }
      
      protected function get style() : ConsoleStyle
      {
         return console.config.style;
      }
      
      protected function init(param1:Number, param2:Number, param3:Boolean = false, param4:Number = -1, param5:Number = -1, param6:int = -1) : void
      {
         bg.graphics.clear();
         bg.graphics.beginFill(param4 >= 0 ? param4 : style.backgroundColor,param5 >= 0 ? param5 : style.backgroundAlpha);
         if(param6 < 0)
         {
            param6 = style.roundBorder;
         }
         if(param6 <= 0)
         {
            bg.graphics.drawRect(0,0,100,100);
         }
         else
         {
            bg.graphics.drawRoundRect(0,0,param6 + 10,param6 + 10,param6,param6);
            bg.scale9Grid = new Rectangle(param6 * 0.5,param6 * 0.5,10,10);
         }
         scalable = param3;
         width = param1;
         height = param2;
      }
      
      public function close() : void
      {
         stopDragging();
         console.panels.tooltip();
         if(parent)
         {
            parent.removeChild(this);
         }
         dispatchEvent(new Event("close"));
      }
      
      override public function set visible(param1:Boolean) : void
      {
         super.visible = param1;
         dispatchEvent(new Event("visibilityChanged"));
      }
      
      override public function set width(param1:Number) : void
      {
         if(param1 < minWidth)
         {
            param1 = minWidth;
         }
         if(scaler)
         {
            scaler.x = param1;
         }
         bg.width = param1;
      }
      
      override public function set height(param1:Number) : void
      {
         if(param1 < minHeight)
         {
            param1 = minHeight;
         }
         if(scaler)
         {
            scaler.y = param1;
         }
         bg.height = param1;
      }
      
      override public function get width() : Number
      {
         return bg.width;
      }
      
      override public function get height() : Number
      {
         return bg.height;
      }
      
      public function registerSnaps(param1:Array, param2:Array) : void
      {
         _snaps = [param1,param2];
      }
      
      protected function registerDragger(param1:DisplayObject, param2:Boolean = false) : void
      {
         if(param2)
         {
            param1.removeEventListener("mouseDown",onDraggerMouseDown);
         }
         else
         {
            param1.addEventListener("mouseDown",onDraggerMouseDown,false,0,true);
         }
      }
      
      private function onDraggerMouseDown(param1:MouseEvent) : void
      {
         if(!stage || !moveable)
         {
            return;
         }
         _resizeTxt = makeTF("positioningField",true);
         _resizeTxt.mouseEnabled = false;
         _resizeTxt.autoSize = "left";
         addChild(_resizeTxt);
         updateDragText();
         _movedFrom = new Point(x,y);
         _dragOffset = new Point(mouseX,mouseY);
         _snaps = [[],[]];
         dispatchEvent(new Event("draggingStarted"));
         stage.addEventListener("mouseUp",onDraggerMouseUp,false,0,true);
         stage.addEventListener("mouseMove",onDraggerMouseMove,false,0,true);
      }
      
      private function onDraggerMouseMove(param1:MouseEvent = null) : void
      {
         if(style.panelSnapping == 0)
         {
            return;
         }
         var _loc2_:Point = returnSnappedFor(parent.mouseX - _dragOffset.x,parent.mouseY - _dragOffset.y);
         x = _loc2_.x;
         y = _loc2_.y;
         updateDragText();
      }
      
      private function updateDragText() : void
      {
         _resizeTxt.text = "<low>" + x + "," + y + "</low>";
      }
      
      private function onDraggerMouseUp(param1:MouseEvent) : void
      {
         stopDragging();
      }
      
      private function stopDragging() : void
      {
         _snaps = null;
         if(stage)
         {
            stage.removeEventListener("mouseUp",onDraggerMouseUp);
            stage.removeEventListener("mouseMove",onDraggerMouseMove);
         }
         if(_resizeTxt && _resizeTxt.parent)
         {
            _resizeTxt.parent.removeChild(_resizeTxt);
         }
         _resizeTxt = null;
         dispatchEvent(new Event("draggingEnded"));
      }
      
      public function moveBackSafePosition() : void
      {
         if(_movedFrom != null)
         {
            if(x + width < 10 || stage && stage.stageWidth < x + 10 || y + height < 10 || stage && stage.stageHeight < y + 20)
            {
               x = _movedFrom.x;
               y = _movedFrom.y;
            }
            _movedFrom = null;
         }
      }
      
      public function get scalable() : Boolean
      {
         return scaler ? true : false;
      }
      
      public function set scalable(param1:Boolean) : void
      {
         var _loc2_:* = 0;
         if(param1 && !scaler)
         {
            _loc2_ = uint(8 + style.controlSize * 0.5);
            scaler = new Sprite();
            scaler.name = "scaler";
            scaler.graphics.beginFill(0,0);
            scaler.graphics.drawRect(-_loc2_ * 1.5,-_loc2_ * 1.5,_loc2_ * 1.5,_loc2_ * 1.5);
            scaler.graphics.endFill();
            scaler.graphics.beginFill(style.controlColor,style.backgroundAlpha);
            scaler.graphics.moveTo(0,0);
            scaler.graphics.lineTo(-_loc2_,0);
            scaler.graphics.lineTo(0,-_loc2_);
            scaler.graphics.endFill();
            scaler.buttonMode = true;
            scaler.doubleClickEnabled = true;
            scaler.addEventListener("mouseDown",onScalerMouseDown,false,0,true);
            addChildAt(scaler,getChildIndex(bg) + 1);
         }
         else if(!param1 && scaler)
         {
            if(contains(scaler))
            {
               removeChild(scaler);
            }
            scaler = null;
         }
      }
      
      private function onScalerMouseDown(param1:Event) : void
      {
         _resizeTxt = makeTF("resizingField",true);
         _resizeTxt.mouseEnabled = false;
         _resizeTxt.autoSize = "right";
         _resizeTxt.x = -4;
         _resizeTxt.y = -17;
         scaler.addChild(_resizeTxt);
         updateScaleText();
         _dragOffset = new Point(scaler.mouseX,scaler.mouseY);
         _snaps = [[],[]];
         scaler.stage.addEventListener("mouseUp",onScalerMouseUp,false,0,true);
         scaler.stage.addEventListener("mouseMove",updateScale,false,0,true);
         dispatchEvent(new Event("scalingStarted"));
      }
      
      private function updateScale(param1:Event = null) : void
      {
         var _loc2_:Point = returnSnappedFor(x + mouseX - _dragOffset.x,y + mouseY - _dragOffset.x);
         _loc2_.x -= x;
         _loc2_.y -= y;
         width = _loc2_.x < minWidth ? minWidth : _loc2_.x;
         height = _loc2_.y < minHeight ? minHeight : _loc2_.y;
         updateScaleText();
      }
      
      private function updateScaleText() : void
      {
         _resizeTxt.text = "<low>" + width + "," + height + "</low>";
      }
      
      public function stopScaling() : void
      {
         onScalerMouseUp(null);
      }
      
      private function onScalerMouseUp(param1:Event) : void
      {
         scaler.stage.removeEventListener("mouseUp",onScalerMouseUp);
         scaler.stage.removeEventListener("mouseMove",updateScale);
         updateScale();
         _snaps = null;
         if(_resizeTxt && _resizeTxt.parent)
         {
            _resizeTxt.parent.removeChild(_resizeTxt);
         }
         _resizeTxt = null;
         dispatchEvent(new Event("scalingEnded"));
      }
      
      public function makeTF(param1:String, param2:Boolean = false) : TextField
      {
         var _loc3_:TextField = new TextField();
         _loc3_.name = param1;
         _loc3_.styleSheet = style.styleSheet;
         if(param2)
         {
            _loc3_.background = true;
            _loc3_.backgroundColor = style.backgroundColor;
         }
         return _loc3_;
      }
      
      private function returnSnappedFor(param1:Number, param2:Number) : Point
      {
         return new Point(getSnapOf(param1,true),getSnapOf(param2,false));
      }
      
      private function getSnapOf(param1:Number, param2:Boolean) : Number
      {
         var _loc6_:Number = param1 + width;
         var _loc4_:Array = _snaps[param2 ? 0 : 1];
         var _loc3_:int = style.panelSnapping;
         for each(var _loc5_:Number in _loc4_)
         {
            if(Math.abs(_loc5_ - param1) < _loc3_)
            {
               return _loc5_;
            }
            if(Math.abs(_loc5_ - _loc6_) < _loc3_)
            {
               return _loc5_ - width;
            }
         }
         return param1;
      }
      
      protected function registerTFRoller(param1:TextField, param2:Function, param3:Function = null) : void
      {
         param1.addEventListener("mouseMove",onTextFieldMouseMove,false,0,true);
         param1.addEventListener("rollOut",onTextFieldMouseOut,false,0,true);
         param1.addEventListener("TEXT_ROLL",param2,false,0,true);
         if(param3 != null)
         {
            param1.addEventListener("link",param3,false,0,true);
         }
      }
   }
}

