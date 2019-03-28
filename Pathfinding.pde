class Pathfinding{
  
  int cols, rows;
  color blanco = color(255), verde = color(0, 255, 0), rojo = color(255, 0, 0), morado = color(181, 126, 220);

  Cell start, end, current;

  ArrayList<Cell> openSet;
  ArrayList<Cell> closedSet;
  ArrayList<Cell> neighbors;
  ArrayList<Cell> path;
  
  Cell[][] grid;
  
  public Pathfinding(int cols_, int rows_){
    
    cols = cols_;
    rows = rows_;
    
    //Making a 2D array
    grid = new Cell[rows][cols];
    
    openSet = new ArrayList<Cell>();
    closedSet = new ArrayList<Cell>();
    neighbors = new ArrayList<Cell>();
    
    for(int i=0; i < cols; i++){
        for(int j=0; j < rows; j++){
          grid[i][j] = new Cell(i, j);
        }
    }
    
    for(int i=0; i < cols; i++){
        for(int j=0; j < rows; j++){
          grid[i][j].addNeighbors(grid);
        }
    }
    
    start = grid[(int)random(rows)][(int)random(cols)];
    start.wall = false; 
    
    end = grid[(int)random(rows)][(int)random(cols)];
    end.wall = false;
    
    openSet.add(start);
  }
  
  
  
  void aEstrella(){
    
    if (openSet.size() > 0){
      
      int winner = 0;
      for(int i = 0; i < openSet.size(); i++){
        if(openSet.get(i).f < openSet.get(winner).f)
        {
          winner = i;
        }
      }
      
      current = openSet.get(winner);
      
      if (current == end){   
        
        empezar = false;
        camino = true;
        //reset = true;
        //noLoop();
        //println("DONE! - ESPERE 5 SEGUNDOS PARA VOLVER A EMPEZAR");
      }
      
      removeFromArray(openSet, current);
      closedSet.add(current);
      
      neighbors = current.neighbors;
      
      for( int i = 0; i < neighbors.size(); i++){
        Cell neighbor = neighbors.get(i);
        
        if(!encontrarNeighbor(closedSet, neighbor) && !neighbor.wall && !diagonalWall(neighbor)){
          float tempG = current.g + 1; //Cambiar el 1 por la distancia entre celdas
          
          boolean newPath = false;
          if(encontrarNeighbor(openSet, neighbor)){
            if(tempG < neighbor.g){
              neighbor.g = tempG;
              newPath = true;
            }
          } else{
            neighbor.g = tempG;
            newPath = true;
            openSet.add(neighbor);
          }
          
          if(newPath){
            
            neighbor.h = heuristica(neighbor, end);
            neighbor.f = neighbor.g + neighbor.h;
            neighbor.previous = current;
          }
          
          
        }
      }
    
    } else{
      //no solution
      empezar = false;
      //reset = true;
      //println("No solution - ESPERE 5 SEGUNDOS PARA VOLVER A EMPEZAR");
      //noLoop();
      //return;
    }
    
    //Añadir al array Path la ruta más óptima de a*
    path = new ArrayList<Cell>();
    Cell temp = current;
    path.add(temp);
          
    while(temp.previous != null)
    {
       path.add(temp.previous);
       temp = temp.previous;
    }
  }
  
  
  void draw(){
    
    //background(0);
          
    for(int i=0; i < cols; i++){
        for(int j=0; j < rows; j++){        
          grid[i][j].display(blanco);
      }
    }
    
    for(int i = 0; i < closedSet.size(); i++){
      closedSet.get(i).display(rojo);
    }
    
    for(int i = 0; i < openSet.size(); i++){
      openSet.get(i).display(verde);
    }
    
    if(path != null){
      for( int i =0; i < path.size(); i++){
        path.get(i).display(morado);    
      }
    }
    
    if(end != null){
      grid[end.i][end.j].display(color(81, 66, 52));
    }
  }
  
  void setStart(int start_x, int start_y){
    
    start = grid[start_x][start_y];
    start.wall = false;   
    
    openSet.add(start);
  }
  
  void setEnd(int end_x, int end_y){
    
    end = grid[end_x][end_y];
    end.wall = false;
  }
  
  
  
  void removeFromArray(ArrayList<Cell> array, Cell cell)
  {
    for(int i = array.size() - 1; i >= 0; i--){
      if(array.get(i) == cell){
          array.remove(i);
      }
    }
    
  }

  boolean encontrarNeighbor(ArrayList<Cell> array, Cell neighbor){
      
    boolean encontrado = false;
      for(int i = 0;  i < array.size(); i++){
        if(array.get(i) == neighbor){
          encontrado = true;
        }
      }
      
      return encontrado;    
  }

  float heuristica(Cell a, Cell b){
    
    float d = dist(a.i, a.j, b.i, b.j);
    //float d = abs(a.i - b.i) + abs(a.j - b.j);
    return d;
  }
  
  Boolean diagonalWall(Cell neighbor){
    Boolean pasar = false;
    switch(neighbors.size()){
      case 8:
            // abajo e izquierda
            if(neighbor.j+1 < rows-1 && neighbor.i-1 > 0 && encontrarNeighbor(neighbors, grid[neighbor.i][neighbor.j+1]) && encontrarNeighbor(neighbors, grid[neighbor.i-1][neighbor.j])){
              if(grid[neighbor.i][neighbor.j+1].wall == true && grid[neighbor.i-1][neighbor.j].wall == true){
                pasar = true;
              }
            }
            //izquierda y arriba
            if(neighbor.j-1 > 0 && neighbor.i-1 > 0 && encontrarNeighbor(neighbors, grid[neighbor.i][neighbor.j-1]) && encontrarNeighbor(neighbors, grid[neighbor.i-1][neighbor.j]) && grid[neighbor.i][neighbor.j-1].wall == true && grid[neighbor.i-1][neighbor.j].wall == true){
              pasar = true;
            }
            //arriba y derecha
            if(neighbor.j-1 > 0 && neighbor.i+1 < cols -1 && encontrarNeighbor(neighbors, grid[neighbor.i][neighbor.j-1]) && encontrarNeighbor(neighbors, grid[neighbor.i+1][neighbor.j]) && grid[neighbor.i][neighbor.j-1].wall == true && grid[neighbor.i+1][neighbor.j].wall == true){
              pasar = true;
            }
            // abajo y derecha
            if(neighbor.j+1 < rows-1 && neighbor.i+1 < cols -1 && encontrarNeighbor(neighbors, grid[neighbor.i][neighbor.j+1]) && encontrarNeighbor(neighbors, grid[neighbor.i+1][neighbor.j])  && grid[neighbor.i][neighbor.j+1].wall == true && grid[neighbor.i+1][neighbor.j].wall == true){
              pasar = true;
            }
           break;
           
      case 3:
       // caso esquina superior izquierda
            if(neighbor.j-1 >= 0 && neighbor.i-1 >= 0 && encontrarNeighbor(neighbors, grid[neighbor.i-1][neighbor.j]) && encontrarNeighbor(neighbors, grid[neighbor.i][neighbor.j-1]) &&  grid[neighbor.i-1][neighbor.j].wall == true && grid[neighbor.i][neighbor.j-1].wall == true)
             {
                pasar = true;
             }
       // caso esquina superior derecha
          if(neighbor.j-1 >=0 && neighbor.i+1 < cols  && encontrarNeighbor(neighbors, grid[neighbor.i][neighbor.j-1]) && encontrarNeighbor(neighbors, grid[neighbor.i+1][neighbor.j])&& grid[neighbor.i][neighbor.j-1].wall == true && grid[neighbor.i+1][neighbor.j].wall == true)
           {
                pasar = true;
           }
       // caso esquina inferior izquierda
          if(neighbor.j+1 < rows && neighbor.i-1 >= 0  && encontrarNeighbor(neighbors, grid[neighbor.i-1][neighbor.j]) && encontrarNeighbor(neighbors, grid[neighbor.i][neighbor.j+1])&& grid[neighbor.i-1][neighbor.j].wall == true && grid[neighbor.i][neighbor.j+1].wall == true)
           {
                pasar = true;
           }
       // caso esquina inferior derecha
          if(neighbor.j+1 < rows && neighbor.i+1 >= 0  && encontrarNeighbor(neighbors, grid[neighbor.i][neighbor.j+1]) && encontrarNeighbor(neighbors, grid[neighbor.i+1][neighbor.j])&& grid[neighbor.i][neighbor.j+1].wall == true && grid[neighbor.i+1][neighbor.j].wall == true)
           {
                pasar = true;
           }
          break;
          
       case 5:
          // abajo e izquierda
            if(neighbor.j+1 < rows && neighbor.i-1 >= 0 && encontrarNeighbor(neighbors, grid[neighbor.i][neighbor.j+1]) && encontrarNeighbor(neighbors, grid[neighbor.i-1][neighbor.j]) && grid[neighbor.i][neighbor.j+1].wall == true && grid[neighbor.i-1][neighbor.j].wall == true)
            {
                pasar = true;
            }
            //izquierda y arriba
            if(neighbor.j-1 >= 0 && neighbor.i-1 >= 0 && encontrarNeighbor(neighbors, grid[neighbor.i][neighbor.j-1]) && encontrarNeighbor(neighbors, grid[neighbor.i-1][neighbor.j]) && grid[neighbor.i][neighbor.j-1].wall == true && grid[neighbor.i-1][neighbor.j].wall == true)
            {
              pasar = true;
            }
            //arriba y derecha
            if(neighbor.j-1 >= 0 && neighbor.i+1 < cols && encontrarNeighbor(neighbors, grid[neighbor.i][neighbor.j-1]) && encontrarNeighbor(neighbors, grid[neighbor.i+1][neighbor.j]) && grid[neighbor.i][neighbor.j-1].wall == true && grid[neighbor.i+1][neighbor.j].wall == true)
            {
              pasar = true;
            }
            // abajo y derecha
            if(neighbor.j+1 < rows && neighbor.i+1 < cols  && encontrarNeighbor(neighbors, grid[neighbor.i][neighbor.j+1]) && encontrarNeighbor(neighbors, grid[neighbor.i+1][neighbor.j])  && grid[neighbor.i][neighbor.j+1].wall == true && grid[neighbor.i+1][neighbor.j].wall == true)
            {
              pasar = true;
            }
           break;
            
    }
    return pasar;
  }
  
}