package server;
 
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;
import java.text.SimpleDateFormat;
import java.util.Collections;
import java.util.Date;
import java.util.Iterator;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

public class ServerBackground {
 
  
    private ServerSocket serverSocket;
    private Socket socket = null;
    private ServerGui gui;
    private String msg;
    private static SimpleDateFormat sdfDate = new SimpleDateFormat ("HH:mm");
    

    //����� ������ ���ε��� ��� ����
    private Map<String, DataOutputStream> clientsMap = new ConcurrentHashMap<String, DataOutputStream>();
    private Map<String, String> wordsMap = new ConcurrentHashMap<String, String>();
    public final void setGui(ServerGui gui) {
        this.gui = gui;
    }
 
    //�������� ���� (��Ʈ = 9000)
    public void setting() throws IOException {
            Collections.synchronizedMap(clientsMap); //����
            serverSocket = new ServerSocket(9000);
            while (true) {
                //������ ����ؼ� ����� ����
                gui.appendMsg("���� �����...\n");
                socket = serverSocket.accept(); //���� ����
                gui.appendMsg("["+sdfDate.format(new Date())+"] "+socket.getInetAddress() + "���� �����߽��ϴ�.\n");
                //���ӽ� �ߴ� ����
                
                //�������� ���ؼ� ä�� ����
                Receiver receiver = new Receiver(socket);
                sendMessage("reset"); //��������Ʈ �ʱ�ȭ
                sendInfor(); //��������Ʈ �缳��
                receiver.start(); //ä�ý���
            }
    }
 
    //Ŭ���̾�Ʈ �߰�
    public void addClient(String nick, DataOutputStream out) throws IOException {
    	clientsMap.put(nick, out);
        sendMessage("["+sdfDate.format(new Date())+"] "+nick + "���� �����ϼ̽��ϴ�.\n");
        gui.appendMsg(nick + "���� �����ϼ̽��ϴ�.\n");
        gui.addButton(nick); 
    }
    
    //Ŭ���̾�Ʈ ����
    public void removeClient(String nick) {
    	sendMessage("deleteClient");
    	sendMessage("nickname");
        sendMessage(nick);
        sendMessage("["+sdfDate.format(new Date())+"] "+nick + "���� �����̽��ϴ�.\n");
        gui.appendMsg("["+sdfDate.format(new Date())+"] "+nick + "���� �����̽��ϴ�.\n");
        gui.removeButton(nick);
        wordsMap.remove(nick);
        clientsMap.remove(nick);
    }

    // �޽��� ���� ��ο��� ����
    public void sendMessage(String msg) {
    	
        Iterator<String> it = clientsMap.keySet().iterator();
        String key = "";
        while (it.hasNext()) {
            key = it.next();
            try {
                clientsMap.get(key).writeUTF(msg);
            } catch (IOException e) {
            	
            }
        }
    }
    
    //�������� ��ο��� ����
    public void sendInfor() {

    	Iterator<String> it = clientsMap.keySet().iterator();
    	String key = "";
    	while (it.hasNext()) {
    		
    		Iterator<String> it2 = wordsMap.keySet().iterator();
    		String key2 = "";
    		
    		key = it.next();
    		sendMessage("newClient");
            sendMessage("nickname");
            sendMessage(key);
    		
    		while (it2.hasNext()) {
        		key2 = it2.next();
        		if(key.equals(key2)){
        			sendMessage("Word");
                    sendMessage(wordsMap.get(key2).toString());
        		}
        	}
    		
    	}
    }

    // -----------------------------------------------------------------------------
    class Receiver extends Thread { //���ù��� �������, ��Ƽä���� ����
        private DataInputStream in;
        private DataOutputStream out;
        private String nick, word;
        private String challengerUser,challengedUser;
        private String user,host, cnt;
        private Integer count;
        private String resetUser, resetWord;
       
 
        //�⺻�� ����
        public Receiver(Socket socket) throws IOException {
            out = new DataOutputStream(socket.getOutputStream());
            in = new DataInputStream(socket.getInputStream());
            nick = in.readUTF();
            word = in.readUTF();
            addClient(nick, out);
            wordsMap.put(nick,word);
            
        }
 
