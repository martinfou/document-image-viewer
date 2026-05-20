package com.docviewer.servlet;

import com.docviewer.model.Document;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.lang.reflect.Type;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.CopyOnWriteArrayList;

/**
 * Servlet that acts as a lightweight controller for document operations.
 *
 * <p>In production, this would proxy to a backend API. Here it loads mock data
 * from a JSON file (the WireMock stubs) for rapid prototyping and testing.
 */
@WebServlet(urlPatterns = {
        "/documents",
        "/documents/*",
        "/api/documents",
        "/api/documents/*",
        "/viewer",
        "/viewer/*"
})
public class DocumentServlet extends HttpServlet {

    private static final String STUBS_PATH = "/wiremock/stubs/documents.json";
    private final Gson gson = new Gson();
    private List<Document> documents;

    @Override
    public void init() throws ServletException {
        super.init();
        loadDocuments();
    }

    private void loadDocuments() {
        try (InputStream is = getClass().getResourceAsStream(STUBS_PATH)) {
            if (is == null) {
                // Fallback: try classpath root
                try (InputStream fallback = getClass().getResourceAsStream("/documents.json")) {
                    if (fallback == null) {
                        getServletContext().log("WARN: No stub file found at " + STUBS_PATH
                                + " or /documents.json — using empty list");
                        documents = new CopyOnWriteArrayList<>();
                        return;
                    }
                    parseDocuments(fallback);
                    return;
                }
            }
            parseDocuments(is);
        } catch (IOException e) {
            getServletContext().log("ERROR: Failed to load documents from " + STUBS_PATH, e);
            documents = new CopyOnWriteArrayList<>();
        }
    }

