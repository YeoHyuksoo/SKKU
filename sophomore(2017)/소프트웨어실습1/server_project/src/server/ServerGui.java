package server;
 
import java.awt.BorderLayout;
import java.awt.Component;
import java.awt.GridLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.IOException;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;
import javax.swing.JTextField;
import javax.swing.SwingConstants;
 
public class ServerGui extends JFrame implements ActionListener {
 
    private JTextArea jta = new JTextArea(40, 25);
    private JTextField jtf = new JTextField(25);
    private ServerBackground server = new ServerBackground();
    JPanel player = new JPanel();
    
    
    public ServerGui() throws IOException {
 
    	//플레이어 리스트 생성
    	player.setLayout(new GridLayout(16,1));
    	player.setSize(100,400);
    	player.add(new JLabel("Player List",SwingConstants.CENTER));
    	add(player, BorderLayout.EAST);
    	
    	//스크롤 생성
    	JScrollPane scrollPane = new JScrollPane(jta);
    	add(scrollPane, BorderLayout.CENTER);
    	
        add(jtf, BorderLayout.SOUTH);
        jtf.addActionListener(this);
 
        setDefaultCloseOperation(EXIT_ON_CLOSE);
        setVisible(true);
        setBounds(200, 100, 400, 600);
        setTitle("서버부분");
 
        server.setGui(this);
        server.setting();
        
    }
 
    public static void main(String[] args) throws IOException {
        new ServerGui();
    }
 
    //서버가 입력한 메세지 전송
    public void actionPerformed(ActionEvent e) {
        String msg = "서버 : "+ jtf.getText() + "\n";
        server.sendMessage(msg);
        jta.append(msg);
        jtf.setText("");
    }
 
    //서버 GUI에 메세지 띄움
    public void appendMsg(String msg) {
        jta.append(msg);
        jta.setCaretPosition(jta.getDocument().getLength());
    }
    
    //서버의 플레이어리스트에 플레이어 추가
    public void addButton(String nickName){
    	player.setVisible(false);
    	player.add(new JButton(nickName));
    	player.setVisible(true);
    }
    
    //서버의 플레이어리스트에서 플레이어 제거
    public void removeButton(String nickName){
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
}