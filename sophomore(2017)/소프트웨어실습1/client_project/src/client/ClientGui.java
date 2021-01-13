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
    
    public ClientGui() { //클라이언트 채팅창 GUI
    	
    	
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
    	setTitle("클라이언트");
    	
    	client.setGui(this);
    	client.setNickname(nickName);
    	client.setMyword(myWord);
    	setTitle(nickName+"의 채팅창");
    	client.connect();
    }
     
    public static void main(String[] args) { //닉네임과 단어 설정 후 채팅 접속
    	
        
        String input=JOptionPane.showInputDialog("행맨에 오신걸 환영합니다!\n채팅창에 쓰일 닉네임을 입력해주세요."); //닉네임을 입력받음 
    	nickName=input.toLowerCase();
    	
    	String input2=JOptionPane.showInputDialog("자신의 단어를 입력해주세요!\n입력한 단어는 다른사람이 당신에게 도전할 때 사용됩니다."); //단어를 입력받음 
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
    //말치면 보내는 부분
    public void actionPerformed(ActionEvent e) { //채팅창 말 치면 보내줌
        String msg = nickName+ ":" + jtf.getText()+"\n";
        client.sendMessage(msg);
        jtf.setText("");
    }
    
    public void getChallenger(String challenger){
    	int option = JOptionPane.showConfirmDialog(null, challenger+"에게 도전신청이 있습니다.\n받아들이겠습니까?",challenger+"에게의 도전", JOptionPane.YES_NO_OPTION);

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
 
    public void appendMsg(String msg) { //자신의 채팅창에 메세지 보여줌
    	jta.append(msg);
    	jta.setCaretPosition(jta.getDocument().getLength());
    }
    
    public void addButton(String nickName){ //닉네임에 해당하는 버튼 생성
    	JButton tmp = new JButton(nickName);
    	tmp.addActionListener (new DoHangman ());
    	tmp.setActionCommand(nickName);
    	player.setVisible(false);
    	player.add(tmp);
    	player.setVisible(true);
    }

    public void removeButton(String nickName){ //nickName에 해당하는 버튼 제거
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
    
    private class DoHangman implements ActionListener { //닉네임으로 만든 버튼 ActionListener

    	public void actionPerformed (ActionEvent e) { 
    		String command = e.getActionCommand();
    		
    		Iterator<String> it = clientMap.keySet().iterator();
        	String key = "";
        	
        	while (it.hasNext()) {
        		key = it.next();
 
            	if(key.equals(command)){
            		
            		if(nickName.equals(key)) JOptionPane.showConfirmDialog(null, "자기 자신에게는 도전할 수 없습니다.","바보", JOptionPane.CANCEL_OPTION);
            		
            		else {
            			int option = JOptionPane.showConfirmDialog(null, key+"에게 도전하시겠습니까?",key+"에게의 도전", JOptionPane.YES_NO_OPTION);

                		if(option == 0){
                			client.sendMessage("challenge");
                			client.sendMessage(nickName); //도전하는 유저 닉네임
                			client.sendMessage(key); //도전당하는 유저 닉네임
                		}//if2
            		}//else

            	}//if1
        	}//while
        }//actionperformed
    }//DoHangman
}