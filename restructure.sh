#!/bin/bash

echo "🔧 Restructuration de mada-events-voyages..."

# Créer les nouveaux dossiers
mkdir -p pages
mkdir -p assets/css
mkdir -p assets/js
mkdir -p assets/images
mkdir -p fiches/prestataires
mkdir -p scripts

# Déplacer les pages (sauf index.html)
for file in regions.html contact.html carte.html prestataires-madagascar.html; do
    if [ -f "$file" ]; then
        mv "$file" pages/
        echo "  ✓ pages/$file"
    fi
done

# Déplacer les assets
if [ -d "css" ]; then
    mv css/* assets/css/ 2>/dev/null
    rmdir css 2>/dev/null
    echo "  ✓ css/ → assets/css/"
fi

if [ -d "js" ]; then
    mv js/* assets/js/ 2>/dev/null
    rmdir js 2>/dev/null
    echo "  ✓ js/ → assets/js/"
fi

if [ -d "images" ]; then
    mv images/* assets/images/ 2>/dev/null
    rmdir images 2>/dev/null
    echo "  ✓ images/ → assets/images/"
fi

# Déplacer les fiches prestataires
if [ -d "prestataires" ]; then
    mv prestataires/* fiches/prestataires/ 2>/dev/null
    rmdir prestataires 2>/dev/null
    echo "  ✓ prestataires/ → fiches/prestataires/"
fi

# Déplacer le script de génération
if [ -f "generer_fiches.sh" ]; then
    mv generer_fiches.sh scripts/
    echo "  ✓ generer_fiches.sh → scripts/"
fi

echo ""
echo "✅ Terminé ! Nouvelle structure :"
find . -maxdepth 3 -not -path './.git/*' | sort
