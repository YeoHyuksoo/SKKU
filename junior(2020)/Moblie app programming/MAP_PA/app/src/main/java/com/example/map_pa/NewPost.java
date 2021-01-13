package com.example.map_pa;

import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.ActionBarDrawerToggle;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.core.view.GravityCompat;
import androidx.drawerlayout.widget.DrawerLayout;

import com.google.android.gms.tasks.Continuation;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;
import com.google.android.material.navigation.NavigationView;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;
import com.google.firebase.storage.FirebaseStorage;
import com.google.firebase.storage.StorageReference;
import com.google.firebase.storage.UploadTask;

import java.util.HashMap;
import java.util.Map;

public class NewPost extends AppCompatActivity implements NavigationView.OnNavigationItemSelectedListener {
    DrawerLayout drawerLayout;

    private DatabaseReference mPostReference;//, mPostReferencePost;
    String Username = "";
    String Fullname = "", Birthday = "", Email = "";
    private static final int PICK_IMAGE = 777;
    private static final int PICK_IMAGE2 = 555;
    private StorageReference mStorageRef, mStorageRefPub, mStorageRefPer;
    Uri currentImageUri, currentImageUri2;
    Uri posturi = null;
    ImageButton imagebutton;
    ImageButton postImage;
    String content = "", tags = "";
    boolean check = false;
    boolean perpub = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_new_post);

        mPostReference = FirebaseDatabase.getInstance().getReference();
        //mPostReferencePost = FirebaseDatabase.getInstance().getReference();

        Intent intent = getIntent();
        Username = intent.getStringExtra("Username");

        mStorageRef = FirebaseStorage.getInstance().getReference("Images");
        mStorageRefPub = FirebaseStorage.getInstance().getReference("Public");
        mStorageRefPer = FirebaseStorage.getInstance().getReference("Personal");

        /*Button createPost = (Button)findViewById(R.id.createPost);
        createPost.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent createPostIntent = new Intent(NewPost.this, postPage.class);
                startActivity(createPostIntent);
            }
        });*/

        Toolbar tb = (Toolbar) findViewById(R.id.main_toolbar);
        setSupportActionBar(tb);
        getSupportActionBar().setDisplayShowTitleEnabled(false);

        drawerLayout = (DrawerLayout) findViewById(R.id.drawerLayout);
        NavigationView navigationView = (NavigationView) findViewById(R.id.drawer);
        navigationView.setNavigationItemSelectedListener(this);
        ActionBarDrawerToggle drawerToggle = new ActionBarDrawerToggle(this, drawerLayout, tb, R.string.app_name, R.string.app_name);
        drawerToggle.syncState();

        Menu menu = navigationView.getMenu();
        View header = navigationView.getHeaderView(0);
        final TextView drawerUsername = (TextView) header.findViewById(R.id.drawer_username);
        final MenuItem navigationFullname = (MenuItem) menu.findItem(R.id.navigationFullname);
        final MenuItem navigationBirthday = (MenuItem) menu.findItem(R.id.navigationBirthday);
        final MenuItem navigationEmail = (MenuItem) menu.findItem(R.id.navigationEmail);
        imagebutton = (ImageButton) header.findViewById(R.id.imageButton);

        StorageReference Ref = mStorageRef.child(Username+"_profile.jpg");
        final long ONE_MEGABYTE = 1024*1024;
        Ref.getBytes(ONE_MEGABYTE).addOnFailureListener(new OnFailureListener() {
            @Override
            public void onFailure(@NonNull Exception exception) {

            }
        }).addOnSuccessListener(new OnSuccessListener<byte[]>() {
            @Override
            public void onSuccess(byte[] bytes) {
                Bitmap bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.length);
                imagebutton.setImageBitmap(bitmap);
            }
        });
        imagebutton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent gallery = new Intent(Intent.ACTION_PICK, MediaStore.Images.Media.INTERNAL_CONTENT_URI);
                startActivityForResult(gallery, PICK_IMAGE);
            }
        });

        final ValueEventListener postListener = new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                for(DataSnapshot postSnapshot : dataSnapshot.getChildren()){
                    String key = postSnapshot.getKey();
                    if(!key.equals(Username)) continue;
                    FirebasePost get = postSnapshot.getValue(FirebasePost.class);
                    String[] info = {get.username, get.fullname, get.birthday, get.email};
                    Fullname = info[1];
                    Birthday = info[2];
                    Email = info[3];
                    drawerUsername.setText(key);
                    navigationFullname.setTitle(Fullname);
                    navigationBirthday.setTitle(Birthday);
                    navigationEmail.setTitle(Email);

                }
            }

            @Override
            public void onCancelled(@NonNull DatabaseError databaseError) {

            }
        };
        mPostReference.child("member").addValueEventListener(postListener);

        postImage = (ImageButton) findViewById(R.id.postImage);
        postImage.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent gallery = new Intent(Intent.ACTION_PICK, MediaStore.Images.Media.INTERNAL_CONTENT_URI);
                startActivityForResult(gallery, PICK_IMAGE2);
            }
        });

        Button createpostButton = (Button) findViewById(R.id.createPost);
        createpostButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                EditText postContent = (EditText) findViewById(R.id.postContent);
                EditText postTags = (EditText) findViewById(R.id.postTags);
                CheckBox publicPost = (CheckBox) findViewById(R.id.publicPost);

                content = postContent.getText().toString();
                tags = postTags.getText().toString();
                perpub = publicPost.isChecked();
                if(content.length()==0){
                    Toast.makeText(NewPost.this, "Please input contents", Toast.LENGTH_SHORT).show();
                    return;
                }
                if(perpub){//public
                    if(check) {
                        final StorageReference Ref2 = mStorageRefPub.child(Username+content+"_image.jpg");
                        UploadTask uploadTask = Ref2.putFile(currentImageUri2);
                        uploadTask.addOnFailureListener(new OnFailureListener() {
                            @Override
                            public void onFailure(@NonNull Exception exception) {

                            }
                        }).addOnSuccessListener(new OnSuccessListener<UploadTask.TaskSnapshot>() {
                            @Override
                            public void onSuccess(UploadTask.TaskSnapshot taskSnapshot) {
                                //Toast.makeText(NewPost.this, "Upload success!", Toast.LENGTH_LONG).show();
                            }
                        });

                        Task<Uri> urlTask = uploadTask.continueWithTask(new Continuation<UploadTask.TaskSnapshot, Task<Uri>>() {
                            @Override
                            public Task<Uri> then(@NonNull Task<UploadTask.TaskSnapshot> task) throws Exception {
                                if(!task.isSuccessful()){
                                    throw task.getException();
                                }
                                return Ref2.getDownloadUrl();
                            }
                        }).addOnCompleteListener(new OnCompleteListener<Uri>() {
                            @Override
                            public void onComplete(@NonNull Task<Uri> task) {
                                if(task.isSuccessful()){
                                    Uri downloadUri = task.getResult();
                                    posturi = downloadUri;
                                    postFirebaseDatabase(true);
                                }else{
                                    postFirebaseDatabase(true);
                                }
                            }
                        });
                    }
                    else{
                        postFirebaseDatabase(true);
                    }
                    Intent createPostIntent = new Intent(NewPost.this, postPage.class);
                    createPostIntent.putExtra("Username", Username);
                    createPostIntent.putExtra("content", content);
                    startActivity(createPostIntent);
                }
                else{
                    if(check) {
                        final StorageReference Ref3 = mStorageRefPer.child(Username + content + "_image.jpg");
                        UploadTask uploadTask = Ref3.putFile(currentImageUri2);
                        uploadTask.addOnFailureListener(new OnFailureListener() {
                            @Override
                            public void onFailure(@NonNull Exception exception) {

                            }
                        }).addOnSuccessListener(new OnSuccessListener<UploadTask.TaskSnapshot>() {
                            @Override
                            public void onSuccess(UploadTask.TaskSnapshot taskSnapshot) {
                                //Toast.makeText(NewPost.this, "Upload success!", Toast.LENGTH_LONG).show();
                            }
                        });
                        Task<Uri> urlTask = uploadTask.continueWithTask(new Continuation<UploadTask.TaskSnapshot, Task<Uri>>() {
                            @Override
                            public Task<Uri> then(@NonNull Task<UploadTask.TaskSnapshot> task) throws Exception {
                                if (!task.isSuccessful()) {
                                    throw task.getException();
                                }
                                return Ref3.getDownloadUrl();
                            }
                        }).addOnCompleteListener(new OnCompleteListener<Uri>() {
                            @Override
                            public void onComplete(@NonNull Task<Uri> task) {
                                if (task.isSuccessful()) {
                                    Uri downloadUri = task.getResult();
                                    posturi = downloadUri;
                                    postFirebaseDatabase(true);
                                } else {
                                    postFirebaseDatabase(true);
                                }
                            }
                        });
                    }
                    else{
                        postFirebaseDatabase(true);
                    }

                    Intent createPostIntent = new Intent(NewPost.this, postPage.class);
                    createPostIntent.putExtra("Username", Username);
                    createPostIntent.putExtra("content", content);
                    startActivity(createPostIntent);
                }
            }
        });
    }

    public void postFirebaseDatabase(boolean add){
        Map<String, Object> childUpdates = new HashMap<>();
        Map<String, Object> postValues = null;
        createFirebasePost post;
        if(add){
            if(check==false){
                post = new createFirebasePost(Username, content, tags, "");
            }
            else{
                post = new createFirebasePost(Username, content, tags, posturi.toString());
            }
            postValues = post.toMap();
        }
        String key = Username+"_"+content;
        if(perpub){
            childUpdates.put("/public/"+key, postValues);
        }
        else {
            childUpdates.put("/personal/"+key, postValues);
        }
        mPostReference.updateChildren(childUpdates);
    }


    @Override
    public boolean onNavigationItemSelected(@NonNull MenuItem item) {
        closeDrawer();

        switch (item.getItemId()){
            case R.id.navigationBirthday:
                break;

            case R.id.navigationEmail:
                break;

            case R.id.navigationFullname:
                break;
        }


        return false;
    }

    private void closeDrawer(){
        drawerLayout.closeDrawer(GravityCompat.START);
    }

    private void openDrawer(){
        drawerLayout.openDrawer(GravityCompat.START);
    }

    @Override
    public void onBackPressed() {
        if(drawerLayout.isDrawerOpen(GravityCompat.START)){
            closeDrawer();
        }
        super.onBackPressed();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if(requestCode == PICK_IMAGE){
            currentImageUri = data.getData();
            imagebutton.setImageURI(currentImageUri);
            StorageReference Ref = mStorageRef.child(Username+"_profile.jpg");
            UploadTask uploadTask = Ref.putFile(currentImageUri);
            uploadTask.addOnFailureListener(new OnFailureListener() {
                @Override
                public void onFailure(@NonNull Exception exception) {

                }
            }).addOnSuccessListener(new OnSuccessListener<UploadTask.TaskSnapshot>() {
                @Override
                public void onSuccess(UploadTask.TaskSnapshot taskSnapshot) {
                    //Toast.makeText(NewPost.this, "Upload success!", Toast.LENGTH_LONG).show();
                }
            });
        }
        else if(requestCode == PICK_IMAGE2){
            currentImageUri2 = data.getData();
            postImage.setImageURI(currentImageUri2);
            check=true;
        }
    }
}
