package client;

import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.Scanner;
import javax.swing.*;


public class Frame {

	Container container;

	JLabel label;
	JButton b,start,exit,reset;
	String msg;
	JFrame startframe;
	String myWord;
	int resetWord=0;
	
	//처음 시작 프레임을 만들어주는 함수
	public void makeStart() {
		startframe = new JFrame("Welcome to HANGMAN");
		startframe.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		
		container = startframe.getContentPane();
		
		//시작버튼. 누르면 시작
		start = new JButton("START!");
		start.setBounds(305,280,100,25);
		start.setActionCommand ("start");
		start.addActionListener (new StartHandler ());
		container.add(start);
		
		//종료버튼. 누르면 종료
		exit = new JButton("EXIT");
		exit.setBounds(305, 315, 100, 25);
		exit.setActionCommand ("exit");
		exit.addActionListener (new StartHandler ());
		container.add(exit);
		
		//단어설정버튼. 누르면 단어를 재설정함.
		reset = new JButton("RESET A WORD");
		reset.setBounds(0,0,130,25);
		reset.setActionCommand("reset");
		reset.addActionListener(new StartHandler());
		container.add(reset);
		
		//배경화면을 위한 패널
		JPanel p = new JPanel();
		ImageIcon icon = new ImageIcon ("./resource/text.jpg");
		JLabel label = new JLabel(icon);
		p.add(label);
		container.add(p);
		
		
		container.setVisible(true);
		startframe.setLocation(600, 300);
		startframe.pack();
		startframe.setVisible(true);
		
	}
	
	//배경이 안보이도록함
	public void setInvisible(){
		startframe.setVisible(false);
	}
	
	//배경이 보이도록함
	public void setVisible(){
		startframe.setVisible(true);
	}
	
	//시작
	public Frame () {
		makeStart();
	}
	
	//ActionListener for start frame
	public class StartHandler implements ActionListener {
		
		public void actionPerformed (ActionEvent e) {
			
			resetWord = 0;
			String command = e.getActionCommand();
			//시작이 눌렸을때 실행
			if(command.equals("start")){
				startframe.setVisible(false);
				String[] st = {"쉬움", "보통", "어려움"};
				int level = JOptionPane.showOptionDialog(null, "난이도를 선택하세요", "난이도", JOptionPane.DEFAULT_OPTION
						, JOptionPane.QUESTION_MESSAGE, null, st, "2");
				
				Hangman hang=new Hangman();
				hang.setLevel(level);
				hang.myFrame();
				hang.arr();
				
			}//Start button action handler
			
			//종료버튼이 눌렸을때 실행
			if(command.equals("exit")){
				System.exit(0);
			}//Exit button action handler
			
			//리셋버튼이 눌렸을때 실행
			if(command.equals("reset")){
				int option = JOptionPane.showConfirmDialog(null, "단어를 재설정 하시겠습니까?","", JOptionPane.YES_NO_OPTION);
		    	if(option == 0){
		    		String input2=JOptionPane.showInputDialog("새로운 단어를 입력하여 주세요. \n재설정한 단어는 채팅을 한 번 치셔야만 적용됩니다."); 
		    		myWord=input2.toLowerCase();
			    	resetWord = 1;
		    	}
			}//RESET button action handler
			
		}
		
	}

}