"""
Karakeep webhook listener — rewrites reddit.com URLs to old.reddit.com.

Flow:
  1. Karakeep fires a webhook POST when a bookmark is created.
  2. This service checks if the URL is a reddit.com link.
  3. If so, it deletes the original bookmark and recreates it with old.reddit.com,
     so the full crawl/AI pipeline runs against the correct URL.

Webhook payload from Karakeep:
  {
    "jobId": "...",
    "bookmarkId": "...",
    "userId": "...",
    "url": "https://reddit.com/...",
    "type": "link",
    "operation": "created" | "edited" | "crawled" | "ai tagged" | "deleted"
  }

Environment variables:
  KARAKEEP_API_URL   Internal URL of the Karakeep web service, e.g. http://karakeep-web:3000
  KARAKEEP_API_KEY   API key generated from Settings > API Keys in the Karakeep UI
  LISTEN_PORT        Port to listen on (default: 7999)
"""

import json
import os
import re
import urllib.request
import urllib.error
from http.server import BaseHTTPRequestHandler, HTTPServer

KARAKEEP_API_URL = os.environ.get(
    "KARAKEEP_API_URL", "http://karakeep-web:3000"
).rstrip("/")
KARAKEEP_API_KEY = os.environ.get("KARAKEEP_API_KEY", "")
LISTEN_PORT = int(os.environ.get("LISTEN_PORT", "7999"))

REDDIT_RE = re.compile(r"^(https?://)(?:www\.)?reddit\.com(/.*)?$", re.IGNORECASE)


def rewrite_url(url: str) -> str | None:
    """Return old.reddit.com URL if url is a reddit.com link, else None."""
    m = REDDIT_RE.match(url)
    if not m:
        return None
    return f"{m.group(1)}old.reddit.com{m.group(2) or ''}"


def api_request(method: str, path: str, body: dict | None = None) -> tuple[bool, dict]:
    """Returns (success, response_body). success=True even for 204 No Content."""
    url = f"{KARAKEEP_API_URL}/api/v1{path}"
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(
        url,
        data=data,
        method=method,
        headers={
            "Authorization": f"Bearer {KARAKEEP_API_KEY}",
            "Content-Type": "application/json",
        },
    )
    try:
        with urllib.request.urlopen(req, timeout=10) as resp:
            raw = resp.read()
            return True, (json.loads(raw) if raw else {})
    except urllib.error.HTTPError as e:
        print(f"[hook] API error {e.code} {method} {path}: {e.read().decode()}")
    except Exception as e:
        print(f"[hook] Request failed {method} {path}: {e}")
    return False, {}


def handle_event(event: dict):
    operation = event.get("operation", "")

    # Only act on newly created bookmarks
    if operation != "created":
        print(f"[hook] Ignoring operation '{operation}'")
        return

    url = event.get("url")
    bookmark_id = event.get("bookmarkId")

    if not url or not bookmark_id:
        print(f"[hook] Missing url or bookmarkId in event, skipping.")
        return

    print(f"[hook] Received 'created' event for bookmark {bookmark_id} url={url}")

    new_url = rewrite_url(url)
    if not new_url:
        print(f"[hook] Not a reddit URL, skipping.")
        return

    print(f"[hook] Rewriting {url} -> {new_url}")

    # Fetch the full bookmark to preserve title if already set
    ok, bookmark = api_request("GET", f"/bookmarks/{bookmark_id}")
    if not ok:
        print(f"[hook] Could not fetch bookmark {bookmark_id}, aborting.")
        return

    # Delete the original bookmark
    ok, _ = api_request("DELETE", f"/bookmarks/{bookmark_id}")
    if not ok:
        print(f"[hook] Failed to delete bookmark {bookmark_id}, aborting.")
        return

    # Recreate with the rewritten URL; Karakeep will crawl it fresh
    payload: dict = {"type": "link", "url": new_url}

    # Preserve title if already set
    title = bookmark.get("title")
    if title:
        payload["title"] = title

    ok, new_bookmark = api_request("POST", "/bookmarks", payload)
    if ok:
        print(f"[hook] Created new bookmark {new_bookmark.get('id')} for {new_url}")
    else:
        print(f"[hook] Failed to recreate bookmark for {new_url}")


class Handler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        # Re-enable request logging
        print(f"[hook] {self.address_string()} - {format % args}")

    def do_POST(self):
        length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(length)
        self.send_response(200)
        self.end_headers()

        try:
            event = json.loads(body)
            handle_event(event)
        except Exception as e:
            print(f"[hook] Failed to process event: {e}")


if __name__ == "__main__":
    if not KARAKEEP_API_KEY:
        print("[hook] WARNING: KARAKEEP_API_KEY is not set.")

    server = HTTPServer(("0.0.0.0", LISTEN_PORT), Handler)
    print(f"[hook] Listening on port {LISTEN_PORT}")
    server.serve_forever()
