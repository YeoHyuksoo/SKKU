
public class Messages {
  static String[] messages = {
      "KNL buy a new book, \"Introduction to Java\".",
      "SDL also buy 10 new books, \"Introduction to Java\".",
      "All \"Introduction to Java\"s in KNL are already borrowed.",
      "8 of all Introduction to Java in SDL is also already borrowed.",
      "Student A wants to borrowed Introduction to Java at KNL,"
          + "\n" + "but it is already borrowed by else."
          + "\n" + "So A decides to check if the book is available at SDL.",
      "Fortunately, the book is available!"
          + "\n" + "B hurried to borrow that book.",
      "The manager of SDL realize that students need more books of it."
          + "\n" + "For this reason, manager tries to buy new books."
          + "\n" + "But the capacity of library is not enough.",
      "So manager request office to extend the library."
          + "\n" + "They agree with him, and extend library to own 90 more books"
          + "\n" + "Finally, manager buys more books.",
      "Now students use those books and actively study with them."
  };
  
  public static String getMessage (int i) {
    return messages[i-1];
  }
}
