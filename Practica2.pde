Pathfinding pathfinding;
int cols = 20, rows = 20;
boolean empezar = false, reset = false, camino = false;
int contador = 0;
//PrintWriter output1;
int t_old = 0, t_new = 0;
boolean boid_creado = true;

int contador_boids = 0;
boolean primera_vez;

final int NUM_BOIDS = 3;

int pos_inicial_x, pos_inicial_y;

//Boids
Flock flock1;
PVector pos_objetivo;

void setup(){
  size(800, 800);
  
  pathfinding = new Pathfinding(cols, rows);
  
  primera_vez = true;
  
  flock1 = new Flock(color(0,0,255));
  
  //output1 = createWriter("T_Computo.txt");
}


void draw(){
  
  if(empezar)
  {
    //t_old = millis();
    pathfinding.aEstrella();
    
    //output1.println(t_new);
  }

  if(reset){
    pathfinding = new Pathfinding(cols, rows);
    contador_boids = NUM_BOIDS;
    
    empezar = true;
    reset = false;    
  }
  
  pathfinding.draw();
  
   
  if(camino)
  {
    if(!primera_vez) //<>//
    {
      contador_boids = NUM_BOIDS;
      
      int goals_size = pathfinding.path.size() - 1;
      
      for(int i = 0; i < NUM_BOIDS; i++){
        flock1.boids.get(i).setNewContadorGoal(goals_size);
      }
      
      for(int i = 0; i < NUM_BOIDS; i++){
        flock1.boids.get(i).setNewGoal(pathfinding.path);
      }
    }
    else{
      
      for( int i = 0; i < NUM_BOIDS; i++){
        
        flock1.addBoid(new Boid((int)pathfinding.start.i *((width/rows)), (int)pathfinding.start.j*((height/cols)), pathfinding.path));
      }
      primera_vez = false;
      contador_boids = NUM_BOIDS;      
    }
    
    boid_creado = true;
    camino = false;
    
    flock1.run();
  }
    
    if(boid_creado)
    {
      flock1.run();
      if(contador_boids == 0)
        reset = true;
    }
    
    /*while(i < pathfinding.path.size()){
      boid1.setNewGoal((new PVector(pathfinding.path.get(i).i, pathfinding.path.get(i).j)));
      
      if((boid1.pos.x == pathfinding.path.get(i).i) && (boid1.pos.y == pathfinding.path.get(i).j))
      {
        i++;
      }
    }*/
  
  //t_new = millis()-t_old;
  
  
}

void mousePressed(){
  
  int pos_celda_x = (int)mouseX/((width/rows));
  int pos_celda_y = (int)mouseY/((height/cols));
  /*
  if(contador == 0)
  {
    pathfinding.setStart(pos_celda_x, pos_celda_y);
    pos_inicial_x = mouseX;
    pos_inicial_y = mouseY;
  }
  else if(contador == 1){
    pathfinding.setEnd(pos_celda_x, pos_celda_y);
  }
  else{*/  
    if(pathfinding.grid[pos_celda_x][pos_celda_y].wall)
      pathfinding.grid[pos_celda_x][pos_celda_y].wall = false;
    else
      pathfinding.grid[pos_celda_x][pos_celda_y].wall = true;
  /*}
  
  contador++;*/
}

void keyPressed() {
  
  if (keyPressed) {
    if (keyCode == 32) { //Tecla espacio
      empezar = true;
    }  
  }
  
  /*if(key == 'f' || key == 'F')
  {
    output1.flush();
    output1.close();
  }*/
}
      