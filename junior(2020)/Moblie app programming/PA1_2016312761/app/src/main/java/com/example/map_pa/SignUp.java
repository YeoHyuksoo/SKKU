package com.example.map_pa;


import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;

import androidx.appcompat.app.AppCompatActivity;

public class SignUp extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_sign_up);

        Button login = (Button)findViewById(R.id.signupButton);
        login.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                EditText username = (EditText)findViewById(R.id.signupUsername);
                Intent signupIntent = new Intent(SignUp.this, MainActivity.class);
                signupIntent.putExtra("Username", username.getText().toString());
                startActivity(signupIntent);
            }
        });

    }
}
