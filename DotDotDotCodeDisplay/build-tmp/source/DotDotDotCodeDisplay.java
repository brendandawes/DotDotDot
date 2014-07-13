import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.nio.*; 
import toxi.math.waves.*; 
import toxi.geom.*; 
import toxi.math.*; 
import toxi.audio.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class DotDotDotCodeDisplay extends PApplet {









int SAMPLE_FREQ=44100;

JOALUtil audio;
AudioBuffer buffer;
AudioSource source;

float[] sample;

float frequency = 0.01f;

float gain;

String lines[];

PFont font;

int counter = 0;

int codeX = 20;
int codeY = 20;

public void setup() {
	size(displayWidth,displayHeight);
	background(0);
	smooth();
	//frameRate(7);
	font = loadFont("Monaco-48.vlw");
	textFont(font, 12);
	lines = loadStrings("code.txt");
	audio = JOALUtil.getInstance();
  	audio.init();
  	setBuffer();
}

public void draw() {

	if (random(100) < 5) {
 		setBuffer();

	}

	setGain();
	
	int m = (int)random(7,15);
	if (frameCount%m==0) {
		fill(random(255),random(255),random(255));
	text(lines[counter%lines.length],codeX,codeY);
	counter++;

	
	
	float fontSize = random(24)+7;
	textFont(font,fontSize);
	//frameRate(random(24)+2);
	codeY += fontSize+2;
	if (codeY > height-20) {

		codeY = 20;
		background(0);
	}
}
	
}

public void setGain() {

gain = max(-0.2f,sin(frequency * frameCount));
source.setGain(gain);

}

public void setBuffer() {
 if (source != null) {
  source.delete();
  buffer.delete();
}

  sample=new float[SAMPLE_FREQ*4];
  // calculate the base frequency in radians
  float freq=AbstractWave.hertzToRadians(random(100,300),SAMPLE_FREQ);
  // create an oscillator for the left channel
  AbstractWave osc=new FMSquareWave(0,AbstractWave.hertzToRadians(6,SAMPLE_FREQ),freq,0);
  // and another modulated one for the right channel (at 2x the base freq)
  // (first define the freq modulation wave)
  AbstractWave fmod=new FMSquareWave(0,AbstractWave.hertzToRadians(6,SAMPLE_FREQ),freq,0);
  // (use a triangle wave to modulate the amplitude)
  AbstractWave amod=new FMTriangleWave(0,AbstractWave.hertzToRadians(1,SAMPLE_FREQ),random(0, 1.0f),0);
  // now create the actual 2nd oscillator
  AbstractWave osc2=new AMFMSineWave(0,freq*2,0,fmod,amod);
  // populate the sample buffer
  for(int i=0; i<sample.length; i+=2) {
    sample[i]=osc.update();
    sample[i+1]=osc2.update();
  }

  // convert raw signal into JOAL 16bit stereo buffer
  buffer=SynthUtil.floatArrayTo16bitStereoBuffer(audio,sample,SAMPLE_FREQ);
  // create a sound source, enable looping & play it
  //source=audio.generateSource();
  source=audio.generateSource();
  source.setBuffer(buffer);
  source.setLooping(true);
  //source.setPosition(random(-1.0,1.0),0,0);
  //source.updatePosition();
  source.play();

}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--full-screen", "--bgcolor=#666666", "--hide-stop", "DotDotDotCodeDisplay" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
