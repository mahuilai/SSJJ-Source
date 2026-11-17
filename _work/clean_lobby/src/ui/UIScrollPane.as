package ui
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Rectangle;
   
   public class UIScrollPane extends UIBase
   {
      
      private var _content:Sprite;
      
      private var _horizontalScrollBar:UIScrollBar;
      
      private var _verticalScrollBar:UIScrollBar;
      
      private var _horizontalScrollPolicy:String;
      
      private var _verticalScrollPolicy:String;
      
      private var _scrollRectangle:Rectangle;
      
      public function UIScrollPane()
      {
         super();
      }
      
      override protected function preinitialize() : void
      {
         super.preinitialize();
         mouseChildren = true;
         _horizontalScrollPolicy = "auto";
         _verticalScrollPolicy = "auto";
         _scrollRectangle = new Rectangle();
      }
      
      override protected function createChildren() : void
      {
         super.createChildren();
         _horizontalScrollBar = new UIScrollBar();
         _verticalScrollBar = new UIScrollBar();
         this.addChild(_horizontalScrollBar);
         this.addChild(_verticalScrollBar);
         _horizontalScrollBar.direction = "horizontal";
         _verticalScrollBar.direction = "vertical";
      }
      
      public function set content(param1:Sprite) : void
      {
         if(_content)
         {
            _content.removeEventListener("resize",onContentResize);
            _content.x = 0;
            _content.y = 0;
         }
         _content = param1;
         if(_content)
         {
            _content.addEventListener("resize",onContentResize);
            this.addChildAt(_content,0);
         }
         callLater(update);
      }
      
      public function get content() : Sprite
      {
         return _content;
      }
      
      public function get horizontalScrollBar() : UIScrollBar
      {
         return _horizontalScrollBar;
      }
      
      public function get verticalScrollBar() : UIScrollBar
      {
         return _verticalScrollBar;
      }
      
      override public function set width(param1:Number) : void
      {
         super.width = param1;
      }
      
      override public function set height(param1:Number) : void
      {
         super.height = param1;
      }
      
      public function set verticalScrollSize(param1:Number) : void
      {
         verticalScrollBar.scrollSize = param1;
      }
      
      public function get verticalScrollSize() : Number
      {
         return verticalScrollBar.scrollSize;
      }
      
      public function set horizontalScrollSize(param1:Number) : void
      {
         horizontalScrollBar.scrollSize = param1;
      }
      
      public function get horizontalScrollSize() : Number
      {
         return horizontalScrollBar.scrollSize;
      }
      
      public function set horizontalScrollPolicy(param1:String) : void
      {
         _horizontalScrollPolicy = param1;
         callLater(update);
      }
      
      public function get horizontalScrollPolicy() : String
      {
         return _horizontalScrollPolicy;
      }
      
      public function set verticalScrollPolicy(param1:String) : void
      {
         _verticalScrollPolicy = param1;
         callLater(update);
      }
      
      public function get verticalScrollPolicy() : String
      {
         return _verticalScrollPolicy;
      }
      
      private function hideScrollBar(param1:UIScrollBar) : void
      {
         if(this.contains(param1))
         {
            this.removeChild(param1);
         }
         param1.target = null;
      }
      
      private function showScrollBar(param1:UIScrollBar) : void
      {
         this.addChild(param1);
         param1.target = content;
      }
      
      private function onContentResize(param1:Event) : void
      {
         update();
      }
      
      private function get isShowHorizontalScrollBar() : Boolean
      {
         return this.contains(horizontalScrollBar);
      }
      
      private function get isShowVerticalScrollBar() : Boolean
      {
         return this.contains(verticalScrollBar);
      }
      
      public function updateDelay() : void
      {
         callLater(update);
      }
      
      public function update() : void
      {
         if(_content == null)
         {
            hideScrollBar(verticalScrollBar);
            hideScrollBar(horizontalScrollBar);
            return;
         }
         if(this._width > 0 && horizontalScrollPolicy == "on" || horizontalScrollPolicy == "auto" && this.width < _content.width)
         {
            showScrollBar(horizontalScrollBar);
            horizontalScrollBar.max = _content.width;
         }
         else
         {
            hideScrollBar(horizontalScrollBar);
            _content.x = 0;
         }
         if(this._height > 0 && verticalScrollPolicy == "on" || verticalScrollPolicy == "auto" && this.height < _content.height)
         {
            showScrollBar(verticalScrollBar);
            verticalScrollBar.max = _content.height;
         }
         else
         {
            hideScrollBar(verticalScrollBar);
            _content.y = 0;
         }
         if(!isShowVerticalScrollBar && !isShowHorizontalScrollBar)
         {
            _content.scrollRect = null;
            return;
         }
         if(isShowVerticalScrollBar && isShowHorizontalScrollBar)
         {
            horizontalScrollBar.width = this.width - verticalScrollBar.width;
            verticalScrollBar.height = this.height - horizontalScrollBar.height;
            _scrollRectangle.width = this.width - verticalScrollBar.width;
            _scrollRectangle.height = this.height - horizontalScrollBar.height;
         }
         else
         {
            horizontalScrollBar.width = this.width;
            verticalScrollBar.height = this.height;
            _scrollRectangle.width = this.width;
            _scrollRectangle.height = this.height;
            if(isShowHorizontalScrollBar)
            {
               verticalScrollBar.height = this.height - horizontalScrollBar.height;
               _scrollRectangle.height = this.height - horizontalScrollBar.height;
            }
            if(isShowVerticalScrollBar)
            {
               horizontalScrollBar.width = this.width - verticalScrollBar.width;
               _scrollRectangle.width = this.width - verticalScrollBar.width;
            }
         }
         _scrollRectangle.x = _scrollRectangle.y = 0;
         if(isShowVerticalScrollBar)
         {
            verticalScrollBar.scrollRectangle = _scrollRectangle;
         }
         if(isShowHorizontalScrollBar)
         {
            horizontalScrollBar.scrollRectangle = _scrollRectangle;
         }
         verticalScrollBar.x = this.width - verticalScrollBar.width;
         horizontalScrollBar.y = this.height - horizontalScrollBar.height;
      }
   }
}

