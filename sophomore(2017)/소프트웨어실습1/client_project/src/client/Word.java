package client;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.Random;

class Words {
	   final int WORDMAX = 19; // words.txt���Ͽ� ��� �ִ� �� �ܾ��� ����
	   private String fileName; // �ܾ� ���� �̸�
	   private Random r = new Random(); // �������ڻ���
	   String word;
	   
	   
	   public Words(String fileName) {
	      this.fileName = fileName;
	   }
	   
	   public String getRandomWord() {
	      // ������ �б� ���� BufferedReader ��ü ����
	      BufferedReader in = null;      
	      try {
	         // ������ ���� ������ �б� ���� BufferedReader ����
	         in = new BufferedReader(new FileReader(fileName));
	      }
	      catch(FileNotFoundException e) {
	         System.out.println("word file not found error");
	         System.exit(0);
	      }
	      int n = r.nextInt(WORDMAX); // ������ �� ��ȣ ����. n ��° ���� �ܾ ���ӿ� ���
	      return readWord(in, n); // in ���Ͽ��� n ��° ������ �ܾ �о ����
	   }
	   
	   // in ���Ͽ��� n ��° ������ �ܾ �о� �����ϴ� �޼ҵ�
	   private String readWord(BufferedReader in, int n) {
	      String line=null; // �� ������ ������ ���ڿ� ��ü. �� ���ο��� �ϳ��� �ܾ ����
	        try {
	         while (n>0) {
	            line = in.readLine(); // ���Ͽ��� �� ����(�� �ܾ�)�� �д´�.
	            if(line == null) // eof�� ������ ���� �߻�. ���� ����
	               break;
	            n--;
	         }
	      } catch (IOException e) {
	         System.exit(0);
	      }
	      return line; // n ��° ������ �ܾ� ����
	   }
	   
}