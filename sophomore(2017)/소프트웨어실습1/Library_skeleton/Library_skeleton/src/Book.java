

// implement this class
public class Book {
  private String name;          // name of this book
  private boolean borrow;     // status of this book which is borrowed or not
  
  
   Book(String Name){
     	name=Name;
    }
    /*Constructor of Book class.
   */
  
  
    void borrowed(){
    	borrow=true;
    }
   /* Update the status of this book to be borrowed.
   */
  
  
    void returned(){
    	borrow=false;
    }
   /* 
   * Update the status of this book to be returned.
   */
  
  
    boolean isBorrowed(){
    	if(borrow==true){
    		return true;
    }
    	else return false;
    }
   /* 
   * Check this book is borrowed or not.
   * If borrowed, return true.
   * Else, return false.
   */
  
  
    String getName(){
    	return name;
    }
   /* 
   * Return the name of this book
   */
}
