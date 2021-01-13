package client;

import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import javax.swing.*;

public class Hangman {

	Words words = new Words("./resource/word.txt");
	String word = words.getRandomWord();;
	int leng = word.length();
	String []c = new String[100];; //�ܾ��� ���̸�ŭ �迭 ���� 
	String []in=new String[25]; //�Է¹��� �� �ִ� �� ���ĺ� �� ��ŭ �迭�� ���� 
	int count=6;
	int z=0; //�Է¹��� ���ĺ��� ����� �� 
	int j=0; //�Է¹��� ���ڰ� ���ڿ��� ��ġ�ϴ� �� ������ ����
	int k=0; //�Է� ���� ���ڰ� ���ڿ��� ��ġ�ϴ°� ������ 
	int win=0;
	int restart = 0;
	int user = 0;
	int getresult =0;
	String userName, hostName;

	JFrame jf = new JFrame();;
	JLabel label;
	ImageIcon icon;
	JButton b;
	
	String letter=" "; //�Է� ���� ���� 
	String str1=""; //correct or incorrect
	String str7="\n"; //�ܾ ǥ���ϴ� �κ�
	String str=""; 
	
	JPanel jp = new JPanel();
	JPanel jp2 = new JPanel();
	
	//������ ������ ���̵��� ���� �ܾ� ����
	public void setLevel(Integer level){
		if(level == 0){
			words = new Words("./resource/easyword.txt");
			this.word = words.getRandomWord();
			leng = word.length();
		}
		if(level == 1){
			words = new Words("./resource/normalword.txt");
			this.word = words.getRandomWord();
			leng = word.length();
		}
		if(level == 2){
			words = new Words("./resource/hardword.txt");
			this.word = words.getRandomWord();
			leng = word.length();
		}
	}
	
	//�ܾ ���ϴ� �ܾ�� �ٲپ���
	public void setWord(String word, String userNick, String hostNick){
		this.word = word;
		leng=word.length();
		user = 1;
		userName = userNick;
		hostName = hostNick;
	}
	
	//��� ���� ȭ��
	public void myFrame()
	{
		jp.setSize(700,100);
		jp.setLayout(new FlowLayout());
		b = new JButton("���ĺ� �Է�"); //��ư�� ������, �ܾ �Է¹���
		b.addActionListener(new DoHangman());
		b.setSize(300,100);
		b.setLocation(300,500);
		jp.add(b);
		
		jp2.setSize(700,100);
		jp2.setLayout(new FlowLayout());
		jp2.add(new JLabel("Ʋ�� ���ĺ�: "));
		
		icon = new ImageIcon ("./resource/HangMan1.png");
		label = new JLabel (icon);
		label.setBounds(0,0,600,600);
		jf.add(label);
		jf.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		jf.setTitle("Let's do Hangman!");
		jf.setSize (700, 700); // pixel
		jf.setLocation(600, 200);
		jf.setVisible (true);
		
		jf.add(jp, BorderLayout.SOUTH);
		jf.add(jp2, BorderLayout.NORTH);
	}

	//���ڿ� ��'_' �� �ʱ�ȭ��	
	public void arr()
	{
		for(int i=0;i<leng;i++){
			c[i]="_ "; 
			str7+=c[i];
		}
	} 

	//�̹����� �Ź� �ٲپ���
	public void change_image(String filename)
	{
		jf.remove(label);
		icon = new ImageIcon (filename);
		label = new JLabel (icon);
		jf.add(label);
	}

	//ȭ��� �ܾ�, ���� ��Ȳ�� ����ϴ� �Լ� 
	public void shows()
	{
		if(count == 5)
			change_image ("./resource/HangMan2.png");
		
		if(count == 4)
			change_image ("./resource/HangMan3.png");
			
		if(count == 3)
			change_image ("./resource/HangMan4.png");
			
		if(count == 2)
			change_image ("./resource/HangMan5.png");
			
		if(count == 1)
			change_image ("./resource/HangMan6.png");
			
		if (count == 0)
		{
			change_image ("./resource/HangMan7.png");
			JOptionPane.showConfirmDialog
				(jf,"\n�й��ϼ̽��ϴ�.\n������ "+'"'+word+'"'+"�Դϴ�!",
						"�й� ",JOptionPane.DEFAULT_OPTION,JOptionPane.ERROR_MESSAGE);
			restart = 1;
		}
		if (win == 1)
		{
			change_image ("./resource/HangMan8.png");
			JOptionPane.showConfirmDialog
			(jf,"\n�¸��ϼ̽��ϴ�.\n������"+'"'+word+'"'+"�Դϴ�!",
					"�¸�",JOptionPane.DEFAULT_OPTION,JOptionPane.INFORMATION_MESSAGE);
			restart = 1;
		}
		
		jf.setVisible(true);
		
		if(restart == 1)
		{
			if(user == 1){
				jf.setVisible(false);
				getresult=1;
				user = 0;
			}
			else {
				JOptionPane.showConfirmDialog(jf,"\n�ѹ� ��?",
						"���� ��� ��̵�",JOptionPane.DEFAULT_OPTION,JOptionPane.INFORMATION_MESSAGE);
				jf.setVisible(false);
				
				Frame f = new Frame();
			}
			
		}
		
	}
	
