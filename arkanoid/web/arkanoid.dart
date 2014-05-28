import 'dart:html';
import 'dart:math';
import 'package:vector_math/vector_math.dart';

CanvasElement platno;
CanvasRenderingContext2D ctx;
Stopwatch stopky = new Stopwatch();
List<HerniObjekt> herniObjekty = new List<HerniObjekt>();
List<Cihla> cihly = new List<Cihla>();
List<Cihla> mazaneCihly = new List<Cihla>();
List<PowerUp> pupy = new List<PowerUp>();
List<PowerUp> mazanePower = new List<PowerUp>();
Palka palka;
Micek micek;
Cihla cihla;
int body=0;
int pokusy=3;

void main() {
   platno = querySelector("#platno");
   ctx = platno.context2D;
    
   init();
}

void init(){
  ctx.fillStyle="white";
  ctx.fillRect(0, 0, platno.width, platno.height);
  palka = new Palka(platno);
  micek = new Micek(platno);
  micek.x = 500;
  micek.y = 500;
  platno.onMouseMove.listen(palka.move);                                  //<--------
  herniObjekty.add(palka);
  herniObjekty.add(micek);
  udelejCihly();
  
  
  draw();
}

void udelejCihly(){
  cihla = new Cihla();
  cihla.nastavParametry(100,200,2,1,200);
  cihly.add(cihla);
  cihla = new Cihla();
  cihla.nastavParametry(200,200,2,2,200);
  cihly.add(cihla);
  cihla = new Cihla();
  cihla.nastavParametry(300,200,2,1,200);
  cihly.add(cihla);
  cihla = new Cihla();
  cihla.nastavParametry(400,200,2,1,200);
  cihly.add(cihla);
  cihla = new Cihla();
  cihla.nastavParametry(500,200,2,1,200);
  cihly.add(cihla);
  cihla = new Cihla();
  cihla.nastavParametry(600,200,2,1,200);
  cihly.add(cihla);
  cihla = new Cihla();
  cihla.nastavParametry(700,200,2,2,200);
  cihly.add(cihla);
  cihla = new Cihla();
  cihla.nastavParametry(100,400,2,1,200);
  cihly.add(cihla);
  cihla = new Cihla();
  cihla.nastavParametry(200,400,2,2,200);
  cihly.add(cihla);
  cihla = new Cihla();
  cihla.nastavParametry(300,400,2,0,200);
  cihly.add(cihla);
  cihla = new Cihla();
  cihla.nastavParametry(400,400,2,2,200);
  cihly.add(cihla);
  cihla = new Cihla();
  cihla.nastavParametry(500,400,2,2,200);
  cihly.add(cihla);
  cihla = new Cihla();
  cihla.nastavParametry(600,400,2,0,200);
  cihly.add(cihla);
  cihla = new Cihla();
  cihla.nastavParametry(700,400,2,2,200);
  cihly.add(cihla);
  
}

void draw(){
  ctx.fillStyle="white";
  ctx.beginPath();
  ctx.fillRect(0,0,platno.width,platno.height);
  ctx.fill();
    
  herniObjekty.forEach((objekt) => objekt.nakresliSe(ctx));
  cihly.forEach((objekt) => objekt.nakresliSe(ctx)); 
  pupy.forEach((objekt)=> objekt.nakresliSe(ctx));
  ctx.fillStyle="black";
  ctx.fillText("Pokusy: "+pokusy.toString(), 20, 20);
  ctx.fillText("Skóre: "+body.toString(), 20, 40);
  
  if(pokusy!=0) window.requestAnimationFrame(loop);
  else{
    ctx.fillStyle="black";
    ctx.fillText("Konec hry!", 400, 400);
  }
}

void loop(num _){
  pupy.forEach((objekt)=> objekt.pohyb());
  pupy.forEach((objekt) {
    if(objekt.sebran&&(objekt.s.elapsedMilliseconds>objekt.cas)) {
      objekt.ukonci();mazanePower.add(objekt);
      }
    });
  pupy.forEach((pup) { 
    if(palka.kolizniTest(pup)) pup.kolize();
    });
  cihly.forEach((objekt) {
    if(micek.kolizniTest(objekt)&&objekt.naraz()) mazaneCihly.add(objekt);});
  micek.pohyb();

  mazaneCihly.forEach((obj) =>cihly.remove(obj));
  mazaneCihly.clear();
  mazanePower.forEach((obj) =>pupy.remove(obj));
  mazanePower.clear();
  draw();

}



//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
abstract class HerniObjekt{
  int x;
  int y;
  int sirka;
  int vyska;
  String barva;
  
  bool kolizniTest(HerniObjekt _obj){
   /* if(((_obj.y)<(y + vyska))
            &&((_obj.x + _obj.sirka)>(x))
            &&((_obj.x)<(x + sirka))
            &&((_obj.y+_obj.vyska)>(y))){
          return true;
          }
        else
          return false;*/
        Rectangle tento = new Rectangle(x, y, sirka, vyska);
        Rectangle tamten = new Rectangle(_obj.x, _obj.y, _obj.sirka, _obj.vyska);
       return tento.containsRectangle(tamten);
  }
  
  
  Vector2 smerovyTest(HerniObjekt _obj){
     return new Vector2((_obj.x-x).toDouble(),(_obj.y-y).toDouble());
  }
  

