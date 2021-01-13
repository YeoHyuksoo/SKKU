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
	String []c = new String[100];; //단어의 길이만큼 배열 만듬 
	String []in=new String[25]; //입력받을 수 있는 총 알파벳 수 만큼 배열을 만듬 
	int count=6;
	int z=0; //입력받은 알파벳이 저장된 수 
	int j=0; //입력받은 문자가 문자열과 일치하는 게 있을때 증가
	int k=0; //입력 받은 문자가 문자열과 일치하는게 없을때 
	int win=0;
	int restart = 0;
	int user = 0;
	int getresult =0;
	String userName, hostName;

	JFrame jf = new JFrame();;
	JLabel label;
	ImageIcon icon;
	JButton b;
	
	String letter=" "; //입력 받은 문자 
	String str1=""; //correct or incorrect
	String str7="\n"; //단어를 표시하는 부분
	String str=""; 
	
	JPanel jp = new JPanel();
	JPanel jp2 = new JPanel();
	
	//유저가 선택한 난이도에 따라 단어 지정
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
	
	//단어를 원하는 단어로 바꾸어줌
	public void setWord(String word, String userNick, String hostNick){
		this.word = word;
		leng=word.length();
		user = 1;
		userName = userNick;
		hostName = hostNick;
	}
	
	//행맨 게임 화면
	public void myFrame()
	{
		jp.setSize(700,100);
		jp.setLayout(new FlowLayout());
		b = new JButton("알파벳 입력"); //버튼을 누를시, 단어를 입력받음
		b.addActionListener(new DoHangman());
		b.setSize(300,100);
		b.setLocation(300,500);
		jp.add(b);
		
		jp2.setSize(700,100);
		jp2.setLayout(new FlowLayout());
		jp2.add(new JLabel("틀린 알파벳: "));
		
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

	//문자열 을'_' 로 초기화함	
	public void arr()
	{
		for(int i=0;i<leng;i++){
			c[i]="_ "; 
			str7+=c[i];
		}
	} 

	//이미지를 매번 바꾸어줌
	public void change_image(String filename)
	{
		jf.remove(label);
		icon = new ImageIcon (filename);
		label = new JLabel (icon);
		jf.add(label);
	}

	//화면과 단어, 현재 상황을 출력하는 함수 
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
				(jf,"\n패배하셨습니다.\n정답은 "+'"'+word+'"'+"입니다!",
						"패배 ",JOptionPane.DEFAULT_OPTION,JOptionPane.ERROR_MESSAGE);
			restart = 1;
		}
		if (win == 1)
		{
			change_image ("./resource/HangMan8.png");
			JOptionPane.showConfirmDialog
			(jf,"\n승리하셨습니다.\n정답은"+'"'+word+'"'+"입니다!",
					"승리",JOptionPane.DEFAULT_OPTION,JOptionPane.INFORMATION_MESSAGE);
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
				JOptionPane.showConfirmDialog(jf,"\n한번 더?",
						"헥헥 행맨 재미따",JOptionPane.DEFAULT_OPTION,JOptionPane.INFORMATION_MESSAGE);
				jf.setVisible(false);
				
				Frame f = new Frame();
			}
			
		}
		
	}
	
	//에러를 잡아줌. 입력된 단어가 2개 이상 or 알파벳이 아님
	public void errors(String st) 
	{ 
		int alphabet=(int)st.charAt(0); //입력받은 문자를 int형으로 바꿈
		if(alphabet>=97 & alphabet<=122 ) //알파벳이 아니면 에러 출력하고 다시 입력하게 함 
		{	
			if(letter.length() > 1) {
				letter=JOptionPane.showInputDialog("Error: 하나의 알파벳만 입력해주세요.");
				errors(letter.toLowerCase());
			}
			else {
				alread(st); //이미 입력된 것이니 검사하는 함수 호출 
				in[z]=st; //입력받은 모든 알파벳을 저장 
				z++;
			}
		} //저장된 횟수 증가 
		else 
		{	
			letter=JOptionPane.showInputDialog("Error: 알파벳을 입력해주세요."); 
			this.errors(letter.toLowerCase()); //입력받은 문자를 다시 검사
		} 
	}


	//이미 입력된 것인지 구분하는 함수
	public void alread(String s)
	{	
		for(int i=0; i<z; i++) //저장된 횟수 만큼 검사 
		{	
			if(in[i].equals(s))	//이미 입력했던 알파벳과 새로 입력한 알파벳이 같으면 다시 입력하게함 
			{ 
				JOptionPane.showMessageDialog(null,"이미 "+s.toUpperCase()+"를 입력하셨습니다. 다른 알파벳을 입력해주세요");
				inletter(); //다시 입력 받음 
				break;
			} 
		}
	}

	
	//문자열에 해당 알파벳이 있는지 확인 하는 함수	
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


			if(j>0) //입력받은 문자가 문자 열과 하나이상 일치함
				str1="Correct!"; 
			else if(k==leng) //입력받은 문자가 문자열과 일치하는게 없음
			{
				str1="Incorrect!";
				count--;
				jp2.add(new JLabel(letter));
			}
			
			str7="\n"; //문자열 초기화 
			for(int i=0;i<leng;i++)
				str7+=c[i];

			str="";
			for(int i=0;i<leng;i++)
				str+=c[i].trim();

			if(str.equals(word)) //단어를 6번의 기회안에 맞추었을때 
			{ 
				win = 1;
				break;
			}
			else
			{
				if(count<1) //단어를 6번의 기화안에 못 맞추었을때 
					break;
				else	
					k=0; j=0;
			}
		}	
		this.shows();
	}
	
	//버튼을 누르면 단어를 입력받는 창이 나옴
	public class DoHangman implements ActionListener{
		public void actionPerformed (ActionEvent e) { 
    		compar();
        }
	}
	
	//단어를 입력받는 창
	public void inletter()
	{ 
		letter=JOptionPane.showInputDialog(str7+"\n"+str1+"\n총 "+(count)+"번의 기회가 남았습니다.\n알파벳을 입력해 주세요."); 
		letter=letter.toLowerCase();
		
		this.errors(letter); //errors를 호출하여 검사 
	}

}	