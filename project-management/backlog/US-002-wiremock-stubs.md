# US-002: WireMock API Stubs

**Status:** Draft  
**Epic:** EPIC-001  
**Priority:** Medium  
**Story Points:** 3  

## Description

As a **developer**, I want **WireMock stubs for the document API** so that I can develop and test the document viewer frontend without a real backend.

## Acceptance Criteria

1. **Stub JSON file** `wiremock/stubs/documents.json` contains:
   - 6 mock document entries with realistic data
   - Each entry has: `id`, `name`, `description`, `type`, `url`, `thumbnailUrl`, `sizeBytes`, `pageCount`
   - Mix of PDF and image document types

2. **DocumentServlet** loads stub data from the JSON file:
   - On init, reads from classpath `/wiremock/stubs/documents.json`
   - Falls back to `/documents.json` at classpath root
   - Returns empty list if no file found (graceful degradation)

3. **REST endpoints** (handled by DocumentServlet):

   | Method | Path | Response |
   |--------|------|----------|
   | GET | `/api/documents` | JSON array of all documents |
   | GET | `/api/documents/{id}` | Single document JSON |
   | GET | `/api/documents/{id}/content` | Binary content (PDF/image) or redirect |

4. **API responses**:
   - Success: HTTP 200 with JSON content type
   - Not found: HTTP 404 with error JSON
   - Content endpoint returns appropriate Content-Type headers

## Stub Data Structure

```json
[
  {
    "id": "doc-001",
    "name": "Annual Report 2025",
    "description": "Annual financial report with charts and summaries",
    "type": "pdf",
    "url": "/api/documents/doc-001/content",
    "thumbnailUrl": "https://via.placeholder.com/300x400.png?text=Annual+Report",
    "sizeBytes": 2456789,
    "pageCount": 42
  }
]
```

## Technical Notes

- Stub data is in JSON format compatible with WireMock (can be imported directly)
- DocumentServlet doubles as the mock API handler for development
- The content endpoint currently redirects to placeholder URLs (e.g., `https://via.placeholder.com/`)
- In production, replace with real document content streaming
- Servlet handles path routing via regex matching on `getPathInfo()`
- Thread safety: uses `CopyOnWriteArrayList` for the document list

## Testing

1. **Unit tests** verify:
   - All 6 stub documents load correctly
   - Required fields are present and non-blank
   - Document IDs are unique
   - Document types are valid ("pdf" or "image")
   - Document model equals/hashCode works correctly
