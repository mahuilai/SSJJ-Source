package ui
{
   import fl.controls.DataGrid;
   import fl.data.DataProvider;
   import flash.utils.getDefinitionByName;
   
   public class UIDataGrid extends DataGrid
   {
      
      private var _cellRendererName:String = "";
      
      private var _dataSource:Array;
      
      public function UIDataGrid()
      {
         super();
      }
      
      public function set cellRenderName(param1:String) : void
      {
         var _loc2_:Object = null;
         _cellRendererName = param1;
         try
         {
            _loc2_ = getDefinitionByName(param1);
         }
         catch(e:Error)
         {
            return;
         }
         this.setStyle("cellRenderer",_loc2_);
      }
      
      public function get cellRenderName() : String
      {
         return this._cellRendererName;
      }
      
      public function set columnString(param1:String) : void
      {
         var _loc2_:Array = param1.split(":");
         this.columns = _loc2_;
      }
      
      public function get dataSource() : Array
      {
         return _dataSource;
      }
      
      public function set dataSource(param1:Array) : void
      {
         _dataSource = param1;
         if(!param1)
         {
            return;
         }
         this.dataProvider = new DataProvider(param1);
      }
   }
}

