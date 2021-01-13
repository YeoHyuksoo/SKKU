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
 
	private static SimpleDateFormat sdfDate = new SimpleDateFormat ("HH:mm"); //시간을 나타내주는 변수
    private Socket socket = null; //소켓 변수. 서버로의 소켓을 받는다.
    private DataInputStream in; //데이터 통료 변수 in out
    private DataOutputStream out;
    private ClientGui gui;
    private String msg; //서버로부터 받는 메세지.
    private String nickName; //유저의 닉네임
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
        	
        	//서버 연결
            socket = new Socket("localhost", 9000);
            gui.appendMsg("["+sdfDate.format(new Date())+"] "+"서버연결됨\n");
            System.out.println("Success");
            //데이터 통로 설정
            out = new DataOutputStream(socket.getOutputStream());
            in = new DataInputStream(socket.getInputStream());
             
            //접속하자마자 닉네임과 단어 전송
            out.writeUTF(nickName);
            out.writeUTF(myWord);
            
            while(in!=null){
            	
                msg=in.readUTF();
                
                //유저가 단어를 재설정 하면 실행
                if(gui.newFrame.resetWord == 1){
        			myWord = gui.newFrame.myWord;
        			sendMessage("resetword");
        			sendMessage(nickName);
        			sendMessage(myWord);
        			gui.newFrame.resetWord = 0;
        		}
                
                //플레이어리스트를 초기화
                if(msg.equals("reset")) {
                	gui.player.setVisible(false);
                	gui.player.removeAll();
                	gui.player.add(new JLabel("Player List",SwingConstants.CENTER));
                	gui.player.setVisible(true);
                }
                
                //새로운 유저가 들어올때, 플레이어 리스트에 추가함
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
                
                //유저가 나가면 플레이어 리스트에서 제거함
                else if(msg.equals("deleteClient")){
                	if(in.readUTF().equals("nickname")){
                		tmpNick = in.readUTF();
                		gui.clientMap.remove(tmpNick);
                		gui.removeButton(tmpNick);
                	}
                }
                
                //도전자가 들어오면 실행
                else if(msg.equals("challenged")){
                	challengerName = in.readUTF();
                	gui.getChallenger(challengerName);
                }
                
                //도전이 받아지거나 받았을때 실행
                else if(msg.equals("start")){
                	newWord = in.readUTF();
                	user = nickName;
                	host = in.readUTF();
                	gui.userHangman(newWord, user, host);
                }
                
                //도전이 거절당했을때
                else if(msg.equals("rejected")){
                	challengedName = in.readUTF();
                	gui.appendMsg("You rejected by "+challengedName);
                }
                
                else gui.appendMsg(msg);
            }
        } catch (IOException e) { //서버연결이 안되었을때
        	System.out.println("Fail to connect server");
        }
    }
    
    //메세지를 서버에게 보내주는 함수
    public void sendMessage(String msg2) {
        try {
            out.writeUTF(msg2);
        } catch (IOException e) {
        	
        }
    }
 
    //닉네임 설정
    public void setNickname(String nickName) {
        this.nickName = nickName;
    }
    
    //단어 설정
    public void setMyword(String myWord) {
        this.myWord = myWord;
    }
}