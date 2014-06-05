import 'dart:html';
import 'dart:math';
import 'dart:collection';

CanvasElement platno;
CanvasRenderingContext2D ctx;
Stopwatch stopky = new Stopwatch();
List<HerniObjekt> herniObjekty = new List<HerniObjekt>();
List<Cihla> cihly = new List<Cihla>();
List<Cihla> mazaneCihly = new List<Cihla>();
List<Cihla> noveCihly = new List<Cihla>();
List<PowerUp> pupy = new List<PowerUp>();
List<PowerUp> mazanePower = new List<PowerUp>();
Palka palka;
Micek micek;
Cihla cihla;
int body=0;
int pokusy=3;
HashMap<PowerUp,int> efekty = new HashMap<PowerUp,int>();



/**
 *  Hlavní metoda
 *  Vytvoření plátna, spuštění inicializace
 */
void main() {
   platno = querySelector("#platno");
   ctx = platno.context2D;
    
   init();
}

/** Inicializace hry
 * Co je potřeba udělat před začátkem - vytvoření míčku, pálky, vytvoření cihliček...
 * Mimo jiné registrace eventu pro ovládání pálky
 * Na závěr - spuštění vykreslovací smyčky
 */
void init(){
  ctx.fillStyle="white";
  ctx.fillRect(0, 0, platno.width, platno.height);
  palka = new Palka(platno);
  micek = new Micek(platno);
  micek.x = 500;
  micek.y = 500;
  platno.onMouseMove.listen(palka.move);       //Propojení eventu pohybu myši po plátnu a pohybu pálkou
  herniObjekty.add(palka);
  herniObjekty.add(micek);
  udelejCihly();
   
  draw();
}

/** Vytvoření startovních cihel 
 */
void udelejCihly(){
  for(int i = 0; i<5 ; i++) randGen();
  
}

/**
 * Vykreslovací smyčka
 * Iterování skrz jednotlivé seznamy objektů a jejich vykreslování
 */
void draw(){
  ctx.fillStyle="white";
  ctx.beginPath();
  ctx.fillRect(0,0,platno.width,platno.height);
  ctx.fill();
    
  herniObjekty.forEach((objekt) => objekt.nakresliSe(ctx));       //
  cihly.forEach((objekt) => objekt.nakresliSe(ctx));              // Smyčky vykreslující objekty  
  pupy.forEach((objekt)=> objekt.nakresliSe(ctx));                //
  ctx.fillStyle="black";
  ctx.fillText("Pokusy: "+pokusy.toString(), 20, 20);
  ctx.fillText("Skóre: "+body.toString(), 20, 40);
  
  if(pokusy!=0) window.requestAnimationFrame(loop);           //Pokud máme životy, hry pokračuje
  else{                                                       //jinak
    ctx.fillStyle="black";                                    //
    ctx.fillText("Konec hry!", 400, 400);                     // Konec hry :)
  }
}

/**Herní smyčka
 * Projíždění herní logikou, kontrolování podmínek pro powerupy atd...
 * 
 */
void loop(num _){
  pupy.forEach((objekt)=> objekt.pohyb());                   //pohyb powerupu
  pupy.forEach((pup) {                                       //kolize powerupů
    if(palka.kolizniTest(pup)) pup.kolize();
    });
  pupy.forEach((objekt) {                                 //zpracování sebraných powerupů
    if(objekt.sebran) {
      if(efekty[objekt] == null) efekty[objekt]=0;      
      efekty[objekt]=efekty[objekt] + objekt.cas;     
      mazanePower.add(objekt);                                                                          
      }
    });
  
  efekty.forEach((objekt,value) {                         //smazání ''prošlých'' powerupů
    if (objekt.s.elapsedMilliseconds> value){
      objekt.ukonci();
      objekt.s.stop();
      objekt.s.reset();
      value=0;
    }
  } );
  cihly.forEach((objekt) {                          //Kolize míčku s cihlami
    if(micek.kolizniTest(objekt)&&objekt.naraz()) mazaneCihly.add(objekt);}); //Pokud kolize && cihla nemá životy, znič ji
  micek.pohyb();
  if (cihly.isEmpty){   //Pokud došly cihly
    randGen();          // vygeneruj nové
    randGen();
    randGen();
  }
  cihly.addAll(noveCihly);      //přidej všechny nově vygenerované cihly na herní plochu
  noveCihly.clear();
  mazaneCihly.forEach((obj) =>cihly.remove(obj));       //
  mazaneCihly.clear();                                  // Mazání cihel a powerupů které už nemají být ve hře
  mazanePower.forEach((obj) =>pupy.remove(obj));        //
  mazanePower.clear();                                  //
  draw();                                   //Zavolej vykreslování - aby herní smyčka pokračovala

}