        public void run() { //ä�ý���
            try {
                while (in != null) {
                    msg = in.readUTF();
                    
                    //�����ڰ� ���� ���
                    if(msg.equals("challenge")){
                    	challengerUser = in.readUTF();
                    	challengedUser = in.readUTF();
                    	
                    	sendMessage("<< "+challengerUser+"��"+challengedUser+"���� �����Ͽ����ϴ� >>\n");
                    	gui.appendMsg("<<"+challengerUser+"��"+challengedUser+"���� �����Ͽ����ϴ� >>\n");
                    	
                    	Iterator<String> it = clientsMap.keySet().iterator();
                    	String key = "";
                        while (it.hasNext()) {
                        	key = it.next();
                            if(key.equals(challengedUser)){
                            	clientsMap.get(key).writeUTF("challenged");
                            	clientsMap.get(key).writeUTF(challengerUser); //send challenger nickname
                            }
                        }
                    }
                    
                    //������ �޾��־��� ���
                    else if(msg.equals("allow")){

                    	challengedUser = in.readUTF();
                    	challengerUser = in.readUTF();
                    	sendMessage("<< "+challengedUser+"��"+challengerUser+"�� ������ �����Ͽ����ϴ� >>\n");
                    	gui.appendMsg("<<"+challengedUser+"��"+challengerUser+"�� ������ �����Ͽ����ϴ� >>\n");
                    	Iterator<String> it = clientsMap.keySet().iterator();
                    	String key = "";
                        while (it.hasNext()) {
                        	key = it.next();
                            if(key.equals(challengerUser)){
                            	clientsMap.get(key).writeUTF("start");
                            	clientsMap.get(key).writeUTF(wordsMap.get(challengedUser).toString()); //send challenged user word
                            	clientsMap.get(key).writeUTF(challengedUser);
                            }
                            if( key.equals(challengedUser)){
                            	clientsMap.get(key).writeUTF("start");
                            	clientsMap.get(key).writeUTF(wordsMap.get(challengerUser).toString()); //send challenger word
                            	clientsMap.get(key).writeUTF(challengerUser);
                            }
                        }
                    }
                    
                    //������ �����Ͽ��� ���
                    else if(msg.equals("reject")){

                    	challengedUser = in.readUTF();
                    	challengerUser = in.readUTF();
                    	sendMessage("<< "+challengedUser+"��"+challengerUser+"�� ������ �����Ͽ����ϴ� >>\n");
                    	gui.appendMsg("<< "+challengedUser+"��"+challengerUser+"�� ������ �����Ͽ����ϴ� >>\n");
                    	Iterator<String> it = clientsMap.keySet().iterator();
                    	String key = "";
                        while (it.hasNext()) {
                        	key = it.next();
                            if(key.equals(challengerUser)){
                            	clientsMap.get(key).writeUTF("rejected");
                            	clientsMap.get(key).writeUTF(challengedUser);
                            	System.out.println("send reject succeess");
                            }
                        }
                    }
                    
                    //������ ���� ��� ���
                    else if(msg.equals("result")){
                    	user = in.readUTF();
                    	host = in.readUTF();
                    	cnt = in.readUTF();
                    	count = Integer.parseInt(cnt);
                    	if(count >0){
                    		sendMessage("<< "+user+"�� "+host+"�� �ܾ "+count+"���� ��ȸ�� ����� ���߾����ϴ� >>\n");
                    		gui.appendMsg("<< "+user+"�� "+host+"�� �ܾ "+count+"���� ��ȸ�� ����� ���߾����ϴ� >>\n");
                    	}
                    	else {
                    		sendMessage("<< "+user+"�� "+host+"�� �ܾ ������ ���Ͽ����ϴ� >>\n");
                    		gui.appendMsg("<< "+user+"�� "+host+"�� �ܾ ������ ���Ͽ����ϴ� >>\n");
                    	}
                    }
                    
                    //�ܾ �缳���� ���
                    else if(msg.equals("resetword")){
                    	resetUser = in.readUTF();
                    	resetWord = in.readUTF();
                    	gui.appendMsg("<< "+resetUser+"��"+resetWord+"�� �ܾ �ٲ���ϴ� >>\n");
                    	Iterator<String> it = wordsMap.keySet().iterator();
                    	String key = "";
                        while (it.hasNext()) {
                        	key = it.next();
                        	System.out.println(key + " in while");
                            if(key.equals(resetUser)){
                            	wordsMap.remove(key);
                            	wordsMap.put(key, resetWord);
                            	
                            	sendMessage("deleteClient");
                            	sendMessage("nickname");
                                sendMessage(resetUser);
                                
                                sendMessage("newClient");
                                sendMessage("nickname");
                                sendMessage(resetUser);
                                sendMessage("Word");
                                sendMessage(resetWord);
                            }
                        }
                    }
                    
                    //������ ����� �޼��� ���
                    else {
                    	sendMessage(msg);
                    	gui.appendMsg(msg);
                    }
                }
            } catch (IOException e) {
                //���� ����� �÷��̾��Ʈ ����
                removeClient(nick);
            }
        }
    }
}