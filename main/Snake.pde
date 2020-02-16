class Snake
{
  // Quantity of number of moves the snake can do to fetch the food
  int numberOfMoves = 150;
  
  // Time the snake has been alive
  int timeAlive = 0;
  
  // Score done by the snake
  int score = 1;
  
  // Snake velocity vector
  PVector snakeVelocity = new PVector();
  
  // Snake Vision
  // The snake is able to see in all 8 directions around her,
  // and for each direction will calculate 3 distances
  // To the food, to its own body, to the wall 
  float[] snakeVision; // Size 24 (8 Diretions X 3 Distances)
  
  // Snake Decision
  // What the snake will do
  // Go Up, Down, Left or Right
  float[] snakeDecision; // Size 4
  
  // Snake Head position
  PVector snakeHead; 

  // Array with the snake body position
  ArrayList<PVector> snakeBody;
  
  
  // Snake fitness
  float snakeFitness = 0;
  
  // Is the Snake Dead?
  boolean isDead = false;
  
  
  // If is true, than show the best snake replay
  boolean replay = false;
  
  // Array with a list of food Positions
  ArrayList<Food> foodPosition;
  
  // Interator, represented by
  // the amount of food consumed
  int foodInterator = 0;
  
  Food food;
  Network brainISH;
  
  Snake() 
  {
    this(hidden_layers);
  }
  
  Snake (int layers)
  {
    snakeHead = new PVector (800, height/2);
    food = new Food();
    snakeBody = new ArrayList<PVector>();
    if (!isHuman)
    {
      snakeVision = new float[24];
      snakeDecision = new float[4];
      foodPosition = new ArrayList<Food>();
      foodPosition.add(food.clone());
      brainISH = new Network(24, hidden_nodes, 4, layers);
      snakeBody.add(new PVector(800, (height/2 + SIZE)));
      snakeBody.add(new PVector(800,(height/2)+(2*SIZE)));
      score += 2;
    }
  }
  
  // This constructor passes in a list of food positions 
  // to replay the best snake
  Snake (ArrayList<Food> foods)
  {
    replay = true;
    snakeVision = new float[24];
    snakeDecision = new float[4];
    snakeBody = new ArrayList<PVector>();
    foodPosition = new ArrayList<Food>(foods.size());
    for (Food f : foods)
    {
      foodPosition.add(f.clone());
    }
    food = foodPosition.get(foodInterator);
    foodInterator++;
    snakeHead = new PVector (800, height/2);
    snakeBody.add(new PVector(800, (height/2 + SIZE)));
    snakeBody.add(new PVector(800,(height/2)+(2*SIZE)));
    score += 2;
  }
  
  // Check if the snake body had a collision with something 
  boolean bodyCollide (float x, float y)
  {
    for (int i = 0; i < snakeBody.size(); i++)
    {
      if (x == snakeBody.get(i).x && y == snakeBody.get(i).y)
      {
        return true;
      }
    }
    return false;
  }
  
  // Check if the food collides with something
  boolean foodCollide (float X, float Y)
  {
    return (X == food.position.x && Y == food.position.y);
  }
  
  // Check if something collided with the wall
  boolean wallCollision(float x, float y)
  {
    return (x >= width-(SIZE) || x < 400 + SIZE || y >= height-(SIZE) || y < SIZE);
  }
  
  void show()
  {
    food.show();
    fill(255);
    stroke(0);
    for(int i = 0; i < snakeBody.size(); i++)
    {
      rect(snakeBody.get(i).x, snakeBody.get(i).y, SIZE, SIZE); 
    }
    if (isDead)
    {
      fill(150);
    } else
    {
      fill(255);
    }
    rect(snakeHead.x, snakeHead.y, SIZE, SIZE);
  }
  
  void move()
  {
    if (!isDead)
    {
      if (!isHuman && !modelLoaded)
      {
        numberOfMoves--;
        timeAlive++;
      }
      if (foodCollide(snakeHead.x, snakeHead.y))
      {
        eat();
      }
      shiftBody();
      if(wallCollision(snakeHead.x, snakeHead.y) 
        || bodyCollide(snakeHead.x, snakeHead.y) 
        || (numberOfMoves <= 0 && !isHuman))
      {
        
        isDead = true;
      }
    }
  }
  
  void eat()
  {
    int len = snakeBody.size() - 1;
    score++;
    if (!isHuman && !modelLoaded)
    {
      if (numberOfMoves < 300)
      {
        numberOfMoves += 150;
      } else numberOfMoves = 300;
    }
    if (len >= 0)
    {
      snakeBody.add(new PVector(snakeBody.get(len).x, snakeBody.get(len).y));
    } else
    {
      snakeBody.add(new PVector(snakeHead.x, snakeHead.y));
    }
    if (!replay)
    {
      food = new Food();
      while (bodyCollide(food.position.x, food.position.y))
      {
        food = new Food();
      }
      if (!isHuman) 
      {
        foodPosition.add(food);
      }
    } else 
    {
      food = foodPosition.get(foodInterator);
      foodInterator++;
    }
  }
  
  void shiftBody()
  {
    PVector temporary1 = snakeHead.copy();
    PVector temporary2 = new PVector();
    snakeHead.add(snakeVelocity);
    for (int i = 0; i < snakeBody.size(); i++)
    {
      temporary2.x = snakeBody.get(i).x;
      temporary2.y = snakeBody.get(i).y;
      snakeBody.get(i).x = temporary1.x;
      snakeBody.get(i).y = temporary1.y;
      temporary1.x = temporary2.x;
      temporary1.y = temporary2.y;
    }
  }
  
  // Clone the version that will be used for the replay
  Snake cloneForReplay()
  {
    Snake clone = new Snake(foodPosition);
    clone.brainISH = brainISH.clone();
    return clone;
  }
  
  // Clone the Snake, only
  Snake clone()
  {
    Snake clone = new Snake(hidden_layers);
    clone.brainISH = brainISH.clone();
    return clone;
  }
  
  // Crossover between snakes
  Snake crossover(Snake parent)
  {
    Snake child = new Snake(hidden_layers);
     child.brainISH = brainISH.crossover(parent.brainISH);
     return child;
  }
  
  void mutate()
  {
    brainISH.mutate(mutationRate);
  }
  
  void calculateFitness()
  {
    
    if (score < 10)
    {
      snakeFitness = floor(numberOfMoves * timeAlive) * pow(2, score);
    } else
    {
      snakeFitness = floor(numberOfMoves * timeAlive); 
      snakeFitness *= pow(2, 10);
      snakeFitness *= (score-9);
    }
  }
  
  //Look in all 8 directions and check for food, body and wall
  void look() 
  {
    snakeVision = new float[24];
    float[] temp = lookInDirection(new PVector(-SIZE,0));
    snakeVision[0] = temp[0];
    snakeVision[1] = temp[1];
    snakeVision[2] = temp[2];
    temp = lookInDirection(new PVector(-SIZE,-SIZE));
    snakeVision[3] = temp[0];
    snakeVision[4] = temp[1];
    snakeVision[5] = temp[2];
    temp = lookInDirection(new PVector(0,-SIZE));
    snakeVision[6] = temp[0];
    snakeVision[7] = temp[1];
    snakeVision[8] = temp[2];
    temp = lookInDirection(new PVector(SIZE,-SIZE));
    snakeVision[9] = temp[0];
    snakeVision[10] = temp[1];
    snakeVision[11] = temp[2];
    temp = lookInDirection(new PVector(SIZE,0));
    snakeVision[12] = temp[0];
    snakeVision[13] = temp[1];
    snakeVision[14] = temp[2];
    temp = lookInDirection(new PVector(SIZE,SIZE));
    snakeVision[15] = temp[0];
    snakeVision[16] = temp[1];
    snakeVision[17] = temp[2];
    temp = lookInDirection(new PVector(0,SIZE));
    snakeVision[18] = temp[0];
    snakeVision[19] = temp[1];
    snakeVision[20] = temp[2];
    temp = lookInDirection(new PVector(-SIZE,SIZE));
    snakeVision[21] = temp[0];
    snakeVision[22] = temp[1];
    snakeVision[23] = temp[2];
  }
  
  // Look in a direction and check for food, body and wall
  float[] lookInDirection(PVector direction) 
  {  
    float look[] = new float[3];
    PVector pos = new PVector(snakeHead.x, snakeHead.y);
    float distance = 0;
    boolean foodFound = false;
    boolean bodyFound = false;
    pos.add(direction);
    distance +=1;
    while (!wallCollision(pos.x,pos.y)) {
      if(!foodFound && foodCollide(pos.x,pos.y)) {
        foodFound = true;
        look[0] = 1;
      }
      if(!bodyFound && bodyCollide(pos.x,pos.y)) {
         bodyFound = true;
         look[1] = 1;
      }
      if(replay && showSnakeVision) {
        stroke(0,255,0);
        point(pos.x,pos.y);
        if(foodFound) {
           noStroke();
           fill(255,255,51);
           ellipseMode(CENTER);
           ellipse(pos.x,pos.y,5,5); 
        }
        if(bodyFound) {
           noStroke();
           fill(102,0,102);
           ellipseMode(CENTER);
           ellipse(pos.x,pos.y,5,5); 
        }
      }
      pos.add(direction);
      distance +=1;
    }
    if(replay && showSnakeVision) {
       noStroke();
       fill(0,255,0);
       ellipseMode(CENTER);
       ellipse(pos.x,pos.y,5,5); 
    }
    look[2] = 1/distance;
    return look;
  }
  
  // Transformation of the network output in movement
  void myDecisionIs()
  {
    snakeDecision = brainISH.output(snakeVision);
    int maxIndex = 0;
    float max = 0;
    for(int i = 0; i < snakeDecision.length; i++) 
    {
      if(snakeDecision[i] > max) 
      {
        max = snakeDecision[i];
        maxIndex = i;
      }
    }
    
    switch(maxIndex) {
       case 0:
         moveUp();
         break;
       case 1:
         moveDown();
         break;
       case 2:
         moveLeft();
         break;
       case 3: 
         moveRight();
         break;
    }
  }
  
  void moveUp() 
  {
    if(snakeVelocity.y!=SIZE) 
    {
      snakeVelocity = new PVector(0, -SIZE);
    
    }
  }
  void moveDown() 
  { 
    if(snakeVelocity.y!=-SIZE) 
    {
      snakeVelocity = new PVector(0, SIZE);
    }
  }
  void moveLeft() 
  { 
    if(snakeVelocity.x!=SIZE) 
    {
      snakeVelocity = new PVector(-SIZE, 0);
    }
  }
  void moveRight() 
  { 
    if(snakeVelocity.x!=-SIZE) 
    {
      snakeVelocity = new PVector(SIZE, 0);
    }
  }
  
  
}
