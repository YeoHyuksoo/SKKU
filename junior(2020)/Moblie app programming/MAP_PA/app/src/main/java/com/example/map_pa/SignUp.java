package com.example.map_pa;


import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

import java.util.HashMap;
import java.util.Map;

public class SignUp extends AppCompatActivity {
    private DatabaseReference mPostReference;
    String un="", pw="", fn="", bd="", em="";
    EditText username, password, fullname, birthday, email;
    Button signupbtn;
    boolean check=false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_sign_up);

        mPostReference = FirebaseDatabase.getInstance().getReference();

        signupbtn = (Button)findViewById(R.id.signupButton);
        signupbtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                username = (EditText)findViewById(R.id.signupUsername);
                password = (EditText)findViewById(R.id.signupPassword);
                fullname = (EditText)findViewById(R.id.signupFullname);
                birthday = (EditText)findViewById(R.id.signupBirthday);
                email = (EditText)findViewById(R.id.signupEmail);
                un = username.getText().toString();
                pw = password.getText().toString();
                fn = fullname.getText().toString();
                bd = birthday.getText().toString();
                em = email.getText().toString();
                if((un.length()*pw.length()*fn.length()*bd.length()*em.length())==0){
                    Toast.makeText(SignUp.this, "Please fill all blanks", Toast.LENGTH_SHORT).show();
                    return;
                }
                final ValueEventListener postListener = new ValueEventListener(){
                    @Override
                    public void onDataChange(@NonNull DataSnapshot dataSnapshot){
                        for(DataSnapshot postSnapshot : dataSnapshot.getChildren()){
                            String key = postSnapshot.getKey();
                            if(un.equals(key) && check==false){
                                mPostReference.removeEventListener(this);
                                Toast.makeText(SignUp.this, "Please use another username", Toast.LENGTH_SHORT).show();
                                return;
                            }
                        }
                        check=true;
                        postFirebaseDatabase(true);
                        Intent signupIntent = new Intent(SignUp.this, MainActivity.class);
                        signupIntent.putExtra("Username", un);
                        startActivity(signupIntent);
                    }
                    @Override
                    public void onCancelled(@NonNull DatabaseError databaseError) {

                    }
                };
                mPostReference.child("member").addValueEventListener(postListener);
            }
        });
    }
    public void postFirebaseDatabase(boolean add){
        Map<String, Object> childUpdates = new HashMap<>();
        Map<String, Object> postValues = null;
        if(add){
            FirebasePost post = new FirebasePost(un, pw, fn, bd, em);
            postValues = post.toMap();
        }
        childUpdates.put("/member/"+un, postValues);
        mPostReference.updateChildren(childUpdates);
    }
}
