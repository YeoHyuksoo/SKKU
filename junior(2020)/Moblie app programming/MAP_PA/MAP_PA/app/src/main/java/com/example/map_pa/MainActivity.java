package com.example.map_pa;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        if(getIntent().getExtras() != null){
            EditText username = (EditText)findViewById(R.id.userid);
            Intent signupIntent = getIntent();
            username.setText(signupIntent.getStringExtra("Username"));
        }

        Button login = (Button)findViewById(R.id.loginButton);
        login.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent loginIntent = new Intent(MainActivity.this, postPage.class);
                loginIntent.putExtra("Username", "hello");
                startActivity(loginIntent);
            }
        });

        TextView signup = (TextView)findViewById(R.id.signup);
        signup.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent signupIntent = new Intent(MainActivity.this, SignUp.class);
                startActivity(signupIntent);
            }
        });


    }
}
