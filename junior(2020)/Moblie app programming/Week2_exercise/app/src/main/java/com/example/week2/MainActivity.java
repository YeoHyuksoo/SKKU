package com.example.week2;

import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

public class MainActivity extends AppCompatActivity {

    private Button btn1, btn2;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        btn1= findViewById(R.id.HI);
        btn1.setOnClickListener(new View.OnClickListener(){

            @Override
            public void onClick(View v){
                Toast.makeText(getApplicationContext(), "Hi, I am hyuksoo", Toast.LENGTH_SHORT).show();
            }
        });
        btn2= findViewById(R.id.BYE);
        btn2.setOnClickListener(new View.OnClickListener(){

            @Override
            public void onClick(View v){
                Toast.makeText(getApplicationContext(), "Good bye, see you", Toast.LENGTH_LONG).show();
            }
        });
    }
}
