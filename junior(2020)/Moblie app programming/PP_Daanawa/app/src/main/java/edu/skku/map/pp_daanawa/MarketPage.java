package edu.skku.map.pp_daanawa;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;
import com.kakao.usermgmt.UserManagement;
import com.kakao.usermgmt.callback.LogoutResponseCallback;

import java.util.HashMap;
import java.util.Map;

public class MarketPage extends AppCompatActivity implements ListviewAdapter.ListBtnClickListener{
    private DatabaseReference mPostReference, mPostReference2;
    //private StorageReference mStorageRef;

    String Username = "";
    String[] data = new String[100];
    int cnt=0;

    ListView listView;
    ListviewAdapter adapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_market_page);

        listView = findViewById(R.id.listView);
        adapter = new ListviewAdapter(this, R.layout.listview_item, this);
        listView.setAdapter(adapter);

        mPostReference = FirebaseDatabase.getInstance().getReference();
        //mStorageRef = FirebaseStorage.getInstance().getReference("Images");

        Intent intent = getIntent();
        Username = intent.getExtras().getString("Username");
        TextView nameText = (TextView) findViewById(R.id.name);
        nameText.setText(Username+"님 반갑습니다.");

        mPostReference2 = FirebaseDatabase.getInstance().getReference("bucket/"+Username);

        loadItemsfromDB();

        /*listView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView parent, View v, int position, long id) {
                // TODO : item click
            }
        });*/
        Button logoutbtn = (Button) findViewById(R.id.logoutbtn);
        logoutbtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                UserManagement.getInstance()
                        .requestLogout(new LogoutResponseCallback() {
                            @Override
                            public void onCompleteLogout() {
                                Log.i("KAKAO_API", "logout success");
                            }
                        });
                Intent intent = new Intent(MarketPage.this, MainActivity.class);
                intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK | Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(intent);
            }
        });

        Button bucketbtn = (Button) findViewById(R.id.bucketbtn);
        bucketbtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(MarketPage.this, BucketPage.class);
                intent.putExtra("Username", Username);
                startActivity(intent);
            }
        });
    }

    public void loadItemsfromDB(){
        final ValueEventListener postListener = new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                adapter.clearItem();
                for(DataSnapshot postSnapshot : dataSnapshot.getChildren()){
                    FirebasePost get = postSnapshot.getValue(FirebasePost.class);
                    long Price = get.price;
                    final String[] info = {get.name, get.intro, Long.toString(Price)};
                    adapter.addItem(info[0], info[1], info[2]);
                    adapter.notifyDataSetChanged();
                    data[cnt++] = info[0];
                    data[cnt++] = info[1];
                    data[cnt++] = info[2];
                }
                adapter.notifyDataSetChanged();
            }
            @Override
            public void onCancelled(@NonNull DatabaseError databaseError) {

            }
        };
        mPostReference.child("market").addValueEventListener(postListener);
    }

    @Override
    public void onListBtnClick(int position) {
        postFirebaseDatabase(position, true);
        Toast.makeText(this, data[position*3]+"selected.", Toast.LENGTH_SHORT).show();
    }

    public void postFirebaseDatabase(int position, boolean add){
        Map<String, Object> childUpdates = new HashMap<>();
        Map<String, Object> postValues = null;
        if(add){
            FirebasePost post = new FirebasePost(data[position*3], data[position*3+1], Long.parseLong(data[position*3+2]));
            postValues = post.toMap();
        }
        childUpdates.put("item"+position, postValues);
        mPostReference2.updateChildren(childUpdates);
    }
}