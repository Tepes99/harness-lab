import json, sqlite3, sys
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
db = sqlite3.connect(sys.argv[2], check_same_thread=False)
db.execute("CREATE TABLE IF NOT EXISTS memory (key TEXT PRIMARY KEY, value TEXT NOT NULL)")
class Handler(BaseHTTPRequestHandler):
    def do_POST(self):
        body = json.loads(self.rfile.read(int(self.headers.get("content-length", "0"))))
        db.execute("INSERT INTO memory(key,value) VALUES(?,?) ON CONFLICT(key) DO UPDATE SET value=excluded.value", (body["key"], body["value"])); db.commit()
        self.send_response(204); self.end_headers()
    def do_GET(self):
        key = self.path.split("/", 2)[-1]; row = db.execute("SELECT value FROM memory WHERE key=?", (key,)).fetchone()
        payload = json.dumps({"value": row[0] if row else None}).encode(); self.send_response(200); self.send_header("content-type", "application/json"); self.send_header("content-length", str(len(payload))); self.end_headers(); self.wfile.write(payload)
    def log_message(self, *_args): pass
ThreadingHTTPServer(("127.0.0.1", int(sys.argv[1])), Handler).serve_forever()
