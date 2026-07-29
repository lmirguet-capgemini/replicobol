#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
PORT=${PORT:-8000}

cd "$ROOT_DIR"

if [ ! -x backend/cgi/projects ] || [ ! -x backend/cgi/timesheet ] || [ ! -x backend/cgi/calendar ]; then
  ./scripts/build.sh
fi

echo "Serving Replicobol at http://127.0.0.1:$PORT/frontend/"
echo "CGI handlers are available under http://127.0.0.1:$PORT/cgi-bin/"

python3 - "$PORT" <<'PY'
import http.server
import os
import subprocess
import sys
from urllib.parse import urlsplit

port = int(sys.argv[1])

class ReplicobolHandler(http.server.SimpleHTTPRequestHandler):
    def run_cobol_cgi(self):
        parsed = urlsplit(self.path)
        name = parsed.path.rsplit('/', 1)[-1]
        script_path = os.path.abspath(os.path.join('backend', 'cgi', name))

        if not os.path.isfile(script_path) or not os.access(script_path, os.X_OK):
            self.send_error(404, 'CGI handler not found')
            return

        content_length = int(self.headers.get('Content-Length', '0') or '0')
        request_body = self.rfile.read(content_length) if content_length else b''
        env = os.environ.copy()
        env.update({
            'REQUEST_METHOD': self.command,
            'QUERY_STRING': parsed.query,
            'CONTENT_LENGTH': str(content_length),
            'CONTENT_TYPE': self.headers.get('Content-Type', ''),
        })

        result = subprocess.run(
            [script_path],
            input=request_body,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            env=env,
            cwd=os.getcwd(),
            check=False,
        )
        output = result.stdout
        body = output
        content_type = 'application/json'
        lines = output.splitlines()
        if lines and lines[0].lower().startswith(b'content-type:'):
            content_type = lines[0].decode('utf-8', 'replace').split(':', 1)[1].strip()
            body_start = 1
            while body_start < len(lines) and not lines[body_start].strip():
                body_start += 1
            body = b'\n'.join(lines[body_start:]) + b'\n'

        if result.returncode != 0:
            body = b'{"ok":false,"error":{"code":"CGI_ERROR","message":"Backend handler failed","field":"backend"}}\n'

        self.send_response(200)
        self.send_header('Content-Type', content_type)
        self.send_header('Content-Length', str(len(body)))
        self.send_header('Cache-Control', 'no-store')
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        if self.path == '/':
            self.send_response(302)
            self.send_header('Location', '/frontend/')
            self.end_headers()
            return
        if self.path.startswith('/cgi-bin/'):
            self.run_cobol_cgi()
            return
        super().do_GET()

    def do_POST(self):
        if self.path.startswith('/cgi-bin/'):
            self.run_cobol_cgi()
            return
        self.send_error(404, 'Not found')

    def translate_path(self, path):
        return super().translate_path(path)

http.server.ThreadingHTTPServer(('127.0.0.1', port), ReplicobolHandler).serve_forever()
PY