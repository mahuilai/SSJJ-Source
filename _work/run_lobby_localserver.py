import json, subprocess, time, os, threading, http.server
root=r"D:\逆向\SSJJ双塔惊魂"
dir=os.path.join(root,"_work","lobby_run")
log=os.path.join(dir,"ruffle_localserver.log")
class Handler(http.server.SimpleHTTPRequestHandler):
    def log_message(self, fmt, *args):
        with open(log,"a",encoding="utf-8") as f: f.write("HTTP "+fmt%args+"\n")
server=http.server.ThreadingHTTPServer(("127.0.0.1",8768),lambda *a,**kw: Handler(*a,directory=dir,**kw))
threading.Thread(target=server.serve_forever,daemon=True).start()
paras=json.load(open(r"D:\SSJJ\SSJJ-4399\Lobby\paras.dat",encoding="utf-8"))
local="http://127.0.0.1:8768/"
paras.update({"resurl":local,"globalResurl":local,"resurl_back":local,"testClientResurl":local,"resConfigFileName":"res_config_38a3d077fefc79e447d6ea3efe8c8f66.xml","loaderInfoLoaderURL":"http%3A%2F%2F127.0.0.1%3A8768%2Flobby_truely.php"})
args=[os.path.join(root,"_tools","ruffle","ruffle.exe"),"--width","1280","--height","800","-s","show-all","--base",local,"--player-runtime","air","--filesystem-access-mode","allow","--tcp-connections","allow","--storage","memory"]
for k,v in paras.items():
    if isinstance(v,(str,int,float,bool)): args += ["-P",f"{k}={v}"]
args += [local+"Lobby_main.swf"]
with open(log,"w",encoding="utf-8") as out:
    p=subprocess.Popen(args,cwd=dir,stdout=out,stderr=subprocess.STDOUT,text=True)
time.sleep(20)
print("pid",p.pid,"alive",p.poll() is None)
server.shutdown()
print(open(log,encoding="utf-8").read()[-30000:])