  void nakresliSe(CanvasRenderingContext2D _ctx){
    _ctx.fillStyle = barva;
    _ctx.fillRect(x, y, sirka, vyska);
    _ctx.fill();
  }
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class Palka extends HerniObjekt{
  
  Palka(CanvasElement _can){
    sirka = 100;
    vyska = 15;
    x = ((_can.width)~/2)-(sirka~/2);
    y = (_can.height)-50;
    barva = "green";    
  }
  void move(MouseEvent e){
    x = e.offset.x;
  }
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class Micek extends HerniObjekt{
  int dx;
  int dy;
  double docasneX;
       double docasneY;
       double novaSirka;
       double novaVyska;
  
  
  Micek(CanvasElement _can){
    sirka = 10;
    vyska = sirka;
    x = ((_can.width)~/2)-(sirka~/2);
    y = ((_can.height)~/2)-(sirka~/2);
    barva = "blue";
    dx = 3;
    dy = 3;
  }
  
  void nakresliSe(CanvasRenderingContext2D _ctx){
    /*ctx.fillStyle = barva;
    ctx.ellipse(x, y, sirka,sirka, 0, 0,2*PI , false);
    ctx.fill();*/
    _ctx.fillStyle = barva; 
    _ctx.fillRect(x, y, sirka, sirka);
    _ctx.fill();
  }
  
  @override
  bool kolizniTest(HerniObjekt _obj){
   if(((_obj.y)<(y + vyska))
            &&((_obj.x + _obj.sirka)>(x))
            &&((_obj.x)<(x + sirka))
            &&((_obj.y+_obj.vyska)>(y))){
          return true;
          }
        else
          return false;
        }

  
   void kolize(HerniObjekt _obj){
  
     
     if(kolizniTest(_obj)){

            
            novaSirka=((sirka/2)/sqrt(2))*2;
            novaVyska=novaSirka;
            
            docasneX=((x+sirka/2))-(novaSirka/2);
            docasneY=((y+vyska/2))-(novaVyska/2);

         
            
       if (((docasneX+dx)>=(_obj.x))&&((docasneX+novaSirka+dx)<=((_obj.x + _obj.sirka).toDouble()))){
          dy=-dy;
          y+=dy;
          x+=dx;
       }
       
       if (((docasneY+dy)>=(_obj.y))&&((docasneY + novaVyska+dy)<=((_obj.y+_obj.vyska).toDouble()))){
         dx=-dx;
         x+=dx;
         y+=dy;
         
       }
       
      //_obj.naraz();
     //if((dx>0)&&(dy<0)){dx=-dx;};
     }


     
   }
   
   
    
  
  void pohyb(){
     if((x+sirka+dx > platno.width)||(x+dx<0)) dx = -dx;
     if((y+dy>platno.height)){pokusy-=1;dy=-dy;} ;
     if((y+dy<0))dy = -dy;
    /* if(kolizniTest(palka)){
        dy=-dy;
     }*/
     kolize(palka);
     cihly.forEach((obj) => kolize(obj));

     x += dx;
     y += dy;  

  }
  }


class Cihla extends HerniObjekt{
  int zivot;
  int powerup;
  int skore;
  int id;
  
  
  Cihla(){

    sirka = 72;
    vyska = 34;
    id = cihly.length +1;
  }
  
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
  

  
  bool naraz(){
    bool ret=false;
    if (zivot>0) {zivot -= 1;}
    if(zivot<1){
      body+=skore;
      vyhodPowerup();
      ret= true;  
    }
    return ret;
    }
  
  void vyhodPowerup(){
    if(powerup!=0){
      PowerUp p = new PowerUp(x+(sirka~/2).toInt(),y+vyska,powerup);
      pupy.add(p);
    }
  }
  
  
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class PowerUp extends HerniObjekt{
 int id;
 int cas;
 Stopwatch s = new Stopwatch();
 bool sebran;
 
 PowerUp(int _x, int _y, int _id){
   x=_x;
   y=_y;
   sirka=10;
   vyska=10;
   id=_id;
   sebran = false;
   switch(id){
     case 1: barva="yellow"; cas = 10000; break;
     case 2: barva="orange"; cas = 10000; break;
   }
   
 }
 
 void efekt(){
   s.start();
   switch(id){
     case 1:
       palka.sirka = 150; break;
     case 2: 
       micek.sirka = 20; micek.vyska = 20; break; 
   }
   
 }
 
 void kolize(){
   efekt();
   sebran=true;
 }
 
 void pohyb(){
   y+=4;
 }
 
  @override
  void nakresliSe(CanvasRenderingContext2D _ctx){
    if(!sebran) super.nakresliSe(_ctx);
  }
 
 void ukonci(){
   switch(id){
     case 1:
       palka.sirka = 100; break;
     case 2: micek.sirka = 10; micek.vyska = 10; break;
   }
 }
 
 
 
 
 
  
  
}



