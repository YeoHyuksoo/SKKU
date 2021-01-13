import java.util.Arrays;


// implement this class
public class Library {
  private String name;      // the name of this library
  private Book[] books;     // list of all books owned by this library
  private int cap;          // book capability of this library
  private int cur;          // current number of books in this library
  

  
    Library(String LibraryName, int AvNumOfBooks){
    	this.name=LibraryName;
    	this.cap=AvNumOfBooks;
    	this.books=new Book[cap];
    	cur=0;
   }
  
  
    String getName(){
    	return name;
   }
   /* Return the name of this library.
   */
  
  
    int getCapability(){
    	return cap;
    }
   /* 
   * Return the capability of this library.
   */
  
  
    void extendCap(int cap){
   /* 
   * Extend the capability of this library by [additional capability].
   * 
   * Hint: recommend to use "Book[] Arrays.copyOf(Book[] arr, int num)" method.
   */ books=Arrays.copyOf(books, this.cap+cap);
   		this.cap=this.cap+cap;
    }
  
  
    boolean requestNewBook(String Bookname){
   /* 
   * Add new book of [name of book].
   * Return true if success on adding book, else false.
   */
    	if(cap<cur) return false;
    	else {
    		books[cur]=new Book(Bookname);
    		cur++;
    		return true;
    	}
    }
  
  
    boolean requestNewBooks(String Bookname, int NumOfbook){
   /* 
   * Add [# of books] new books of [name of book].
   * Return true if sccuess on adding all books, else false.
   * When returning false, do not add any of the books.
   */
    	if(cur+NumOfbook>cap){
    		return false;
    	}
    	else {
    		int i;
    		for(i=0;i<NumOfbook;i++){
    			books[cur]=new Book(Bookname);
    			cur++;
    		}
    		return true;
    	}
    }
  
  
   boolean isBorrowed(String Bookname){
	   for(int i=0;i<cur;i++){
		   if(books[i].getName().compareTo(Bookname)==0){
			   if(books[i].isBorrowed()==true){
				   return true;
			   }

		   }
	   }
	   return false;
   }
   /* 
   * Check whether [name of book] is borrowed or not.
   * If borrowed, return true.
   * Else, return false.
   */
  
  
    boolean borrow(String Bookname){
    	for(int i=0;i<cur;i++){
    		if(books[i].getName().compareTo(Bookname)==0){
    			if(books[i].isBorrowed()==false){
    				books[i].borrowed();
    				return true;
    			}
    		}
    	}
    	return false;
    }
   /* 
   * Find the [name of book] in library.
   * And update the status of book to be currently borrowed.
   * If success on updating, return true.
   * Else in all other cases, return false.
   */
}
