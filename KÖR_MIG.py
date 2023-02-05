
import numpy as np
import matlab.engine
import timeit

from filhantering_modul import *
from text_till_matris import *
from ordmoln import skapa_ordmoln

def SVD(matris,engine,u=True,s=True,v=True):
    """args;    matris; numpy array
        returnerar--> U,S,V;  numpy arrays"""
    matris = matlab.double(matris.tolist())
    U, S, V = engine.svd(matris,nargout=3)
    res = []
    if u:   res.append(double_till_array(U))
    if s:   res.append(double_till_array(S))
    if v:   res.append(double_till_array(V))

    if len(res) > 1:    return tuple(res)
    else:               return res[0]

def double_till_array(A):
    """args:    matlab double
     returns --->  numpy array"""
    return np.array(A._data).reshape(A.size, order='F')

def tema(vektor, ordbok, antal_ord):
    """args;    V_vek; singulärvektor   (list)
                ordbok; en lista med ord i rätt ordning (list)
                antal_ord; hur många ord som ska beskriva temat; (int)
    returns--> zip obj med ord och 'ordstyrka', sorterad efter 'ordstyrka'; (zip)"""
    vektor = np.abs(vektor)
    return sorted(  zip(ordbok, vektor) , key= lambda x: x[1], reverse=True)[0:antal_ord]

def teman(VT, ordbok, antal_teman=4, antal_ord=12):
    """ars;     VT; transponerad V-matris; (numpy_array)
                ordbok; lista med ord i rätt ordning; (list)
                antal_teman; hur många teman; (int)
                antal_ord; hur många ord som ska beskriva varje tema; (int)
    returnerar-->   lista med zips; varje zip är ett tema, med ord och dess "styrka; [zip]"""

    teman = []
    for i in range(0,antal_teman):
        vektor = VT[:,i]
        teman.append(tema(vektor,ordbok,antal_ord))

    return teman
  
def printa_tiden(tick):
    tack = timeit.default_timer()
    minuter, sekunder = divmod(tack-tick, 60)
    print(f"\t{int(minuter)} min {sekunder:.4f} sek",end='')

def promt_bool():
    """returnerar bool som använder anger"""
    while True:
        ans = input( 'j/n >> ')
        if ans.lower().strip(' ') in ('j','y','1','true','ja','yes','sant','ok','okej'):
            return True
        elif ans.lower().strip(' ') in ('n','nej','0','no','false','ej','inte','not'):
            return False
        print('Invalid.  ',end=' ')    

def promt_int():
    """returnerar det heltal användaren anger"""
    while True:
        try:    return int(input('>> '))
        except: print('Invalid.',end=' ')


def main():

    textfiler = välj_öppna_filväg(titel="Välj textfiler",flera=True,filtyp=('text-dokument','*.txt'))

    sparväg = None
    print('\nVill du spara matrisen?',end=' ')
    if promt_bool(): sparväg = välj_spara_väg(titel='Spara matris',filtyp=('text-dokument','*.txt'))

    print('\nSka ord-matrisen TD-IDF viktas?',end=' ')
    om_TDIDF = promt_bool()
    print('\nVill du rensa bort vanliga svenska ord? ',end=' ')
    utan_vanliga_ord = promt_bool()
    alfbetisk_ordning = True #promt_bool()

    print('\nAnge antal teman som ska extraheras:',end=' ')
    antal_teman = promt_int()
    print('\nAnge antal ord som ska definera varje tema:',end=' ')
    antal_ord = promt_int()


    print('\n\n...läser textfiler...')
    tick = timeit.default_timer()
    texter = texter_till_textlista(textfiler)
    printa_tiden(tick)


    print('\n\n...skapar ordbok...')
    tick = timeit.default_timer()
    ordbok = skapa_ordbok(texter,utan_vanliga_ord=utan_vanliga_ord,alf=alfbetisk_ordning)  # skapa ordbok
    printa_tiden(tick)
    print('\t ( antal unika ord:\t',len(ordbok),' )',end='')

    print('\n\n...skapar dok-ord matris...')
    tick = timeit.default_timer()
    matris = skapa_matris(ordbok,texter,IDF_viktad=om_TDIDF)
    printa_tiden(tick)
    print('\t ( matris-storlek:\t',matris.shape,' )',end='')

    if sparväg:
        karta_filväg = sparväg.strip('.txt') + '_karta.txt'
        skriv_till_textfil(sparväg, matris)
        skriv_till_textfil(karta_filväg, skapa_karta(textfiler, ordbok))

    print('\n\n...startar matlab...')
    tick = timeit.default_timer()
    eng = matlab.engine.start_matlab()
    printa_tiden(tick)

    print('\n\n...beräknar SVD...')
    tick = timeit.default_timer()
    V = SVD(matris,eng,u=False,s=False,v=True)
    printa_tiden(tick)

    print('\n\n...stänger matlab...')
    tick = timeit.default_timer()
    eng.quit()
    printa_tiden(tick)
    
    print('\n\n...tolkar singulärvektorer...')
    tick = timeit.default_timer()
    VT = np.transpose(V)
    TEMAN = teman(VT,ordbok,antal_teman=antal_teman,antal_ord=antal_ord)
    printa_tiden(tick)
    print('\n')


    skapa_ordmoln(TEMAN)


        
main()