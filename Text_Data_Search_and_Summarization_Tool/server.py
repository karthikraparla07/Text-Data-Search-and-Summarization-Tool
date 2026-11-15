#!/usr/bin/env python3
"""Local browser prototype. All text processing is performed by Bash/grep/awk/sed."""
import json
import re
import subprocess
import tempfile
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlparse

ROOT = Path(__file__).resolve().parent
MAX_BYTES = 2 * 1024 * 1024


def execute(command, text, pattern='', n=10, remove_stopwords=True):
    with tempfile.TemporaryDirectory(prefix='sws_text_') as folder:
        source = Path(folder) / 'input.txt'
        source.write_text(text, encoding='utf-8')
        cmd = ['bash', str(ROOT / 'main.sh')]
        if command == 'search':
            cmd += ['search', str(source), pattern]
        elif command == 'clean':
            cmd += ['clean', str(source)]
        elif command == 'frequency':
            cmd += ['frequency', str(source), str(n)]
            if not remove_stopwords:
                cmd.append('--keep-stopwords')
        elif command == 'sentences':
            cmd += ['sentences', str(source)]
        elif command == 'report':
            # No server-side permanent file needed: generate with actual awk/sed scripts.
            cmd = ['bash', str(ROOT / 'summarize.sh'), 'report', str(source), str(n)]
        else:
            raise ValueError('Unsupported action')
        p = subprocess.run(cmd, capture_output=True, text=True, timeout=12, cwd=ROOT)
        if p.returncode != 0:
            raise ValueError((p.stderr or 'Processing failed').strip()[:500])
        return p.stdout


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if urlparse(self.path).path in ('/', '/index.html'):
            content = (ROOT / 'prototype.html').read_bytes()
            self.send_response(200)
            self.send_header('Content-Type', 'text/html; charset=utf-8')
            self.send_header('Content-Length', str(len(content)))
            self.end_headers()
            self.wfile.write(content)
        elif urlparse(self.path).path == '/api/sample':
            self.send_json({'text': (ROOT / 'data/sample.txt').read_text(encoding='utf-8')})
        else:
            self.send_error(404)

    def do_POST(self):
        if self.path != '/api/analyze':
            self.send_error(404)
            return
        try:
            length = int(self.headers.get('Content-Length', '0'))
            if length < 1 or length > MAX_BYTES * 3:
                raise ValueError('Request is too large or empty (maximum text size 2 MB)')
            data = json.loads(self.rfile.read(length))
            text = data.get('text', '')
            if not isinstance(text, str) or len(text.encode('utf-8')) > MAX_BYTES:
                raise ValueError('Text file must be at most 2 MB')
            action = data.get('action', '')
            n = int(data.get('n', 10))
            if not 1 <= n <= 100:
                raise ValueError('Top N must be between 1 and 100')
            pattern = data.get('pattern', '')
            if not isinstance(pattern, str) or len(pattern) > 300:
                raise ValueError('Invalid search pattern')
            out = execute(action, text, pattern, n, bool(data.get('remove_stopwords', True)))
            self.send_json({'ok': True, 'output': out})
        except (ValueError, TypeError, json.JSONDecodeError, subprocess.TimeoutExpired) as exc:
            self.send_json({'ok': False, 'error': str(exc)}, 400)

    def send_json(self, data, status=200):
        content = json.dumps(data).encode('utf-8')
        self.send_response(status)
        self.send_header('Content-Type', 'application/json; charset=utf-8')
        self.send_header('Content-Length', str(len(content)))
        self.end_headers()
        self.wfile.write(content)


if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser(description='Text Data Search & Summarization UI')
    parser.add_argument('--port', type=int, default=8000)
    args = parser.parse_args()
    print(f'Open http://localhost:{args.port} in your browser (Ctrl+C to stop)', flush=True)
    ThreadingHTTPServer(('127.0.0.1', args.port), Handler).serve_forever()
