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

public class BucketPage extends AppCompatActivity implements ListviewAdapter.ListBtnClickListener{
    private DatabaseReference mPostReference;

    String Username = "";
    String keydata[] = new String [100];

    long total=0;
    long pricelist[] = new long[100];
    TextView totalview;

    ListView listView;
    ListviewAdapter adapter;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_bucket_page);

        listView = findViewById(R.id.listView);
        adapter = new ListviewAdapter(this, R.layout.listview_item, this);
        listView.setAdapter(adapter);

        Intent intent = getIntent();
        Username = intent.getExtras().getString("Username");
        TextView nameText = (TextView) findViewById(R.id.name);
        nameText.setText(Username+"님 반갑습니다.");

        mPostReference = FirebaseDatabase.getInstance().getReference("bucket");

        totalview = (TextView) findViewById(R.id.totalView);
        loadItemsfromDB();



        Button logoutbtn = (Button) findViewById(R.id.logoutbtn2);
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
                Intent intent = new Intent(BucketPage.this, MainActivity.class);
                intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK | Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(intent);
            }
        });

        Button marketbtn = (Button) findViewById(R.id.marketbtn);
        marketbtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(BucketPage.this, MarketPage.class);
                intent.putExtra("Username", Username);
                startActivity(intent);
            }
        });

        Button buybtn = (Button) findViewById(R.id.buybtn);
        buybtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(BucketPage.this, BuyPage.class);
                intent.putExtra("Username", Username);
                intent.putExtra("Total", String.valueOf(total));
                startActivity(intent);
            }
        });
    }

    public void loadItemsfromDB(){
        final ValueEventListener postListener = new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                adapter.clearItem();
                int cnt=0;
                total=0;
                for(DataSnapshot postSnapshot : dataSnapshot.getChildren()){
                    FirebasePost get = postSnapshot.getValue(FirebasePost.class);
                    long Price = get.price;
                    total+=Price;
                    pricelist[cnt]=Price;
                    final String[] info = {get.name, get.intro, Long.toString(Price)};
                    adapter.addItem(info[0], info[1], info[2]);
                    adapter.notifyDataSetChanged();
                    keydata[cnt++] = postSnapshot.getKey();
                }
                adapter.notifyDataSetChanged();
                totalview.setText("Total price : "+total+" won");
            }
            @Override
            public void onCancelled(@NonNull DatabaseError databaseError) {

            }
        };
        mPostReference.child(Username).addValueEventListener(postListener);
    }

    @Override
    public void onListBtnClick(int position) {
        removeDatabase(keydata[position]);
        total-=pricelist[position];
        totalview.setText("Total price : "+total+" won");
        Toast.makeText(this, "item is deleted from your bucket.", Toast.LENGTH_SHORT).show();
    }

    public void removeDatabase(final String pos){
        mPostReference.child(Username).child(pos).setValue(null);
    }
}