    private void parseDocuments(InputStream is) {
        try (InputStreamReader reader = new InputStreamReader(is)) {
            Type listType = new TypeToken<List<Document>>() {}.getType();
            List<Document> loaded = gson.fromJson(reader, listType);
            documents = loaded != null ? new CopyOnWriteArrayList<>(loaded) : new CopyOnWriteArrayList<>();
        } catch (IOException e) {
            getServletContext().log("ERROR: Failed to parse documents JSON", e);
            documents = new CopyOnWriteArrayList<>();
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String pathInfo = req.getPathInfo();
        String contextPath = req.getContextPath();

        // Determine if this is an API call or a page navigation
        String requestURI = req.getRequestURI();
        boolean isApiCall = requestURI.contains("/api/");

        // Route: /api/documents/{id}/content
        if (isApiCall && pathInfo != null && pathInfo.matches("/[^/]+/content/?")) {
            String docId = extractId(pathInfo);
            serveDocumentContent(docId, req, resp);
            return;
        }

        // Route: /api/documents/{id}
        if (isApiCall && pathInfo != null && pathInfo.matches("/[^/]+/?")) {
            String docId = extractId(pathInfo);
            serveDocumentDetail(docId, req, resp);
            return;
        }

        // Route: /api/documents (list)
        if (isApiCall) {
            serveDocumentList(req, resp);
            return;
        }

        // Route: /viewer/{id} — embedded viewer page (not modal)
        if (requestURI.contains("/viewer")) {
            String viewerId = null;
            if (pathInfo != null && pathInfo.length() > 1) {
                viewerId = pathInfo.replaceAll("^/+|/+$", "");
            } else {
                viewerId = req.getParameter("doc");
            }

            if (viewerId != null && !viewerId.isEmpty()) {
                Optional<Document> viewerDoc = getDocumentById(viewerId);
                if (viewerDoc.isPresent()) {
                    req.setAttribute("viewerDoc", viewerDoc.get());
                    req.setAttribute("viewerDocs", getDocuments());
                    req.setAttribute("viewerIndex", getDocumentIndex(viewerId));
                    // Zoom via URL param (no JS needed for basic zoom)
                    String zoomParam = req.getParameter("zoom");
                    String zoomMode = "fixed";
                    int zoomLevel = 100;
                    if (zoomParam != null && !zoomParam.isEmpty()) {
                        switch (zoomParam) {
                            case "fitW" -> zoomMode = "fitWidth";
                            case "fitH" -> zoomMode = "fitHeight";
                            default -> {
                                try {
                                    zoomLevel = Math.max(10, Math.min(300, Integer.parseInt(zoomParam)));
                                } catch (NumberFormatException ignored) {}
                            }
                        }
                    }
                    req.setAttribute("viewerZoom", zoomLevel);
                    req.setAttribute("viewerZoomMode", zoomMode);
                    req.getRequestDispatcher("/viewer.jsp").forward(req, resp);
                    return;
                }
            }
            // Fallback: redirect to document list
            resp.sendRedirect(req.getContextPath() + "/documents");
            return;
        }

        // Route: /documents (JSP page view)
        req.setAttribute("documents", getDocuments());
        req.getRequestDispatcher("/index.jsp").forward(req, resp);
    }

    private String extractId(String pathInfo) {
        String id = pathInfo.replaceAll("^/+", "").replaceAll("/+$", "");
        // Remove trailing /content if present
        if (id.endsWith("/content")) {
            id = id.substring(0, id.length() - "/content".length());
        }
        return id;
    }

    private void serveDocumentList(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        gson.toJson(getDocuments(), resp.getWriter());
    }

    private void serveDocumentDetail(String docId, HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        Optional<Document> doc = getDocumentById(docId);
        if (doc.isPresent()) {
            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            gson.toJson(doc.get(), resp.getWriter());
        } else {
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            resp.setContentType("application/json");
            resp.getWriter().write("{\"error\":\"Document not found: " + escapeJson(docId) + "\"}");
        }
    }

    private void serveDocumentContent(String docId, HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        Optional<Document> doc = getDocumentById(docId);
        if (doc.isPresent()) {
            Document d = doc.get();
            String type = d.getType() != null ? d.getType().toLowerCase() : "pdf";

            // Map document ID to a local sample file
            String sampleFile = mapDocIdToSampleFile(docId);
            Path samplePath = Paths.get(getServletContext().getRealPath("/samples/"), sampleFile);

            if (Files.exists(samplePath)) {
                // Serve the local sample file directly
                byte[] content = Files.readAllBytes(samplePath);
                resp.setContentLength(content.length);
                resp.setHeader("Content-Disposition", "inline; filename=\"" + d.getName() + "\"");

                switch (type) {
                    case "pdf" -> resp.setContentType("application/pdf");
                    case "jpg", "jpeg" -> resp.setContentType("image/jpeg");
                    case "png" -> resp.setContentType("image/png");
                    case "gif" -> resp.setContentType("image/gif");
                    case "tiff", "tif" -> resp.setContentType("image/tiff");
                    default -> resp.setContentType("application/octet-stream");
                }

                resp.getOutputStream().write(content);
                getServletContext().log("Served sample file: " + samplePath);
            } else {
                // Fallback: redirect to placeholder
                getServletContext().log("Sample file not found: " + samplePath
                        + " — redirecting to placeholder");
                resp.sendRedirect("https://via.placeholder.com/800x600.png?text="
                        + d.getName().replace(" ", "+"));
            }
        } else {
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            resp.setContentType("text/html");
            resp.getWriter().write("<html><body><h1>404 - Document Not Found</h1>"
                    + "<p>Document ID: " + escapeHtml(docId) + "</p></body></html>");
        }
    }

    /**
     * Maps document IDs to local sample file names.
     */
    private String mapDocIdToSampleFile(String docId) {
        return switch (docId) {
            case "doc-001" -> "sample.pdf";
            case "doc-002" -> "blueprint.pdf";
            case "doc-003" -> "photo.jpg";
            case "doc-004" -> "sample.jpg";
            case "doc-005" -> "scan.tiff";
            case "doc-006" -> "document.tiff";
            default -> "sample.pdf";
        };
    }

    private List<Document> getDocuments() {
        return documents != null ? documents : Collections.emptyList();
    }

    private Optional<Document> getDocumentById(String id) {
        return getDocuments().stream()
                .filter(d -> d.getId() != null && d.getId().equals(id))
                .findFirst();
    }

    private int getDocumentIndex(String id) {
        List<Document> docs = getDocuments();
        for (int i = 0; i < docs.size(); i++) {
            if (docs.get(i).getId() != null && docs.get(i).getId().equals(id)) {
                return i;
            }
        }
        return 0;
    }

    private static String escapeHtml(String input) {
        if (input == null) return "";
        return input
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;");
    }

    private static String escapeJson(String input) {
        if (input == null) return "";
        return input
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
