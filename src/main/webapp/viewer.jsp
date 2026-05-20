<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="doc" uri="https://docviewer.example.com/tags" %>
<!DOCTYPE html>
<html lang="en" data-bs-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${fn:escapeXml(viewerDoc.name)} — Document Viewer</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <style>
        :root { --dz-green: #00874e; --dz-dark: #004c2a; --dz-light: #e8f5e9; }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        html, body { height: 100%; overflow: hidden; background: #1a1d23; font-family: system-ui, -apple-system, sans-serif; }
        
        /* ── Toolbar ── */
        .viewer-toolbar {
            display: flex; align-items: center; gap: 4px;
            padding: 6px 16px; background: #2a2d35;
            border-bottom: 1px solid rgba(255,255,255,0.08);
            height: 52px; flex-shrink: 0;
            user-select: none;
        }
        .toolbar-group { display: flex; align-items: center; gap: 2px; }
        .toolbar-divider {
            width: 1px; height: 24px; background: rgba(255,255,255,0.12);
            margin: 0 8px; flex-shrink: 0;
        }
        .tb-btn {
            display: inline-flex; align-items: center; justify-content: center;
            width: 34px; height: 34px; border: none; border-radius: 6px;
            background: transparent; color: #c8c8c8; cursor: pointer;
            transition: all 0.15s; font-size: 16px;
        }
        .tb-btn:hover { background: rgba(255,255,255,0.1); color: #fff; }
        .tb-btn.active { background: var(--dz-green); color: #fff; }
        .tb-btn.active:hover { background: var(--dz-dark); }
        
        .tb-label {
            color: #a0a0a0; font-size: 12px; padding: 0 6px;
            min-width: 36px; text-align: center; font-variant-numeric: tabular-nums;
        }
        .doc-title {
            color: #e0e0e0; font-size: 14px; font-weight: 500;
            padding: 0 12px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
            flex: 1; text-align: center;
        }
        
        /* ── Slider ── */
        .zoom-slider {
            width: 100px; height: 4px; appearance: none; background: rgba(255,255,255,0.2);
            border-radius: 2px; outline: none; cursor: pointer;
        }
        .zoom-slider::-webkit-slider-thumb {
            appearance: none; width: 14px; height: 14px; border-radius: 50%;
            background: var(--dz-green); border: 2px solid #fff; cursor: pointer;
        }
        
        /* ── Content area ── */
        .viewer-content {
            flex: 1; display: flex; align-items: center; justify-content: center;
            position: relative; overflow: hidden; background: #1a1d23;
        }
        .viewer-content img, .viewer-content object, .viewer-content iframe {
            max-width: 100%; max-height: 100%;
            transition: transform 0.15s ease;
            transform-origin: center center;
            box-shadow: 0 4px 30px rgba(0,0,0,0.4);
        }
        
        /* ── Navigation arrows ── */
        .nav-overlay {
            position: absolute; top: 0; bottom: 0; width: 80px;
            display: flex; align-items: center; justify-content: center;
            cursor: pointer; opacity: 0; transition: opacity 0.2s;
            z-index: 10;
        }
        .viewer-content:hover .nav-overlay { opacity: 1; }
        .nav-overlay:hover { opacity: 1; }
        .nav-overlay.prev { left: 0; background: linear-gradient(to right, rgba(0,0,0,0.3), transparent); }
        .nav-overlay.next { right: 0; background: linear-gradient(to left, rgba(0,0,0,0.3), transparent); }
        .nav-overlay i { font-size: 32px; color: #fff; opacity: 0.7; }
        .nav-overlay:hover i { opacity: 1; }
        
        /* ── Info bar ── */
        .info-bar {
            display: flex; align-items: center; justify-content: center; gap: 16px;
            padding: 6px 16px; background: #2a2d35;
            border-top: 1px solid rgba(255,255,255,0.08);
            height: 36px; flex-shrink: 0;
            color: #888; font-size: 12px;
        }
        .info-bar span { display: flex; align-items: center; gap: 4px; }
        
        /* ── Loading ── */
        .loading-state {
            display: flex; flex-direction: column; align-items: center; gap: 16px;
            color: #888;
        }
        .spinner { width: 40px; height: 40px; border: 3px solid rgba(255,255,255,0.1); border-top-color: var(--dz-green); border-radius: 50%; animation: spin 0.8s linear infinite; }
        @keyframes spin { to { transform: rotate(360deg); } }
        
        /* ── Empty state ── */
        .empty-viewer {
            display: flex; flex-direction: column; align-items: center; justify-content: center;
            height: 100%; color: #666; gap: 12px;
        }
        .empty-viewer i { font-size: 64px; opacity: 0.3; }
    </style>
</head>
<body style="display:flex;flex-direction:column;height:100vh;">

<!-- ═══ Toolbar ═══ -->
<div class="viewer-toolbar">
    <!-- Back -->
    <div class="toolbar-group">
        <button class="tb-btn" onclick="location.href='${pageContext.request.contextPath}/documents'" title="Back to grid (Esc)">
            <i class="bi bi-arrow-left"></i>
        </button>
    </div>
    
    <div class="toolbar-divider"></div>
    
    <!-- Previous / Next -->
    <div class="toolbar-group">
        <button class="tb-btn" onclick="navDoc(-1)" title="Previous (←)" id="btnPrev" ${viewerIndex <= 0 ? 'disabled style="opacity:0.3"' : ''}>
            <i class="bi bi-chevron-left"></i>
        </button>
        <span class="tb-label" id="docCounter">${viewerIndex + 1} / ${fn:length(viewerDocs)}</span>
        <button class="tb-btn" onclick="navDoc(1)" title="Next (→)" id="btnNext" ${viewerIndex >= fn:length(viewerDocs) - 1 ? 'disabled style="opacity:0.3"' : ''}>
            <i class="bi bi-chevron-right"></i>
        </button>
    </div>
    
    <div class="toolbar-divider"></div>
    
    <!-- Document title (center) -->
    <div class="doc-title" id="docTitle">${fn:escapeXml(viewerDoc.name)}</div>
    
    <div class="toolbar-divider"></div>
    
    <!-- Zoom -->
    <div class="toolbar-group">
        <button class="tb-btn" onclick="zoomOut()" title="Zoom Out (−)">−</button>
        <input type="range" class="zoom-slider" id="zoomSlider" min="10" max="300" value="100" oninput="zoomTo(this.value)">
        <span class="tb-label" id="zoomLabel">100%</span>
        <button class="tb-btn" onclick="zoomIn()" title="Zoom In (+)">+</button>
        <button class="tb-btn" onclick="zoomReset()" title="Reset (Ctrl+0)">⟲</button>
    </div>
    
    <div class="toolbar-divider"></div>
    
    <!-- Fit / Rotate -->
    <div class="toolbar-group">
        <button class="tb-btn" onclick="fitWidth()" title="Fit to Width (F)">⬉</button>
        <button class="tb-btn" onclick="fitHeight()" title="Fit to Height (H)">⬈</button>
        <button class="tb-btn" onclick="fitPage()" title="Fit to Page">⊞</button>
        <button class="tb-btn" onclick="rotateDoc()" title="Rotate 90° (R)">⟳</button>
    </div>
    
    <div class="toolbar-divider"></div>
    
    <!-- Actions -->
    <div class="toolbar-group">
        <button class="tb-btn" onclick="toggleFullscreen()" title="Fullscreen (F11)">⛶</button>
        <button class="tb-btn" onclick="downloadDoc()" title="Download">⬇</button>
    </div>
</div>

<!-- ═══ Content ═══ -->
<div class="viewer-content" id="viewerContent">
    <!-- Loading -->
    <div id="loadingState" class="loading-state">
        <div class="spinner"></div>
        <span>Loading document...</span>
    </div>
    
    <!-- Document -->
    <div id="docContainer" style="display:none;position:relative;">
        <c:choose>
            <c:when test="${viewerDoc.type eq 'pdf'}">
                <iframe id="docFrame" src="${pageContext.request.contextPath}/api/documents/${viewerDoc.id}/content"
                        style="border:none;width:100%;height:90vh;background:#fff;border-radius:4px;"
                        onload="onDocLoaded()"></iframe>
            </c:when>
            <c:otherwise>
                <img id="docImage" src="${pageContext.request.contextPath}/api/documents/${viewerDoc.id}/content"
                     alt="${fn:escapeXml(viewerDoc.name)}"
                     style="max-width:100%;max-height:85vh;border-radius:4px;cursor:grab;"
                     onload="onDocLoaded()">
            </c:otherwise>
        </c:choose>
    </div>
    
    <!-- Navigation overlay arrows -->
    <div class="nav-overlay prev" onclick="navDoc(-1)" id="navPrev" ${viewerIndex <= 0 ? 'style="display:none"' : ''}>
        <i class="bi bi-chevron-left"></i>
    </div>
    <div class="nav-overlay next" onclick="navDoc(1)" id="navNext" ${viewerIndex >= fn:length(viewerDocs) - 1 ? 'style="display:none"' : ''}>
        <i class="bi bi-chevron-right"></i>
    </div>
</div>

<!-- ═══ Info bar ═══ -->
<div class="info-bar">
    <span><i class="bi bi-file-earmark"></i> ${fn:escapeXml(viewerDoc.name)}</span>
    <c:choose>
        <c:when test="${viewerDoc.type eq 'pdf'}"><span><i class="bi bi-filetype-pdf"></i> PDF</span></c:when>
        <c:when test="${viewerDoc.type eq 'jpeg'}"><span><i class="bi bi-image"></i> JPEG</span></c:when>
        <c:when test="${viewerDoc.type eq 'tiff'}"><span><i class="bi bi-file-earmark"></i> TIFF</span></c:when>
    </c:choose>
    <span><i class="bi bi-hdd"></i> ${viewerDoc.sizeBytes gt 1000000 ? String.format('%.1f', viewerDoc.sizeBytes / 1000000.0) : String.format('%.0f', viewerDoc.sizeBytes / 1000.0)} ${viewerDoc.sizeBytes gt 1000000 ? 'MB' : 'KB'}</span>
    <c:if test="${viewerDoc.pageCount > 0}"><span><i class="bi bi-files"></i> ${viewerDoc.pageCount} pages</span></c:if>
</div>

<script>
// ── State ──
var zoomLevel = 100;
var rotation = 0;
var currentIdx = ${viewerIndex};
var docs = [
    <c:forEach var="d" items="${viewerDocs}" varStatus="loop">
    {id:'${d.id}', name:'${fn:escapeXml(d.name)}', type:'${d.type}'}${!loop.last ? ',' : ''}
    </c:forEach>
];

// ── Zoom Engine ──
function zoomIn() { zoomTo(zoomLevel + 25); }
function zoomOut() { zoomTo(zoomLevel - 25); }
function zoomTo(lvl) {
    zoomLevel = Math.max(10, Math.min(300, lvl));
    applyZoom();
}
function zoomReset() { zoomTo(100); rotation = 0; applyZoom(); }

function applyZoom() {
    var el = document.getElementById('docImage') || document.getElementById('docFrame');
    if (!el) return;
    var scale = zoomLevel / 100;
    el.style.transform = 'scale(' + scale + ') rotate(' + rotation + 'deg)';
    document.getElementById('zoomLabel').textContent = zoomLevel + '%';
    document.getElementById('zoomSlider').value = zoomLevel;
}

// ── Fit Engine ──
function fitWidth() {
    var el = document.getElementById('docImage');
    if (!el || !el.naturalWidth) { zoomReset(); return; }
    var container = document.getElementById('viewerContent');
    var w = container.clientWidth - 80;
    var scale = Math.min(w / el.naturalWidth, 3);
    zoomLevel = Math.round(scale * 100);
    applyZoom();
}
function fitHeight() {
    var el = document.getElementById('docImage');
    if (!el || !el.naturalHeight) { zoomReset(); return; }
    var container = document.getElementById('viewerContent');
    var h = container.clientHeight - 40;
    var scale = Math.min(h / el.naturalHeight, 3);
    zoomLevel = Math.round(scale * 100);
    applyZoom();
}
function fitPage() {
    var el = document.getElementById('docImage');
    if (!el || !el.naturalWidth) { zoomReset(); return; }
    var container = document.getElementById('viewerContent');
    var wScale = (container.clientWidth - 80) / el.naturalWidth;
    var hScale = (container.clientHeight - 40) / el.naturalHeight;
    var scale = Math.min(wScale, hScale, 3);
    zoomLevel = Math.round(scale * 100);
    applyZoom();
}

// ── Rotation ──
function rotateDoc() { rotation = (rotation + 90) % 360; applyZoom(); }

// ── Navigation ──
function navDoc(dir) {
    var next = currentIdx + dir;
    if (next < 0 || next >= docs.length) return;
    var d = docs[next];
    window.location.href = '${pageContext.request.contextPath}/viewer/' + d.id;
}

// ── Fullscreen ──
function toggleFullscreen() {
    if (!document.fullscreenElement) {
        document.documentElement.requestFullscreen().catch(function(){});
    } else {
        document.exitFullscreen();
    }
}

// ── Download ──
function downloadDoc() {
    window.open('${pageContext.request.contextPath}/api/documents/${viewerDoc.id}/content', '_blank');
}

// ── Loaded ──
function onDocLoaded() {
    document.getElementById('loadingState').style.display = 'none';
    document.getElementById('docContainer').style.display = 'block';
}

// ── Keyboard ──
document.addEventListener('keydown', function(e) {
    if (e.key === '+' || e.key === '=') { zoomIn(); e.preventDefault(); }
    else if (e.key === '-') { zoomOut(); e.preventDefault(); }
    else if (e.key === '0' && e.ctrlKey) { zoomReset(); e.preventDefault(); }
    else if (e.key === 'ArrowLeft') { navDoc(-1); e.preventDefault(); }
    else if (e.key === 'ArrowRight') { navDoc(1); e.preventDefault(); }
    else if (e.key === 'f' && !e.ctrlKey) { fitWidth(); e.preventDefault(); }
    else if (e.key === 'h' && !e.ctrlKey) { fitHeight(); e.preventDefault(); }
    else if (e.key === 'r' && !e.ctrlKey) { rotateDoc(); e.preventDefault(); }
    else if (e.key === 'Escape') { window.location.href = '${pageContext.request.contextPath}/documents'; }
    else if (e.key === 'F11') { e.preventDefault(); toggleFullscreen(); }
});
</script>
</body>
</html>
