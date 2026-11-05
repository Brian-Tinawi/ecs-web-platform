"""Tiny web app for the ECS platform demo. /health for the ALB; / shows which AZ served the request."""
import json
import os
import socket
import urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer


def task_az() -> str:
    base = os.environ.get("ECS_CONTAINER_METADATA_URI_V4")
    if not base:
        return "local"
    try:
        with urllib.request.urlopen(base + "/task", timeout=2) as r:
            return json.load(r).get("AvailabilityZone", "unknown")
    except Exception:
        return "unknown"


AZ = task_az()
HOST = socket.gethostname()
VERSION = os.environ.get("APP_VERSION", "dev")

PAGE = """<!doctype html><html><head><meta charset="utf-8"><title>Contoso Harbor Supply</title>
<style>body{{font-family:system-ui,sans-serif;background:#0b2545;color:#eef4ed;display:grid;place-items:center;height:100vh;margin:0}}
.c{{text-align:center}}h1{{font-size:2.4rem}}.b{{display:inline-block;background:#13315c;border-radius:8px;padding:.6rem 1.2rem;margin:.3rem}}</style></head>
<body><div class="c"><h1>Contoso Harbor Supply</h1><p>Customer portal &mdash; fictional demo company</p>
<div class="b">Availability Zone: <b>{az}</b></div><div class="b">Task: <b>{host}</b></div><div class="b">Version: <b>{ver}</b></div></div></body></html>"""


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/health":
            body, ctype = b'{"status":"ok"}', "application/json"
        else:
            body, ctype = PAGE.format(az=AZ, host=HOST, ver=VERSION).encode(), "text/html; charset=utf-8"
        self.send_response(200)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(body)))
        self.send_header("X-AZ", AZ)
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, *a):
        print(f"{self.address_string()} {self.path}", flush=True)


if __name__ == "__main__":
    ThreadingHTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
