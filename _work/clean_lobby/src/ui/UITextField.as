package ui
{
   import flash.filters.GlowFilter;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import style.I18NConfig;
   
   public class UITextField extends TextField
   {
      
      public function UITextField()
      {
         super();
         initUI();
      }
      
      protected function initUI() : void
      {
         this.selectable = false;
         this.defaultTextFormat = new TextFormat("宋体",12,16777215);
         var _loc1_:GlowFilter = new GlowFilter(0,1,2,2,2000);
         filters = [_loc1_];
      }
      
      public function set zLanID(param1:String) : void
      {
         if(!param1 || param1.length == 0)
         {
            return;
         }
         try
         {
            text = I18NConfig.getText(param1);
         }
         catch(e:Error)
         {
         }
      }
   }
}

