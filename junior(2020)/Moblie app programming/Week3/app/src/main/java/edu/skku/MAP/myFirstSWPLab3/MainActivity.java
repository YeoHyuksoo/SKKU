package edu.skku.MAP.myFirstSWPLab3;

import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

public class MainActivity extends AppCompatActivity {
    int i=1,j=-1;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        final TextView text = (TextView)findViewById(R.id.textView);

        Button btn1 = (Button)findViewById(R.id.button_id);
        btn1.setOnClickListener(new Button.OnClickListener(){
            public void onClick(View v){
                i=1-i;
                if(i==0) {
                    text.setText("2016312761");
                }
                if(i==1){
                    text.setText("Hyuksoo Yeo");
                }
            }
        });

        Button btn2 = (Button)findViewById(R.id.button_food);
        final ImageView img1= (ImageView)findViewById(R.id.imageView);
        btn2.setOnClickListener(new Button.OnClickListener(){
            public void onClick(View v){
                j++;
                if(j%3==0){
                    img1.setImageResource(R.drawable.me1);
                }
                if(j%3==1){
                    img1.setImageResource(R.drawable.me2);
                }
                if(j%3==2){
                    img1.setImageResource(R.drawable.mom);
                    j=-1;
                }
            }
        });
    }
}
