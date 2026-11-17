package fl.controls
{
   import fl.managers.IFocusManager;
   import fl.managers.IFocusManagerGroup;
   import flash.display.DisplayObject;
   import flash.display.Graphics;
   import flash.display.Shape;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   
   public class RadioButton extends LabelButton implements IFocusManagerGroup
   {
      
      public static var createAccessibilityImplementation:Function;
      
      private static var defaultStyles:Object = {
         "icon":null,
         "upIcon":"RadioButton_upIcon",
         "downIcon":"RadioButton_downIcon",
         "overIcon":"RadioButton_overIcon",
         "disabledIcon":"RadioButton_disabledIcon",
         "selectedDisabledIcon":"RadioButton_selectedDisabledIcon",
         "selectedUpIcon":"RadioButton_selectedUpIcon",
         "selectedDownIcon":"RadioButton_selectedDownIcon",
         "selectedOverIcon":"RadioButton_selectedOverIcon",
         "focusRectSkin":null,
         "focusRectPadding":null,
         "textFormat":null,
         "disabledTextFormat":null,
         "embedFonts":null,
         "textPadding":5
      };
      
      protected var _value:Object;
      
      protected var _group:RadioButtonGroup;
      
      protected var defaultGroupName:String = "RadioButtonGroup";
      
      public function RadioButton()
      {
         super();
         mode = "border";
         groupName = defaultGroupName;
      }
      
      public static function getStyleDefinition() : Object
      {
         return defaultStyles;
      }
      
      override public function get toggle() : Boolean
      {
         return true;
      }
      
      override public function set toggle(param1:Boolean) : void
      {
         throw new Error("Warning: You cannot change a RadioButtons toggle.");
      }
      
      override public function get autoRepeat() : Boolean
      {
         return false;
      }
      
      override public function set autoRepeat(param1:Boolean) : void
      {
      }
      
      override public function get selected() : Boolean
      {
         return super.selected;
      }
      
      override public function set selected(param1:Boolean) : void
      {
         if(param1 == false || selected)
         {
            return;
         }
         if(_group != null)
         {
            _group.selection = this;
         }
         else
         {
            super.selected = param1;
         }
      }
      
      override protected function configUI() : void
      {
         super.configUI();
         super.toggle = true;
         var _loc2_:Shape = new Shape();
         var _loc1_:Graphics = _loc2_.graphics;
         _loc1_.beginFill(0,0);
         _loc1_.drawRect(0,0,100,100);
         _loc1_.endFill();
         background = _loc2_ as DisplayObject;
         addChildAt(background,0);
         addEventListener("click",handleClick,false,0,true);
      }
      
      override protected function drawLayout() : void
      {
         super.drawLayout();
         var _loc1_:Number = Number(getStyleValue("textPadding"));
         switch(_labelPlacement)
         {
            case "right":
               icon.x = _loc1_;
               textField.x = icon.x + (icon.width + _loc1_);
               background.width = textField.x + textField.width + _loc1_;
               background.height = Math.max(textField.height,icon.height) + _loc1_ * 2;
               break;
            case "left":
               icon.x = width - icon.width - _loc1_;
               textField.x = width - icon.width - _loc1_ * 2 - textField.width;
               background.width = textField.width + icon.width + _loc1_ * 3;
               background.height = Math.max(textField.height,icon.height) + _loc1_ * 2;
               break;
            case "top":
            case "bottom":
               background.width = Math.max(textField.width,icon.width) + _loc1_ * 2;
               background.height = textField.height + icon.height + _loc1_ * 3;
         }
         background.x = Math.min(icon.x - _loc1_,textField.x - _loc1_);
         background.y = Math.min(icon.y - _loc1_,textField.y - _loc1_);
      }
      
      public function get groupName() : String
      {
         return _group == null ? null : _group.name;
      }
      
      public function set groupName(param1:String) : void
      {
         if(_group != null)
         {
            _group.removeRadioButton(this);
            _group.removeEventListener("change",handleChange);
         }
         _group = param1 == null ? null : RadioButtonGroup.getGroup(param1);
         if(_group != null)
         {
            _group.addRadioButton(this);
            _group.addEventListener("change",handleChange,false,0,true);
         }
      }
      
      public function get group() : RadioButtonGroup
      {
         return _group;
      }
      
      public function set group(param1:RadioButtonGroup) : void
      {
         groupName = param1.name;
      }
      
      public function get value() : Object
      {
         return _value;
      }
      
      public function set value(param1:Object) : void
      {
         _value = param1;
      }
      
      override public function drawFocus(param1:Boolean) : void
      {
         var _loc2_:Number = NaN;
         super.drawFocus(param1);
         if(param1)
         {
            _loc2_ = Number(getStyleValue("focusRectPadding"));
            uiFocusRect.x = background.x - _loc2_;
            uiFocusRect.y = background.y - _loc2_;
            uiFocusRect.width = background.width + _loc2_ * 2;
            uiFocusRect.height = background.height + _loc2_ * 2;
         }
      }
      
      protected function handleChange(param1:Event) : void
      {
         super.selected = _group.selection == this;
         dispatchEvent(new Event("change",true));
      }
      
      protected function handleClick(param1:MouseEvent) : void
      {
         if(_group == null)
         {
            return;
         }
         _group.dispatchEvent(new MouseEvent("click",true));
      }
      
      override protected function draw() : void
      {
         super.draw();
      }
      
      override protected function drawBackground() : void
      {
      }
      
      override protected function initializeAccessibility() : void
      {
         if(RadioButton.createAccessibilityImplementation != null)
         {
            RadioButton.createAccessibilityImplementation(this);
         }
      }
      
      override protected function keyDownHandler(param1:KeyboardEvent) : void
      {
         switch(int(param1.keyCode) - 32)
         {
            case 0:
               setThis();
               _toggle = false;
            default:
               super.keyDownHandler(param1);
               break;
            case 5:
               setPrev(!param1.ctrlKey);
               param1.stopPropagation();
               break;
            case 6:
               setPrev(!param1.ctrlKey);
               param1.stopPropagation();
               break;
            case 7:
               setNext(!param1.ctrlKey);
               param1.stopPropagation();
               break;
            case 8:
               setNext(!param1.ctrlKey);
               param1.stopPropagation();
         }
      }
      
      override protected function keyUpHandler(param1:KeyboardEvent) : void
      {
         super.keyUpHandler(param1);
         if(param1.keyCode == 32 && !_toggle)
         {
            _toggle = true;
         }
      }
      
      private function setPrev(param1:Boolean = true) : void
      {
         var _loc4_:RadioButton = null;
         var _loc2_:RadioButtonGroup = _group;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:IFocusManager = focusManager;
         if(_loc3_)
         {
            _loc3_.showFocusIndicator = true;
         }
         var _loc6_:int;
         var _loc5_:int = _loc6_ = _loc2_.getRadioButtonIndex(this);
         if(_loc6_ != -1)
         {
            while(true)
            {
               _loc5_ = int(--_loc5_ == -1 ? _loc2_.numRadioButtons - 1 : _loc5_);
               _loc4_ = _loc2_.getRadioButtonAt(_loc5_);
               if(_loc4_ && _loc4_.enabled)
               {
                  break;
               }
               if(param1 && _loc2_.getRadioButtonAt(_loc5_) != _loc2_.selection)
               {
                  _loc2_.selection = this;
               }
               this.drawFocus(true);
               if(_loc5_ != _loc6_)
               {
                  continue;
               }
            }
            if(param1)
            {
               _loc2_.selection = _loc4_;
            }
            _loc4_.setFocus();
            return;
         }
      }
      
      private function setNext(param1:Boolean = true) : void
      {
         var _loc4_:RadioButton = null;
         var _loc2_:RadioButtonGroup = _group;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:IFocusManager = focusManager;
         if(_loc3_)
         {
            _loc3_.showFocusIndicator = true;
         }
         var _loc7_:int = _loc2_.getRadioButtonIndex(this);
         var _loc6_:Number = _loc2_.numRadioButtons;
         var _loc5_:int = _loc7_;
         if(_loc7_ != -1)
         {
            while(true)
            {
               _loc5_ = int(++_loc5_ > _loc2_.numRadioButtons - 1 ? 0 : _loc5_);
               _loc4_ = _loc2_.getRadioButtonAt(_loc5_);
               if(_loc4_ && _loc4_.enabled)
               {
                  break;
               }
               if(param1 && _loc2_.getRadioButtonAt(_loc5_) != _loc2_.selection)
               {
                  _loc2_.selection = this;
               }
               this.drawFocus(true);
               if(_loc5_ != _loc7_)
               {
                  continue;
               }
            }
            if(param1)
            {
               _loc2_.selection = _loc4_;
            }
            _loc4_.setFocus();
            return;
         }
      }
      
      private function setThis() : void
      {
         var _loc1_:RadioButtonGroup = _group;
         if(_loc1_ != null)
         {
            if(_loc1_.selection != this)
            {
               _loc1_.selection = this;
            }
         }
         else
         {
            super.selected = true;
         }
      }
   }
}

