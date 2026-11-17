package ui
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class UITabButton extends Sprite
   {
      
      public static const TAB_BUTTON_CHANGE:String = "TAB_BUTTON_CHANGE";
      
      protected var gap:int = 2;
      
      protected var btns:Array;
      
      private var _buttonSkin:String;
      
      private var _labels:Array;
      
      protected var _align:String = "horizon";
      
      protected var _selectIndex:int = -1;
      
      public function UITabButton()
      {
         super();
         btns = [];
      }
      
      public function setEnabled(param1:int, param2:Boolean) : void
      {
         var _loc3_:int = 0;
         if(btns.length > param1)
         {
            (btns[param1] as UIButton).enabled = param2;
            if(selectIndex == param1 && param2 == false)
            {
               _loc3_ = 0;
               while(_loc3_ < btns.length)
               {
                  if((btns[_loc3_] as UIButton).enabled)
                  {
                     selectIndex = _loc3_;
                     break;
                  }
                  _loc3_++;
               }
            }
         }
      }
      
      public function get align() : String
      {
         return _align;
      }
      
      public function set align(param1:String) : void
      {
         _align = param1;
         layout();
      }
      
      public function get selectIndex() : int
      {
         return _selectIndex;
      }
      
      public function set selectIndex(param1:int) : void
      {
         if(_selectIndex == param1)
         {
            return;
         }
         _selectIndex = param1;
         changeSelectButton();
      }
      
      public function addButton(param1:UIButton, param2:int = 2, param3:Number = -1, param4:* = -1) : void
      {
         var _loc5_:UIButton = null;
         this.gap = param2;
         if(param3 > 0)
         {
            param1.width = param3;
         }
         if(param4 > 0)
         {
            param1.height = param4;
         }
         if(btns.length > 0)
         {
            _loc5_ = btns[btns.length - 1] as UIButton;
            setXY(param1,_loc5_);
         }
         param1.addEventListener("click",onButtonClick);
         param1.toggle = true;
         addChild(param1);
         btns.push(param1);
      }
      
      protected function layout() : void
      {
         var _loc3_:int = 0;
         var _loc1_:UIButton = null;
         var _loc2_:UIButton = null;
         if(btns.length > 0)
         {
            _loc3_ = 0;
            while(_loc3_ < btns.length)
            {
               _loc1_ = btns[_loc3_] as UIButton;
               if(_loc1_)
               {
                  _loc2_ = _loc3_ > 0 ? btns[_loc3_ - 1] as UIButton : null;
                  setXY(_loc1_,_loc2_);
               }
               _loc3_++;
            }
         }
      }
      
      private function setXY(param1:UIButton, param2:UIButton) : void
      {
         if(param2 == null)
         {
            param1.x = 0;
            param1.y = 0;
            return;
         }
         if(align == "horizon")
         {
            param1.x = param2.width + param2.x + gap;
            param1.y = 0;
         }
         else if(align == "vertical")
         {
            param1.y = param2.height + param2.y + gap;
            param1.x = 0;
         }
      }
      
      protected function onButtonClick(param1:MouseEvent) : void
      {
         var _loc2_:Object = param1.target;
         _loc2_.selected = true;
         selectIndex = btns.indexOf(_loc2_);
      }
      
      protected function changeSelectButton() : void
      {
         var _loc1_:UIButton = null;
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < btns.length)
         {
            _loc1_ = btns[_loc2_] as UIButton;
            if(_loc2_ == selectIndex)
            {
               if(_loc1_.selected == false)
               {
                  _loc1_.selected = true;
               }
            }
            else if(_loc1_.selected == true)
            {
               _loc1_.selected = false;
            }
            _loc2_++;
         }
         dispatchEvent(new Event("TAB_BUTTON_CHANGE"));
      }
      
      public function clear() : void
      {
         var _loc1_:UIButton = null;
         while(this.btns.length > 0)
         {
            _loc1_ = btns.pop() as UIButton;
            this.removeChild(_loc1_);
            _loc1_.removeEventListener("click",onButtonClick);
         }
      }
      
      public function set buttonSkin(param1:String) : void
      {
         _buttonSkin = param1;
         showPreview();
      }
      
      public function get buttonSkin() : String
      {
         return _buttonSkin;
      }
      
      public function set buttonLabels(param1:Array) : void
      {
         _labels = param1;
         showPreview();
      }
      
      public function get buttonLabels() : Array
      {
         return _labels;
      }
      
      private function showPreview() : void
      {
         var _loc3_:int = 0;
         var _loc2_:int = 0;
         var _loc1_:UIButton = null;
         if(!_buttonSkin || !_labels)
         {
            return;
         }
         clear();
         _loc3_ = 0;
         _loc2_ = int(_labels.length);
         while(_loc3_ < _loc2_)
         {
            _loc1_ = new UIButton();
            _loc1_.skins = _buttonSkin;
            _loc1_.label = _labels[_loc3_];
            addButton(_loc1_);
            _loc3_++;
         }
      }
   }
}

