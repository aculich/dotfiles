"""Minimal rate-limited HTTP client for pubmed-database skill."""
from __future__ import annotations

import json
import time
import urllib.error
import urllib.request


class HttpError(Exception):
    def __init__(self, message, status_code=None):
        super().__init__(message)
        self.status_code = status_code


class _Resp:
    def __init__(self, text: str):
        self.text = text


class HttpClient:
    def __init__(self, base: str, qps: float = 3):
        self.base = base.rstrip("/")
        self._min_interval = 1.0 / max(qps, 0.1)
        self._last = 0.0

    def _throttle(self):
        now = time.monotonic()
        wait = self._min_interval - (now - self._last)
        if wait > 0:
            time.sleep(wait)
        self._last = time.monotonic()

    def _request(self, url: str, method: str = "GET", data=None) -> str:
        self._throttle()
        req = urllib.request.Request(url, data=data, method=method)
        req.add_header("User-Agent", "pubmed-database-skill/1.0 (research; mailto:aculich@gmail.com)")
        if data is not None:
            req.add_header("Content-Type", "application/x-www-form-urlencoded")
        try:
            with urllib.request.urlopen(req, timeout=60) as resp:
                return resp.read().decode("utf-8", "replace")
        except urllib.error.HTTPError as e:
            body = e.read().decode("utf-8", "replace")
            raise HttpError(body or str(e), status_code=e.code) from e
        except urllib.error.URLError as e:
            raise HttpError(str(e), status_code=None) from e

    def fetch_text(self, url: str) -> str:
        return self._request(url)

    def fetch_json(self, url: str):
        return json.loads(self._request(url))

    def fetch(self, url: str, method: str = "GET", data=None) -> _Resp:
        return _Resp(self._request(url, method=method, data=data))
