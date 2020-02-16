class Button
{
  PVector position;
  PVector dimension;
  String buttonDescription;
  
  Button (float x, float y, float w, float h, String text)
  {
    position = new PVector(x,y);
    dimension = new PVector(w, h);
    buttonDescription = text;
  }
  
  boolean collide (float x, float y)
  {
    return (x >= position.x - dimension.x/2 && x <= position.x + dimension.x/2
        && y >= position.y - dimension.y/2 && y <= position.y + dimension.y/2);
         
  }
   
  void show()
  {
    fill(255);
    stroke(0);
    rectMode(CENTER);
    rect(position.x, position.y, dimension.x, dimension.y);
    textSize(20);
    textAlign(CENTER, CENTER);
    fill(0);
    noStroke();
    text(buttonDescription, position.x, position.y-3);
  }
}
