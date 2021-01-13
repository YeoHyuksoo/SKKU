package edu.skku.map.map_pa;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;

import androidx.appcompat.app.AppCompatActivity;

public class LoginActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);

        Button button2 = findViewById(R.id.button2);
        button2.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent2 = new Intent(LoginActivity.this, SignActivity.class);
                startActivity(intent2);
            }
        });
        Intent intent3 = getIntent();
        String un = intent3.getStringExtra("myData");
        EditText editText = findViewById(R.id.editText);
        editText.setText(un);

        Button button = findViewById(R.id.button);
        button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent4 = new Intent(LoginActivity.this, MpgActivity.class);
                startActivity(intent4);
            }
        });
    }
}