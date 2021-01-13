package client;
 
import java.awt.BorderLayout;
import java.awt.Component;
import java.awt.GridLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.Iterator;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;
import javax.swing.JTextField;
import javax.swing.SwingConstants;
 
public class ClientGui  extends JFrame implements ActionListener{
 
    private JTextArea jta = new JTextArea(40, 25);
    private JTextField jtf = new JTextField(25);
    private ClientBackground client = new ClientBackground();
    private static String nickName;
	private static String myWord;
    JPanel player = new JPanel();
    Frame newFrame = new Frame();
    Map<String, String> clientMap = new ConcurrentHashMap<String, String>();
    
    public ClientGui() { //Ŭ���̾�Ʈ ä��â GUI
    	
    	
    	player.setLayout(new GridLayout(16,2));
    	player.setSize(100,400);
    	player.add(new JLabel("Player List",SwingConstants.CENTER));
    	add(player, BorderLayout.EAST);

    	
    	JScrollPane scrollPane = new JScrollPane(jta);


    	add(scrollPane, BorderLayout.CENTER);
    	add(jtf, BorderLayout.SOUTH);
    	jtf.addActionListener(this);

    	setDefaultCloseOperation(EXIT_ON_CLOSE);
    	setVisible(true);
    	setBounds(1330, 300, 450, 600);
    	setTitle("Ŭ���̾�Ʈ");
    	
    	client.setGui(this);
    	client.setNickname(nickName);
    	client.setMyword(myWord);
    	setTitle(nickName+"�� ä��â");
    	client.connect();
    }
     
    public static void main(String[] args) { //�г��Ӱ� �ܾ� ���� �� ä�� ����
    	
        
        String input=JOptionPane.showInputDialog("��ǿ� ���Ű� ȯ���մϴ�!\nä��â�� ���� �г����� �Է����ּ���."); //�г����� �Է¹��� 
    	nickName=input.toLowerCase();
    	
    	String input2=JOptionPane.showInputDialog("�ڽ��� �ܾ �Է����ּ���!\n�Է��� �ܾ�� �ٸ������ ��ſ��� ������ �� ���˴ϴ�."); //�ܾ �Է¹��� 
    	myWord=input2.toLowerCase();
    	 
    	new ClientGui();
    	
    }
 
    public void getResult(String userName, String hostName, Integer count){
    	String cnt = String.valueOf(count);
    	client.sendMessage("result");
    	client.sendMessage(userName);
    	client.sendMessage(hostName);
    	client.sendMessage(cnt);
    }
    
    @Override
    //��ġ�� ������ �κ�
    public void actionPerformed(ActionEvent e) { //ä��â �� ġ�� ������
        String msg = nickName+ ":" + jtf.getText()+"\n";
        client.sendMessage(msg);
        jtf.setText("");
    }
    
    public void getChallenger(String challenger){
    	int option = JOptionPane.showConfirmDialog(null, challenger+"���� ������û�� �ֽ��ϴ�.\n�޾Ƶ��̰ڽ��ϱ�?",challenger+"������ ����", JOptionPane.YES_NO_OPTION);

		if(option == 0){
			client.sendMessage("allow");
			client.sendMessage(nickName);
			client.sendMessage(challenger);
		}
		else {
			client.sendMessage("reject");
			client.sendMessage(nickName);
			client.sendMessage(challenger);
		}
    }
 
    public void appendMsg(String msg) { //�ڽ��� ä��â�� �޼��� ������
    	jta.append(msg);
    	jta.setCaretPosition(jta.getDocument().getLength());
    }
    
    public void addButton(String nickName){ //�г��ӿ� �ش��ϴ� ��ư ����
    	JButton tmp = new JButton(nickName);
    	tmp.addActionListener (new DoHangman ());
    	tmp.setActionCommand(nickName);
    	player.setVisible(false);
    	player.add(tmp);
    	player.setVisible(true);
    }

    public void removeButton(String nickName){ //nickName�� �ش��ϴ� ��ư ����
    	Component[] comps = player.getComponents ();
    	for (Component comp : comps) {
    		
    		if (comp instanceof JButton) {
    			JButton button = (JButton) comp;
    			
    			if (button.getText ().equals (nickName)) {
    				player.setVisible(false);
    				player.remove(comp);
    				player.setVisible(true);
    			}
    			
    		}
    	}

    }
    void userHangman(String word, String user, String host){
    	
    	newFrame.setInvisible();
    	Hangman hang=new Hangman();
		
		hang.setWord(word, user, host);
		hang.myFrame();
		hang.arr();
		
		while(true){
			
			if(hang.getresult == 1){
				client.sendMessage("result");
		    	client.sendMessage(user);
		    	client.sendMessage(host);
		    	client.sendMessage(String.valueOf(hang.count));
		    	newFrame.setVisible();
		    	break;
			}
			else{
				try {
					Thread.sleep(10);
				} catch (InterruptedException e) {
					
				}
			}
		}
		
    }
    
    private class DoHangman implements ActionListener { //�г������� ���� ��ư ActionListener

    	public void actionPerformed (ActionEvent e) { 
    		String command = e.getActionCommand();
    		
    		Iterator<String> it = clientMap.keySet().iterator();
        	String key = "";
        	
        	while (it.hasNext()) {
        		key = it.next();
 
            	if(key.equals(command)){
            		
            		if(nickName.equals(key)) JOptionPane.showConfirmDialog(null, "�ڱ� �ڽſ��Դ� ������ �� �����ϴ�.","�ٺ�", JOptionPane.CANCEL_OPTION);
            		
            		else {
            			int option = JOptionPane.showConfirmDialog(null, key+"���� �����Ͻðڽ��ϱ�?",key+"������ ����", JOptionPane.YES_NO_OPTION);

                		if(option == 0){
                			client.sendMessage("challenge");
                			client.sendMessage(nickName); //�����ϴ� ���� �г���
                			client.sendMessage(key); //�������ϴ� ���� �г���
                		}//if2
            		}//else

            	}//if1
        	}//while
        }//actionperformed
    }//DoHangman
}