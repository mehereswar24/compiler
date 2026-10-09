"""Tiny local server: serves the UI and runs the real arithc.exe (Review-1 build) on posted source.
Usage: python ui/server.py   ->  http://127.0.0.1:8765
"""
import json, pathlib, re, subprocess
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

ROOT = pathlib.Path(__file__).resolve().parent.parent
HERE = pathlib.Path(__file__).resolve().parent
EXE = ROOT / "arithc.exe"
HEAD = re.compile(r"^== (.*) ==$", re.M)


def compile_source(src):
    p = subprocess.run([str(EXE)], input=src, capture_output=True, text=True, timeout=10)
    out = p.stdout.replace("\r", "")
    marks = list(HEAD.finditer(out))
    sections = {}
    for i, m in enumerate(marks):
        end = marks[i + 1].start() if i + 1 < len(marks) else len(out)
        sections[m.group(1)] = out[m.end():end].strip("\n")

    def find(prefix):
        for k, v in sections.items():
            if k.startswith(prefix): return v
        return ""

    tokens = []
    for line in find("Token stream").split("\n"):
        parts = line.split(None, 2)
        if len(parts) == 3 and parts[0].isdigit():
            tokens.append({"line": int(parts[0]), "type": parts[1], "lexeme": parts[2]})
    return {"diag": find("Phase 1+2"), "tokens": tokens, "tree": find("Syntax (parse) tree"), "raw": out}


class H(BaseHTTPRequestHandler):
    def log_message(self, *a): pass

    def _send(self, code, body, ctype):
        b = body if isinstance(body, bytes) else body.encode("utf-8")
        self.send_response(code); self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(b))); self.end_headers(); self.wfile.write(b)

    def do_GET(self):
        if self.path in ("/", "/index.html"):
            self._send(200, (HERE / "index.html").read_bytes(), "text/html; charset=utf-8")
        else:
            self._send(404, "not found", "text/plain")

    def do_POST(self):
        if self.path != "/api/compile":
            return self._send(404, "not found", "text/plain")
        try:
            n = int(self.headers.get("Content-Length", 0))
            req = json.loads(self.rfile.read(n) or b"{}")
            self._send(200, json.dumps(compile_source(req.get("source", ""))), "application/json")
        except Exception as e:
            self._send(500, json.dumps({"error": str(e)}), "application/json")


if __name__ == "__main__":
    if not EXE.exists(): print(f"missing {EXE} - run: sh build.sh")
    print("UI on http://127.0.0.1:8765")
    ThreadingHTTPServer(("127.0.0.1", 8765), H).serve_forever()
