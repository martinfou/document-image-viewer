package com.docviewer.taglib;

import jakarta.servlet.jsp.JspException;
import jakarta.servlet.jsp.JspWriter;
import jakarta.servlet.jsp.tagext.SimpleTagSupport;
import java.io.IOException;
import java.io.StringWriter;

/**
 * Custom JSP tag that renders a document viewer (iframe/div) for a given document ID.
 *
 * <p>Usage:
 * <pre>{@code
 * <doc:documentViewer documentId="${doc.id}" height="600px" width="100%" zoom="1.0">
 *   Fallback content
 * </doc:documentViewer>
 * }</pre>
 */
public class DocumentViewerTag extends SimpleTagSupport {

    private String documentId;
    private String height = "600px";
    private String width = "100%";
    private String zoom = "1.0";

    public void setDocumentId(String documentId) {
        this.documentId = documentId;
    }

    public void setHeight(String height) {
        this.height = height;
    }

    public void setWidth(String width) {
        this.width = width;
    }

    public void setZoom(String zoom) {
        this.zoom = zoom;
    }

    @Override
    public void doTag() throws JspException, IOException {
        JspWriter out = getJspContext().getOut();

        // Capture body content (fallback)
        StringWriter bodyContent = new StringWriter();
        if (getJspBody() != null) {
            getJspBody().invoke(bodyContent);
        }

        String safeDocId = escapeHtml(documentId != null ? documentId : "");
        String safeHeight = escapeHtml(height != null ? height : "600px");
        String safeWidth = escapeHtml(width != null ? width : "100%");
        String safeZoom = escapeHtml(zoom != null ? zoom : "1.0");
        String fallbackText = bodyContent.toString().trim().isEmpty()
                ? "Loading document..."
                : bodyContent.toString().trim();

        String containerId = "doc-viewer-" + safeDocId;

        out.println("<div class=\"doc-viewer-wrapper\" style=\"position:relative;width:" + safeWidth + ";height:" + safeHeight + ";\">");
        out.println("  <div id=\"" + containerId + "\" class=\"doc-viewer-container\"");
        out.println("       data-document-id=\"" + safeDocId + "\"");
        out.println("       data-zoom=\"" + safeZoom + "\"");
        out.println("       style=\"width:100%;height:100%;border:1px solid #dee2e6;border-radius:4px;overflow:hidden;background:#f8f9fa;\">");

        // Render an iframe pointing to the document content endpoint
        out.println("    <iframe");
        out.println("      src=\"" + getContextPath() + "/api/documents/" + safeDocId + "/content\"");
        out.println("      style=\"width:100%;height:100%;border:none;\"");
        out.println("      title=\"Document " + safeDocId + "\"");
        out.println("      onerror=\"this.parentElement.innerHTML='<div class=\\'alert alert-warning m-2\\'>Unable to load document</div>';\"");
        out.println("    ></iframe>");

        // Zoom controls
        out.println("    <div class=\"doc-viewer-controls\"");
        out.println("         style=\"position:absolute;bottom:8px;right:8px;display:flex;gap:4px;\">");
        out.println("      <button type=\"button\" class=\"btn btn-sm btn-light border\"");
        out.println("              onclick=\"document.getElementById('" + containerId + "').querySelector('iframe').style.transform='scale('+(parseFloat(getComputedStyle(document.getElementById('" + containerId + "').querySelector('iframe')).transform.split(',')[0]||1)-0.1)+')'\"");
        out.println("              title=\"Zoom out\">−</button>");
        out.println("      <button type=\"button\" class=\"btn btn-sm btn-light border\"");
        out.println("              onclick=\"document.getElementById('" + containerId + "').querySelector('iframe').style.transform='scale('+(parseFloat(getComputedStyle(document.getElementById('" + containerId + "').querySelector('iframe')).transform.split(',')[0]||1)+0.1)+')'\"");
        out.println("              title=\"Zoom in\">+</button>");
        out.println("      <button type=\"button\" class=\"btn btn-sm btn-light border\"");
        out.println("              onclick=\"document.getElementById('" + containerId + "').querySelector('iframe').style.transform='scale(1)'\"");
        out.println("              title=\"Reset zoom\">↺</button>");
        out.println("    </div>");

        out.println("  </div>");
        out.println("  <noscript>" + fallbackText + "</noscript>");
        out.println("</div>");
    }

    private String getContextPath() {
        try {
            Object req = getJspContext().findAttribute("jakarta.servlet.jsp.jstl.functions.request");
            if (req == null) {
                return "";
            }
            return jakarta.servlet.http.HttpServletRequest.class
                    .cast(req)
                    .getContextPath();
        } catch (Exception e) {
            return "";
        }
    }

    private static String escapeHtml(String input) {
        if (input == null) return "";
        return input
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
}
