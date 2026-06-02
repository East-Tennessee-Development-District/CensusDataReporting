# cp ../reports/countyDashboard.qmd ../reports/Anderson.qmd

declare -a arr=(
  "Anderson"
  "Blount"
  "Campbell"
  "Claiborne"
  "Cocke"
  "Grainger"
  "Hamblen"
  "Jefferson"
  "Knox"
  "Loudon"
  "Monroe"
  "Morgan"
  "Roane"
  "Scott"
  "Sevier"
  "Union"
)

## loop through above array (quotes are important if your elements may contain spaces)
for county in "${arr[@]}"
do
  sed "s/\"Anderson\"/\"$county\"/" notebooks/countyDashboard.qmd > reports/$county.qmd
done

