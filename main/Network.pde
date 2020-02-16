class Network
{
  // Input 24 (8 x 3) Explained in Snake vision
  // Output 4 (Up, Down, Left, Right)
  int inputNodes, hiddenNodes, outputNodes, hiddenLayers;
  Matrix[] weights;
  
  Network (int input, int hiddenN, int output, int hiddenL)
  {
    inputNodes = input;
    hiddenNodes = hiddenN;
    outputNodes = output;
    hiddenLayers = hiddenL;
    
    weights = new Matrix [hiddenLayers + 1];
    weights[0] = new Matrix(hiddenNodes, inputNodes+1);
    for (int i = 1; i < hiddenLayers; i++)
    {
      weights[i] = new Matrix (hiddenNodes, hiddenNodes+1);
    }
    weights[weights.length -1] = new Matrix(outputNodes, hiddenNodes + 1);
    
    for (Matrix w : weights)
    {
      w.randomize();
    }
  }  
  
  void mutate (float mutationRate)
  {
    for (Matrix w : weights)
    {
      w.mutate(mutationRate);
    }
  }
  
  float[] output(float[] inputsArr)
  {
    Matrix inputs = weights[0].singleColumnMatrixFromArray(inputsArr);
     
     Matrix curr_bias = inputs.addBias();
     
     for(int i=0; i<hiddenLayers; i++) {
        Matrix hidden_ip = weights[i].dot(curr_bias); 
        Matrix hidden_op = hidden_ip.activate();
        curr_bias = hidden_op.addBias();
     }
     
     Matrix output_ip = weights[weights.length-1].dot(curr_bias);
     Matrix output = output_ip.activate();
     
     return output.toArray();
  }
  
  Network crossover(Network partner) 
  {
     Network child = new Network(inputNodes, hiddenNodes, outputNodes, hiddenLayers);
     for(int i=0; i<weights.length; i++) 
     {
        child.weights[i] = weights[i].crossover(partner.weights[i]);
     }
     return child;
  }
  
  Network clone() 
  {
     Network clone = new Network(inputNodes, hiddenNodes, outputNodes, hiddenLayers);
     for(int i=0; i<weights.length; i++) 
     {
        clone.weights[i] = weights[i].clone(); 
     }
     
     return clone;
  }
  
  void load(Matrix[] weight) 
  {
      for(int i=0; i<weights.length; i++) 
      {
         weights[i] = weight[i]; 
      }
  }
  
  Matrix[] pull() 
  {
     Matrix[] model = weights.clone();
     return model;
  }
  
 void show(float x, float y, float w, float h, float[] vision, float[] decision) 
 {

     float space = 5;
     float nSize = (h - (space*(inputNodes-2))) / inputNodes;
     float nSpace = (w - (weights.length*nSize)) / weights.length;
     float hBuff = (h - (space*(hiddenNodes-1)) - (nSize*hiddenNodes))/2;
     float oBuff = (h - (space*(outputNodes-1)) - (nSize*outputNodes))/2;
     
     int maxIndex = 0;
     for(int i = 1; i < decision.length; i++) 
     {
        if(decision[i] > decision[maxIndex]) 
        {
           maxIndex = i; 
        }
     }
     
     //Layer Count
     int lc = 0;
     
     
     // DRAW NODES
     //DRAW INPUTS
     for(int i = 0; i < inputNodes; i++) 
     {
         if(vision[i] != 0) {
           fill(0,255,0);
         } else {
           fill(255); 
         }
         stroke(0);
         ellipseMode(CORNER);
         ellipse(x,y+(i*(nSize+space)),nSize,nSize);
         textSize(nSize/2);
         textAlign(CENTER,CENTER);
         fill(0);
         text(i,x+(nSize/2),y+(nSize/2)+(i*(nSize+space)));
     }
     
     lc++;
     
     for(int a = 0; a < hiddenLayers; a++) 
     {
       //DRAW HIDDEN
       for(int i = 0; i < hiddenNodes; i++) 
       {  
           fill(255);
           stroke(0);
           ellipseMode(CORNER);
           ellipse(x+(lc*nSize)+(lc*nSpace),y+hBuff+(i*(nSize+space)),nSize,nSize);
       }
       lc++;
     }
     
     //DRAW OUTPUTS
     for(int i = 0; i < outputNodes; i++) {  
         if(i == maxIndex) {
           fill(0,255,0);
         } else {
           fill(255); 
         }
         stroke(0);
         ellipseMode(CORNER);
         ellipse(x+(lc*nSpace)+(lc*nSize),y+oBuff+(i*(nSize+space)),nSize,nSize);
     }
     
     lc = 1;
     
     //DRAW WEIGHTS
     //INPUT TO HIDDEN
     for(int i = 0; i < weights[0].rows; i++) 
     {  
        for(int j = 0; j < weights[0].cols-1; j++) 
        {
            if(weights[0].matrix[i][j] < 0) {
               stroke(255,0,0); 
               
            } else {
               stroke(0,0,255);
               
            }
            line(x+nSize,y+(nSize/2)+(j*(space+nSize)),
              x+nSize+nSpace,y+hBuff+(nSize/2)+(i*(space+nSize)));
        }
     }
     
     lc++;
     
     for(int a = 1; a < hiddenLayers; a++) 
     {      //HIDDEN TO HIDDEN
       for(int i = 0; i < weights[a].rows; i++) 
       {  
          for(int j = 0; j < weights[a].cols-1; j++) 
          {
              if(weights[a].matrix[i][j] < 0) 
              {
                 stroke(255,0,0); 
              } else 
              {
                 stroke(0,0,255); 
              }
              line(x+(lc*nSize)+((lc-1)*nSpace),y+hBuff+(nSize/2)+(j*(space+nSize)),
                x+(lc*nSize)+(lc*nSpace),y+hBuff+(nSize/2)+(i*(space+nSize)));
          }
       }
       lc++;
     }
     
     //HIDDEN TO OUTPUT
     for(int i = 0; i < weights[weights.length-1].rows; i++) 
     {  
        for(int j = 0; j < weights[weights.length-1].cols-1; j++) 
        {
            if(weights[weights.length-1].matrix[i][j] < 0) 
            {
               stroke(255,0,0); 
            } else 
            {
               stroke(0,0,255); 
            }
            line(x+(lc*nSize)+((lc-1)*nSpace),y+hBuff+(nSize/2)+(j*(space+nSize)),
              x+(lc*nSize)+(lc*nSpace),y+oBuff+(nSize/2)+(i*(space+nSize)));
        }
     }
     
     fill(0);
     textSize(15);
     textAlign(CENTER,CENTER);
     text("U",x+(lc*nSize)+(lc*nSpace)+nSize/2,y+oBuff+(nSize/2));
     text("D",x+(lc*nSize)+(lc*nSpace)+nSize/2,y+oBuff+space+nSize+(nSize/2));
     text("L",x+(lc*nSize)+(lc*nSpace)+nSize/2,y+oBuff+(2*space)+(2*nSize)+(nSize/2));
     text("R",x+(lc*nSize)+(lc*nSpace)+nSize/2,y+oBuff+(3*space)+(3*nSize)+(nSize/2));
  }
}
