package fl.controls
{
   import fl.core.UIComponent;
   import fl.events.ComponentEvent;
   import fl.managers.IFocusManagerComponent;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class LabelButton extends BaseButton implements IFocusManagerComponent
   {
      
      public static var createAccessibilityImplementation:Function;
      
      private static var defaultStyles:Object = {
         "icon":null,
         "upIcon":null,
         "downIcon":null,
         "overIcon":null,
         "disabledIcon":null,
         "selectedDisabledIcon":null,
         "selectedUpIcon":null,
         "selectedDownIcon":null,
         "selectedOverIcon":null,
         "textFormat":null,
         "disabledTextFormat":null,
         "textPadding":5,
         "embedFonts":false
      };
      
      public var textField:TextField;
      
      protected var _labelPlacement:String = "right";
      
      protected var _toggle:Boolean = false;
      
      protected var icon:DisplayObject;
      
      protected var oldMouseState:String;
      
      protected var _label:String = "Label";
      
      protected var mode:String = "center";
      
      public function LabelButton()
      {
         super();
      }
      
      public static function getStyleDefinition() : Object
      {
         return mergeStyles(defaultStyles,BaseButton.getStyleDefinition());
      }
      
      public function get label() : String
      {
         return _label;
      }
      
      public function set label(param1:String) : void
      {
         _label = param1;
         if(textField.text != _label)
         {
            textField.text = _label;
            dispatchEvent(new ComponentEvent("labelChange"));
         }
         invalidate("size");
         invalidate("styles");
      }
      
      public function get labelPlacement() : String
      {
         return _labelPlacement;
      }
      
      public function set labelPlacement(param1:String) : void
      {
         _labelPlacement = param1;
         invalidate("size");
      }
      
      public function get toggle() : Boolean
      {
         return _toggle;
      }
      
      public function set toggle(param1:Boolean) : void
      {
         if(!param1 && super.selected)
         {
            selected = false;
         }
         _toggle = param1;
         if(_toggle)
         {
            addEventListener("click",toggleSelected,false,0,true);
         }
         else
         {
            removeEventListener("click",toggleSelected);
         }
         invalidate("state");
      }
      
      protected function toggleSelected(param1:MouseEvent) : void
      {
         selected = !selected;
         dispatchEvent(new Event("change",true));
      }
      
      override public function get selected() : Boolean
      {
         return _toggle ? _selected : false;
      }
      
      override public function set selected(param1:Boolean) : void
      {
         _selected = param1;
         if(_toggle)
         {
            invalidate("state");
         }
      }
      
      override protected function configUI() : void
      {
         super.configUI();
         textField = new TextField();
         textField.type = "dynamic";
         textField.selectable = false;
         addChild(textField);
      }
      
      override protected function draw() : void
      {
         if(textField.text != _label)
         {
            label = _label;
         }
         if(isInvalid("styles","state"))
         {
            drawBackground();
            drawIcon();
            drawTextFormat();
            invalidate("size",false);
         }
         if(isInvalid("size"))
         {
            drawLayout();
         }
         if(isInvalid("size","styles"))
         {
            if(isFocused && focusManager.showFocusIndicator)
            {
               drawFocus(true);
            }
         }
         validate();
      }
      
      protected function drawIcon() : void
      {
         var _loc3_:DisplayObject = icon;
         var _loc1_:String = enabled ? mouseState : "disabled";
         if(selected)
         {
            _loc1_ = "selected" + _loc1_.substr(0,1).toUpperCase() + _loc1_.substr(1);
         }
         _loc1_ += "Icon";
         var _loc2_:Object = getStyleValue(_loc1_);
         if(_loc2_ == null)
         {
            _loc2_ = getStyleValue("icon");
         }
         if(_loc2_ != null)
         {
            icon = getDisplayObjectInstance(_loc2_);
         }
         if(icon != null)
         {
            addChildAt(icon,1);
         }
         if(_loc3_ != null && _loc3_ != icon)
         {
            removeChild(_loc3_);
         }
      }
      
      protected function drawTextFormat() : void
      {
         var _loc2_:Object = UIComponent.getStyleDefinition();
         var _loc1_:TextFormat = enabled ? _loc2_.defaultTextFormat as TextFormat : _loc2_.defaultDisabledTextFormat as TextFormat;
         textField.setTextFormat(_loc1_);
         var _loc3_:TextFormat = getStyleValue(enabled ? "textFormat" : "disabledTextFormat") as TextFormat;
         if(_loc3_ != null)
         {
            textField.setTextFormat(_loc3_);
         }
         else
         {
            _loc3_ = _loc1_;
         }
         textField.defaultTextFormat = _loc3_;
         setEmbedFont();
      }
      
      protected function setEmbedFont() : *
      {
         var _loc1_:Object = getStyleValue("embedFonts");
         if(_loc1_ != null)
         {
            textField.embedFonts = _loc1_;
         }
      }
      
      override protected function drawLayout() : void
      {
         var _loc5_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = Number(getStyleValue("textPadding"));
         var _loc1_:String = icon == null && mode == "center" ? "top" : _labelPlacement;
         textField.height = textField.textHeight + 4;
         var _loc6_:Number = textField.textWidth + 4;
         var _loc8_:Number = textField.textHeight + 4;
         var _loc7_:Number = icon == null ? 0 : icon.width + _loc4_;
         var _loc2_:Number = icon == null ? 0 : icon.height + _loc4_;
         textField.visible = label.length > 0;
         if(icon != null)
         {
            icon.x = Math.round((width - icon.width) / 2);
            icon.y = Math.round((height - icon.height) / 2);
         }
         if(textField.visible == false)
         {
            textField.width = 0;
            textField.height = 0;
         }
         else if(_loc1_ == "bottom" || _loc1_ == "top")
         {
            _loc5_ = Math.max(0,Math.min(_loc6_,width - 2 * _loc4_));
            if(height - 2 > _loc8_)
            {
               _loc3_ = _loc8_;
            }
            else
            {
               _loc3_ = height - 2;
            }
            textField.width = _loc6_ = _loc5_;
            textField.height = _loc8_ = _loc3_;
            textField.x = Math.round((width - _loc6_) / 2);
            textField.y = Math.round((height - textField.height - _loc2_) / 2 + (_loc1_ == "bottom" ? _loc2_ : 0));
            if(icon != null)
            {
               icon.y = Math.round(_loc1_ == "bottom" ? textField.y - _loc2_ : textField.y + textField.height + _loc4_);
            }
         }
         else
         {
            _loc5_ = Math.max(0,Math.min(_loc6_,width - _loc7_ - 2 * _loc4_));
            textField.width = _loc6_ = _loc5_;
            textField.x = Math.round((width - _loc6_ - _loc7_) / 2 + (_loc1_ != "left" ? _loc7_ : 0));
            textField.y = Math.round((height - textField.height) / 2);
            if(icon != null)
            {
               icon.x = Math.round(_loc1_ != "left" ? textField.x - _loc7_ : textField.x + _loc6_ + _loc4_);
            }
         }
         super.drawLayout();
      }
      
      override protected function keyDownHandler(param1:KeyboardEvent) : void
      {
         if(!enabled)
         {
            return;
         }
         if(param1.keyCode == 32)
         {
            if(oldMouseState == null)
            {
               oldMouseState = mouseState;
            }
            setMouseState("down");
            startPress();
         }
      }
      
      override protected function keyUpHandler(param1:KeyboardEvent) : void
      {
         if(!enabled)
         {
            return;
         }
         if(param1.keyCode == 32)
         {
            setMouseState(oldMouseState);
            oldMouseState = null;
            endPress();
            dispatchEvent(new MouseEvent("click"));
         }
      }
      
      override protected function initializeAccessibility() : void
      {
         if(LabelButton.createAccessibilityImplementation != null)
         {
            LabelButton.createAccessibilityImplementation(this);
         }
      }
   }
}

