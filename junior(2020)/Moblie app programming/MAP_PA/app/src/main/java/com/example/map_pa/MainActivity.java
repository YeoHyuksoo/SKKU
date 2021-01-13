package com.example.map_pa;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

public class MainActivity extends AppCompatActivity {
    private DatabaseReference mPostReference;
    String un, pw;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        mPostReference = FirebaseDatabase.getInstance().getReference();

        if(getIntent().getExtras() != null){
            EditText username = (EditText)findViewById(R.id.userid);
            Intent signupIntent = getIntent();
            username.setText(signupIntent.getStringExtra("Username"));
        }

        Button login = (Button)findViewById(R.id.loginButton);
        login.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                EditText username = (EditText)findViewById(R.id.userid);
                EditText password = (EditText)findViewById(R.id.password);
                un = username.getText().toString();
                pw = password.getText().toString();
                if(un.length()==0){
                    Toast.makeText(MainActivity.this, "Wrong Username", Toast.LENGTH_SHORT).show();
                    return;
                }
                final ValueEventListener postListener = new ValueEventListener(){
                    @Override
                    public void onDataChange(@NonNull DataSnapshot dataSnapshot){
                        for(DataSnapshot postSnapshot : dataSnapshot.getChildren()){
                            String key = postSnapshot.getKey();
                            if(!key.equals(un)) continue;
                            FirebasePost content = postSnapshot.getValue(FirebasePost.class);
                            if(!content.password.equals(pw)){
                                Toast.makeText(MainActivity.this, "Wrong Password", Toast.LENGTH_SHORT).show();
                                return;
                            }
                            Intent loginIntent = new Intent(MainActivity.this, postPage.class);
                            loginIntent.putExtra("Username", key);
                            startActivity(loginIntent);
                        }
                    }
                    @Override
                    public void onCancelled(@NonNull DatabaseError databaseError) {

                    }
                };
                mPostReference.child("member").addValueEventListener(postListener);
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
