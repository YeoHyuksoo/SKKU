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
    

    //사용자 정보를 따로따로 모두 저장
    private Map<String, DataOutputStream> clientsMap = new ConcurrentHashMap<String, DataOutputStream>();
    private Map<String, String> wordsMap = new ConcurrentHashMap<String, String>();
    public final void setGui(ServerGui gui) {
        this.gui = gui;
    }
 
    //서버소켓 구현 (포트 = 9000)
    public void setting() throws IOException {
            Collections.synchronizedMap(clientsMap); //정리
            serverSocket = new ServerSocket(9000);
            while (true) {
                //서버가 계속해서 사람을 받음
                gui.appendMsg("서버 대기중...\n");
                socket = serverSocket.accept(); //유저 받음
                gui.appendMsg("["+sdfDate.format(new Date())+"] "+socket.getInetAddress() + "에서 접속했습니다.\n");
                //접속시 뜨는 문구
                
                //리씨버를 통해서 채팅 구현
                Receiver receiver = new Receiver(socket);
                sendMessage("reset"); //유저리스트 초기화
                sendInfor(); //유저리스트 재설정
                receiver.start(); //채팅시작
            }
    }
 
    //클아이언트 추가
    public void addClient(String nick, DataOutputStream out) throws IOException {
    	clientsMap.put(nick, out);
        sendMessage("["+sdfDate.format(new Date())+"] "+nick + "님이 접속하셨습니다.\n");
        gui.appendMsg(nick + "님이 접속하셨습니다.\n");
        gui.addButton(nick); 
    }
    
    //클라이언트 삭제
    public void removeClient(String nick) {
    	sendMessage("deleteClient");
    	sendMessage("nickname");
        sendMessage(nick);
        sendMessage("["+sdfDate.format(new Date())+"] "+nick + "님이 나가셨습니다.\n");
        gui.appendMsg("["+sdfDate.format(new Date())+"] "+nick + "님이 나가셨습니다.\n");
        gui.removeButton(nick);
        wordsMap.remove(nick);
        clientsMap.remove(nick);
    }

    // 메시지 내용 모두에게 전달
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
    
    //유저정보 모두에게 전달
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
    class Receiver extends Thread { //리시버는 쓰레드로, 멀티채팅을 구현
        private DataInputStream in;
        private DataOutputStream out;
        private String nick, word;
        private String challengerUser,challengedUser;
        private String user,host, cnt;
        private Integer count;
        private String resetUser, resetWord;
       
 
        //기본값 설정
        public Receiver(Socket socket) throws IOException {
            out = new DataOutputStream(socket.getOutputStream());
            in = new DataInputStream(socket.getInputStream());
            nick = in.readUTF();
            word = in.readUTF();
            addClient(nick, out);
            wordsMap.put(nick,word);
            
        }
 
        public void run() { //채팅시작
            try {
                while (in != null) {
                    msg = in.readUTF();
                    
                    //도전자가 있을 경우
                    if(msg.equals("challenge")){
                    	challengerUser = in.readUTF();
                    	challengedUser = in.readUTF();
                    	
                    	sendMessage("<< "+challengerUser+"가"+challengedUser+"에게 도전하였습니다 >>\n");
                    	gui.appendMsg("<<"+challengerUser+"가"+challengedUser+"에게 도전하였습니다 >>\n");
                    	
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
                    
                    //도전을 받아주었을 경우
                    else if(msg.equals("allow")){

                    	challengedUser = in.readUTF();
                    	challengerUser = in.readUTF();
                    	sendMessage("<< "+challengedUser+"가"+challengerUser+"의 도전을 수락하였습니다 >>\n");
                    	gui.appendMsg("<<"+challengedUser+"가"+challengerUser+"의 도전을 수락하였습니다 >>\n");
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
                    
                    //도전을 거절하였을 경우
                    else if(msg.equals("reject")){

                    	challengedUser = in.readUTF();
                    	challengerUser = in.readUTF();
                    	sendMessage("<< "+challengedUser+"가"+challengerUser+"의 도전을 거절하였습니다 >>\n");
                    	gui.appendMsg("<< "+challengedUser+"가"+challengerUser+"의 도전을 거절하였습니다 >>\n");
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
                    
                    //도전에 대한 결과 출력
                    else if(msg.equals("result")){
                    	user = in.readUTF();
                    	host = in.readUTF();
                    	cnt = in.readUTF();
                    	count = Integer.parseInt(cnt);
                    	if(count >0){
                    		sendMessage("<< "+user+"가 "+host+"의 단어를 "+count+"번의 기회를 남기고 맞추었습니다 >>\n");
                    		gui.appendMsg("<< "+user+"가 "+host+"의 단어를 "+count+"번의 기회를 남기고 맞추었습니다 >>\n");
                    	}
                    	else {
                    		sendMessage("<< "+user+"가 "+host+"의 단어를 맞추지 못하였습니다 >>\n");
                    		gui.appendMsg("<< "+user+"가 "+host+"의 단어를 맞추지 못하였습니다 >>\n");
                    	}
                    }
                    
                    //단어를 재설정할 경우
                    else if(msg.equals("resetword")){
                    	resetUser = in.readUTF();
                    	resetWord = in.readUTF();
                    	gui.appendMsg("<< "+resetUser+"가"+resetWord+"로 단어를 바꿨습니다 >>\n");
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
                    
                    //나머지 모든경우 메세지 출력
                    else {
                    	sendMessage(msg);
                    	gui.appendMsg(msg);
                    }
                }
            } catch (IOException e) {
                //접속 종료시 플레이어리스트 제거
                removeClient(nick);
            }
        }
    }
}