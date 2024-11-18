# This script copies my current Obsidian notes as the README.md file, and pushes to GitHub.
#!/bin/bash

version="v2024.11.18"
original="/home/pablo/Documents/obsidian/Work ⚛️/Instruments/Quantum ESPRESSO.md"
final="README.md"
title="QuantumEspresso4dummies update"
date=$(date +"%Y-%m-%d %H:%M")
temp="TEMP.md"
# Dict to clean Obsidian wikilinks
declare -A dictionary=(
    ["[[CASTEP]]"]="[CASTEP](http://www.castep.org/)"
    ["[[DFT]]"]="DFT"
    ["[[SCARF]]"]="SCARF"
    ["[[Atlas & Hyperion]]"]="Atlas & Hyperion"
    ["[[cif2cell]]"]="https://github.com/torbjornbjorkman/cif2cell"
    ["[[ASE]]"]="https://wiki.fysik.dtu.dk/ase/index.html"
    ["[[VESTA]]"]="https://jp-minerals.org/vesta/en/"
    ["[[naming convention]]"]="naming convention"
    ["[[SLURM]]"]="[SLURM](https://slurm.schedmd.com/documentation.html)"
    ["[[CP2K]]"]="[CP2K](https://www.cp2k.org/about)"
    ["[[Phonopy]]"]="[Phonopy](https://phonopy.github.io/phonopy/)"
)

# Iterate over the dictionary and apply substitutions
for key in "${!dictionary[@]}"; do
    awk -v key="$key" -v val="${dictionary[$key]}" '{gsub(key, val)} 1' "$original" > "$temp"
done

if diff -q "$temp" "$final" >/dev/null; then
    rm "$temp"
    zenity --warning --text="No changes detected." --timeout=1 --no-wrap --title="$title"
    exit 0
fi

cp "$temp" "$final"
rm "$temp"

(zenity --info --text="README.md updated. \nPushing to GitHub..." --timeout=1 --no-wrap --title="$title") &

# Check if the repo is updated
git fetch

if [ $(git rev-list HEAD...origin/master --count) -ne 0 ]; then
    (zenity --error --text="Changes detected in the remote repository. \nCheck it manually..." --no-wrap --title="$title") &
    exit 0
fi

git status
git add .
git commit -m "Automatic update from Obsidian on $date with $version"

if [ $? -ne 0 ]; then
    (zenity --error --text="Git commit failed. \nCheck it manually..." --no-wrap --title="$title") &
    exit 0
fi

git push

# Check if the push was successful
if [ $? -ne 0 ]; then
    (zenity --error --text="Git push failed. \nCheck it manually..." --no-wrap --title="$title") &
    exit 0
fi

(zenity --info --text="✅ Done!" --timeout=1 --no-wrap --title="$title") &

