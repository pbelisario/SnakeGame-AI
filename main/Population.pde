class Population
{
  Snake[] snakes;
  Snake bestSnake;
  
  int bestSnakeScore = 0;
  int generation = 0;
  
  
  float bestFitness = 0;
  float fitnessSum = 0;
  
  Population(int size)
  {
    snakes = new Snake[size];
    for (int i = 0; i < snakes.length; i++)
    {
      snakes[i] = new Snake();
    }
    bestSnake = snakes[0].clone();
    bestSnake.replay = true;
  }
  
  // Check if the population has died
  boolean done() 
  {
    for (int i = 0; i < snakes.length; i++)
    {
      if(!snakes[i].isDead)
        return false;
    }
    if (!bestSnake.isDead)
    {
      return false;
    }
    return true;
  }
  
  void update()
  {
    if (!bestSnake.isDead)
    {
      bestSnake.look();
      bestSnake.myDecisionIs();
      bestSnake.move();
    }
    for (int i = 0; i < snakes.length; i++)
    {
      if (!snakes[i].isDead)
      {
        snakes[i].look();
        snakes[i].myDecisionIs();
        snakes[i].move();
      }
    }
  }
  
  void show()
  {
    if (replayBest)
    {
      bestSnake.show();
      // Shows the network of the best snake
      bestSnake.brainISH.show(0,0,360,790,bestSnake.snakeVision, bestSnake.snakeDecision);
    } else
    {
      for (int i = 0; i < snakes.length; i++)
      {
        snakes[i].show();
      }
    }
  }
  
  void setBestSnake()
  {
    float max = 0;
    int maxIndex = 0;
    for (int i = 0; i < snakes.length; i++)
    {
      if (snakes[i].snakeFitness > max)
      {
        max = snakes[i].snakeFitness;
        maxIndex = i;
      }
    }
    if (max > bestFitness)
    {
      bestFitness = max;
      bestSnake = snakes[maxIndex].cloneForReplay();
      bestSnakeScore = snakes[maxIndex].score;
    } else 
    {
      bestSnake = bestSnake.cloneForReplay();
    }
  }
  
  Snake selectParent() {
    float rand = random(fitnessSum);
    float somation = 0;
    for (int i = 0; i < snakes.length; i++)
    {
      somation += snakes[i].snakeFitness;
      if (somation*3 > rand)
      {
        return snakes[i];
      }
    }
    return snakes[0];
  }
  
  void naturalSelection() 
  {
      Snake[] newSnakes = new Snake[snakes.length];
      
      setBestSnake();
      calculateFitnessSum();
      
      newSnakes[0] = bestSnake.clone();  
      for(int i = 1; i < snakes.length; i++) 
      {
         Snake child = selectParent().crossover(selectParent());
         child.mutate();
         newSnakes[i] = child;
      }
      snakes = newSnakes.clone();
      evolution.add(bestSnakeScore);
      generation+=1;
   }
   
   void mutate() 
   {
       for(int i = 1; i < snakes.length; i++) 
       {
          snakes[i].mutate(); 
       }
   }
   
   void calculateFitness() 
   {
      for(int i = 0; i < snakes.length; i++) 
      {
         snakes[i].calculateFitness(); 
      }
   }
   
   void calculateFitnessSum() 
   { 
       fitnessSum = 0;
       for(int i = 0; i < snakes.length; i++) 
       {
         fitnessSum += snakes[i].snakeFitness; 
      }
   }
  
}
