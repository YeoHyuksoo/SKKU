package com.example.map_pa;

import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.ImageButton;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.ActionBarDrawerToggle;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.core.view.GravityCompat;
import androidx.drawerlayout.widget.DrawerLayout;
import androidx.viewpager2.widget.ViewPager2;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.material.navigation.NavigationView;
import com.google.android.material.tabs.TabLayout;
import com.google.android.material.tabs.TabLayoutMediator;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;
import com.google.firebase.storage.FirebaseStorage;
import com.google.firebase.storage.StorageReference;
import com.google.firebase.storage.UploadTask;


public class postPage extends AppCompatActivity implements NavigationView.OnNavigationItemSelectedListener {
    DrawerLayout drawerLayout;

    private DatabaseReference mPostReference;
    //ArrayList<String> data;
    //ArrayAdapter<String> arrayAdapter;
    String Username = "";
    String Fullname = "", Birthday = "", Email = "";
    String Content = "";
    private static final int PICK_IMAGE = 777;
    private StorageReference mStorageRef;
    Uri currentImageUri;
    ImageButton imagebutton;



    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_post_page);

        mPostReference = FirebaseDatabase.getInstance().getReference();

        Intent intent = getIntent();
        Username = intent.getExtras().getString("Username");
        Content = intent.getExtras().getString("content");

        mStorageRef = FirebaseStorage.getInstance().getReference("Images");

        ImageButton newPost = (ImageButton)findViewById(R.id.newPost);
        newPost.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent newPostIntent = new Intent(postPage.this, NewPost.class);
                newPostIntent.putExtra("Username", Username);
                startActivity(newPostIntent);
            }
        });

        //arrayAdapter = new ArrayAdapter<String>(this, android.R.layout.simple_list_item_1);


        /* to use toolbar,
        1. add implementation
                implementation 'com.android.support:appcompat-v7:29.0.3'
           into build.gradle(Module:app)  !!!! version is same with buildToolsversion

        2. add toolbar in your layout
        3. Set toolbar when onCreate (you must import androidx.appcompat.widget.Toolbar
        4. If not Refactor -> Migrate to Androidx
         */
        Toolbar tb = (Toolbar) findViewById(R.id.main_toolbar);
        setSupportActionBar(tb);
        getSupportActionBar().setDisplayShowTitleEnabled(false);

        ViewPager2 viewPager2 = findViewById(R.id.viewpager);
        viewPager2.setAdapter(new myFragmentStateAdapter(this));

        TabLayout tabLayout = (TabLayout) findViewById(R.id.TabLayout);
        TabLayoutMediator tabLayoutMediator = new TabLayoutMediator(tabLayout, viewPager2, new TabLayoutMediator.TabConfigurationStrategy() {
            @Override
            public void onConfigureTab(@NonNull TabLayout.Tab tab, int position) {
                switch (position){
                    case 0:
                        tab.setText("Personal");
                        break;
                    case 1:
                        tab.setText("Public");
                        break;
                }
            }
        });
        tabLayoutMediator.attach();



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
                //data.clear();
                for(DataSnapshot postSnapshot : dataSnapshot.getChildren()){
                    String key = postSnapshot.getKey();
                    if(!key.equals(Username)) continue;
                    FirebasePost get = postSnapshot.getValue(FirebasePost.class);
                    String[] info = {get.username, get.fullname, get.birthday, get.email};
                    Fullname = info[1];
                    Birthday = info[2];
                    Email = info[3];
                    Log.d(Fullname, Birthday);
                    drawerUsername.setText(key);
                    navigationFullname.setTitle(Fullname);
                    navigationBirthday.setTitle(Birthday);
                    navigationEmail.setTitle(Email);
                    //String result = info[0] + info[1] + info[2] + info[3];
                    //data.add(result);

                }
                //arrayAdapter.clear();
                //arrayAdapter.addAll(data);
                //arrayAdapter.notifyDataSetChanged();
            }

            @Override
            public void onCancelled(@NonNull DatabaseError databaseError) {

            }
        };
        mPostReference.child("member").addValueEventListener(postListener);
    }

    public void getFirebaseDatabase(){

    }

    @Override
    public boolean onNavigationItemSelected(@NonNull MenuItem item) {
        drawerLayout.closeDrawer(GravityCompat.START);

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

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if(requestCode == PICK_IMAGE){
            currentImageUri = data.getData();
            imagebutton.setImageURI(data.getData());
            StorageReference Ref = mStorageRef.child(Username+"_profile.jpg");
            UploadTask uploadTask = Ref.putFile(currentImageUri);
            uploadTask.addOnFailureListener(new OnFailureListener() {
                @Override
                public void onFailure(@NonNull Exception exception) {

                }
            }).addOnSuccessListener(new OnSuccessListener<UploadTask.TaskSnapshot>() {
                @Override
                public void onSuccess(UploadTask.TaskSnapshot taskSnapshot) {
                    //Toast.makeText(postPage.this, "Upload success!", Toast.LENGTH_LONG).show();
                }
            });
        }
    }
}
