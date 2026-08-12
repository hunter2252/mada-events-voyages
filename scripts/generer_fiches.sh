#!/bin/bash

FICHES_DIR="fiches/prestataires"
JSON_FILE="scripts/prestataires.json"
mkdir -p "$FICHES_DIR"

# Nettoyer les anciennes fiches
rm -f "$FICHES_DIR"/*.html

# Slugifier
slugify() {
    echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//'
}

# Extraire chaque prestataire avec python3
python3 << 'PYEOF'
import json, os

with open("scripts/prestataires.json", "r") as f:
    prestataires = json.load(f)

# Générer la page index
html_index = """<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Prestataires - Mada Events & Voyages</title>
    <link rel="stylesheet" href="../../assets/css/style.css">
    <style>
        .prestataires-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 20px; padding: 40px 20px; max-width: 1200px; margin: 0 auto; }
        .card { background: white; border-radius: 12px; padding: 25px; box-shadow: 0 3px 15px rgba(0,0,0,0.08); transition: transform 0.3s; }
        .card:hover { transform: translateY(-5px); }
        .card .type { display: inline-block; padding: 4px 12px; border-radius: 15px; font-size: 0.8em; color: white; margin-bottom: 10px; }
        .type-hotel { background: #4CAF50; }
        .type-agence { background: #2196F3; }
        .type-restaurant { background: #FF9800; }
        .type-transport { background: #9C27B0; }
        .type-guide { background: #E91E63; }
        .type-urgence { background: #F44336; }
        .card h3 { color: #2d6a4f; margin: 10px 0; }
        .card p { color: #555; font-size: 0.9em; margin: 5px 0; }
        .card a { color: #2196F3; text-decoration: none; }
        .card a:hover { text-decoration: underline; }
        .filters { text-align: center; padding: 30px 20px; }
        .filters select, .filters input { padding: 10px 20px; border: 1px solid #ddd; border-radius: 25px; margin: 5px; font-size: 1em; }
        .btn-whatsapp { display: inline-block; background: #25D366; color: white; padding: 8px 16px; border-radius: 20px; text-decoration: none; font-size: 0.9em; margin-top: 10px; }
        .btn-fb { display: inline-block; background: #1877F2; color: white; padding: 8px 16px; border-radius: 20px; text-decoration: none; font-size: 0.9em; margin-top: 10px; }
        .btn-call { display: inline-block; background: #FF5722; color: white; padding: 8px 16px; border-radius: 20px; text-decoration: none; font-size: 0.9em; margin-top: 10px; }
        .btn-email { display: inline-block; background: #607D8B; color: white; padding: 8px 16px; border-radius: 20px; text-decoration: none; font-size: 0.9em; margin-top: 10px; }
    </style>
</head>
<body>
    <div class="annonce-vacances">◆ Annuaire des prestataires touristiques de Madagascar ◆</div>
    <nav>
        <a href="../../index.html" class="logo">Mada Events & Voyages</a>
        <ul class="menu">
            <li><a href="../../index.html">Accueil</a></li>
            <li><a href="index.html">Prestataires</a></li>
            <li><a href="../../pages/carte.html">Carte</a></li>
            <li><a href="../../pages/contact.html">Contact</a></li>
        </ul>
    </nav>
    <header style="text-align:center; padding: 60px 20px 20px;">
        <h1>Prestataires Touristiques</h1>
        <p>Trouvez hôtels, guides, agences et restaurants à Madagascar</p>
    </header>
    <div class="filters">
        <select id="filterType" onchange="filterPrestataires()">
            <option value="">Tous les types</option>
            <option value="hotel">Hôtels</option>
            <option value="agence">Agences</option>
            <option value="restaurant">Restaurants</option>
            <option value="transport">Transport</option>
            <option value="guide">Guides</option>
            <option value="urgence">Urgences</option>
        </select>
        <select id="filterRegion" onchange="filterPrestataires()">
            <option value="">Toutes les régions</option>
        </select>
        <input type="text" id="searchInput" placeholder="Rechercher..." oninput="filterPrestataires()">
    </div>
    <section class="prestataires-grid" id="prestatairesContainer"></section>
    <footer style="text-align:center; padding:40px 20px; background:#2d6a4f; color:white; margin-top:40px;">
        <p>&copy; 2026 Mada Events & Voyages</p>
    </footer>
    <script>
        const prestataires = %s;
        let regions = [...new Set(prestataires.map(p => p.region))].sort();
        const regionSelect = document.getElementById('filterRegion');
        regions.forEach(r => { const opt = document.createElement('option'); opt.value = r; opt.textContent = r; regionSelect.appendChild(opt); });
        
        function generateCard(p) {
            const wa = p.tel.replace(/[^0-9]/g, '');
            return '<div class="card">' +
                '<span class="type type-' + p.type + '">' + p.type + '</span>' +
                '<h3>' + p.nom + '</h3>' +
                '<p><strong>📍</strong> ' + p.adresse + '</p>' +
                '<p><strong>🏙️</strong> ' + p.region + '</p>' +
                '<p>' + p.description + '</p>' +
                (p.tel ? '<a href="tel:' + p.tel + '" class="btn-call">📞 Appeler</a> ' : '') +
                (p.tel ? '<a href="https://wa.me/' + wa + '" class="btn-whatsapp">💬 WhatsApp</a> ' : '') +
                (p.email ? '<a href="mailto:' + p.email + '" class="btn-email">✉️ Email</a> ' : '') +
                (p.site ? '<a href="' + p.site + '" target="_blank">🌐 Site web</a> ' : '') +
                (p.fb ? '<a href="' + p.fb + '" target="_blank" class="btn-fb">📘 Facebook</a>' : '') +
                '</div>';
        }
        
        function filterPrestataires() {
            const type = document.getElementById('filterType').value;
            const region = document.getElementById('filterRegion').value;
            const search = document.getElementById('searchInput').value.toLowerCase();
            const filtered = prestataires.filter(p => 
                (!type || p.type === type) &&
                (!region || p.region === region) &&
                (!search || p.nom.toLowerCase().includes(search) || p.region.toLowerCase().includes(search) || p.description.toLowerCase().includes(search))
            );
            document.getElementById('prestatairesContainer').innerHTML = filtered.map(generateCard).join('');
        }
        
        filterPrestataires();
    </script>
</body>
</html>"""

with open("fiches/prestataires/index.html", "w") as f:
    f.write(html_index % json.dumps(prestataires, ensure_ascii=False))

print(f"✅ Page index générée avec {len(prestataires)} prestataires")
PYEOF

echo "✅ Fiches générées dans $FICHES_DIR"
ls -la "$FICHES_DIR"
