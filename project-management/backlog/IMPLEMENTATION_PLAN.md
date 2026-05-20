# Plan d'Implémentation — Outils de Navigation

> Basé sur le brainstorm `docs/brainstorm-navigation.md`
> Priorisation : P0 → P1 → P2 (deadline serrée)
> 2026-05-20

---

## 📋 Stories (avec points d'effort)

### Sprint Actuel — P0 : Navigation Core (5 pts)

| Story | Pts | Description | Dépend de |
|---|---|---|---|
| **NAV-01** | 2 | **Toolbar UI** — Barre d'outils complète dans le modal : zoom control, fit buttons, nav arrows, rotate. Design responsive avec couleurs Desjardins. Boutons avec icônes Bootstrap. | — |
| **NAV-02** | 1 | **Zoom Slider + Level** — Curseur 25%-200% avec affichage du % actuel. Zoom In/Out par paliers de 25%. Reset zoom à 100%. | NAV-01 |
| **NAV-03** | 1 | **Fit to Width / Fit to Height / Fit to Page** — Trois boutons qui ajustent l'échelle automatiquement. Fit Width = largeur du panneau. Fit Height = hauteur. Fit Page = min(largeur, hauteur). | NAV-01 |
| **NAV-04** | 1 | **Raccourcis Clavier** — `+`/`-` zoom, `←`/`→` navigation, `F` fit width, `H` fit height, `R` rotate, `Esc` fermer, `Ctrl+F` search. | NAV-01, NAV-02, NAV-03 |

### Sprint Prochain — P1 : Outils Avancés (3 pts)

| Story | Pts | Description | Dépend de |
|---|---|---|---|
| **NAV-05** | 1 | **Rotation** — Rotation 90° CW et CCW avec reset. Applique `transform: rotate()` sur l'élément affiché. | NAV-01 |
| **NAV-06** | 1 | **Fullscreen** — Bouton ⛶ pour basculer en mode plein écran via Fullscreen API. | NAV-01 |
| **NAV-07** | 1 | **Download Document** — Bouton ⬇ qui télécharge le fichier original via l'URL du document. | — |

### Backlog — P2 : Recherche (5 pts)

| Story | Pts | Description | Dépend de |
|---|---|---|---|
| **NAV-08** | 3 | **Search dans métadonnées** — Barre de recherche qui filtre les documents par nom/description dans la grille. Highlight des matchs. | — |
| **NAV-09** | 2 | **Search dans le document** — Pour les PDF textuels : extraire le texte côté serveur et chercher des mots-clés avec navigation entre résultats. | NAV-08 |

---

## 🎯 Sprint 1 — Contenu du code

### Fichiers à modifier

| Fichier | Changement |
|---|---|
| `src/main/webapp/index.jsp` | + Toolbar HTML (zoom, fit, nav, rotate, fullscreen) |
| `src/main/webapp/index.jsp` | + JavaScript : ZoomEngine, FitEngine, KeyboardHandler |
| `src/main/webapp/index.jsp` | + CSS : toolbar styles, slider personnalisé |

### Aucun nouveau fichier Java nécessaire

Toute la logique de navigation est **côté client** (JavaScript dans le JSP).
Pas besoin de modifier le servlet, les tags, ou le modèle.

---

## 📐 Spécifications Techniques

### ZoomEngine (JavaScript)

```javascript
const ZoomEngine = {
    level: 100,        // pourcentage
    min: 25,
    max: 200,
    step: 25,
    
    zoomIn() { this.setLevel(this.level + this.step); },
    zoomOut() { this.setLevel(this.level - this.step); },
    reset() { this.setLevel(100); },
    
    setLevel(lvl) {
        this.level = Math.max(this.min, Math.min(this.max, lvl));
        this.apply();
    },
    
    fitToWidth() {
        const scale = containerWidth / naturalWidth;
        this.level = Math.round(scale * 100);
        this.apply();
    },
    
    fitToHeight() {
        const scale = containerHeight / naturalHeight;
        this.level = Math.round(scale * 100);
        this.apply();
    },
    
    fitToPage() {
        const wScale = containerWidth / naturalWidth;
        const hScale = containerHeight / naturalHeight;
        this.level = Math.round(Math.min(wScale, hScale) * 100);
        this.apply();
    },
    
    apply() {
        const scale = this.level / 100;
        element.style.transform = `scale(${scale})`;
        this.updateUI();
    }
};
```

### Toolbar Layout

```html
<div class="viewer-toolbar">
    <!-- Zoom group -->
    <div class="toolbar-group">
        <button class="btn btn-sm btn-desjardins-outline" onclick="zoomOut()" title="Zoom Out">−</button>
        <input type="range" min="25" max="200" value="100" 
               oninput="zoomTo(this.value)" class="zoom-slider">
        <span class="zoom-level" id="zoomLevel">100%</span>
        <button class="btn btn-sm btn-desjardins-outline" onclick="zoomIn()" title="Zoom In">+</button>
    </div>
    
    <div class="toolbar-divider"></div>
    
    <!-- Fit group -->
    <div class="toolbar-group">
        <button class="btn btn-sm btn-desjardins-outline" onclick="fitWidth()" title="Fit to Width">⬉</button>
        <button class="btn btn-sm btn-desjardins-outline" onclick="fitHeight()" title="Fit to Height">⬈</button>
        <button class="btn btn-sm btn-desjardins-outline" onclick="fitPage()" title="Fit to Page">⟲</button>
    </div>
    
    <div class="toolbar-divider"></div>
    
    <!-- Navigation group -->
    <div class="toolbar-group">
        <button class="btn btn-sm btn-desjardins-outline" onclick="prevDoc()" title="Previous (←)">◀</button>
        <span class="doc-counter" id="docCounter">1 / 6</span>
        <button class="btn btn-sm btn-desjardins-outline" onclick="nextDoc()" title="Next (→)">▶</button>
    </div>
    
    <div class="toolbar-divider"></div>
    
    <!-- Actions group -->
    <div class="toolbar-group">
        <button class="btn btn-sm btn-desjardins-outline" onclick="rotate()" title="Rotate 90°">⟳</button>
        <button class="btn btn-sm btn-desjardins-outline" onclick="fullscreen()" title="Fullscreen">⛶</button>
        <button class="btn btn-sm btn-desjardins-outline" onclick="download()" title="Download">⬇</button>
    </div>
</div>
```

### Timeline

```
Jour 1 (today) ── NAV-01 Toolbar UI       ── 2h
              ── NAV-02 Zoom Slider       ── 1h
              ── NAV-03 Fit Width/Height  ── 1h
              ── NAV-04 Keyboard          ── 1h
              ── Tests + validation       ── 1h
              ── Push GitHub              ── 10min

Jour 2         ── NAV-05 Rotation         ── 1h
              ── NAV-06 Fullscreen        ── 0.5h
              ── NAV-07 Download          ── 0.5h

Future          ── NAV-08 Search metadata ── 3h
              ── NAV-09 Search content    ── 2h
```

---

## ✅ Critères de succès

- [ ] La toolbar s'affiche dans le modal avec les couleurs Desjardins
- [ ] Le zoom slider fonctionne (25% → 200%) avec affichage du %
- [ ] Fit Width / Fit Height / Fit Page ajustent le document correctement
- [ ] Les flèches ← → naviguent entre les documents
- [ ] Les raccourcis clavier marchent dans le modal
- [ ] La rotation 90° fonctionne
- [ ] Le mode plein écran est disponible
- [ ] 7/7 tests verts (mvn test)
- [ ] Compilation OK (mvn compile -q)
