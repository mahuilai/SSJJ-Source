package ui
{
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextFormat;
   
   public class UIPage extends UIBase implements IUIPage
   {
      
      private var _totalPage:int = 0;
      
      private var _firstPageBtn:UIButton;
      
      private var _lastPageBtn:UIButton;
      
      private var _prePageBtn:UIButton;
      
      private var _nextPageBtn:UIButton;
      
      private var _pageNumberLB:UILabel;
      
      private var _curPageInex:int = 1;
      
      private var _maxPageNum:int;
      
      private var _skin:String;
      
      public var showCurPage:Boolean = true;
      
      public function UIPage()
      {
         super();
         init();
      }
      
      public function hideFirstAndLast() : void
      {
         _lastPageBtn.visible = false;
         _firstPageBtn.visible = false;
      }
      
      public function set skin(param1:String) : void
      {
         _skin = param1;
         _lastPageBtn.skin = "last_" + param1;
         _firstPageBtn.skin = "first_" + param1;
         _prePageBtn.skin = "pre_" + param1;
         _nextPageBtn.skin = "next_" + param1;
      }
      
      public function get skin() : String
      {
         return _skin;
      }
      
      private function init() : void
      {
         _firstPageBtn = new UIButton();
         _lastPageBtn = new UIButton();
         _prePageBtn = new UIButton();
         _nextPageBtn = new UIButton();
         _firstPageBtn.x = 0;
         _prePageBtn.x = 32;
         _nextPageBtn.x = 148;
         _lastPageBtn.x = 178;
         _pageNumberLB = new UILabel();
         addChild(_pageNumberLB);
         _pageNumberLB.format = new TextFormat("宋体",15,16777215,null,null,null,null,null,"center");
         _pageNumberLB.x = 53;
         _pageNumberLB.y = 2;
         _pageNumberLB.width = 96;
         addChild(_firstPageBtn);
         addChild(_lastPageBtn);
         addChild(_prePageBtn);
         addChild(_nextPageBtn);
         _firstPageBtn.addEventListener("click",onClickFirstPageBtn);
         _lastPageBtn.addEventListener("click",onClickLastPageBtn);
         _prePageBtn.addEventListener("click",onClickPrePageBtn);
         _nextPageBtn.addEventListener("click",onClickNextPageBtn);
         _totalPage = 0;
      }
      
      private function onClickFirstPageBtn(param1:MouseEvent) : void
      {
         currentPage = 1;
      }
      
      private function onClickLastPageBtn(param1:MouseEvent) : void
      {
         currentPage = _totalPage;
      }
      
      private function onClickPrePageBtn(param1:MouseEvent) : void
      {
         currentPage = currentPage - 1;
      }
      
      private function onClickNextPageBtn(param1:MouseEvent) : void
      {
         currentPage = currentPage + 1;
      }
      
      public function get totalPage() : int
      {
         return _totalPage;
      }
      
      public function set totalPage(param1:int) : void
      {
         if(_totalPage == param1)
         {
            return;
         }
         _totalPage = param1;
         if(_totalPage == 0)
         {
            currentPage = 0;
         }
         else if(showCurPage)
         {
            currentPage = currentPage == 0 ? 1 : currentPage;
         }
         else
         {
            currentPage = 1;
         }
      }
      
      public function get currentPage() : int
      {
         return _curPageInex;
      }
      
      public function set currentPage(param1:int) : void
      {
         if(param1 < 0 || param1 > _totalPage)
         {
            param1 = 1;
         }
         _curPageInex = param1;
         _pageNumberLB.width = _nextPageBtn.x - _prePageBtn.x + _nextPageBtn.width;
         _pageNumberLB.x = _prePageBtn.x;
         _pageNumberLB.text = _curPageInex + "/" + _totalPage;
         if(_totalPage == 0)
         {
            _firstPageBtn.enabled = false;
            _prePageBtn.enabled = false;
            _nextPageBtn.enabled = false;
            _lastPageBtn.enabled = false;
            dispatchEvent(new Event("change"));
            return;
         }
         _firstPageBtn.enabled = _curPageInex != 1;
         _prePageBtn.enabled = _curPageInex != 1;
         _nextPageBtn.enabled = _curPageInex != _totalPage;
         _lastPageBtn.enabled = _curPageInex != _totalPage;
         dispatchEvent(new Event("change"));
      }
   }
}

