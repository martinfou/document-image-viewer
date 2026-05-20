# 🧠 Brainstorm — Outils de Navigation du Visualiseur

> Features brainstorming pour le Document Image Viewer
> 2026-05-20 | Couleurs Desjardins

---

## 🎯 Vision

Le visualiseur doit permettre à l'utilisateur de **consulter, naviguer et
explorer** tout type de document (PDF, JPEG, TIFF) avec une expérience
fluide et professionnelle, aux couleurs Desjardins.

---

## 🔍 Fonctionnalités de Navigation

### 1. Zoom (nécessaire immédiatement)

| Fonction | Comportement | Raccourci |
|---|---|---|
| **Zoom In** | Agrandir l'image/document par paliers de 25% | `Ctrl +` ou `+` |
| **Zoom Out** | Réduire par paliers de 25% | `Ctrl -` ou `-` |
| **Reset Zoom** | Revenir à 100% | `Ctrl 0` |
| **Zoom Slider** | Curseur 25% → 200% avec affichage du % | — |
| **Molette** | Scroll = navigation verticale, `Ctrl+scroll` = zoom | Ctrl+scroll |

### 2. Fit (redimensionnement intelligent)

| Fonction | Comportement |
|---|---|
| **Fit to Width** | Ajuste le document à la largeur du panneau (défaut pour PDF) |
| **Fit to Height** | Ajuste le document à la hauteur du panneau |
| **Fit to Page** | Ajuste pour voir la page entière (largeur + hauteur) |
| **Actual Size** | 100% (taille réelle) |

### 3. Navigation entre documents

| Fonction | Comportement |
|---|---|
| **Previous / Next** | Document précédent/suivant dans la liste |
| **Document counter** | "3 / 6" avec progression cliquable |
| **Dropdown liste** | Sélectionner un document par son nom |
| **Keyboard arrows** | ← → pour naviguer entre docs |

### 4. Recherche dans le document

| Fonction | Comportement |
|---|---|
| **Search bar** | Champ de recherche dans la barre d'outils |
| **Match count** | "12 résultats" avec surlignage |
| **Next / Prev match** | Navigation entre les résultats |
| **Case sensitive** | Option toggle |

*Note : La recherche nécessite que le contenu textuel soit extrait
du PDF/TIFF via OCR ou extraction. MVP = recherche dans les métadonnées
(nom, description).*

### 5. Rotation

| Fonction | Comportement |
|---|---|
| **Rotate CW** | Rotation 90° horaire |
| **Rotate CCW** | Rotation 90° anti-horaire |
| **Reset** | Revenir à 0° |

### 6. Outils supplémentaires

| Fonction | Comportement |
|---|---|
| **Fullscreen** | Mode plein écran (F11 ou bouton) |
| **Download** | Télécharger le document original |
| **Print** | Imprimer le document |
| **Info panel** | Métadonnées : nom, type, taille, pages, date |

---

## 🎨 Barre d'outils (UI Design)

```
┌──────────────────────────────────────────────────────────────┐
│ 🔍 [___________]  ← Search (dans les métadonnées, MVP)       │
│                                                              │
│ [−] [🔍] [25%] [🔍] [+]  |  [⬉] [⬈] [⟲]  |  [◀] 3/6 [▶]   │
│  zoom out / slider / zoom in    fit W/H/Page  prev/next doc   │
│                                                              │
│ [🔄] [⛶] [⬇] [🖨] [ℹ]                                     │
│  rotate full dl print info                                    │
└──────────────────────────────────────────────────────────────┘
```

### Organisation en groupes

```
╔═══════════════════════════════════════════════════════════════╗
║  [SEARCH]                              [DOC: Annual Report] ║
║                                                              ║
║  [ZOOM −] [=== SLIDER ===] [ZOOM +]  │  [⬉⬈⟲]  │  [◀ 3/6 ▶] ║
║                                                              ║
║  [⟳] [⛶] [⬇] [🖨] [ℹ]                                      ║
╚═══════════════════════════════════════════════════════════════╝
```

---

## 📋 Priorisation

| Priorité | Fonction | Effort | Valeur |
|---|---|---|---|
| **P0** 🔥 | Zoom In/Out + slider | 2h | Critique |
| **P0** 🔥 | Fit Width / Fit Height | 1h | Critique |
| **P0** 🔥 | Navigation ◀▶ entre docs | 1h | Critique (déjà fait) |
| **P1** | Rotation (⟳ CW/CCW) | 1h | Haute |
| **P1** | Fullscreen (⛶) | 0.5h | Haute |
| **P2** | Search dans métadonnées | 2h | Moyenne |
| **P2** | Download (⬇) | 0.5h | Moyenne |
| **P3** | Search dans contenu PDF | 8h+ | Future |
| **P3** | Print (🖨) | 1h | Future |

---

## ⌨️ Raccourcis clavier

| Touche | Action |
|---|---|
| `+` / `-` | Zoom in / out |
| `Ctrl+0` | Reset zoom |
| `←` / `→` | Document précédent / suivant |
| `F` | Fit to width |
| `H` | Fit to height |
| `R` | Rotation 90° |
| `Ctrl+F` | Search |
| `Esc` | Fermer le visualiseur |
| `F11` | Fullscreen |

---

## 📐 Spécifications techniques

### Zoom levels
```
[25%] [50%] [75%] [100%] [125%] [150%] [200%]
  ↑                                       ↑
  Fit to width (dynamique)          Fit to page (si plus grand)
```

### Fit modes
```javascript
fitToWidth: function() {
    const container = viewer.offsetWidth - 40; // padding
    const scale = container / img.naturalWidth;
    img.style.transform = `scale(${scale})`;
    zoomLevel = Math.round(scale * 100);
}

fitToHeight: function() {
    const container = viewer.offsetHeight - 40;
    const scale = container / img.naturalHeight;
    img.style.transform = `scale(${scale})`;
    zoomLevel = Math.round(scale * 100);
}

fitToPage: function() {
    const wScale = (viewer.offsetWidth - 40) / img.naturalWidth;
    const hScale = (viewer.offsetHeight - 40) / img.naturalHeight;
    const scale = Math.min(wScale, hScale);
    img.style.transform = `scale(${scale})`;
    zoomLevel = Math.round(scale * 100);
}
```

### Keyboard handler
```javascript
document.addEventListener('keydown', function(e) {
    if (!modalVisible) return;
    if (e.key === '+' || e.key === '=') zoomIn();
    if (e.key === '-') zoomOut();
    if (e.key === '0' && e.ctrlKey) zoomReset();
    if (e.key === 'ArrowLeft') prevDocument();
    if (e.key === 'ArrowRight') nextDocument();
    if (e.key === 'f' && !e.ctrlKey) fitToWidth();
    if (e.key === 'h') fitToHeight();
    if (e.key === 'r') rotate();
    if (e.key === 'Escape') closeViewer();
});
```
