package com.example.map_pa;

import androidx.annotation.NonNull;
import androidx.appcompat.app.ActionBarDrawerToggle;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.core.view.GravityCompat;
import androidx.drawerlayout.widget.DrawerLayout;
import androidx.viewpager2.widget.ViewPager2;


import android.content.Intent;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.ImageButton;

import com.google.android.material.navigation.NavigationView;
import com.google.android.material.tabs.TabLayout;
import com.google.android.material.tabs.TabLayoutMediator;


public class postPage extends AppCompatActivity implements NavigationView.OnNavigationItemSelectedListener {
    DrawerLayout drawerLayout;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_post_page);


        ImageButton newPost = (ImageButton)findViewById(R.id.newPost);
        newPost.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent newPostIntent = new Intent(postPage.this, NewPost.class);
                startActivity(newPostIntent);
            }
        });


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

}
