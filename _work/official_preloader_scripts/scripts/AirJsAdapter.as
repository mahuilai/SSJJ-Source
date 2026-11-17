package
{
   import flash.desktop.NativeApplication;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import jsmock.ClientSocket;
   import org.as3commons.logging.api.ILogger;
   import org.as3commons.logging.api.getLogger;
   import tools.js.IJSCallable;
   
   public class AirJsAdapter implements IJSCallable
   {
      
      private static const _logger:ILogger = getLogger(AirJsAdapter);
      
      private var _socket:ClientSocket = null;
      
      private var _callbackMap:Dictionary = new Dictionary(true);
      
      public function AirJsAdapter(param1:int)
      {
         super();
         _socket = new ClientSocket("localhost",param1);
         _socket.packHandle = onPackRecv;
         _socket.closeHandle = onCloseHandle;
      }
      
      public function connect() : void
      {
         _socket.connect();
      }
      
      public function set connectHandle(param1:Function) : void
      {
         _socket.connectHandle = param1;
      }
      
      private function onCloseHandle() : void
      {
         NativeApplication.nativeApplication.exit();
         MultiApplicationUtil.appClosed();
      }
      
      private function onPackRecv(param1:ByteArray) : void
      {
         var _loc3_:Function = null;
         var _loc5_:ByteArray = null;
         var _loc4_:String = null;
         var _loc2_:String = param1.readUTF();
         _logger.info("funcName:" + _loc2_);
         if(_loc2_ == "wangYiCheckGamePlus")
         {
            _loc5_ = new ByteArray();
            if(param1.bytesAvailable)
            {
               param1.readBytes(_loc5_,0,param1.bytesAvailable);
            }
            else
            {
               _logger.info("无wangYiCheckGamePlus数据");
            }
            _loc3_ = _callbackMap[_loc2_];
            if(null == _loc3_)
            {
               _logger.info("callback " + _loc2_ + " not exist");
               return;
            }
            _loc3_(_loc5_);
         }
         else
         {
            _loc4_ = "";
            if(param1.bytesAvailable)
            {
               _loc4_ = param1.readUTF();
               _logger.info("funcParam:" + _loc4_);
            }
            else
            {
               _loc4_ = "";
               _logger.info("无参数");
            }
            _loc3_ = _callbackMap[_loc2_];
            if(null == _loc3_)
            {
               _logger.info("callback " + _loc2_ + " not exist");
               return;
            }
            _loc3_(_loc4_);
         }
      }
      
      private function needLog(param1:String) : Boolean
      {
         return "airHeartBeat" != param1;
      }
      
      public function call(param1:String, param2:String) : void
      {
         if(needLog(param1))
         {
            _logger.info("call:" + param1 + ",funcParam:" + param2);
         }
         if(!this._socket.connected)
         {
            _logger.info("call " + param1 + " _socket is not connected");
            return;
         }
         var _loc3_:ByteArray = new ByteArray();
         _loc3_.endian = "littleEndian";
         _loc3_.writeUTF(param1);
         _loc3_.writeUTF(param2);
         _socket.sendBytes(_loc3_);
         if(needLog(param1))
         {
            _logger.info("call " + param1);
         }
      }
      
      public function addCallback(param1:String, param2:Function) : void
      {
         if(null != _callbackMap[param1])
         {
            _logger.error("function " + param1 + " has been registerd");
         }
         _callbackMap[param1] = param2;
      }
      
      public function removeCallback(param1:Array) : void
      {
         var _loc4_:int = 0;
         var _loc2_:String = null;
         _logger.info("removeCallback",param1);
         var _loc3_:int = 0;
         if(null != param1)
         {
            _loc3_ = int(param1.length);
         }
         _loc4_ = 0;
         while(_loc4_ < _loc3_)
         {
            _loc2_ = param1[_loc4_];
            if(null != _callbackMap[_loc2_])
            {
               delete _callbackMap[_loc2_];
            }
            _loc4_++;
         }
      }
   }
}

