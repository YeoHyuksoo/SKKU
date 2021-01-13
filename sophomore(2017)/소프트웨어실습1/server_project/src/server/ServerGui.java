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
 
    	//�÷��̾� ����Ʈ ����
    	player.setLayout(new GridLayout(16,1));
    	player.setSize(100,400);
    	player.add(new JLabel("Player List",SwingConstants.CENTER));
    	add(player, BorderLayout.EAST);
    	
    	//��ũ�� ����
    	JScrollPane scrollPane = new JScrollPane(jta);
    	add(scrollPane, BorderLayout.CENTER);
    	
        add(jtf, BorderLayout.SOUTH);
        jtf.addActionListener(this);
 
        setDefaultCloseOperation(EXIT_ON_CLOSE);
        setVisible(true);
        setBounds(200, 100, 400, 600);
        setTitle("�����κ�");
 
        server.setGui(this);
        server.setting();
        
    }
 
    public static void main(String[] args) throws IOException {
        new ServerGui();
    }
 
    //������ �Է��� �޼��� ����
    public void actionPerformed(ActionEvent e) {
        String msg = "���� : "+ jtf.getText() + "\n";
        server.sendMessage(msg);
        jta.append(msg);
        jtf.setText("");
    }
 
    //���� GUI�� �޼��� ���
    public void appendMsg(String msg) {
        jta.append(msg);
        jta.setCaretPosition(jta.getDocument().getLength());
    }
    
    //������ �÷��̾��Ʈ�� �÷��̾� �߰�
    public void addButton(String nickName){
    	player.setVisible(false);
    	player.add(new JButton(nickName));
    	player.setVisible(true);
    }
    
    //������ �÷��̾��Ʈ���� �÷��̾� ����
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