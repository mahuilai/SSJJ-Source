package ui
{
   import flash.events.Event;
   import flash.events.TextEvent;
   
   public class UITextInput extends UILabel
   {
      
      public function UITextInput(param1:String = "", param2:String = null)
      {
         super(param1,param2);
      }
      
      override protected function initialize() : void
      {
         super.initialize();
         width = 128;
         height = 22;
         selectable = true;
         _textField.type = "input";
         _textField.autoSize = "none";
         _textField.addEventListener("change",onTextFieldChange);
         _textField.addEventListener("textInput",onTextFieldTextInput);
      }
      
      private function onTextFieldTextInput(param1:TextEvent) : void
      {
         param1.stopPropagation();
         dispatchEvent(param1.clone());
      }
      
      protected function onTextFieldChange(param1:Event) : void
      {
         param1.stopPropagation();
         text = _textField.text;
         dispatchEvent(param1.clone());
      }
      
      override public function set text(param1:String) : void
      {
         _htmlText = null;
         if(_text != param1)
         {
            _text = param1;
            changeText();
         }
      }
      
      override public function set htmlText(param1:String) : void
      {
         _text = null;
         if(_htmlText != param1)
         {
            _htmlText = param1;
            changeText();
         }
      }
      
      public function get restrict() : String
      {
         return _textField.restrict;
      }
      
      public function set restrict(param1:String) : void
      {
         _textField.restrict = param1;
      }
      
      public function get editable() : Boolean
      {
         return _textField.type == "input";
      }
      
      public function set editable(param1:Boolean) : void
      {
         _textField.type = param1 ? "input" : "dynamic";
      }
      
      public function get maxChars() : int
      {
         return _textField.maxChars;
      }
      
      public function set maxChars(param1:int) : void
      {
         _textField.maxChars = param1;
      }
      
      public function setSelection(param1:int, param2:int) : void
      {
         _textField.setSelection(param1,param2);
      }
   }
}

