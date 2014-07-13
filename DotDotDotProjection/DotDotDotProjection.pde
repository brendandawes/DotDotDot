import com.francisli.processing.http.*;
import geomerative.*;
import processing.pdf.*;

RFont f;
RShape grp;
RPoint[] points;

HDrawablePool pool;
HOscillator yoBase;
HSwarm swarm;

int index, timerStart, timer;
int timerFire = 250;
int timerBase = timerFire;

HttpClient client;

ArrayList projects;
ArrayList swarms;

final int GRID_SIZE = 10;

final float STROKE_WEIGHT = 1;

final int ELLIPSESHAPE = 0;

final int SQUARESHAPE = 1;

final int LINESHAPE = 2;

final color BACKGROUND_COLOR = color(0, 0, 0);

int SHAPE_TYPE = ELLIPSESHAPE;

int extraCounter = 0;

final HColorPool colors = new HColorPool(#FFFFFF, #71a9cc, #c5413d, #bcbc9a,#c5d7ef,#3aaca3,#cbbf71);

void setup() {
  size(1024,768);
  rectMode(CENTER);
  RG.init(this);
  H.init(this).background(#f9f9f9).autoClear(false);
  //background(BACKGROUND_COLOR);
  smooth();
  projects = new ArrayList();
  swarms = new ArrayList();
  //grp = RG.loadShape("datapoetry.svg");
  //grp = RG.centerIn(grp, g);
  grp = RG.getText("DOT", "DinMedium.ttf", 300, CENTER);
  //grp = RG.centerIn(grp, g);
  RG.setPolygonizer(RG.UNIFORMLENGTH);
  RG.setPolygonizerLength(5);
  points = grp.getPoints();
   yoBase = new HOscillator()
      .speed(10f)
      .range(2,10)
      .freq(2f) 
      .property(H.SIZE)
      .waveform(H.SINE)

     ;

     initSwarm();
  
  //beginRecord(PDF, "dotdotdot2.pdf");
}

void initSwarm() {

  int r = (int)random(3);

  SHAPE_TYPE = r;

  extraCounter = 0;

  background(BACKGROUND_COLOR);

  createSwarms();

}

void responseReceived(HttpRequest request, HttpResponse response) {
  if (response.statusCode == 200) {
    com.francisli.processing.http.JSONObject results = response.getContentAsJSONObject();
    for (int i = 0; i < results.size(); i++) {
      com.francisli.processing.http.JSONObject entry = results.get(i);
      String text = entry.get("title").stringValue();
      String url = entry.get("url").stringValue();
      int date = entry.get("date").intValue();
      addProject(text,url,date);
      
      println("text: "+text);
    }
    //createSwarms();
    //createPool();

  }
  println(response.getContentAsJSONObject());
}

void createSwarms() {

 for (int i=0; i < points.length; i++) {

      createSwarm(points[i].x,points[i].y);
      
    }
createPool();
}

void createSwarm(float x, float y) {

    HSwarm swarm = new HSwarm()
    .goal((width/2)+x,(height/2)+y)
    .speed(random(5,25))
    .turnEase(1)
    .twitch(25);
  ;

  swarms.add(swarm);

}

void createPool() {

  pool = new HDrawablePool(points.length);
  
  pool.autoAddToStage()
    .add (
      new HEllipse()
      
      .size(10)
    )


    
    .setOnCreate (
        new HCallback() {
          public void run(Object obj) {


            int i = pool.currentIndex();
            HDrawable d = (HDrawable) obj;
          d
            .fill( colors.getColor() )
            .loc(random(width),random(height))
            .anchorAt( H.CENTER )
            .alpha(0)
          ;
          // Create an oscillator with yoBase's values
          HOscillator yo = yoBase.createCopy();
          yo.target( d );
          HSwarm swarm = (HSwarm) swarms.get(pool.count()-1);
          swarm.addTarget(d);

        }
      }
    )
  ;
}

void addProject(String title, String url, int date) {

      Project p = new Project(title,url,date);
      projects.add(p);

}

void draw() {

  if (pool != null) {
 timer = millis() - timerStart;
  if (timer >= timerFire) {
    if(!pool.isFull()){
      pool.request();
      index = pool.currentIndex() + 1;  
        
    }
  }


  timerFire = timerBase * index/2;
  HIterator<HDrawable> it = pool.iterator();
  while(it.hasNext()) {
    HDrawable d = it.next();
    float snappedXpos = floor( d.x() / GRID_SIZE) * GRID_SIZE;
    float snappedYpos = floor( (d.y()+100) / GRID_SIZE) * GRID_SIZE;
    float r = d.width();
    fill(d.fill());
    noFill();
    strokeWeight(STROKE_WEIGHT);
    smooth();
    stroke(d.fill(),50);
    if (SHAPE_TYPE== ELLIPSESHAPE) {
      ellipse(snappedXpos,snappedYpos,r,r);
    }
    if (SHAPE_TYPE == SQUARESHAPE) {
     rect(snappedXpos, snappedYpos, r, r);
    }

     if (SHAPE_TYPE == LINESHAPE) {
     ellipse(snappedXpos,snappedYpos,r*2,r*2);
    }
  }
  H.drawStage();
}

if (index > points.length-1) {

  extraCounter++;
  if (extraCounter > 150) {
    initSwarm();
  }
}
  
}

void keyPressed() {

if(key=='s') {
  background(BACKGROUND_COLOR);
 initSwarm();

}
}
