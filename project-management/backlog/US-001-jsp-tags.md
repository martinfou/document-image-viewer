# US-001: JSP Custom Tags Implementation

**Status:** Draft  
**Epic:** EPIC-001  
**Priority:** High  
**Story Points:** 5  

## Description

As a **developer**, I want **reusable JSP custom tags** so that I can compose document and image viewers declaratively in JSP pages without writing scriptlets or inline HTML.

## Acceptance Criteria

1. **DocumentViewerTag** renders a document viewer component with:
   - An iframe pointing to the document content endpoint
   - Zoom in/out/reset controls positioned at bottom-right
   - Support for `documentId` (required), `height`, `width`, `zoom` (optional) attributes
   - Fallback content in a `<noscript>` element
   - Proper HTML escaping of all attribute values

2. **ImageViewerTag** renders an image component with:
   - An `<img>` tag with configurable `src`, `alt`, `maxWidth`
   - Inline JavaScript click-to-zoom (toggles between 1x, 2x, 3x zoom levels)
   - A zoom indicator badge when zoomable is true
   - Proper HTML escaping of all attribute values

3. **Tag Library Descriptor** (`docviewer.tld`) defines:
   - Namespace URI: `https://docviewer.example.com/tags`
   - Short name: `docviewer`
   - Both tags with full attribute metadata (required, rtexprvalue, description)

4. **Usage in JSP**:
   - No scriptlets allowed (EL + JSTL + custom tags only)
   - Tags are registered via `<%@ taglib prefix="doc" uri="..." %>`

## Tag Specifications

### DocumentViewerTag

| Attribute   | Required | Type    | Default  | Description |
|-------------|----------|---------|----------|-------------|
| documentId  | true     | String  | —       | Unique document identifier |
| height      | false    | String  | 600px   | Viewer height (CSS value) |
| width       | false    | String  | 100%    | Viewer width (CSS value) |
| zoom        | false    | String  | 1.0     | Initial zoom level |

```jsp
<doc:documentViewer documentId="${doc.id}" height="600px" width="100%" zoom="1.0">
  <p>JavaScript is required to view this document.</p>
</doc:documentViewer>
```

### ImageViewerTag

| Attribute | Required | Type    | Default | Description |
|-----------|----------|---------|---------|-------------|
| src       | true     | String  | —      | Image source URL |
| alt       | false    | String  | ""     | Alt text |
| zoomable  | false    | boolean | true   | Enable click-to-zoom |
| maxWidth  | false    | String  | 100%   | Max container width |

```jsp
<doc:imageViewer src="${doc.thumbnailUrl}" alt="${doc.name}" zoomable="true" maxWidth="800px"/>
```

## Technical Notes

- Tags extend `SimpleTagSupport` (Jakarta EE)
- Body content: `scriptless` for DocumentViewer (supports fallback), `empty` for ImageViewer
- All dynamic attribute values must use `rtexprvalue="true"`
- Attribute values must be HTML-escaped before rendering
- Tags import `jakarta.servlet.jsp.tagext.SimpleTagSupport`
- TLD must be placed in `META-INF/` for auto-discovery
