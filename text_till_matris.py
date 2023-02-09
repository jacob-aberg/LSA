
from filhantering_modul import *    
import numpy as np


def text_till_ordlista(textfil,siffror=True):
    """args: filsökväg till textfil (str)
        --> returnerar lista med alla ord (list)
            (ord görs till gemener och rensas på skiljetecken)
        """
    with open(textfil,'r',encoding='UTF-8') as fil:
        text  = fil.readlines()

    alla_ord = []
    for rad in text:    alla_ord.extend( rad.lower().split(' ') )
    
    alla_ord = rensa_skiljetecken(alla_ord,siffror=siffror)

    
    return alla_ord

def texter_till_textlista(textfiler,siffror=True):
    """args: filsökväg till textfiler (list med str)
        --> returnerar lista med texter, (list med lists med strs)
            (ord görs till gemener och rensas på skiljetecken)
        """
    texter = []
    for fil in textfiler:    
        texter.append( text_till_ordlista(fil,siffror=siffror) ) 
    return texter

def rensa_skiljetecken(ordlista,siffror=True):
    """args:    lista med str
        param; siffror; om False kastas siffror
            --> returnerar lista med endast alfanumeriska/alfa str"""
    for i, ord in enumerate(ordlista):
        a = ''
        for c in ord:
            if siffror:     
                if c.isalnum(): a += c
            else:   
                if c.isalpha(): a+=c
        ordlista[i] = a
    
    while '' in ordlista:  ordlista.remove('')

    return ordlista



def skapa_ordbok(texter,utan_vanliga_ord=True,alf=False,siffror=True):
    """args:    texter; (list med lists) en lista med listor med ord; [ ['ord','ord'],['ord','ord'] ]
                alf; (bool); om True --> alfabetisk ordning
        --> returnerar ordbok; lista med unika ord"""
    ordlista = []
    for text in texter: ordlista.extend(text)
    
    ordbok = []
    for ord in ordlista:
        if ord not in ordbok: 
            ordbok.append(ord)

    if alf: ordbok = sorted(ordbok)
    if utan_vanliga_ord: return rensa_vanliga_ord(ordbok,siffror=siffror)
    else:   return ordbok

def ord_frekvens(ord, text):
    """räknar hur många ggr ett ord förekommer i en lista med ord
    args:   ord; (str)
            text; lista med ord (list)
        --> returnerar antal (int)"""
    return np.count_nonzero(np.array(text) == ord)

def doc_frekvens2(ord,texter):
    """args:    ord;(str)
                text; (list med lists); lista med ordlistor     
        ---> (int); returnerar antalet dokument som ordet förekommer i """
    
    frek = 0
    for text in texter:
        if ord in text: frek +=1       

    return frek

def doc_frekvens(ord,texter):
    """args:    ord;(str)
                texter; (list med lists); lista med ordlistor
    ---> (int); returnerar antalet dokument som ordet förekommer i """
    return np.sum([1 for text in texter if ord in text])

def invers_dok_frekvens(ord,texter):
    """args:    ord;(str)
                text; (list med lists); lista med ordlistor     
        ---> (float); returnerar värde på hur "unikt" ett ord är i textsamlingen """     
    return np.log10(len(texter) / np.sum([1 for text in texter if ord in text]))

def rensa_vanliga_ord(ordbok,siffror=True):
    """args:    lista med ord (list)
            --> returnerar ordlista utan "vanliga ord (list)" """

    fil = os.path.join( os.getcwd(),'vanliga_ord.txt')
    vanliga_ord = text_till_ordlista( fil, siffror=siffror )

    unika_ord = []
    for ord in ordbok:
        if ord not in vanliga_ord: 
            unika_ord.append(ord)
    return  unika_ord

def skriv_till_textfil(filväg, data):
    """args:    filväg; filsökväg till ny textfil, (str)
                data; lista med data
        --> sparar fil  (returnerar ingenting) """

    if not filväg.endswith('.txt'): filväg += '.txt'
    ny_fil = open(filväg,'w',encoding='UTF-8')

    if isinstance(data[0], list) or isinstance(data[0], tuple) or isinstance(data[0], type(np.array(0))):
        for rad in data:
            ny_fil.writelines([str(element)+' ' for element in rad])
            ny_fil.write('\n')
        return
    else:
        for elem in data:
            ny_fil.write(str(elem) +'\n')


def skapa_matris2(ordbok, texter, IDF_viktad=False):
    """args:    ordbok; (list); lista med alla unika ord
                texter; (list(list)); lista med texter;
                IDF-viktad; (bool); om True skalas varje ordfrekvens med ett "unikhets-värde"
        returnerar--> matris; (np.array)"""     
    kolonner = []
    for ord in ordbok:
        kolonn = []
        for text in texter:
            if IDF_viktad: kolonn.append(    float(ord_frekvens(ord,text))  * invers_dok_frekvens(ord,texter)   )
            else: kolonn.append(ord_frekvens(ord,text))
        kolonner.append(kolonn)

        matris = np.transpose(np.array(kolonner))
    return matris

def skapa_matris(ordbok, texter, IDF_viktad=False):
    """
    Funktionen tar ordbok, lista med texter
    Returnerar en matris där varje rad representerar en text och varje kolumn ett unikt ord.
                matrisens element är ordfrekvens i dokumentet, alternativt TD_IDF-värdet
    args;
        ordbok:     (list); unika ord
        texter:     (list(list)); lista med texter(lista med textens ord) 
        IDF_viktad: (bool); om True skalas ordfrekvensen med ett "unikhets-värde" för ordet
    Returnerar-->   (np.array); matris  """

    antal_ord = len(ordbok)
    antal_texter = len(texter)

    matris = np.zeros((antal_texter, antal_ord))
    idf = 1.0
    for kol, ord in enumerate(ordbok):
        if IDF_viktad:  idf = np.log10(len(texter) / np.sum([1 for text in texter if ord in text]))

        for rad, text in enumerate(texter):
            tf = np.count_nonzero(np.isin(text, ord))  # tf = ord-frekvens
            matris[rad, kol] = tf * idf
    return matris


def skapa_karta(filer,ordbok):
    rad_namn = []
    for filnamn in filer:
        rad_namn.append(os.path.basename(filnamn)[0:-4])
    matris = []
    matris.append(['-----RADER:-----'])
    for rad, dok in enumerate(rad_namn):
        matris.append(['rad '+str(rad+1)+':\t'+ dok])
    matris.append(['\n\n---KOLONNER:---'])
    for kol, ord in enumerate(ordbok):
        matris.append(['kol '+str(kol+1)+':\t '+ ord])
    return matris

def spara_ordbok(filväg, ordbok):
    if not filväg.endswith('.txt'): filväg += '.txt'
    ny_fil = open(filväg,'w',encoding='UTF-8')

    for ord in ordbok:
        ny_fil.write(ord+'\n')


def main():
    filer = välj_öppna_filväg(titel="Välj textfiler",flera=True,filtyp=('text-dokument','*.txt'))
    texter = []
    for fil in filer:    
        texter.append( text_till_ordlista(fil) ) 

    ordbok = skapa_ordbok(texter,alf=True,utan_vanliga_ord=True)

    matris_filväg = välj_spara_väg(titel='Spara matris',filtyp=('text-dokument','*.txt'))
    karta_filväg = matris_filväg.strip('.txt') + '_karta.txt'

    skriv_till_textfil( matris_filväg, skapa_matris(ordbok,texter,IDF_viktad=True))

    skriv_till_textfil(karta_filväg, skapa_karta(filer,ordbok))





