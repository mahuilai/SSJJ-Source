package ui
{
   import fl.data.DataProvider;
   
   internal interface IUIList
   {
      
      function set dataProvider(param1:DataProvider) : void;
      
      function get dataProvider() : DataProvider;
      
      function addItem(param1:Object) : void;
      
      function addItemAt(param1:Object, param2:int) : void;
      
      function removeItem(param1:Object) : void;
      
      function removeItemAt(param1:int) : void;
      
      function set selectedItem(param1:Object) : void;
      
      function get selectedItem() : Object;
      
      function clearItemPool() : void;
      
      function set columnCount(param1:int) : void;
      
      function get columnCount() : int;
      
      function set rowCount(param1:int) : void;
      
      function get rowCount() : int;
      
      function set rowHeight(param1:int) : void;
      
      function get rowHeight() : int;
      
      function set columnWidth(param1:int) : void;
      
      function get columnWidth() : int;
      
      function set cellRenderer(param1:Class) : void;
      
      function get cellRenderer() : Class;
      
      function set cellRendererName(param1:String) : void;
      
      function get cellRendererName() : String;
      
      function get pageSize() : int;
      
      function getDataIndex(param1:int) : int;
      
      function set page(param1:IUIPage) : void;
      
      function get page() : IUIPage;
      
      function get scrollPane() : UIScrollPane;
      
      function set horizontalScrollPolicy(param1:String) : void;
      
      function get horizontalScrollPolicy() : String;
      
      function set verticalScrollPolicy(param1:String) : void;
      
      function get verticalScrollPolicy() : String;
      
      function set scrollBarSkins(param1:String) : void;
      
      function get scrollBarSkins() : String;
      
      function set verticalScrollBarSkins(param1:String) : void;
      
      function get verticalScrollBarSkins() : String;
      
      function set horizontalScrollBarSkins(param1:String) : void;
      
      function get horizontalScrollBarSkins() : String;
   }
}