/**
 * Náhodné generování cihel
 */
void randGen(){
  var random = new Random();
  int r= random.nextInt(3)+2;       //chceme 2-5 cihel
  for (int i=0; i<r;i++){
    int x = (random.nextInt(7)+1)*100;    //
    int y = (random.nextInt(8)+1)*50;     //
    int p = random.nextInt(3);            // Vygenerování náhodných parametrů cihliček
    int z = random.nextInt(2)+1;          //
    int s = (random.nextInt(8)+1)*50;     //
    Cihla c = new Cihla();            //vytvoř novou cihlu...
    c.nastavParametry(x, y, z, p, s); //...s těmito parametry
    bool kolize = false;
    cihly.forEach((objekt){if(c.kolizniTest(objekt)) kolize=true;});    //Testujeme, zda nová cihla nekoliduje s existující
if (!kolize){                 //Pokud nekoliduje, přidej ji
  noveCihly.add(c);
}
else i-=1;                    //Pokud koliduje, vygenerujeme místo ní novou
    
  }
}

/**
 * Hlídač - testuje zda je čas generovat nové cihličky a zrychluje pohyb míčku
 */
void hlidacSkore(){
  if ((body % 150) == 0){
    randGen();
    if (!((micek.dx==10) || (micek.dx==-10))){
      if (micek.dx>0) micek.dx+=0.2;
      else micek.dx-=0.2;
      if (micek.dy>0) micek.dy+=0.2;
      else micek.dy-=0.2;
    }
  }
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/** Herní objekt
 *  Abstrakt, ze kterého postupně dědíme. Sám o sobě má všechny vlastnosti a umí všechny metody,
 *  které by herní objekt měl umět. Obsahuje vše, co je našim budoucím objektům společné. Nebo
 *  lépe, všechny další objekty umí přesně to, co Herní Objekt. Pokud budeme později potřebovat 
 *  něco změnit, využijeme dědičnosti.
 *  Abstraktní objekt nelze sám o sobě použít, což dává smysl, jelikož nás zajímají konkrétní
 *  herní objekty s určitou formou a vlastnostmi.
 */ 
abstract class HerniObjekt{
  var x;
  var y;
  int sirka;
  int vyska;
  String barva;
  
  /** Kolizní objekt
   *  Jedna z našich nejduležitějších metod - funkce, která testuje, jestli se dva objekty 
   *  nepřekrývají. 
   */
  bool kolizniTest(HerniObjekt _obj){
        Rectangle tento = new Rectangle(x, y, sirka, vyska);      //vytvoř obdélník z vlastností tohoto objektu
        Rectangle tamten = new Rectangle(_obj.x, _obj.y, _obj.sirka, _obj.vyska); //vytvoř obdélník z vlastností objektu z parametru funkce
       return tento.containsRectangle(tamten); //Využijeme metodu třídy Rectangle, která vypočte kolizi :)
  }
  
  
  
  /**
   * Vykreslovací metoda
   * Každý zděděný objekt by se už v základu měl umět nakreslit
   */
  void nakresliSe(CanvasRenderingContext2D _ctx){
    _ctx.fillStyle = barva;
    _ctx.fillRect(x, y, sirka, vyska);    //Vykresli obdélník podle vlastností objektu
    _ctx.fill();
  }
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/**
 * Pálka - náš "hráč".
 * Tím, že dědíme z Herního objektu nemusíme zmiňovat to, co už máme - rozměry, barvu, vykreslování...
 * Pouze Herní Objekt obohatíme o to, co dělá pálku pálkou.
 */
class Palka extends HerniObjekt{
  /**
   * Konstruktor
   */
  Palka(CanvasElement _can){
    sirka = 100;
    vyska = 15;
    x = ((_can.width)~/2)-(sirka~/2);
    y = (_can.height)-50;
    barva = "green";    
  }
  /**
   * Pohybovací metoda - přesune pálku na pozici myši
   */
  void move(MouseEvent e){
    x = e.offset.x;
  }
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/**
 * Míček
 * Opět zděděný z Herního Objektu
 * Má mnoho proměnných navíc kvuli přepočtům kolizí při pohybu
 */
class Micek extends HerniObjekt{
  double dx;
  double dy;
  double docasneX;
  double docasneY;
  double novaSirka;
  double novaVyska;
  
 /**
  * Konstruktor, zadáváme pouze plátno podle kterého se vypočte pozice 
  */
  Micek(CanvasElement _can){
    sirka = 10;
    vyska = sirka;
    x = ((_can.width)~/2)-(sirka~/2);
    y = ((_can.height)~/2)-(sirka~/2);
    barva = "blue";
    dx = 3.0;
    dy = 3.0;
  }
  
  /**
   *  Přetížená zděděná metoda pro nakreslení
   */
  @override
  void nakresliSe(CanvasRenderingContext2D _ctx){
    _ctx.fillStyle = barva; 
    _ctx.fillRect(x, y, sirka, sirka);
    _ctx.fill();
  }
  
  /**
   * Přetížený kolizní test
   */
  @override
  bool kolizniTest(HerniObjekt _obj){
   if(((_obj.y)<(y + vyska))
   &&((_obj.x + _obj.sirka)>(x))
   &&((_obj.x)<(x + sirka))
   &&((_obj.y+_obj.vyska)>(y))){
      return true;
   }
   else return false;
  }

  /**
   * Metoda pro počítání kolizí s objekty a adekvátní pohyb vůči výsledku kolize
   * @param _obj Objekt se kterým se zjišťuje kolize
   */
   void kolize(HerniObjekt _obj){
     if(kolizniTest(_obj)){
       novaSirka=((sirka/2)/sqrt(2))*2;
       novaVyska=novaSirka;
       docasneX=((x+sirka/2))-(novaSirka/2);
       docasneY=((y+vyska/2))-(novaVyska/2);     
       
       if (((docasneX+dx)>=(_obj.x))&&((docasneX+novaSirka+dx)<=((_obj.x + _obj.sirka).toDouble()))){
          dy=-dy;
          /*y+=dy;
          x+=dx;*/
       }
       
       if (((docasneY+dy)>=(_obj.y))&&((docasneY + novaVyska+dy)<=((_obj.y+_obj.vyska).toDouble()))){
         dx=-dx;
         /*x+=dx;
         y+=dy;*/
         
       } 
     }   
   }
   
/**
 * Metoda pro pohyb míčku
 */
  void pohyb(){
     if((x+sirka+dx > platno.width)||(x+dx<0)) dx = -dx;    //Odrážení míčku od stěn
     if((y+dy>platno.height)){pokusy-=1;dy=-dy;} ;          //Odrážení míčku od spodku a odebrání životu
     if((y+dy<0))dy = -dy;                                  //Odrážení od stropu
     kolize(palka);                                    //Spočtení kolize s pálkou
     cihly.forEach((obj) => kolize(obj));              //Spočtení kolizí s cihlami

     x += dx;      //
     y += dy;      // Hni se

    }
  }

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/**
 * Cihla
 * Udržuje si ID které značí jaký typ powerupu cihlička obsahuje. Stejně tak udržuje informaci
 * o množství životů (tedy počtu nárazů než cihlička zmizí) a počet bodů, které dostaneme za její
 * zničení
 */
class Cihla extends HerniObjekt{
  int zivot;
  int powerup;
  int skore;
  
/**
 * Konstruktor - nastavujeme rozměry které jsou fixní
 */
  Cihla(){
    sirka = 72;
    vyska = 34;
  }
 
  /**
   * Metoda pro hromadné nastavení parametrů cihly
   */
  void nastavParametry(int _x, int _y, int ziv, int pow, int skor){
    x = _x;
    y = _y;
    zivot = ziv;
    powerup = pow;
    skore = skor;
    switch(powerup){
      case 0: barva ="red"; break;
      case 1: barva = "blue"; break;
      case 2: barva = "green";break;     
    }
    
  }
  

  /**Co se má stát při nárazu míčku do cihly
   * Hodnota vrací true nebo false - jde o takový myšlenkový hack - místo toho, abychom post ex 
   * zjišťovali, jestli jsme cihlu zničili, nastavili jsme nárazové metodě návratovou hodnotu.
   * Ta nám vrátí False, pokud cihla nebyla zničena, nebo True, pokud zničena byla.
   */
  bool naraz(){
    bool ret=false; //Nastav návratovou hodnotu na false
    if (zivot>0) {zivot -= 1;}    //Když mám ještě hodně životů. tak mi jeden odečti
    if(zivot<1){                  //Když už nemám životy...
      body+=skore;                //Připočti skóre
      hlidacSkore();              //Dej hlídačovi echo ať se podívá jestli nemá vytvořit nové cihly
      vyhodPowerup();             //Vyhoď powerup
      ret= true;                  //Nastav return na true - byla jsem zničena
    }
    return ret;                   
    }
  
  /**
   * Metoda pro vyhazování powerupů
   */
  void vyhodPowerup(){
    if(powerup!=0){         //Pokud mám nastavený nějaký powerup
      PowerUp p = new PowerUp(x+(sirka~/2).toInt(),y+vyska,powerup);    //Vytvoř nový powerup
      pupy.add(p);                                                      //A přidej ho do seznamu
    }
  }
  
  
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/**
 * Power Up
 * Kromě toho že si uchovává své ID které značí jaký typ efektu má, má každý powerup také své stopky,
 * které počítají uběhlý čas, pamatují si dobu po jakou trvají a má boolean značící, zda byl sebrán
 */
class PowerUp extends HerniObjekt{
 int id;
 int cas;
 Stopwatch s = new Stopwatch();
 bool sebran;
 
 /**
  * Konstruktor
  */
 PowerUp(int _x, int _y, int _id){
   x=_x;
   y=_y;
   sirka=10;
   vyska=10;
   id=_id;
   sebran = false;
   switch(id){                    //Nastav barvu podle id powerupu
     case 1: barva="yellow"; cas = 10000; break;
     case 2: barva="orange"; cas = 10000; break;
   }
   
 }
 
 /**
  * Metoda spouštějící efekt   
  */
 void efekt(){
   s.start();         //spusť stopky 
   switch(id){        //podle toho jaké je ID proveď něco
     case 1:
       palka.sirka = 150; break;
     case 2: 
       micek.sirka = 20; micek.vyska = 20; break; 
   }
   
 }
 
 /**
  * Přetížený operátor porovnávání - potřebujeme, aby se identičnost powerupů posuzovala
  * pouze podle ID a nikoliv podle celých objektů.
  */
 @override
 bool operator==(PowerUp p){
   if (this.id == p.id) return true;
   else return false;
 }
 
 /**
  * Přetížená metoda pro hashkód - kvuli hashtabulce. Chceme, aby se objekty indexovaly pouze podle ID
  */
 @override
 int get hashCode{
    return id;
 }
 
 /**
  * Když dojde ke kolizi s pálkou, spusť efekt a nastav sebrat=true
  */
 void kolize(){
   efekt();
   sebran=true;
 }
 
 /**
  * Hýbej se dolůůůůů
  */
 void pohyb(){
   y+=4;
 }
 
 
 /**
  * Přetížená metoda pro vykreslení - vykresluj se pouze pokud nejsi sebrán
  */
  @override
  void nakresliSe(CanvasRenderingContext2D _ctx){
    if(!sebran) super.nakresliSe(_ctx);
  }
 
  /**
   * Metoda pro ukončení powerupů - vracíme všechno co jsme změnili zpět
   */
 void ukonci(){
   switch(id){
     case 1:
       palka.sirka = 100; break;
     case 2:
       micek.sirka = 10; micek.vyska = 10; break;
   }
 }
 
 
 
 
 
  
  
}



