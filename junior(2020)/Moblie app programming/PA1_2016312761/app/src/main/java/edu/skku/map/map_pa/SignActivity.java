package edu.skku.map.map_pa;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;

import androidx.appcompat.app.AppCompatActivity;

public class SignActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_sign);
        Button button3 = findViewById(R.id.button3);
        button3.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent3 = new Intent(SignActivity.this, LoginActivity.class);
                EditText editText3 = findViewById(R.id.editText3);
                intent3.putExtra("myData", editText3.getText().toString());
                startActivity(intent3);
            }
        });
    }
}
