package jsmock
{
   import flash.desktop.NativeApplication;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.Socket;
   import flash.utils.ByteArray;
   import org.as3commons.logging.api.ILogger;
   import org.as3commons.logging.api.getLogger;
   
   public class ClientSocket
   {
      
      private static const _logger:ILogger = getLogger(ClientSocket);
      
      private var _serverIp:String = null;
      
      private var _serverPort:uint = 0;
      
      private var _socket:Socket = null;
      
      private var _timeout:uint = 20000;
      
      private var _dataLen:int = 0;
      
      private var _packHandle:Function = null;
      
      private var _connectHandle:Function = null;
      
      private var _closeHandle:Function = null;
      
      public function ClientSocket(param1:String, param2:uint)
      {
         super();
         this._serverIp = param1;
         this._serverPort = param2;
         this._socket = new Socket();
         this._socket.endian = "littleEndian";
      }
      
      public function connect() : void
      {
         if(_socket.connected)
         {
            return;
         }
         this._socket.timeout = _timeout;
         this._socket.connect(this._serverIp,this._serverPort);
         this._socket.addEventListener("connect",onConnected);
         this._socket.addEventListener("close",onClosed);
         this._socket.addEventListener("ioError",onError);
         this._socket.addEventListener("securityError",secErrorHandler);
         this._socket.addEventListener("socketData",recvData);
      }
      
      public function close() : void
      {
         this._socket.removeEventListener("connect",onConnected);
         this._socket.removeEventListener("ioError",onError);
         this._socket.removeEventListener("securityError",secErrorHandler);
         this._socket.removeEventListener("socketData",recvData);
         if(this._socket.connected)
         {
            this._socket.close();
         }
      }
      
      public function dispose() : void
      {
         close();
         this._packHandle = null;
      }
      
      public function get connected() : Boolean
      {
         return this._socket.connected;
      }
      
      public function sendBytes(param1:ByteArray) : void
      {
         this._socket.writeInt(param1.length);
         this._socket.writeBytes(param1);
         this._socket.flush();
      }
      
      private function onConnected(param1:Event) : void
      {
         _logger.info("socket connected");
         if(null != this._connectHandle)
         {
            this._connectHandle.apply();
         }
      }
      
      private function onClosed(param1:Event) : void
      {
         _logger.info("socket closed");
         if(null != this._closeHandle)
         {
            this._closeHandle.apply();
         }
      }
      
      private function onError(param1:IOErrorEvent) : void
      {
         _logger.error("socket onError",[param1.toString(),param1]);
         _socket.close();
         NativeApplication.nativeApplication.exit();
         MultiApplicationUtil.appClosed();
      }
      
      private function secErrorHandler(param1:SecurityErrorEvent) : void
      {
         _logger.error("socket secErrorHandler",[param1.toString(),param1]);
         _socket.close();
         NativeApplication.nativeApplication.exit();
         MultiApplicationUtil.appClosed();
      }
      
      private function recvData(param1:ProgressEvent) : void
      {
         var _loc2_:ByteArray = null;
         while(true)
         {
            if(0 == _dataLen)
            {
               if(!_socket.connected)
               {
                  return;
               }
               if(_socket.bytesAvailable < 4)
               {
                  break;
               }
               _dataLen = _socket.readInt();
            }
            else
            {
               if(_socket.bytesAvailable < _dataLen)
               {
                  break;
               }
               _loc2_ = new ByteArray();
               _loc2_.endian = "littleEndian";
               _socket.readBytes(_loc2_,0,_dataLen);
               _dataLen = 0;
               onPacket(_loc2_);
            }
         }
      }
      
      public function set packHandle(param1:Function) : void
      {
         this._packHandle = param1;
      }
      
      public function set connectHandle(param1:Function) : void
      {
         this._connectHandle = param1;
      }
      
      public function set closeHandle(param1:Function) : void
      {
         this._closeHandle = param1;
      }
      
      private function onPacket(param1:ByteArray) : void
      {
         param1.position = 0;
         this._packHandle(param1);
      }
   }
}

