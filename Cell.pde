class Cell{
  
  int i;
  int j;
  float f = 0;
  float g = 0;
  float h = 0;
  Cell previous;
  boolean wall = false;
  
  ArrayList<Cell> neighbors;
  
  public Cell(int i_, int j_){    
    i = i_;
    j = j_;
    
    neighbors = new ArrayList<Cell>();
    previous = null;
    
    if(random(1) < 0) { //30% probabilidad de ser un obstaculo
      this.wall = true;
    }
  }
  
  void addNeighbors(Cell[][] grid){
    
    int i = this.i;
    int j = this.j;
    
    if (i < cols -1){
      this.neighbors.add(grid[i+1][j]);
    }
    if (i > 0){
      this.neighbors.add(grid[i-1][j]);
    }
    if (j < rows - 1){
      this.neighbors.add(grid[i][j+1]);
    }
    if (j > 0){
      this.neighbors.add(grid[i][j-1]);    
    }
    
    //Diagonales
    if(i > 0 && j > 0){
      this.neighbors.add(grid[i-1][j-1]); 
    }
    if(i < cols-1 && j > 0){
      this.neighbors.add(grid[i+1][j-1]); 
    }
    if(i > 0 && j < rows-1){
      this.neighbors.add(grid[i-1][j+1]); 
    }
    if(i < cols -1 && j < rows - 1){
      this.neighbors.add(grid[i+1][j+1]); 
    }
  }
  
  void display(color c){

    fill(c);
    if(this.wall){
      fill(0);
    }
    stroke(0);
    rect(i * (width/rows), j * (height/cols), (width/rows) - 1, (height/cols) - 1); 
    
  }
}