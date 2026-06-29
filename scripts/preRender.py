import os
import re


# print(os.getcwd())
# with open("wkdir.txt","w") as f:
#   f.write(os.getcwd())
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
 with open("notebooks/countyDashboard.qmd") as f:
  updatedFile=re.sub(r"Anderson",county,f.read())
  with open("reports/"+county+".qmd", "w") as o:
    o.write(updatedFile)   
