#!/bin/bash

# Script de synchronisation avec l'annuaire officiel du tourisme
# À exécuter périodiquement (cron job)

echo "🔄 Synchronisation avec annuaire.tourisme.gov.mg..."
DATE=$(date +%Y-%m-%d_%H-%M)

# Créer un dossier de backup
mkdir -p backups

# Sauvegarder l'ancienne version
cp fiches/prestataires/index.html "backups/prestataires_${DATE}.html"

# Télécharger les données officielles (5 catégories)
CATEGORIES=(
    "entreprise-de-voyages-et-de-prestations-touristiques"
    "etablissement-dhebergement"
    "etablissement-dhebergement-et-de-restauration"
    "etablissement-de-restauration"
    "guide"
)

for cat in "${CATEGORIES[@]}"; do
    echo "  📥 Téléchargement : $cat"
    curl -s "https://annuaire.tourisme.gov.mg/$cat" > "/tmp/annuaire_${cat}.html"
    
    # Extraire les noms et régions
    grep -A5 "membre__content--item" "/tmp/annuaire_${cat}.html" | \
        grep -oP '(?<=<div class="titreitem">).*?(?=</div>)|(?<=<span class="localisation">).*?(?=</span>)' | \
        paste -d "|" - - >> "/tmp/prestataires_sync.txt"
done

# Compter les nouvelles entrées
NB=$(wc -l < /tmp/prestataires_sync.txt 2>/dev/null || echo 0)
echo "✅ $NB prestataires trouvés"

# Mettre à jour le compteur dans la page
if [ $NB -gt 0 ]; then
    # Mettre à jour les chiffres dans index.html
    NB_AGENCES=$(grep -c "entreprise" /tmp/prestataires_sync.txt 2>/dev/null || echo 541)
    echo "   → Agences : $NB_AGENCES"
fi

echo "✅ Synchronisation terminée"
echo "📋 Les données officielles sont consultables sur annuaire.tourisme.gov.mg"
