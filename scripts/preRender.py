import os
import re
import subprocess
from bs4 import BeautifulSoup
# print(os.getcwd())
# with open("wkdir.txt","w") as f:
#   f.write(os.getcwd())
#  

def makeCitationQmd(pathToReferences,folderWhereCitations):
  with open(pathToReferences,'r', encoding='utf-8') as f:
    tmp=re.findall(r'@\w*{\w*',f.read())
    dictOfCites={}
    for citation in tmp:
      citationStr=re.sub(r'\w*{','',citation)
      dictOfCites[re.sub(r'@','',citationStr)]=citationStr
  with open(os.path.join(os.getcwd(),folderWhereCitations,"citations.qmd"),'w', encoding='utf-8') as f:
    strToWrite='---\ntitle: \"Citations\"\nformat: html\ncsl: ../common_shared_assets/citations/chicago-notes-bibliography-access-dates.csl\nbibliography: ../common_shared_assets/citations/references.bib\n---\n\n'
    for citation in dictOfCites.keys():
      strToWrite=strToWrite+"# " + str(citation) + "\n\n" + dictOfCites.get(citation) + "\n\n"
    f.write(strToWrite)
  subprocess.run(["quarto","render", os.path.join(folderWhereCitations,"citations.qmd"), "-o", "citations.html"], stdout=subprocess.PIPE,stderr=subprocess.STDOUT, stdin=subprocess.DEVNULL) 
  if os.path.isfile(os.path.join(folderWhereCitations,'citations.html')):
    os.remove(os.path.join(folderWhereCitations,'citations.html'))
  os.rename("citations.html", os.path.join(folderWhereCitations,'citations.html'))
  
    
def getDictOfCitations(folderWhereCitations):
  with open(os.path.join(folderWhereCitations,'citations.html'),'r',encoding='utf-8') as f:
    soup=BeautifulSoup(f, features="html.parser")
  dicOfCites={}
  for p in soup.body.find_all('p'):
    if p.parent.find('h1') is not None:
      ref="@"+p.parent.find('h1').text
      cite=re.sub(r'\d+$','',p.text)
      dicOfCites[ref]=cite
  return(dicOfCites)

def updateCitations(fileName,dicOfCites):
  with open(fileName,'w',encoding='utf-8') as f:
    text=f.read()
    for key in dicOfCites.keys():
      text=re.sub(key,dicOfCites.get('key'),text)
    f.seek(0,0)
    f.write(text)
    f.truncate() #to remove spare spaces, recommended by Stack Overflow
    # Source - https://stackoverflow.com/a/68184578
    # Posted by Booboo, modified by community. See post 'Timeline' for change history
    # Retrieved 2026-07-08, License - CC BY-SA 4.0

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

pathToReferences=os.path.join("common_shared_assets","citations","references.bib")
folderWhereCitations="resources"
print(os.path.isfile(pathToReferences))

makeCitationQmd(pathToReferences,folderWhereCitations)
dicOfCites=getDictOfCitations(folderWhereCitations)

with open("scripts/citations.R",'w',encoding='utf-8') as f:
  with open("resources/troubleCitations.txt",'w',encoding='utf-8') as t:
    for key in dicOfCites.keys():
      if re.match("^@\\d",str(key)):
        print(str(key))
        t.write(f"{str(key)}\n")
      else:
        f.write(f"{re.sub('@','',key)}Cite <- \"{dicOfCites.get(key)}\"\n")

for county in countiesInETDD:
 with open("notebooks/countyDashboard.qmd") as f:
  updatedFile=re.sub(r"Anderson",county,f.read())
  
  if county == "Anderson":
    updatedFile=re.sub(r'caption = "Density is population / area (in square miles)"','caption = "Density is population / area (in square miles) (a) Formerly Lake City"',updatedFile)
  with open("reports/"+county+".qmd", "w") as o:
    o.write(updatedFile)   
