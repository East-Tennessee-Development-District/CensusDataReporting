import os
import re
from bs4 import BeautifulSoup

def replaceExtraHeadersWithDiv(soup):
  for i, header in enumerate(soup.body.find_all('header')):
    if i != 0:
      header.name="div"

def addAriaToHeaderNavs(soup):
  for nav in soup.body.find_all('nav'):
    if nav.parent.get('id') == 'quarto-dashboard-header':
      nav['aria-label']="dashboard header"
    elif nav.parent.get('id')=='quarto-header':
      nav['aria-label']="website header"

def fixA11yIssues(fileName):
  with open(fileName, encoding="utf8") as f:
    soup = BeautifulSoup(f,features="html.parser")
  replaceExtraHeadersWithDiv(soup)
  addAriaToHeaderNavs(soup)
  with open(fileName,'w', encoding="utf8") as f:
    f.write(str(soup))
 

# soup.body.find_all('header')[0]
# soup.body.find_all('header')[1]
  
countiesInETDD=[
  "Anderson",
  "Blount",
  "Campbell",
  "Claiborne",
  "Cocke",
  "Grainger",
  "Hamblen",
  "Jefferson",
  "Knox",
  "Loudon",
  "Monroe",
  "Morgan",
  "Roane",
  "Scott",
  "Sevier",
  "Union"
]
for county in countiesInETDD:
  fileName=os.path.join(os.getcwd(),os.getenv("QUARTO_PROJECT_OUTPUT_DIR"),"reports",str(county)+".html")
  if os.path.isfile(fileName):
    fixA11yIssues(fileName)
