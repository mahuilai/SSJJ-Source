package ui
{
   import flash.display.DisplayObject;
   import flash.display.Shape;
   
   public class UIMask extends Shape
   {
      
      private var _target:DisplayObject;
      
      public function UIMask()
      {
         super();
         this.graphics.beginFill(0);
         this.graphics.drawRect(0,0,10,10);
         this.graphics.endFill();
      }
      
      public function set target(param1:DisplayObject) : void
      {
         _target = param1;
         if(_target.mask != null)
         {
            _target.mask.parent.removeChild(_target.mask);
         }
         _target.parent.addChild(this);
         _target.mask = this;
      }
      
      public function dispose() : void
      {
         if(_target != null)
         {
            _target.mask = null;
            _target = null;
         }
         if(parent != null)
         {
            parent.removeChild(this);
         }
      }
   }
}

