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
	
	//ó�� ���� �������� ������ִ� �Լ�
	public void makeStart() {
		startframe = new JFrame("Welcome to HANGMAN");
		startframe.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		
		container = startframe.getContentPane();
		
		//���۹�ư. ������ ����
		start = new JButton("START!");
		start.setBounds(305,280,100,25);
		start.setActionCommand ("start");
		start.addActionListener (new StartHandler ());
		container.add(start);
		
		//�����ư. ������ ����
		exit = new JButton("EXIT");
		exit.setBounds(305, 315, 100, 25);
		exit.setActionCommand ("exit");
		exit.addActionListener (new StartHandler ());
		container.add(exit);
		
		//�ܾ����ư. ������ �ܾ �缳����.
		reset = new JButton("RESET A WORD");
		reset.setBounds(0,0,130,25);
		reset.setActionCommand("reset");
		reset.addActionListener(new StartHandler());
		container.add(reset);
		
		//���ȭ���� ���� �г�
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
	
	//����� �Ⱥ��̵�����
	public void setInvisible(){
		startframe.setVisible(false);
	}
	
	//����� ���̵�����
	public void setVisible(){
		startframe.setVisible(true);
	}
	
	//����
	public Frame () {
		makeStart();
	}
	
	//ActionListener for start frame
	public class StartHandler implements ActionListener {
		
		public void actionPerformed (ActionEvent e) {
			
			resetWord = 0;
			String command = e.getActionCommand();
			//������ �������� ����
			if(command.equals("start")){
				startframe.setVisible(false);
				String[] st = {"����", "����", "�����"};
				int level = JOptionPane.showOptionDialog(null, "���̵��� �����ϼ���", "���̵�", JOptionPane.DEFAULT_OPTION
						, JOptionPane.QUESTION_MESSAGE, null, st, "2");
				
				Hangman hang=new Hangman();
				hang.setLevel(level);
				hang.myFrame();
				hang.arr();
				
			}//Start button action handler
			
			//�����ư�� �������� ����
			if(command.equals("exit")){
				System.exit(0);
			}//Exit button action handler
			
			//���¹�ư�� �������� ����
			if(command.equals("reset")){
				int option = JOptionPane.showConfirmDialog(null, "�ܾ �缳�� �Ͻðڽ��ϱ�?","", JOptionPane.YES_NO_OPTION);
		    	if(option == 0){
		    		String input2=JOptionPane.showInputDialog("���ο� �ܾ �Է��Ͽ� �ּ���. \n�缳���� �ܾ�� ä���� �� �� ġ�ž߸� ����˴ϴ�."); 
		    		myWord=input2.toLowerCase();
			    	resetWord = 1;
		    	}
			}//RESET button action handler
			
		}
		
	}

}