# LSA
Latent semantisk analys med SVD
Projektsammanfattning 
 
SF1694 - SVD/Bildkompression 3 
 
Samuel Andersson  
samander@kth.se 
Anton Blomgren  
ablomg@kth.se 
Isak Sjöö  
isjoo@kth.se 
Jacob Åberg 
jacobabe@kth.se 
 
 
Teori / Bakgrund 

Singulärvärdesfaktorisering (SVD) är en metod inom linjär algebra som har många tillämpningsområden.
Bland annat används SVD för bildkomprimering där man förvarar bildens pixlar i en stor matris som man sedan delar upp i tre andra matriser som består av vänster- samt högersingulära vektorer och dess motsvarande singulära värden. 
Om matrisen bestående av bildens pixlar kallas A kan matrisen representeras av A=UΣVT där U:s kolonnvektorer består av vänstersingulära vektorer till A och V:s kolonnvektorer består av högersingulära vektorer till A samt U och V är ortonormala.
Man kan i exemplet med bildkomprimering säga att U består av data som beskriver de större dragen av bilden man komprimerar och VT består av data som beskriver vilken ”mix” av informationen i U som man ska använda för att få den ursprungliga bilden.
Matrisen Σ en diagonalmatris vars diagonalelement består av de singulära värdena till matrisen A inlagda i storleksordning från störst till minst samt nollor.
De vektorer i U som korresponderar med de största singulärvärdena i Σ är de starkaste dragen som beskriver bilden.
Detta gör att man kan ta bort de svagaste dragen (de vektorer med minst singulärvärde) från U och VT och skapa reducerade versioner av dessa matriser som tar upp mindre utrymme.
Med hjälp av de reducerade U och VT kan man skapa en reducerad A-matris och sedan ”projicera” en ny bild på delrummet som skapas av A och på så sätt approximera den nya bilden utifrån de starkaste dragen i bilderna i A.
Då kan man gå från bilder med 106 pixlar till att beskriva en bild utifrån ett par hundra drag (kombinationer av pixlar) med olika styrka.   
 
Sammanfattning

I detta projekt ska fokuseras på Latent Semantisk Analys (LSA) som är metod inom Natual-Language-Processing som använder SVD.
LSA används för att analysera relationer mellan dokument utifrån de förekommande orden.
Dokumenten görs till vektorer i ett högdimensionellt vektorrum där dimensionerna är ord. 
Ett dokument representeras således som ”en linjär kombination av dess ord”. 
Flera ”dokument-vektorer” sammanställs som radvektorer i en matris, och på den matrisen görs singulärvärdesuppdelning. 
Tanken är att det finns en slags underliggande semantisk struktur i dokumenten. SVD låter oss extrahera denna ”latenta semantik” hos textsamlingen, alltså de viktigaste ”teman”. 
Konceptuellt besläktade dokument ligger nära varandra i vektorrummet, och SVD kan identifiera vilka texter som semantiskt/tematiskt liknar varandra. 
Detta kan tillämpas på alla former av text i olika syften men är framför allt användbart för större och flera dokument. 
Man kan med större texter få reda på vad ett dokument innehåller för information i stora drag för att kunna kategorisera ett digitalt bibliotek. 
Det kan användas för att hitta teman och genrer hos skönlitterärara verk. LSA skulle mycket möjligt även kunna användas för exempelvis plagiatkontroll.  
 
Frågeställningar 

Kan singulärvärdesuppdelning användas för att extrahera värdefull information ur en textsamling? 
Vilka är de huvudsakliga teman en artist sjunger om i ett av deras album? 
Vad brukar Svenska Dagbladets ledar- och kultursidor handla om? 
