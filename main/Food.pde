class Food 
{
  PVector position;
  
  Food()
  {
    int x = 400 + SIZE + floor(random(38))*SIZE;
    int y = SIZE + floor(random(38)) * SIZE;
    position = new PVector(x,y);
  }
  
  void show()
  {
    stroke(0);
    fill(250,0,0);
    rect(position.x, position.y, SIZE, SIZE);
  }
  
  Food clone()
  {
    Food clone = new Food();
    clone.position = position.copy();
    
    return clone;
  }
}
