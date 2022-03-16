import yaml
import sys
def para(filename, appname):
        with open(r'../charts/bitnami/'+appname+"/Chart.yaml") as file:
            a=yaml.load(file, Loader=yaml.FullLoader)
            data=[]
            for j in a["keywords"]:
                data.append(j)
            #f=open(r'./metadata-template.yml','a') 
            f=open(filename,'a') 
            for i in data:
                f.write('  - '+i+'\n')

inp=sys.argv
inp1=inp[1]
inp2=inp[2]
para(inp1, inp2)
