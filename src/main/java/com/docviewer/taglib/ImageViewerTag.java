package com.docviewer.taglib;

import jakarta.servlet.jsp.JspException;
import jakarta.servlet.jsp.JspWriter;
import jakarta.servlet.jsp.tagext.SimpleTagSupport;
import java.io.IOException;
import java.io.StringWriter;

/**
 * Custom JSP tag that renders an image with inline JavaScript zoom support.
 *
 * <p>Usage:
 * <pre>{@code
 * <doc:imageViewer src="${doc.thumbnailUrl}" alt="${doc.name}" zoomable="true" maxWidth="800px"/>
 * }</pre>
 */
public class ImageViewerTag extends SimpleTagSupport {

    private String src;
    private String alt = "";
    private boolean zoomable = true;
    private String maxWidth = "100%";

    public void setSrc(String src) {
        this.src = src;
    }

    public void setAlt(String alt) {
        this.alt = alt;
    }

    public void setZoomable(boolean zoomable) {
        this.zoomable = zoomable;
    }

    public void setMaxWidth(String maxWidth) {
        this.maxWidth = maxWidth;
    }

    @Override
    public void doTag() throws JspException, IOException {
        JspWriter out = getJspContext().getOut();

        String safeSrc = escapeHtml(src != null ? src : "");
        String safeAlt = escapeHtml(alt != null ? alt : "");
        String safeMaxWidth = escapeHtml(maxWidth != null ? maxWidth : "100%");

        String containerId = "img-viewer-" + Math.abs(safeSrc.hashCode());

        out.println("<div class=\"image-viewer-wrapper\" id=\"" + containerId + "-wrapper\"");
        out.println("     style=\"position:relative;display:inline-block;max-width:" + safeMaxWidth + ";\">");

        out.println("  <div class=\"image-viewer-container\"");
        out.println("       style=\"position:relative;overflow:hidden;border:1px solid #dee2e6;border-radius:4px;background:#fff;\">");

        out.println("    <img id=\"" + containerId + "\"");
        out.println("         src=\"" + safeSrc + "\"");
        out.println("         alt=\"" + safeAlt + "\"");
        out.println("         style=\"display:block;max-width:100%;height:auto;transition:transform 0.2s ease;cursor:"
                + (zoomable ? "zoom-in" : "default") + ";\"");
        out.println("         data-zoom-level=\"1\"");

        if (zoomable) {
            // Attach click-to-zoom toggle via inline JS
            out.println("         onclick=\"(function(){");
            out.println("           var img=document.getElementById('" + containerId + "');");
            out.println("           var level=parseFloat(img.getAttribute('data-zoom-level'));");
            out.println("           if(level===1){");
            out.println("             img.style.transform='scale(2)';");
            out.println("             img.setAttribute('data-zoom-level','2');");
            out.println("             img.style.cursor='zoom-out';");
            out.println("           }else if(level===2){");
            out.println("             img.style.transform='scale(3)';");
            out.println("             img.setAttribute('data-zoom-level','3');");
            out.println("             img.style.cursor='zoom-out';");
            out.println("           }else{");
            out.println("             img.style.transform='scale(1)';");
            out.println("             img.setAttribute('data-zoom-level','1');");
            out.println("             img.style.cursor='zoom-in';");
            out.println("           }");
            out.println("         })()\"");
        }

        out.println("    />");

        if (zoomable) {
            // Zoom indicator badge
            out.println("    <span class=\"badge bg-secondary position-absolute top-0 end-0 m-1\"");
            out.println("          style=\"font-size:0.7rem;opacity:0.8;\">🔍</span>");
        }

        out.println("  </div>");

        // Caption with alt text if present
        if (!safeAlt.isEmpty()) {
            out.println("  <p class=\"image-viewer-caption text-muted small mt-1 mb-0 text-center\">"
                    + safeAlt + "</p>");
        }

        out.println("</div>");
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
