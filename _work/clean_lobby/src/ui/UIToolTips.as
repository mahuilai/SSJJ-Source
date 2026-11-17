package ui
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   import ui.core.UICommon;
   import ui.tips.IToolTips;
   import ui.tips.RpgImageTip;
   import ui.tips.WordTips;
   
   public class UIToolTips extends Sprite
   {
      
      public static var instance:UIToolTips;
      
      private const distance:int = 15;
      
      private var toolTips:IToolTips;
      
      private var my_timedProcess:Number = 0;
      
      private var isHide:Boolean;
      
      private var currentType:int;
      
      private var toolTipTargetDic:Dictionary = new Dictionary();
      
      private var _invalid:Boolean = true;
      
      public function UIToolTips()
      {
         super();
         instance = this;
         this.addEventListener("resize",onResize);
      }
      
      public static function registerToolTip(param1:DisplayObject, param2:String, param3:Array) : void
      {
         if(null != instance.toolTipTargetDic[param1])
         {
            instance.toolTipTargetDic[param1] = {
               "tipsType":param2,
               "param":param3
            };
            return;
         }
         instance.toolTipTargetDic[param1] = {
            "tipsType":param2,
            "param":param3
         };
         param1.addEventListener("rollOver",onTipTargetRollOver);
         param1.addEventListener("rollOut",onTipTargetRollOut);
         param1.addEventListener("mouseMove",onTipTargetMove);
         param1.addEventListener("removedFromStage",onTipRemoved);
      }
      
      public static function unregisterToolTip(param1:DisplayObject) : void
      {
         if(null == instance.toolTipTargetDic[param1])
         {
            return;
         }
         instance.hide();
         delete instance.toolTipTargetDic[param1];
         param1.removeEventListener("rollOver",onTipTargetRollOver);
         param1.removeEventListener("rollOut",onTipTargetRollOut);
         param1.removeEventListener("mouseMove",onTipTargetMove);
         param1.removeEventListener("removedFromStage",onTipRemoved);
      }
      
      public static function onTipRemoved(param1:Event) : void
      {
         unregisterToolTip(param1.currentTarget as DisplayObject);
      }
      
      public static function unregisterAll() : void
      {
         var _loc4_:int = 0;
         if(null == instance)
         {
            return;
         }
         var _loc3_:Array = [];
         for each(var _loc1_ in instance.toolTipTargetDic)
         {
            _loc3_.push(_loc1_);
         }
         var _loc2_:int = int(_loc3_.length);
         _loc4_ = 0;
         while(_loc4_ < _loc2_)
         {
            unregisterToolTip(_loc3_[_loc4_]);
            _loc4_++;
         }
      }
      
      private static function onTipTargetMove(param1:MouseEvent) : void
      {
         var _loc2_:Object = instance.toolTipTargetDic[param1.currentTarget];
         if(null == _loc2_)
         {
            return;
         }
         instance.show(_loc2_.tipsType,_loc2_.param);
      }
      
      private static function onTipTargetRollOver(param1:MouseEvent) : void
      {
         instance.setDelay();
      }
      
      private static function onTipTargetRollOut(param1:MouseEvent) : void
      {
         instance.hide();
      }
      
      private function removeOldToolTips() : void
      {
         if(null != toolTips)
         {
            toolTips.dispose();
            this.removeChild(tips);
         }
         removeChildren();
         toolTips = null;
      }
      
      public function dispose() : void
      {
         unregisterAll();
         removeOldToolTips();
      }
      
      public function show(param1:String, param2:Array) : void
      {
         switch(param1)
         {
            case "word":
               if(!(toolTips is WordTips))
               {
                  removeOldToolTips();
                  toolTips = new WordTips();
               }
               break;
            case "image":
               if(!(toolTips is RpgImageTip))
               {
                  removeOldToolTips();
                  toolTips = new RpgImageTip(this.loyout);
               }
         }
         if(!my_timedProcess && !tips.visible)
         {
            tips.visible = true;
         }
         if(!contains(tips))
         {
            addChild(tips);
         }
         if(this._invalid)
         {
            this._invalid = false;
         }
         toolTips.show(param2);
         loyout();
         isHide = false;
      }
      
      private function onResize(param1:Event) : void
      {
         loyout();
      }
      
      private function loyout() : void
      {
         var _loc2_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc1_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc3_:Number = NaN;
         if(tips)
         {
            _loc2_ = UICommon.scale;
            _loc7_ = UICommon.stage.mouseX / _loc2_;
            _loc1_ = UICommon.stage.mouseY / _loc2_;
            _loc6_ = _loc7_ + 15;
            _loc4_ = _loc1_ + 15;
            _loc5_ = toolTips.getWidth();
            _loc3_ = toolTips.getHeight();
            if(_loc6_ > UICommon.LOBBY_WIDTH - _loc5_)
            {
               tips.x = _loc7_ - _loc5_ - 15;
            }
            else
            {
               tips.x = _loc6_;
            }
            if(tips.x < 0)
            {
               tips.x = 0;
            }
            if(_loc4_ > UICommon.LOBBY_HEIGHT - _loc3_)
            {
               tips.y = UICommon.LOBBY_HEIGHT - _loc3_;
            }
            else
            {
               tips.y = _loc4_;
            }
         }
      }
      
      public function setDelay(param1:Number = 0.5) : void
      {
         if(tips != null)
         {
            tips.visible = false;
            my_timedProcess = setTimeout(delayEnd,param1 * 1000);
         }
      }
      
      private function delayEnd() : void
      {
         if(tips != null)
         {
            tips.visible = !isHide;
         }
         clearTimeout(my_timedProcess);
         my_timedProcess = 0;
      }
      
      public function hide() : void
      {
         if(null != tips)
         {
            if(tips.visible)
            {
               tips.visible = false;
            }
            if(tips is IToolTips)
            {
               (tips as IToolTips).hide();
            }
            removeOldToolTips();
         }
         isHide = true;
         this._invalid = true;
      }
      
      public function get tips() : Sprite
      {
         return toolTips as Sprite;
      }
   }
}

