

// do not modify this class
public class Main {
  static int cnt = 0;
  static void checkError (boolean chk) {
    cnt ++;
    if (!chk) {
      System.err.println("Failed at trial #" + cnt);
      System.exit(-1);
    }
    else {
      System.out.println("#" + cnt);
      System.out.println(Messages.getMessage(cnt) + "\n");
    }
  }
  
  static void checkError (String chk, String ans) {
    checkError (!chk.equals (ans));
  }

  public static void main(String[] args) {
    // constructor of Library is (name, capacity)
    Library knl = new Library ("Korea National Library", 100);
    Library sdl = new Library ("Samsung Digital Library", 10);
    
    // initialize check
    System.out.println(knl.getName () + " has capacity of " + knl.getCapability () + " books");
    System.out.println(sdl.getName () + " has capacity of " + sdl.getCapability () + " books\n");
    
    checkError (knl.requestNewBook("Introduction to Java"));       // 1
    
    checkError (sdl.requestNewBooks("Introduction to Java", 10));   // 2
    
    checkError (knl.borrow("Introduction to Java"));               // 3
    
    for (int i = 0; i < 8; i ++)
      sdl.borrow("Introduction to Java");
    checkError (sdl.borrow("Introduction to Java"));               // 4
    
    checkError (!knl.borrow("Introduction to Java"));              // 5
    
    if (sdl.isBorrowed("Introduction to Java"))
      checkError (sdl.borrow("Introduction to Java"));             // 6
    
    checkError (!sdl.requestNewBooks("Introduction to Java", 10));   // 7
    
    sdl.extendCap(90);
    checkError (sdl.requestNewBooks("Introduction to Java", 40));   // 8
  }
}
