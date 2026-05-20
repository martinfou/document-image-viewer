# EPIC-001: Document Image Viewer

**Status:** Draft  
**Priority:** High  
**Deadline:** ASAP  

## Vision

Provide a lightweight, JSP-based document viewer that allows users to browse, preview, and inspect documents (PDFs and images) directly in the browser without requiring modern JavaScript frameworks. The application uses JSP Custom Tags (taglibs) for reusable UI components, Servlets for backend logic, and Bootstrap 5 for responsive styling.

## Use Cases

### UC-1: Browse Document List
- **Actor:** Authenticated user
- **Flow:** User navigates to the main page → sees a grid of document cards (thumbnail, name, type, size) → can search/filter by name
- **Outcome:** Document grid is displayed with all available documents

### UC-2: View Document in Modal
- **Actor:** Authenticated user
- **Flow:** User clicks a document card → a modal opens with the document viewer → document content is displayed (PDF in iframe, image with zoom support) → user can close the modal
- **Outcome:** Document is displayed inline without page navigation

### UC-3: Zoom In/Out on Images
- **Actor:** Authenticated user
- **Flow:** User opens an image document → clicks the image to zoom (1x → 2x → 3x → reset) → or uses zoom controls in PDF viewer
- **Outcome:** Image/document scales smoothly

### UC-4: Search Documents
- **Actor:** Authenticated user
- **Flow:** User types in the search bar → grid filters in real-time by document name or type
- **Outcome:** Only matching documents remain visible

## Wireframes (Textual)

```
┌──────────────────────────────────────────────────────┐
│  [🔷] Document Viewer    [🔍 Search...      ] [↻]  │  ← Navbar
├──────────────────────────────────────────────────────┤
│  📄 6 document(s)    Click any card to open          │  ← Stats bar
├──────────────────────────────────────────────────────┤
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐                │
│  │ 📄   │ │ 📄   │ │ 🖼   │ │ 📄   │                │
│  │Annual│ │Bluepr│ │Team  │ │Roadm│                │
│  │Report│ │int   │ │Photo │ │ap    │                │
│  │ 2.4MB│ │ 1.2MB│ │ 457KB│ │ 890KB│                │
│  │ 42p. │ │ 28p. │ │      │ │ 15p. │                │
│  └──────┘ └──────┘ └──────┘ └──────┘                │
│  ┌──────┐ ┌──────┐                                   │
│  │ 🖼   │ │ 📄   │                                   │
│  │Infogr│ │Contra│                                   │
│  │aphic │ │ct    │                                   │
│  │ 235KB│ │ 346KB│                                   │
│  └──────┘ └──────┘                                   │
├──────────────────────────────────────────────────────┤
│  Document Image Viewer · JSP + Custom Tags           │  ← Footer
└──────────────────────────────────────────────────────┘
```

### Modal Viewer

```
┌──────────────────────────────────────────────────────┐
│  Annual Report 2025       [PDF]              [✕]    │  ← Modal header
├──────────────────────────────────────────────────────┤
│  ┌────────────────────────────────────────────────┐  │
│  │                                                │  │
│  │          [PDF content in iframe]               │  │
│  │          [or Image with zoom]                  │  │
│  │                                                │  │
│  │                                    [−] [+] [↺] │  │  ← Zoom controls
│  └────────────────────────────────────────────────┘  │
│  📝 Annual financial report with charts...           │  ← Info footer
└──────────────────────────────────────────────────────┘
```

## Technical Stack

| Component | Technology |
|-----------|-----------|
| Frontend  | JSP + Bootstrap 5 CDN |
| Custom Tags | JSP Taglib (SimpleTagSupport) |
| Controller | Jakarta Servlets (@WebServlet) |
| Build     | Maven 3.x, Java 17 |
| Runtime   | Apache Tomcat 10 (Jakarta EE) |
| API Stubs | WireMock (test) + embedded JSON |
| Testing   | JUnit 5 + AssertJ |

## Non-Goals
- No modern JS frameworks (React, Vue, Angular)
- No Spring Boot or Jakarta EE full stack
- No database persistence (filesystem JSON for mock data)

## Risks
- TLD/Servlet compatibility with Tomcat 10
- Iframe CORS restrictions for external content
- Search performance with large document sets

## Open Questions
- Should zoom levels be configurable?
- Add keyboard shortcuts for the viewer?
- Support more document types (docx, xlsx)?
