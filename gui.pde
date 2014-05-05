/* =========================================================
 * ====                   WARNING                        ===
 * =========================================================
 * The code in this tab has been generated from the GUI form
 * designer and care should be taken when editing this file.
 * Only add/edit code inside the event handlers i.e. only
 * use lines between the matching comment tags. e.g.

 void myBtnEvents(GButton button) { //_CODE_:button1:12356:
     // It is safe to enter your event code here  
 } //_CODE_:button1:12356:
 
 * Do not rename this tab!
 * =========================================================
 */

public void startBtn_click1(GImageButton source, GEvent event) { //_CODE_:startBtn:903391:
  startGame();
  title.setVisible(false);
  startBtn.setVisible(false);
  movesLabel.setVisible(true);
  println("startBtn - GImageButton event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:startBtn:903391:



// Create all the GUI controls. 
// autogenerated do not edit
public void createGUI(){
  G4P.messagesEnabled(false);
  G4P.setGlobalColorScheme(GCScheme.BLUE_SCHEME);
  G4P.setCursor(ARROW);
  if(frame != null)
    frame.setTitle("QMan");
  title = new GLabel(this, 0, 40, 640, 40);
  title.setText("Adventures of QMan");
  title.setTextBold();
  title.setLocalColorScheme(GCScheme.RED_SCHEME);
  title.setOpaque(false);
  startBtn = new GImageButton(this, 240, 220, 160, 60, new String[] { "rectangle.jpg", "rectangle.jpg", "rectangle.jpg" } );
  startBtn.addEventHandler(this, "startBtn_click1");
  movesLabel = new GLabel(this, 20, 560, 300, 40);
  movesLabel.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  movesLabel.setText("Amount Of Steps: ");
  movesLabel.setLocalColorScheme(GCScheme.YELLOW_SCHEME);
  movesLabel.setOpaque(false);
}

// Variable declarations 
// autogenerated do not edit
GLabel title; 
GImageButton startBtn; 
GLabel movesLabel; 

