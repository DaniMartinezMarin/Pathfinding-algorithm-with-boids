class Boid {

  PVector pos;
  PVector vel;
  PVector acc;
  float r;
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed
  float distance, distance2, distance3;
  
  ArrayList<Cell> goals;
  int contador_goal;
  
  Objetivo objetivo_boid;
  Esquivar obstaculo;
  PVector pos_objetivo, pos_obstaculo;

    Boid(float x, float y, ArrayList<Cell> goal) {
    acc = new PVector(0, 0);

    // This is a new PVector method not yet implemented in JS
    // velocity = PVector.random2D();

    // Leaving the code temporarily this way so that this example runs in JS
    float angle = random(TWO_PI);
    vel = new PVector(cos(angle), sin(angle));

    pos = new PVector(x, y);
    r = 4.0;
    maxspeed = 2;
    maxforce = 0.03;
    
    goals = goal;
    contador_goal = goals.size() - 1;
    
    /*for(int j = 0; j < contador_goal; j++){
      println(goals.get(j).i + "/" + goals.get(j).j);
    }*/
  }
  
  void setNewGoal(ArrayList<Cell> goal){
    
    goals = goal;
  }
  
  void setNewContadorGoal(int goals_size){
    contador_goal = goals_size;
  }

  void run(ArrayList<Boid> boids, color c1) {
    flock(boids);
    //flock_flock(boids_esquivar);
    update();
    borders();
    render(c1);
    
    //applyForce(seek(pos_objetivo));
    
    /*if(PVector.dist(pos, pos_obstaculo) < 100)
    {
        applyForce(flee(pos_obstaculo));
    }*/
    
    if(contador_goal >= 0)
    {
      PVector pos_boid_obj = new PVector((goals.get(contador_goal).i )* ((width/cols)-1 ) + width/rows/2, (goals.get(contador_goal).j * ((height/rows) -1) + height/rows/2));
      applyForce(seek(pos_boid_obj).mult(1.5));
      
      int celda_x = (int)pos.x/((width/rows)-1); //Conversion a coordenadas de la celda
      int celda_y = (int)pos.y/((height/cols)-1); 
      
      if(celda_x == goals.get(contador_goal).i && celda_y == goals.get(contador_goal).j)
        contador_goal--;
    }
    
  }

  void applyForce(PVector force) {
    // We could add mass here if we want A = F / M
    acc.add(force);
  }

  // We accumulate a new acceleration each time based on three rules
  void flock(ArrayList<Boid> boids) {
    PVector sep = separacion(boids);   // Separation
    PVector ali = alinear(boids);      // Alignment
    PVector coh = cohesion(boids);   // Cohesion
    
    // Arbitrarily weight these forces
    //sep.mult(0.5);
    ali.mult(1.0);
    //coh.mult(1.0);
    // Add the force vectors to acceleration
    applyForce(sep);
    applyForce(ali);
    applyForce(coh);
  }
  
  void flock_flock(ArrayList<Boid> boids_esquivar) {
    PVector sep_flock = separacionFlock(boids_esquivar);
    
    sep_flock.mult(3);
    
    applyForce(sep_flock);
  }

  // Method to update position
  void update() { 
    // Update velocity
    vel.add(acc);
    // Limit speed
    vel.limit(maxspeed);
    pos.add(vel);
    // Reset accelertion to 0 each cycle
    acc.mult(0);
    
  }

  // A method that calculates and applies a steering force towards a target
  // STEER = DESIRED MINUS VELOCITY
  PVector seek(PVector target) {
    
    float doff = 0, dstop = 100.0;
    
    PVector desired = PVector.sub(target, pos);  // A vector pointing from the position to the target
    // Scale to maximum speed
    doff = desired.mag();
    
    desired.normalize();    
    
    /*if(doff > dstop)
      maxspeed = 2;
    else{
      maxspeed = (maxspeed * doff)/dstop;
      print(maxspeed);
    }*/
    
    desired.mult(maxspeed);

    // Above two lines of code below could be condensed with new PVector setMag() method
    // Not using this method until Processing.js catches up
    // desired.setMag(maxspeed);

    // Steering = Desired minus Velocity
    PVector steer = PVector.sub(desired, vel);
    steer.limit(maxforce);  // Limit to maximum steering force
    return steer;
  }
  
  PVector flee(PVector target){
    
    PVector desired = PVector.sub(pos, target);
    desired.normalize();
    desired.mult(maxspeed);
    
    //Buscar la dirección (seek) de huida, desired
    //target = seek(desired);
    
    // Steering = Desired minus Velocity
    PVector steer = PVector.sub(desired, vel);
    steer.limit(maxforce);  // Limit to maximum steering force
    
    if(PVector.dist(target, pos) > 100)
      steer = new PVector(0,0);
    return steer;      
  }

  void render(color c1) {
    // Draw a triangle rotated in the direction of velocity
    float theta = vel.heading2D() + radians(90);
    // heading2D() above is now heading() but leaving old syntax until Processing.js catches up
    
    color color1 = c1;
    
    fill(color1);
    stroke(255);
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(theta);
    beginShape(TRIANGLES);
    vertex(0, -r*2);
    vertex(-r, r*2);
    vertex(r, r*2);
    endShape();
    popMatrix();
  }

  // Wraparound
  void borders() {
    if (pos.x < -r) pos.x = width+r;
    if (pos.y < -r) pos.y = height+r;
    if (pos.x > width+r) pos.x = -r;
    if (pos.y > height+r) pos.y = -r;
  }

  // Separation
  // Method checks for nearby boids and steers away
  PVector separacion (ArrayList<Boid> boids) {
    
    float desiredseparation = 25.0f;
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    // For every boid in the system, check if it's too close
    for (Boid other : boids) {
      float d = PVector.dist(pos, other.pos);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation)) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(pos, other.pos);
        diff.normalize();
        diff.div(d);        // Weight by distance
        steer.add(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      steer.div((float)count);
    }

    // As long as the vector is greater than 0
    if (steer.mag() > 0) {
      // First two lines of code below could be condensed with new PVector setMag() method
      // Not using this method until Processing.js catches up
      // steer.setMag(maxspeed);

      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(vel);
      steer.limit(maxforce);
    }
    return steer;
  }

  // Alignment
  // For every nearby boid in the system, calculate the average velocity
  PVector alinear (ArrayList<Boid> boids) {
    
    float neighbordist = 50.0;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(pos, other.pos);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.vel);
        count++;
      }
    }
    if (count > 0) {
      sum.div((float)count);
      // First two lines of code below could be condensed with new PVector setMag() method
      // Not using this method until Processing.js catches up
      // sum.setMag(maxspeed);

      // Implement Reynolds: Steering = Desired - Velocity
      sum.normalize();
      sum.mult(maxspeed);
      PVector steer = PVector.sub(sum, vel);
      steer.limit(maxforce);
      return steer;
    } 
    else {
      return new PVector(0, 0);
    }
  }

  // Cohesion
  // For the average position (i.e. center) of all nearby boids, calculate steering vector towards that position
  PVector cohesion (ArrayList<Boid> boids) {
    
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all positions
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(pos, other.pos);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.pos); // Add position
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);
      return seek(sum);  // Steer towards the position
    } 
    else {      
      return new PVector(0, 0);
    }   
    
  }
  
  PVector cohesionFlocks (ArrayList<Boid> boids, ArrayList<Boid> boids2) {
    
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all positions
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(pos, other.pos);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.pos); // Add position
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);
      return seek(sum);  // Steer towards the position
    } 
    else {      
      return new PVector(0, 0);
    }   
    
  }
  
  Boolean borrarBoid(Boid b){
    
    boolean borrar = false;
    
    int celda_x = (int)pos.x/((width/rows)-1); //Conversion a coordenadas de la celda
    int celda_y = (int)pos.y/((height/cols)-1);
    
    if(celda_x == goals.get(0).i && celda_y == goals.get(0).j)
      borrar = true;         
    
    return borrar;       
  }
  
  PVector separacionFlock (ArrayList<Boid> boids) {
    
    float desiredseparation = 60.0f;
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    // For every boid in the system, check if it's too close
    for (Boid other : boids) {
      float d = PVector.dist(pos, other.pos);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation)) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(pos, other.pos);
        diff.normalize();
        diff.div(d);        // Weight by distance
        steer.add(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      steer.div((float)count);
    }

    // As long as the vector is greater than 0
    if (steer.mag() > 0) {
      // First two lines of code below could be condensed with new PVector setMag() method
      // Not using this method until Processing.js catches up
      // steer.setMag(maxspeed);

      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(vel);
      steer.limit(maxforce);
    }
    return steer;
  }
}