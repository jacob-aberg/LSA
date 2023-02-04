
import os
from tkinter import filedialog


def välj_mapp(titel='Välj en mapp'):
    """returnerar filsökväg till en mapp"""
    return filedialog.askdirectory(title=titel)

def välj_öppna_filväg(flera=False,titel='Öppna fil',filtyp=('Alla filtyper','*.*')):
    """frågar om filväg och returnerar filväg
    params (valfria):   title= str ; fönstrets namn; default: 'Öppna fil'
                        filtyp= tuple; filtyp(er):('beskrivning','suffix'); default: ('Alla filtyper','*.*')
                        flera= bool; default: false; om false; returnar 1 str; om true; tuple med str(ar)"""
    if flera: return filedialog.askopenfilenames(title=titel,filetypes=(filtyp,))
    else:     return filedialog.askopenfilename(title=titel,filetypes=(filtyp,))

def välj_spara_väg(titel = 'Spara fil',filtyp=('Alla filtyper','*.*')):
    """frågar om filväg och returnerar filväg
    params (valfri):    title= str ; fönstrets namn ex: 'Välj en fil'
                        filtyp= tuple ; filtyp ex: ('beskrivning', '.suffix )"""
    return filedialog.asksaveasfilename(title = titel, filetypes=(filtyp,))

def hitta_excel_filer(mapp):
    """returnerar lista med excel-filnamn från mapp, input är mapp-sökväg"""
    if not os.path.isdir(mapp): return []
    filnamn = [f for f in os.listdir(mapp) if f.endswith('.xlsx')]
    filer = []
    for fil in filnamn:
        filer.append(os.path.join(mapp,fil))
    return filer
