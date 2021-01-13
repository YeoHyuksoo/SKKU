package client;
 
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.net.Socket;
import java.text.SimpleDateFormat;
import java.util.Date;
import javax.swing.JLabel;
import javax.swing.SwingConstants;
 
public class ClientBackground {
 
	private static SimpleDateFormat sdfDate = new SimpleDateFormat ("HH:mm"); //�ð��� ��Ÿ���ִ� ����
    private Socket socket = null; //���� ����. �������� ������ �޴´�.
    private DataInputStream in; //������ ��� ���� in out
    private DataOutputStream out;
    private ClientGui gui;
    private String msg; //�����κ��� �޴� �޼���.
    private String nickName; //������ �г���
	private String myWord;
    private String tmpNick,tmpWord;
    private String challengerName, challengedName;
    private String newWord;
    private String user,host;
    
    public final void setGui(ClientGui gui) {
        this.gui = gui;
    }
 
    public void connect() {
        try {
        	
        	//���� ����
            socket = new Socket("localhost", 9000);
            gui.appendMsg("["+sdfDate.format(new Date())+"] "+"���������\n");
            System.out.println("Success");
            //������ ��� ����
            out = new DataOutputStream(socket.getOutputStream());
            in = new DataInputStream(socket.getInputStream());
             
            //�������ڸ��� �г��Ӱ� �ܾ� ����
            out.writeUTF(nickName);
            out.writeUTF(myWord);
            
            while(in!=null){
            	
                msg=in.readUTF();
                
                //������ �ܾ �缳�� �ϸ� ����
                if(gui.newFrame.resetWord == 1){
        			myWord = gui.newFrame.myWord;
        			sendMessage("resetword");
        			sendMessage(nickName);
        			sendMessage(myWord);
        			gui.newFrame.resetWord = 0;
        		}
                
                //�÷��̾��Ʈ�� �ʱ�ȭ
                if(msg.equals("reset")) {
                	gui.player.setVisible(false);
                	gui.player.removeAll();
                	gui.player.add(new JLabel("Player List",SwingConstants.CENTER));
                	gui.player.setVisible(true);
                }
                
                //���ο� ������ ���ö�, �÷��̾� ����Ʈ�� �߰���
                else if(msg.equals("newClient")){
                	if(in.readUTF().equals("nickname")){
                		tmpNick = in.readUTF();
                		gui.addButton(tmpNick);
                		if(in.readUTF().equals("Word")){
                			tmpWord = in.readUTF();
                			gui.clientMap.put(tmpNick,tmpWord);
                		}
                	}
                }
                
                //������ ������ �÷��̾� ����Ʈ���� ������
                else if(msg.equals("deleteClient")){
                	if(in.readUTF().equals("nickname")){
                		tmpNick = in.readUTF();
                		gui.clientMap.remove(tmpNick);
                		gui.removeButton(tmpNick);
                	}
                }
                
                //�����ڰ� ������ ����
                else if(msg.equals("challenged")){
                	challengerName = in.readUTF();
                	gui.getChallenger(challengerName);
                }
                
                //������ �޾����ų� �޾����� ����
                else if(msg.equals("start")){
                	newWord = in.readUTF();
                	user = nickName;
                	host = in.readUTF();
                	gui.userHangman(newWord, user, host);
                }
                
                //������ ������������
                else if(msg.equals("rejected")){
                	challengedName = in.readUTF();
                	gui.appendMsg("You rejected by "+challengedName);
                }
                
                else gui.appendMsg(msg);
            }
        } catch (IOException e) { //���������� �ȵǾ�����
        	System.out.println("Fail to connect server");
        }
    }
    
    //�޼����� �������� �����ִ� �Լ�
    public void sendMessage(String msg2) {
        try {
            out.writeUTF(msg2);
        } catch (IOException e) {
        	
        }
    }
 
    //�г��� ����
    public void setNickname(String nickName) {
        this.nickName = nickName;
    }
    
    //�ܾ� ����
    public void setMyword(String myWord) {
        this.myWord = myWord;
    }
}