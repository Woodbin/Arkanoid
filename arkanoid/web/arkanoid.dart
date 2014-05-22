import 'dart:html';
import 'dart:math';
import 'package:vector_math/vector_math.dart';

CanvasElement platno;
CanvasRenderingContext2D ctx;
Stopwatch stopky = new Stopwatch();
List<HerniObjekt> herniObjekty = new List<HerniObjekt>();
List<Cihla> cihly = new List<Cihla>();
List<Cihla> mazaneCihly = new List<Cihla>();
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
  cihla = new Cihla();
  cihla.nastavParametry(500,200,2,0,200);
  cihly.add(cihla);
  cihla = new Cihla();
    cihla.nastavParametry(200,400,2,0,200);
    cihly.add(cihla);
    cihla = new Cihla();
      cihla.nastavParametry(100,600,2,0,200);
      cihly.add(cihla);
  draw();
}

void draw(){
  ctx.fillStyle="white";
  ctx.beginPath();
  ctx.fillRect(0,0,platno.width,platno.height);
  ctx.fill();
    
  herniObjekty.forEach((objekt) => objekt.nakresliSe(ctx));
  cihly.forEach((objekt) => objekt.nakresliSe(ctx)); 
  ctx.fillText("Pokusy: "+pokusy.toString(), 20, 20);
  ctx.fillText("Skóre: "+body.toString(), 20, 40);
  
  window.requestAnimationFrame(loop);
}

void loop(num _){
  micek.pohyb();
  cihly.forEach((objekt) { if(objekt.kolizniTest(micek)&&objekt.naraz()) mazaneCihly.add(objekt);});
  mazaneCihly.forEach((obj) =>cihly.remove(obj));
  mazaneCihly.clear();
  draw();

}

int idCihly(Cihla _c){
  for (int i=0;i<cihly.length;i++){
   if((cihly.elementAt(i).x == _c.x)&&(cihly.elementAt(i).y == _c.y)) return i;
  }
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
    barva = "red";    
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
    /*ctx.fillStyle = "red";
    ctx.ellipse(x, y, sirka,sirka, 0, 0,2*PI , false);
    ctx.fill();*/
    _ctx.fillStyle = "green"; 
    _ctx.rect(x, y, sirka, sirka);
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
    /* if((!((_obj.y)<(y)) 
         && ((_obj.y + _obj.vyska)>(y)))
         ||(!((_obj.y)<(y + vyska)) 
             && ((_obj.y + _obj.vyska)<(y + vyska)))){
       dy=-dy;
       }                      
     if((!((_obj.x)<(x)) 
         && ((_obj.x + _obj.sirka)>(x)))
         ||(!((_obj.x)<(x + sirka)) 
             && ((_obj.x + _obj.sirka)<(x + sirka)))){
       dx=-dx;
       }*/
     
     
     
     if(kolizniTest(_obj)){

            
            novaSirka=((sirka/2)/sqrt(2))*2;
            novaVyska=novaSirka;
            
            docasneX=((x+sirka/2))-(novaSirka/2);
            docasneY=((y+vyska/2))-(novaVyska/2);

         
            
       if (((docasneX)>=(_obj.x))&&((docasneX+novaSirka)<=((_obj.x + _obj.sirka).toDouble()))){
          dy=-dy;
          y+=dy;
          x+=dx;
       }
       
       if (((docasneY)>=(_obj.y))&&((docasneY + novaVyska)<=((_obj.y+_obj.vyska).toDouble()))){
         dx=-dx;
         x+=dx;
         y+=dy;
         
       }
       
     
     //if((dx>0)&&(dy<0)){dx=-dx;};
     }


     
     
    }
  
  void pohyb(){
     if((x+dx > platno.width)||(x+dx<0)) dx = -dx;
     if((y+dy>platno.height)){} ;
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
    barva="red";
    sirka = 172;
    vyska = 134;
    id = cihly.length +1;
  }
  
  void nastavParametry(int _x, int _y, int ziv, int pow, int skor){
    x = _x;
    y = _y;
    zivot = ziv;
    powerup = pow;
    skore = skor;
    
  }
  

  
  bool naraz(){
    if (zivot>0) {zivot -= 1;return false;}
    else{
      body+=skore;
      return true;  
    }
    }
  
  
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~




