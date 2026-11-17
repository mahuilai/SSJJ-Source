package ui
{
   import flash.events.MouseEvent;
   
   public class UIComboboxCellRenderer extends UICellRenderer
   {
      
      public var upBg:UIImage;
      
      public var overBg:UIImage;
      
      public var textField:UILabel;
      
      public function UIComboboxCellRenderer()
      {
         super();
         styleName = "UIComboboxDropListCell";
         mouseChildren = false;
      }
      
      override protected function createChildren() : void
      {
         upBg = new UIImage();
         overBg = new UIImage();
         textField = new UILabel();
         this.addChild(upBg);
         this.addChild(overBg);
         this.addChild(textField);
         overBg.visible = false;
      }
      
      override public function set selected(param1:Boolean) : void
      {
         super.selected = param1;
         if(overBg)
         {
            overBg.visible = param1;
         }
         if(upBg)
         {
            upBg.visible = !param1;
         }
      }
      
      override public function set data(param1:Object) : void
      {
         super.data = param1;
         textField.text = param1.label;
         this.addEventListener("rollOut",mouseEventHandler);
         this.addEventListener("rollOver",mouseEventHandler);
      }
      
      override public function set width(param1:Number) : void
      {
         super.width = param1;
         overBg.width = param1;
         upBg.width = param1;
         textField.width = param1;
      }
      
      override public function set height(param1:Number) : void
      {
         super.height = param1;
         overBg.height = param1;
         upBg.height = param1;
         textField.height = param1;
      }
      
      private function mouseEventHandler(param1:MouseEvent) : void
      {
         if(param1.type == "rollOver")
         {
            if(overBg)
            {
               overBg.visible = true;
            }
            if(upBg)
            {
               upBg.visible = false;
            }
         }
         else
         {
            if(overBg)
            {
               overBg.visible = selected;
            }
            if(upBg)
            {
               upBg.visible = !selected;
            }
         }
      }
      
      override public function dispose() : void
      {
         super.dispose();
         textField.text = "";
         this.removeEventListener("rollOut",mouseEventHandler);
         this.removeEventListener("rollOver",mouseEventHandler);
      }
   }
}

