package fl.controls
{
   import fl.core.UIComponent;
   import fl.events.ScrollEvent;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class UIScrollBar extends ScrollBar
   {
      
      private static var defaultStyles:Object = {};
      
      protected var _scrollTarget:DisplayObject;
      
      protected var inEdit:Boolean = false;
      
      protected var inScroll:Boolean = false;
      
      protected var _targetScrollProperty:String;
      
      protected var _targetMaxScrollProperty:String;
      
      public function UIScrollBar()
      {
         super();
      }
      
      public static function getStyleDefinition() : Object
      {
         return UIComponent.mergeStyles(defaultStyles,ScrollBar.getStyleDefinition());
      }
      
      override public function set minScrollPosition(param1:Number) : void
      {
         super.minScrollPosition = param1 < 0 ? 0 : param1;
      }
      
      override public function set maxScrollPosition(param1:Number) : void
      {
         var _loc2_:Number = param1;
         if(_scrollTarget != null)
         {
            _loc2_ = Math.min(_loc2_,_scrollTarget[_targetMaxScrollProperty]);
         }
         super.maxScrollPosition = _loc2_;
      }
      
      public function get scrollTarget() : DisplayObject
      {
         return _scrollTarget;
      }
      
      public function set scrollTarget(param1:DisplayObject) : void
      {
         if(_scrollTarget != null)
         {
            _scrollTarget.removeEventListener("change",handleTargetChange,false);
            _scrollTarget.removeEventListener("textInput",handleTargetChange,false);
            _scrollTarget.removeEventListener("scroll",handleTargetScroll,false);
         }
         _scrollTarget = param1;
         var _loc5_:String = null;
         var _loc3_:String = null;
         var _loc6_:Boolean = false;
         if(_scrollTarget != null)
         {
            try
            {
               if(_scrollTarget.hasOwnProperty("blockProgression"))
               {
                  _loc5_ = _scrollTarget["blockProgression"];
               }
               if(_scrollTarget.hasOwnProperty("direction"))
               {
                  _loc3_ = _scrollTarget["direction"];
               }
               if(_scrollTarget.hasOwnProperty("pixelScrollV"))
               {
                  _loc6_ = true;
               }
            }
            catch(e:Error)
            {
               _loc5_ = null;
               _loc3_ = null;
            }
         }
         var _loc2_:Boolean = this.direction == "horizontal";
         var _loc4_:Number = Math.abs(this.rotation);
         if(_loc2_ && (_loc5_ == "rl" || _loc3_ == "rtl"))
         {
            if(getScaleY() > 0 && rotation == 90)
            {
               x += width;
            }
            setScaleY(-1);
         }
         else if(!_loc2_ && _loc5_ == "rl" && _loc3_ == "rtl")
         {
            if(getScaleY() > 0 && rotation != 90)
            {
               y += height;
            }
            setScaleY(-1);
         }
         else
         {
            if(getScaleY() < 0)
            {
               if(_loc2_)
               {
                  if(rotation == 90)
                  {
                     x -= width;
                  }
               }
               else if(rotation != 90)
               {
                  y -= height;
               }
            }
            setScaleY(1);
         }
         setTargetScrollProperties(_loc2_,_loc5_,_loc6_);
         if(_scrollTarget != null)
         {
            _scrollTarget.addEventListener("change",handleTargetChange,false,0,true);
            _scrollTarget.addEventListener("textInput",handleTargetChange,false,0,true);
            _scrollTarget.addEventListener("scroll",handleTargetScroll,false,0,true);
         }
         invalidate("data");
      }
      
      public function get scrollTargetName() : String
      {
         return _scrollTarget.name;
      }
      
      public function set scrollTargetName(param1:String) : void
      {
         try
         {
            scrollTarget = parent.getChildByName(param1);
         }
         catch(error:Error)
         {
            throw new Error("ScrollTarget not found, or is not a valid target");
         }
      }
      
      override public function get direction() : String
      {
         return super.direction;
      }
      
      override public function set direction(param1:String) : void
      {
         var _loc2_:DisplayObject = null;
         if(isLivePreview)
         {
            return;
         }
         if(!componentInspectorSetting && _scrollTarget != null)
         {
            _loc2_ = _scrollTarget;
            scrollTarget = null;
         }
         super.direction = param1;
         if(_loc2_ != null)
         {
            scrollTarget = _loc2_;
         }
         else
         {
            updateScrollTargetProperties();
         }
      }
      
      public function update() : void
      {
         inEdit = true;
         updateScrollTargetProperties();
         inEdit = false;
      }
      
      override protected function draw() : void
      {
         if(isInvalid("data"))
         {
            updateScrollTargetProperties();
         }
         super.draw();
      }
      
      protected function updateScrollTargetProperties() : void
      {
         var _loc1_:String = null;
         var _loc2_:Boolean = false;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc6_:Namespace = new Namespace("http://ns.adobe.com/textLayout/internal/2008");
         var _loc5_:* = undefined;
         if(_scrollTarget == null)
         {
            setScrollProperties(_loc3_,minScrollPosition,maxScrollPosition);
            scrollPosition = 0;
         }
         else
         {
            _loc1_ = null;
            _loc2_ = false;
            try
            {
               if(_scrollTarget.hasOwnProperty("blockProgression"))
               {
                  _loc1_ = _scrollTarget["blockProgression"];
               }
               if(_scrollTarget.hasOwnProperty("pixelScrollV"))
               {
                  _loc2_ = true;
               }
            }
            catch(e1:Error)
            {
            }
            setTargetScrollProperties(this.direction == "horizontal",_loc1_,_loc2_);
            if(_targetScrollProperty == "scrollH")
            {
               _loc4_ = 0;
               try
               {
                  if(_scrollTarget.hasOwnProperty("controller") && _scrollTarget["controller"].hasOwnProperty("compositionWidth"))
                  {
                     _loc3_ = Number(_scrollTarget["controller"]["compositionWidth"]);
                  }
                  else
                  {
                     _loc3_ = _scrollTarget.width;
                  }
               }
               catch(e2:Error)
               {
                  _loc3_ = _scrollTarget.width;
               }
            }
            else
            {
               try
               {
                  if(_loc1_ != null)
                  {
                     _loc5_ = _scrollTarget["pixelMinScrollV"];
                     if(_loc5_ is int)
                     {
                        _loc4_ = _loc5_;
                     }
                     else
                     {
                        _loc4_ = 1;
                     }
                  }
                  else
                  {
                     _loc4_ = 1;
                  }
               }
               catch(e3:Error)
               {
                  _loc4_ = 1;
               }
               _loc3_ = 10;
            }
            setScrollProperties(_loc3_,_loc4_,scrollTarget[_targetMaxScrollProperty]);
            scrollPosition = _scrollTarget[_targetScrollProperty];
         }
      }
      
      override public function setScrollProperties(param1:Number, param2:Number, param3:Number, param4:Number = 0) : void
      {
         var _loc5_:Number = param3;
         var _loc6_:Number = param2 < 0 ? 0 : param2;
         if(_scrollTarget != null)
         {
            _loc5_ = Math.min(param3,_scrollTarget[_targetMaxScrollProperty]);
         }
         super.setScrollProperties(param1,_loc6_,_loc5_,param4);
      }
      
      override public function setScrollPosition(param1:Number, param2:Boolean = true) : void
      {
         super.setScrollPosition(param1,param2);
         if(!_scrollTarget)
         {
            inScroll = false;
            return;
         }
         updateTargetScroll();
      }
      
      protected function updateTargetScroll(param1:ScrollEvent = null) : void
      {
         if(inEdit)
         {
            return;
         }
         _scrollTarget[_targetScrollProperty] = scrollPosition;
      }
      
      protected function handleTargetChange(param1:Event) : void
      {
         inEdit = true;
         setScrollPosition(_scrollTarget[_targetScrollProperty],true);
         updateScrollTargetProperties();
         inEdit = false;
      }
      
      protected function handleTargetScroll(param1:Event) : void
      {
         if(inDrag)
         {
            return;
         }
         if(!enabled)
         {
            return;
         }
         inEdit = true;
         updateScrollTargetProperties();
         scrollPosition = _scrollTarget[_targetScrollProperty];
         inEdit = false;
      }
      
      private function setTargetScrollProperties(param1:Boolean, param2:String, param3:Boolean = false) : void
      {
         if(param2 == "rl")
         {
            if(param1)
            {
               _targetScrollProperty = param3 ? "pixelScrollV" : "scrollV";
               _targetMaxScrollProperty = param3 ? "pixelMaxScrollV" : "maxScrollV";
            }
            else
            {
               _targetScrollProperty = "scrollH";
               _targetMaxScrollProperty = "maxScrollH";
            }
         }
         else if(param1)
         {
            _targetScrollProperty = "scrollH";
            _targetMaxScrollProperty = "maxScrollH";
         }
         else
         {
            _targetScrollProperty = param3 ? "pixelScrollV" : "scrollV";
            _targetMaxScrollProperty = param3 ? "pixelMaxScrollV" : "maxScrollV";
         }
      }
   }
}

