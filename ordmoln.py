
from wordcloud import WordCloud
import matplotlib.pyplot as plt
import math


def skapa_ordmoln(teman):
    """skapar och visar flera ordmoln i ett fönster
    args; lista/tuple med list/tuple/zip/dict där varje element är ett ord-värde par
    returnerar--> None
    """
    
    teman = [dict(tema) if type(tema) != dict else tema for tema in teman]

    n = len(teman)
    
    #beräknar grid-storlek
    rader = int(math.ceil(math.sqrt(n)))
    kols = int(math.ceil(n / rader))
    
    #skapar subplots
    fig, subplots = plt.subplots(rader, kols, figsize=(10, 7))
    #skapar ordmoln för varje tema
    for i, tema in enumerate(teman):
        rad = i // kols
        kol = i % kols
        plot = subplots[rad, kol]
        wordcloud = WordCloud(width=1200, height=500, background_color="white", 
                    scale=3).generate_from_frequencies(tema)
        plot.imshow(wordcloud, interpolation="bilinear")
    for plot in subplots.flat:
        plot.axis("off")
    plt.show()
