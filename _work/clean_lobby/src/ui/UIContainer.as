package ui
{
   import flash.display.DisplayObject;
   import utils.UIUtil;
   
   public dynamic class UIContainer extends UIBase
   {
      
      public function UIContainer()
      {
         super();
         mouseChildren = true;
      }
      
      public function initUI(param1:XML) : void
      {
         UIUtil.initUI(this,param1);
      }
      
      protected function removeAllChild() : void
      {
         var _loc1_:DisplayObject = null;
         while(this.numChildren > 0)
         {
            _loc1_ = this.removeChildAt(0);
            _loc1_ = null;
         }
      }
   }
}

