import os
import json
import logging
from http.server import BaseHTTPRequestHandler, HTTPServer

logging.basicConfig(level=logging.DEBUG)

class SimpleHTTPRequestHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/api/data' or self.path == '/api/update':
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()

            if hasattr(self.server, 'latest_data'):
                self.wfile.write(bytes(json.dumps(self.server.latest_data), "utf8"))
            else:
                self.wfile.write(bytes(json.dumps({"status": "Server started", "data": "", "timestamp": ""}), "utf8"))
        else:
            self.send_response(404)
            self.end_headers()

    def do_POST(self):
        if self.path == '/api/update':
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            try:
                self.server.latest_data = json.loads(post_data)
                logging.debug(f"Received data: {self.server.latest_data}")

                self.send_response(200)
                self.send_header("Content-type", "application/json")
                self.send_header("Access-Control-Allow-Origin", "*")
                self.end_headers()
                self.wfile.write(bytes(json.dumps({"status": "Data received"}), "utf8"))
            except json.JSONDecodeError as e:
                logging.error(f"Failed to decode JSON: {e}")
                self.send_response(400)
                self.end_headers()
                self.wfile.write(bytes(json.dumps({"status": "Failed to decode JSON"}), "utf8"))
        else:
            self.send_response(404)
            self.end_headers()

    def do_OPTIONS(self):
        if self.path == '/api/data' or self.path == '/api/update':
            self.send_response(200)
            self.send_header("Access-Control-Allow-Origin", "*")
            self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
            self.send_header("Access-Control-Allow-Headers", "Content-Type")
            self.end_headers()

def run(server_class=HTTPServer, handler_class=SimpleHTTPRequestHandler, port=8081):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    httpd.latest_data = {"status": "Server started", "data": "", "timestamp": ""}  # 초기 데이터 설정
    logging.info(f"Starting httpd server on port {port}")
    httpd.serve_forever()

if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Accept incoming TCP connections and make them available on a specified address and port.")
    parser.add_argument("--address", default="0.0.0.0", help="Address to bind to (default: all)")
    parser.add_argument("--port", type=int, default=8081, help="Port to bind to (default: 8081)")
    args = parser.parse_args()

    run(port=args.port)
