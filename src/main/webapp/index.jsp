<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="doc" uri="https://docviewer.example.com/tags" %>
<!DOCTYPE html>
<html lang="en" data-bs-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document Image Viewer</title>

    <!-- Bootstrap 5 CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet"
          integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH"
          crossorigin="anonymous">

    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css"
          rel="stylesheet">

    <style>
        :root {
            --doc-card-hover: rgba(0, 135, 78, 0.05);
        }

        body {
            background: #f0f7f2;
            min-height: 100vh;
        }

        .navbar-brand-icon {
            width: 32px;
            height: 32px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 6px;
            background: linear-gradient(135deg, #00874e, #6610f2);
            color: #fff;
            font-size: 1rem;
        }

        .doc-card {
            transition: transform 0.2s ease, box-shadow 0.2s ease;
            cursor: pointer;
            border: 1px solid rgba(0,0,0,0.08);
            height: 100%;
        }
        .doc-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.1);
        }

        .doc-thumb {
            height: 180px;
            object-fit: cover;
            background: #f0f2f5;
        }

        .doc-type-badge {
            position: absolute;
            top: 8px;
            right: 8px;
            font-size: 0.7rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .modal-doc-viewer {
            min-height: 60vh;
        }

        .pulse-loader {
            display: inline-block;
            width: 2rem;
            height: 2rem;
            border-radius: 50%;
            background: #00874e;
            animation: pulse 1.2s ease-in-out infinite;
        }
        @keyframes pulse {
            0%, 100% { opacity: 0.4; transform: scale(1); }
            50% { opacity: 1; transform: scale(1.2); }
        }

        .empty-state {
            text-align: center;
            padding: 4rem 2rem;
            color: #6c757d;
        }
        .empty-state i {
            font-size: 4rem;
            opacity: 0.3;
        }

        .stats-bar {
            background: #fff;
            border-bottom: 1px solid #dee2e6;
        }

        footer {
            border-top: 1px solid #dee2e6;
            background: #fff;
        }

        /* Desjardins official colors */
        :root {
            --desjardins-teal: #00874e;
            --desjardins-dark: #004c2a;
            --desjardins-light: #e8f5e9;
            --desjardins-accent: #00a86b;
        }
        
        .btn-desjardins {
            --bs-btn-color: #fff;
            --bs-btn-bg: #00874e;
            --bs-btn-border-color: #00874e;
            --bs-btn-hover-color: #fff;
            --bs-btn-hover-bg: #006c3e;
            --bs-btn-hover-border-color: #006c3e;
            --bs-btn-active-color: #fff;
            --bs-btn-active-bg: #004c2a;
            --bs-btn-active-border-color: #004c2a;
        }
        
        .bg-desjardins {
            background-color: #00874e !important;
        }
        
        .text-desjardins {
            color: #00874e !important;
        }
        
        .border-desjardins {
            border-color: #00874e !important;
        }
        
        .bg-desjardins-light {
            background-color: #e8f5e9 !important;
        }
        
        .doc-card:hover {
            border-color: #00874e !important;
            box-shadow: 0 8px 25px rgba(0, 135, 78, 0.15) !important;
        }
        
        .navbar-brand-icon {
            background: linear-gradient(135deg, #00874e, #004c2a) !important;
        }
        
        .nav-link.active {
            color: #00874e !important;
            border-bottom-color: #00874e !important;
        }
        
        .pulse-loader {
            background: #00874e !important;
        }
        
        footer {
            border-top: 1px solid rgba(0, 135, 78, 0.15) !important;
        }
        
        .stats-bar {
            border-bottom: 1px solid rgba(0, 135, 78, 0.15) !important;
        }
        
        ::selection {
            background: rgba(0, 135, 78, 0.2);
        }

    </style>
</head>
<body>

<!-- ===== Navbar ===== -->
<nav class="navbar navbar-expand-lg bg-white shadow-sm sticky-top">
    <div class="container">
        <a class="navbar-brand fw-semibold d-flex align-items-center gap-2" href="${pageContext.request.contextPath}/">
            <span class="navbar-brand-icon">
                <i class="bi bi-file-earmark-text"></i>
            </span>
            Document Viewer
        </a>

        <button class="navbar-toggler" type="button"
                data-bs-toggle="collapse" data-bs-target="#mainNav"
                aria-controls="mainNav" aria-expanded="false"
                aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="mainNav">
            <form class="d-flex ms-auto me-2" role="search"
                  onsubmit="return false;">
                <div class="input-group input-group-sm">
                    <span class="input-group-text bg-transparent border-end-0">
                        <i class="bi bi-search text-muted"></i>
                    </span>
                    <input type="search" class="form-control border-start-0"
                           id="docSearch" placeholder="Search documents..."
                           aria-label="Search">
                </div>
            </form>
            <button class="btn btn-sm btn-outline-primary" type="button"
                    onclick="window.location.reload()"
                    title="Refresh">
                <i class="bi bi-arrow-clockwise"></i>
            </button>
        </div>
    </div>
</nav>

<!-- ===== Stats Bar ===== -->
<div class="stats-bar py-2">
    <div class="container d-flex justify-content-between align-items-center small text-muted">
        <span>
            <i class="bi bi-files me-1"></i>
            <strong>${fn:length(documents)}</strong> document(s)
        </span>
        <span>
            <i class="bi bi-info-circle me-1"></i>
            Click any card to open the viewer
        </span>
    </div>
</div>

<!-- ===== Main Content: Document Grid ===== -->
<main class="container py-4">
    <c:choose>
        <c:when test="${empty documents}">
            <div class="empty-state">
                <i class="bi bi-inbox"></i>
                <h4 class="mt-3">No documents available</h4>
                <p class="text-muted">Check that the document data source is configured.</p>
                <a href="${pageContext.request.contextPath}/documents" class="btn btn-desjardins">
                    <i class="bi bi-arrow-repeat me-1"></i>Try loading again
                </a>
            </div>
        </c:when>
        <c:otherwise>
            <div class="row g-4" id="docGrid">
                <c:forEach var="doc" items="${documents}" varStatus="loop">
                    <div class="col-12 col-sm-6 col-md-4 col-lg-3 doc-grid-item"
                         data-doc-name="${fn:toLowerCase(doc.name)}"
                         data-doc-type="${fn:toLowerCase(doc.type)}">
                        <div class="card doc-card shadow-sm"
                             data-bs-toggle="modal"
                             data-bs-target="#viewerModal"
                             data-doc-id="${doc.id}"
                             data-doc-name="${fn:escapeXml(doc.name)}"
                             data-doc-description="${fn:escapeXml(doc.description)}"
                             data-doc-type="${doc.type}"
                             data-doc-url="${doc.url}"
                             data-doc-thumb="${doc.thumbnailUrl}">
                            <div class="position-relative overflow-hidden">
                                <img src="${doc.thumbnailUrl}"
                                     alt="${fn:escapeXml(doc.name)}"
                                     class="card-img-top doc-thumb"
                                     loading="lazy"
                                     onerror="this.parentElement.innerHTML='<div class=\'doc-thumb d-flex align-items-center justify-content-center text-muted\'><i class=\'bi bi-file-earmark fs-1\'></i></div>'">
                                <span class="badge doc-type-badge bg-${doc.type eq 'image' ? 'success' : 'primary'} bg-opacity-85">
                                    <c:choose>
                                        <c:when test="${doc.type eq 'pdf'}">
                                            <i class="bi bi-filetype-pdf me-1"></i>PDF
                                        </c:when>
                                        <c:when test="${doc.type eq 'image'}">
                                            <i class="bi bi-image me-1"></i>Image
                                        </c:when>
                                        <c:otherwise>
                                            <i class="bi bi-file-earmark me-1"></i>${doc.type}
                                        </c:otherwise>
                                    </c:choose>
                                </span>
                            </div>
                            <div class="card-body">
                                <h6 class="card-title text-truncate mb-1"
                                    title="${fn:escapeXml(doc.name)}">
                                    ${fn:escapeXml(doc.name)}
                                </h6>
                                <p class="card-text small text-muted text-truncate mb-0"
                                   title="${fn:escapeXml(doc.description)}">
                                    ${fn:escapeXml(doc.description)}
                                </p>
                            </div>
                            <div class="card-footer bg-transparent border-top-0 pt-0">
                                <small class="text-muted">
                                    <i class="bi bi-file-earmark me-1"></i>
                                    <c:choose>
                                        <c:when test="${doc.sizeBytes gt 1000000}">
                                            ${String.format('%.1f', doc.sizeBytes / 1000000.0)} MB
                                        </c:when>
                                        <c:otherwise>
                                            ${String.format('%.0f', doc.sizeBytes / 1000.0)} KB
                                        </c:otherwise>
                                    </c:choose>
                                    <c:if test="${doc.pageCount > 0}">
                                        &middot; ${doc.pageCount} p.
                                    </c:if>
                                </small>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>
</main>

<!-- ===== Viewer Modal ===== -->
<div class="modal fade" id="viewerModal" tabindex="-1"
     aria-labelledby="viewerModalLabel" aria-hidden="true"
     data-bs-backdrop="static" data-bs-keyboard="true">
    <div class="modal-dialog modal-xl modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content">
            <div class="modal-header bg-white border-bottom-0">
                <div class="d-flex align-items-center gap-3 w-100">
                    <h5 class="modal-title fw-semibold text-truncate" id="viewerModalLabel">
                        Document Viewer
                    </h5>
                    <span class="badge bg-desjardins bg-opacity-10 text-primary ms-auto" id="modalDocType">
                        PDF
                    </span>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"
                            aria-label="Close"></button>
                </div>
            </div>
            <div class="modal-body pt-0">
                <!-- Loading indicator -->
                <div id="viewerLoading" class="text-center py-5">
                    <div class="pulse-loader mb-3"></div>
                    <p class="text-muted small">Loading document...</p>
                </div>

                <!-- Document viewer container (populated by JS) -->
                <div id="viewerContainer" class="d-none">
                    <!-- Custom tags will be injected here by JavaScript -->
                </div>

                <!-- Document info footer -->
                <div id="viewerInfo" class="d-none small text-muted mt-3 border-top pt-2">
                    <i class="bi bi-info-circle me-1"></i>
                    <span id="modalDocDescription"></span>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- ===== Footer ===== -->
<footer class="py-3">
    <div class="container text-center small text-muted">
        <i class="bi bi-file-earmark-text me-1"></i>
        Document Image Viewer &middot; JSP + Custom Tags
        <span class="mx-2">|</span>
        Bootstrap 5
        <span class="mx-2">|</span>
        <span id="footerTime"></span>
    </div>
</footer>

<!-- Bootstrap JS bundle -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz"
        crossorigin="anonymous"></script>

<!-- Inline JS for viewer modal and search -->
<script>
(function() {
    'use strict';

    // ---- Footer clock ----
    function updateFooterTime() {
        var el = document.getElementById('footerTime');
        if (el) {
            el.textContent = new Date().toLocaleString();
        }
    }
    updateFooterTime();
    setInterval(updateFooterTime, 30000);

    // ---- Search filter ----
    var searchInput = document.getElementById('docSearch');
    if (searchInput) {
        searchInput.addEventListener('input', function(e) {
            var query = e.target.value.toLowerCase();
            var items = document.querySelectorAll('.doc-grid-item');
            items.forEach(function(item) {
                var name = item.getAttribute('data-doc-name') || '';
                var type = item.getAttribute('data-doc-type') || '';
                var match = name.indexOf(query) !== -1 || type.indexOf(query) !== -1;
                item.style.display = match ? '' : 'none';
            });
        });
    }

    // ---- Modal viewer logic ----
    var viewerModal = document.getElementById('viewerModal');
    var loadingEl = document.getElementById('viewerLoading');
    var containerEl = document.getElementById('viewerContainer');
    var infoEl = document.getElementById('viewerInfo');
    var labelEl = document.getElementById('viewerModalLabel');
    var docTypeEl = document.getElementById('modalDocType');
    var docDescEl = document.getElementById('modalDocDescription');

    if (viewerModal) {
        viewerModal.addEventListener('show.bs.modal', function(event) {
            var trigger = event.relatedTarget;
            if (!trigger) return;

            var docId = trigger.getAttribute('data-doc-id');
            var docName = trigger.getAttribute('data-doc-name') || 'Document';
            var docDescription = trigger.getAttribute('data-doc-description') || '';
            var docType = trigger.getAttribute('data-doc-type') || 'pdf';
            var docUrl = trigger.getAttribute('data-doc-url') || '';
            var docThumb = trigger.getAttribute('data-doc-thumb') || '';

            // Reset state
            loadingEl.classList.remove('d-none');
            containerEl.classList.add('d-none');
            infoEl.classList.add('d-none');
            containerEl.innerHTML = '';

            labelEl.textContent = docName;
            docTypeEl.textContent = docType.toUpperCase();
            docDescEl.textContent = docDescription;

            // Build viewer content using custom tag equivalents via plain HTML
            // (In a real JSP context these would be rendered server-side)
            var viewerHtml = '';

            if (docType === 'image') {
                // Use image viewer
                viewerHtml = '<div class="image-viewer-wrapper" style="position:relative;display:inline-block;max-width:100%;">'
                    +   '<div class="image-viewer-container" style="position:relative;overflow:hidden;border:1px solid #dee2e6;border-radius:4px;background:#fff;">'
                    +     '<img src="' + escapeHtml(docUrl) + '"'
                    +          ' alt="' + escapeHtml(docName) + '"'
                    +          ' style="display:block;max-width:100%;height:auto;transition:transform 0.2s ease;cursor:zoom-in;"'
                    +          ' data-zoom-level="1"'
                    +          ' onclick="toggleZoom(this)"/>'
                    +     '<span class="badge bg-secondary position-absolute top-0 end-0 m-1" style="font-size:0.7rem;opacity:0.8;">🔍</span>'
                    +   '</div>'
                    + '</div>';
            } else {
                // Use document viewer (iframe)
                viewerHtml = '<div class="doc-viewer-wrapper" style="position:relative;width:100%;height:70vh;">'
                    +   '<div class="doc-viewer-container"'
                    +        ' data-document-id="' + escapeHtml(docId) + '"'
                    +        ' style="width:100%;height:100%;border:1px solid #dee2e6;border-radius:4px;overflow:hidden;background:#f8f9fa;">'
                    +     '<iframe src="' + escapeHtml(docUrl) + '"'
                    +             ' style="width:100%;height:100%;border:none;"'
                    +             ' title="' + escapeHtml(docName) + '"'
                    +             ' onerror="this.parentElement.innerHTML=\'<div class=\\\'alert alert-warning m-2\\\'>Unable to load document</div>\';"'
                    +     '></iframe>'
                    +     '<div class="doc-viewer-controls" style="position:absolute;bottom:8px;right:8px;display:flex;gap:4px;">'
                    +       '<button type="button" class="btn btn-sm btn-light border" onclick="zoomIframe(this, -0.1)" title="Zoom out">−</button>'
                    +       '<button type="button" class="btn btn-sm btn-light border" onclick="zoomIframe(this, 0.1)" title="Zoom in">+</button>'
                    +       '<button type="button" class="btn btn-sm btn-light border" onclick="zoomIframe(this, \'reset\')" title="Reset zoom">↺</button>'
                    +     '</div>'
                    +   '</div>'
                    + '</div>';
            }

            containerEl.innerHTML = viewerHtml;

            // Simulate loading
            setTimeout(function() {
                loadingEl.classList.add('d-none');
                containerEl.classList.remove('d-none');
                infoEl.classList.remove('d-none');
            }, 400);
        });

        viewerModal.addEventListener('hidden.bs.modal', function() {
            // Clean up on close
            containerEl.innerHTML = '';
        });
    }

    // ---- Zoom helpers ----
    window.toggleZoom = function(img) {
        var level = parseFloat(img.getAttribute('data-zoom-level') || '1');
        if (level === 1) {
            img.style.transform = 'scale(2)';
            img.setAttribute('data-zoom-level', '2');
            img.style.cursor = 'zoom-out';
        } else if (level === 2) {
            img.style.transform = 'scale(3)';
            img.setAttribute('data-zoom-level', '3');
            img.style.cursor = 'zoom-out';
        } else {
            img.style.transform = 'scale(1)';
            img.setAttribute('data-zoom-level', '1');
            img.style.cursor = 'zoom-in';
        }
    };

    window.zoomIframe = function(btn, delta) {
        var container = btn.closest('.doc-viewer-container');
        if (!container) return;
        var iframe = container.querySelector('iframe');
        if (!iframe) return;

        if (delta === 'reset') {
            iframe.style.transform = 'scale(1)';
            iframe.style.transformOrigin = 'top left';
            return;
        }

        var currentScale = 1;
        var match = iframe.style.transform.match(/scale\(([^)]+)\)/);
        if (match) { currentScale = parseFloat(match[1]); }

        var newScale = Math.max(0.3, Math.min(5, currentScale + delta));
        iframe.style.transform = 'scale(' + newScale + ')';
        iframe.style.transformOrigin = 'top left';
    };

    // ---- Utility ----
    function escapeHtml(str) {
        if (!str) return '';
        return str.replace(/&/g, '&amp;')
                  .replace(/</g, '&lt;')
                  .replace(/>/g, '&gt;')
                  .replace(/"/g, '&quot;')
                  .replace(/'/g, '&#39;');
    }
})();
</script>
</body>
</html>
