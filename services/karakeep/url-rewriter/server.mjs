import http from "node:http";

const port = Number(process.env.PORT || 8080);
const webhookToken = process.env.WEBHOOK_TOKEN;
const karakeepApiToken = process.env.KARAKEEP_API_TOKEN;
const karakeepBaseUrl = (
  process.env.KARAKEEP_BASE_URL || "http://tailscale-karakeep:3000"
).replace(/\/$/, "");

if (!webhookToken) throw new Error("WEBHOOK_TOKEN is required");

if (!karakeepApiToken) throw new Error("KARAKEEP_API_TOKEN is required");

const processedJobs = new Map();
const processedJobTtlMs = 60 * 60 * 1000;

setInterval(() => {
  const now = Date.now();

  for (const [jobId, processedAt] of processedJobs.entries()) {
    if (now - processedAt > processedJobTtlMs) processedJobs.delete(jobId);
  }
}, processedJobTtlMs).unref();

function rewriteRedditUrl(rawUrl) {
  const url = new URL(rawUrl);

  url.hostname = "old.reddit.com";
  return url.toString();
}

function rewriteYoutubeShortUrl(rawUrl) {
  const url = new URL(rawUrl);

  const match = url.pathname.match(/^\/shorts\/([^/]+)\/?$/);
  if (!match) return null;

  url.pathname = "/watch";
  url.search = "";
  url.searchParams.set("v", match[1]);
  return url.toString();
}

function rewriteUrl(rawUrl) {
  const rewriteUrls = {
    "reddit.com": rewriteRedditUrl,
    "www.reddit.com": rewriteRedditUrl,
    "youtube.com": rewriteYoutubeShortUrl,
    "www.youtube.com": rewriteYoutubeShortUrl,
  };

  return rewriteUrls[new URL(rawUrl).hostname.toLowerCase()]?.(rawUrl) ?? null;
}

function log(message, extra) {
  if (extra === undefined) {
    console.log(message);
    return;
  }

  console.log(message, extra);
}

function json(response, statusCode, payload) {
  response.writeHead(statusCode, { "Content-Type": "application/json" });
  response.end(JSON.stringify(payload));
}

function collectJson(request) {
  return new Promise((resolve, reject) => {
    let body = "";

    request.on("data", (chunk) => {
      body += chunk;
    });

    request.on("end", () => {
      try {
        resolve(body ? JSON.parse(body) : {});
      } catch (error) {
        reject(error);
      }
    });

    request.on("error", reject);
  });
}

async function karakeepRequest(path, options = {}) {
  const response = await fetch(`${karakeepBaseUrl}${path}`, {
    ...options,
    headers: {
      Accept: "application/json",
      Authorization: `Bearer ${karakeepApiToken}`,
      ...(options.body ? { "Content-Type": "application/json" } : {}),
      ...(options.headers || {}),
    },
  });

  if (response.status === 204) return null;

  const text = await response.text();
  const data = text ? tryParseJson(text) : null;

  if (!response.ok) {
    const error = new Error(`Karakeep request failed with ${response.status}`);
    error.status = response.status;
    error.data = data;
    throw error;
  }

  return data;
}

function tryParseJson(text) {
  try {
    return JSON.parse(text);
  } catch {
    return text;
  }
}

function buildCreateBookmarkPayload(bookmark, rewrittenUrl) {
  const createPayload = {
    type: "link",
    url: rewrittenUrl,
  };

  if (typeof bookmark.title === "string") {
    createPayload.title = bookmark.title;
  }

  if (typeof bookmark.archived === "boolean") {
    createPayload.archived = bookmark.archived;
  }

  if (typeof bookmark.favourited === "boolean") {
    createPayload.favourited = bookmark.favourited;
  }

  if (typeof bookmark.note === "string" && bookmark.note.length > 0) {
    createPayload.note = bookmark.note;
  }

  return createPayload;
}

function rememberJob(jobId) {
  if (!jobId) return;

  processedJobs.set(jobId, Date.now());
}

function hasProcessedJob(jobId) {
  if (!jobId) return false;

  const processedAt = processedJobs.get(jobId);
  if (!processedAt) return false;

  if (Date.now() - processedAt > processedJobTtlMs) {
    processedJobs.delete(jobId);
    return false;
  }

  return true;
}

async function rewriteBookmark(payload) {
  if (payload.operation !== "created")
    return { skipped: true, reason: "unsupported_operation" };

  const rewrittenUrl = rewriteUrl(payload.url);
  if (!rewrittenUrl) return { skipped: true, reason: "not_rewritable" };

  const bookmark = await karakeepRequest(
    `/api/v1/bookmarks/${payload.bookmarkId}`,
  );

  if (bookmark?.content?.type !== "link")
    return { skipped: true, reason: "unsupported_bookmark_type" };

  const createPayload = buildCreateBookmarkPayload(bookmark, rewrittenUrl);

  const created = await karakeepRequest("/api/v1/bookmarks", {
    method: "POST",
    body: JSON.stringify(createPayload),
  });

  await karakeepRequest(`/api/v1/bookmarks/${payload.bookmarkId}`, {
    method: "DELETE",
  });

  return {
    skipped: false,
    oldBookmarkId: payload.bookmarkId,
    newBookmarkId: created?.id,
    rewrittenUrl,
  };
}

const server = http.createServer(async (request, response) => {
  if (request.url === "/healthz") return json(response, 200, { ok: true });

  if (request.url !== "/webhook")
    return json(response, 404, { error: "not_found" });

  if (request.method !== "POST")
    return json(response, 405, { error: "method_not_allowed" });

  const authorization = request.headers.authorization;
  if (authorization !== `Bearer ${webhookToken}`)
    return json(response, 401, { error: "unauthorized" });

  try {
    const payload = await collectJson(request);

    if (hasProcessedJob(payload.jobId))
      return json(response, 200, { ok: true, deduplicated: true });

    const result = await rewriteBookmark(payload);
    rememberJob(payload.jobId);

    log("Processed Karakeep webhook", {
      jobId: payload.jobId,
      bookmarkId: payload.bookmarkId,
      operation: payload.operation,
      type: payload.type,
      result,
    });

    return json(response, 200, { ok: true, result });
  } catch (error) {
    console.error("Failed to process Karakeep webhook", {
      message: error.message,
      status: error.status,
      data: error.data,
      stack: error.stack,
    });
    return json(response, 500, {
      error: "processing_failed",
      message: error.message,
    });
  }
});

server.listen(port, () => {
  log(`Karakeep url rewriter listening on ${port}`);
});
