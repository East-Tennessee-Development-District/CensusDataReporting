import os
import re
from bs4 import BeautifulSoup
import subprocess

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

def fixA11yIssues(soup):
  replaceExtraHeadersWithDiv(soup)
  addAriaToHeaderNavs(soup)
  
 
def makePlotlyIdsUnique(soup):
  for i, plotlyPlot in enumerate(soup.find_all(class_='plotly')):
    originalId=plotlyPlot.get('id')
    plotlyPlot['id']="plotlyPlot"+str(i)
    plotlyPlot.parent.find(attrs={"data-for": originalId})['data-for']="plotlyPlot"+str(i)

def adjustPlotlySize(soup):
  for plotlyPlot in soup.find_all(class_='plotly'):
    plotlyPlot['style']=re.sub(r'height:\d+px','height:100%',plotlyPlot['style'])


# with open(fileName, encoding="utf8") as f:
#       soup = BeautifulSoup(f,features="html.parser")
# soup.find_all(class_='plotly')[0]['style']=re.sub(r'height:\d+px','height:100%',soup.find_all(class_='plotly')[0]['style'])
# ['height']="100%"
# # for plotlyPlot in soup.find_all(class_='plotly'):
#   print(plotlyPlot)
#   print(plotlyPlot.parent.find('script'))
  # print(f"plotlyId = {plotlyPlot.get['id']}")#" and plotlyScriptId = {plotlyPlot.parent.find('script').get('data-for')}")
  # 
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
  if os.getenv("QUARTO_PROJECT_OUTPUT_DIR") is not None:
    fileName=os.path.join(os.getcwd(),os.getenv("QUARTO_PROJECT_OUTPUT_DIR"),"reports",str(county)+".html")  
  else:
    fileName=os.path.join(os.getcwd(),"dev","reports",str(county)+".html")
  if os.path.isfile(fileName):
    with open(fileName, encoding="utf8") as f:
      soup = BeautifulSoup(f,features="html.parser")
    fixA11yIssues(soup)
    makePlotlyIdsUnique(soup)
    adjustPlotlySize(soup)
    with open(fileName,'w', encoding="utf8") as f:
      f.write(str(soup))