	//������ �����. �Էµ� �ܾ 2�� �̻� or ���ĺ��� �ƴ�
	public void errors(String st) 
	{ 
		int alphabet=(int)st.charAt(0); //�Է¹��� ���ڸ� int������ �ٲ�
		if(alphabet>=97 & alphabet<=122 ) //���ĺ��� �ƴϸ� ���� ����ϰ� �ٽ� �Է��ϰ� �� 
		{	
			if(letter.length() > 1) {
				letter=JOptionPane.showInputDialog("Error: �ϳ��� ���ĺ��� �Է����ּ���.");
				errors(letter.toLowerCase());
			}
			else {
				alread(st); //�̹� �Էµ� ���̴� �˻��ϴ� �Լ� ȣ�� 
				in[z]=st; //�Է¹��� ��� ���ĺ��� ���� 
				z++;
			}
		} //����� Ƚ�� ���� 
		else 
		{	
			letter=JOptionPane.showInputDialog("Error: ���ĺ��� �Է����ּ���."); 
			this.errors(letter.toLowerCase()); //�Է¹��� ���ڸ� �ٽ� �˻�
		} 
	}


	//�̹� �Էµ� ������ �����ϴ� �Լ�
	public void alread(String s)
	{	
		for(int i=0; i<z; i++) //����� Ƚ�� ��ŭ �˻� 
		{	
			if(in[i].equals(s))	//�̹� �Է��ߴ� ���ĺ��� ���� �Է��� ���ĺ��� ������ �ٽ� �Է��ϰ��� 
			{ 
				JOptionPane.showMessageDialog(null,"�̹� "+s.toUpperCase()+"�� �Է��ϼ̽��ϴ�. �ٸ� ���ĺ��� �Է����ּ���");
				inletter(); //�ٽ� �Է� ���� 
				break;
			} 
		}
	}

	
	//���ڿ��� �ش� ���ĺ��� �ִ��� Ȯ�� �ϴ� �Լ�	
	public void compar(){

		System.out.println(word);
		System.out.println(c);
		System.out.println(leng);
		
		while(count>0)
		{ 
			shows();
			inletter();

			for(int i=0; i<leng; i++)
			{	 
				if(word.substring(i,i+1).equals(letter.toLowerCase()))
				{ 
					c[i]=letter+" ";
					j++;
				}
				else k++;
			}


			if(j>0) //�Է¹��� ���ڰ� ���� ���� �ϳ��̻� ��ġ��
				str1="Correct!"; 
			else if(k==leng) //�Է¹��� ���ڰ� ���ڿ��� ��ġ�ϴ°� ����
			{
				str1="Incorrect!";
				count--;
				jp2.add(new JLabel(letter));
			}
			
			str7="\n"; //���ڿ� �ʱ�ȭ 
			for(int i=0;i<leng;i++)
				str7+=c[i];

			str="";
			for(int i=0;i<leng;i++)
				str+=c[i].trim();

			if(str.equals(word)) //�ܾ 6���� ��ȸ�ȿ� ���߾����� 
			{ 
				win = 1;
				break;
			}
			else
			{
				if(count<1) //�ܾ 6���� ��ȭ�ȿ� �� ���߾����� 
					break;
				else	
					k=0; j=0;
			}
		}	
		this.shows();
	}
	
	//��ư�� ������ �ܾ �Է¹޴� â�� ����
	public class DoHangman implements ActionListener{
		public void actionPerformed (ActionEvent e) { 
    		compar();
        }
	}
	
	//�ܾ �Է¹޴� â
	public void inletter()
	{ 
		letter=JOptionPane.showInputDialog(str7+"\n"+str1+"\n�� "+(count)+"���� ��ȸ�� ���ҽ��ϴ�.\n���ĺ��� �Է��� �ּ���."); 
		letter=letter.toLowerCase();
		
		this.errors(letter); //errors�� ȣ���Ͽ� �˻� 
	}

}	