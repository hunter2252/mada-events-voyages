#!/bin/bash

FICHES_DIR="prestataires/fiches"
mkdir -p "$FICHES_DIR"

# Fonction pour créer un slug (nom simplifié pour l'URL)
slugify() {
    echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//'
}

# Boucler sur chaque prestataire du fichier JS (extraction basique)
# Pour l'instant, on va créer manuellement les fiches principales

echo "Fiches generees dans $FICHES_DIR"
